#
# Cookbook Name:: seconion
# Recipe:: sensor
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
end

package ['securityonion-sensor', 'syslog-ng-core']


directories = ['/nsm/sensor_data',
               '/opt/bro/share/bro/ghc_extraction',
               '/opt/bro/share/bro/etpro',
               '/opt/bro/share/bro/smtp-embedded-url-bloom',
                '/opt/bro/share/bro/networks']

directories.each do |path|
  directory path do
	  owner 'root'
	  group 'root'
	  mode '0755'
	  action :create
	end
end


###########
# SSH Sensor Config
###########

execute 'ssh-keygen -f "/root/.ssh/securityonion" -N \'\'' do
  not_if do ::File.exists?('/root/.ssh/securityonion') end
end

if File.exists?('/root/.ssh/securityonion.pub')
  node.default[:seconion][:so_ssh_pub] = File.open('/root/.ssh/securityonion.pub', "r").read 
else
  node.default[:seconion][:so_ssh_pub] = '' 
end

template '/root/.ssh/securityonion_ssh.conf' do
  source 'sensor/securityonion_ssh.conf.erb'
  mode '0600'
  owner 'root'
  group 'root'
end


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Need to remove test in destination
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
###########
# Network Interfaces Config
###########
template '/etc/network/testinterfaces' do
  source 'sensor/interfaces.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables( 
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
end


###########
#
###########

template '/etc/nsm/securityonion.conf' do
  source 'default/securityonion.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
end


############
# Configure Sensors
############
node[:seconion][:sensor][:sniffing_interfaces].each do |sniff|
  directories = ["/etc/nsm/#{sniff[:sensorname]}",
                  "/etc/nsm/pulledpork/#{sniff[:sensorname]}",
                  "/opt/bro/share/bro/networks"]

  directories.each do |path|
    directory path do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end
  end
  
  pulledpork_confs = ['disablesid', 'dropsid', 'enablesid', 'modifysid', 'pulledpork']
  pulledpork_confs.each do |conf|
    template "/etc/nsm/pulledpork/#{sniff[:sensorname]}/#{conf}.conf" do
      source "pulledpork/#{conf}.conf.erb"
      owner 'root'
      group 'root'
      mode '0644'
      variables( 
        :sniff => sniff
      )
    end
  end  

  template "/etc/nsm/#{sniff[:sensorname]}/snort.conf" do
    source 'snort/snort.conf.erb'
    mode '0644'
    owner 'root'
    group 'root'
    variables(
      :sniff => sniff
    )
  end


  template "/opt/bro/share/bro/networks/#{sniff[:sensorname]}_networks.bro" do
    source 'bro/networks/sniff_networks.bro.erb'
    mode '0644'
    owner 'root'
    group 'root'
    variables(
      :sniff => sniff
    )
  end
end

############
# Add options to sensor.conf 
############
# template templates/sensor/sensor.conf

# template '/etc/nsm/sensortab' do
#   source 'source.erb'
#   owner 'root'
#   group 'root'
#   mode '0644'
# end

############
# Configure Bro 
############
template '/opt/bro/etc/node.cfg' do
  source 'bro/node.cfg.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables( 
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
end

template '/opt/bro/etc/network.cfg' do
  source 'bro/network.cfg.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables( 
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
end

template '/opt/bro/share/bro/networks/__load__.bro' do
  source 'bro/networks/__load__.bro.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables( 
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
end

############
# Configure Bro Continued
# Create GHC Specific rule files for File Extraction
############

# Create files for ET Intelligence in Bro
# template '/opt/bro/share/bro/etpro/__load__.bro' do
#    source 'bro/etpro/__load__.bro.erb'
#    owner 'root'
#    group 'root'
#    mode '0644'
# end

# template '/opt/bro/share/bro/etpro/etpro_intel.bro' do
#    source 'bro/etpro/etpro_intel.bro.erb'
#    owner 'root'
#    group 'root'
#    mode '0644'
# end

# Installing ET intelligence in Bro
# cron 'etpro_intel' do
#   hour '1'
#   command 'wget -q https://rules.emergingthreats.net/#{oinkcode}/reputation/brorepdata.tar.gz && tar -xzf bro-repdata.tar.gz -C /opt/bro/share/bro/etpro && rm -rf bro-repdata.tar.gz > /dev/null 2>&1'
# end

# Create files for SMTP embedded Url Bloom
template '/opt/bro/share/bro/smtp-embedded-url-bloom/__load__.bro' do
   source 'bro/smtp-embedded-url-bloom/__load__.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

template '/opt/bro/share/bro/smtp-embedded-url-bloom/smtp-embedded-url-bloom-ghc.bro' do
   source 'bro/smtp-embedded-url-bloom/smtp-embedded-url-bloom-ghc.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

template '/opt/bro/share/bro/smtp-embedded-url-bloom/smtp-embedded-url-cluster.bro' do
   source 'bro/smtp-embedded-url-bloom/smtp-embedded-url-cluster.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

# Create files for GHC File Extraction
template '/opt/bro/share/bro/ghc_extraction/__load__.bro' do
   source 'bro/extraction/ghc/__load__.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

template '/opt/bro/share/bro/ghc_extraction/extract.bro' do
   source 'bro/extraction/ghc/extract.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

# Insert Command in File to load GHC, SMTP, and ETPRO file extraction specific to GHC
ruby_block 'insert_line' do
  block do
    file = Chef::Util::FileEdit.new("/opt/bro/share/bro/site/local.bro")
    file.insert_line_if_no_match(/^@load smtp-embedded-url-bloom$/, "@load smtp-embedded-url-bloom")
    file.insert_line_if_no_match(/^@load ghc_extraction$/, "@load ghc_extraction")
    file.insert_line_if_no_match(/^@load etpro$/, "@load etpro")
    file.write_file
  end
end

#########################################
# Download rules using Pulledpork
#########################################





#########################################
# Apache configuration
#########################################
#disable apache? Sensors don't use it. 
