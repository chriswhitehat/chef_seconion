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

template '/opt/bro/share/bro/site/local.bro' do
   source 'bro/site/local.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
   variables({
    :bro_scripts => node[:seconion][:sensor][:bro_script],
    :bro_sigs => node[:seconion][:sensor][:bro_sig]
  })
end


#########################################
# Download rules using Pulledpork
#########################################





#########################################
# Apache configuration
#########################################
#disable apache? Sensors don't use it. 


template '/etc/modprobe.d/pf_ring.conf' do
   source 'sensor/pf_ring.conf.erb'
   owner 'root'
   group 'root'
   mode '0644'
end



############
# Configure Sensors
############
node[:seconion][:sensor][:sniffing_interfaces].each do |sniff|

  barnyard_port = 8000

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


  ############
  # Add options to sensor.conf 
  ############
  template "/etc/nsm/#{sniff[:sensorname]}/sensor.conf" do
    source "sensor/sensor.conf.erb"
    owner 'root'
    group 'root'
    mode '0644'
    variables({
      :sniff => sniff,
    })
  end

  template "/etc/nsm/pulledpork/pulledpork.conf" do
      source "pulledpork/pulledpork.conf.erb"
      owner 'root'
      group 'root'
      mode '0644'
      variables({
        :sniff => sniff,
      })
    end

  pulledpork_confs = ['disablesid', 'dropsid', 'enablesid', 'modifysid']
  pulledpork_confs.each do |conf|

    if node[:seconion][:sensor][:pulledpork][conf] 
      if node[:seconion][:sensor][:pulledpork][conf][:global] 
        global = node[:seconion][:sensor][:pulledpork][conf][:global]
      else
        global = {}
      end
      if node[:seconion][:sensor][:pulledpork][conf][:regional] 
        regional = node[:seconion][:sensor][:pulledpork][conf][:regional]
      else
        regional = {}
      end
      if node[:seconion][:sensor][:pulledpork][conf][node[:fqdn]] 
        host = node[:seconion][:sensor][:pulledpork][conf][node[:fqdn]]
      else
        host = {}
      end
      if node[:seconion][:sensor][:pulledpork][conf][sniff[:sensorname]] 
        sensor = node[:seconion][:sensor][:pulledpork][conf][sniff[:sensorname]]
      else
        sensor = {}
      end
    end

    template "/etc/nsm/pulledpork/#{sniff[:sensorname]}/#{conf}.conf" do
      source "pulledpork/#{conf}.conf.erb"
      owner 'root'
      group 'root'
      mode '0644'
      variables({
        :sniff => sniff,
        :global_sigs => global,
        :regional_sigs => regional,
        :host_sigs => host,
        :sensor_sigs => sensor
      })
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


  execute 'nsm_sensor_add' do
    command "/usr/sbin/nsm_sensor_add --sensor-name=\"#{sniff[:sensorname]}\" --sensor-interface=\"#{sniff[:interface]}\" --sensor-interface-auto=no "\
                                          "--sensor-server-host=\"#{node[:seconion][:server][:servername]}\" --sensor-server-port=7736 "\
                                          "--sensor-barnyard2-port=#{barnyard_port} --sensor-auto=yes --sensor-utc=yes "\
                                          "--sensor-vlan-tagging=no --sensor-net-group=\"#{sniff[:sensorname]}\" --force-yes"
    not_if do ::File.exists?("/nsm/sensor_data/#{sniff[:sensorname]}") end
  end
  
  barnyard_port = barnyard_port + 100

end