#
# Cookbook Name:: seconion
# Recipe:: sensor
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


def sniffing_interface
  sniff = {
    # interface to drop into promiscuious mode
    'interface' => node[:seconion][:sensor][:sniff][:interface],
    # mtu for promiscuious nic
    'mtu' => node[:seconion][:sensor][:sniff][:mtu],
    # name of sensor in sguil and directory structure
    'sensorname' => node[:seconion][:sensor][:sniff][:sensorname],
    # enable the ids engine 
    'ids_engine_enabled' => node[:seconion][:sensor][:sniff][:ids_engine_enabled],
    # type of ids engine (snort/suriciata)
    'ids_engine' => node[:seconion][:sensor][:sniff][:ids_engine],
    # load balance instances for ids engine
    'ids_lb_procs' => node[:seconion][:sensor][:sniff][:ids_lb_procs],
    # enable squil agent to send ids alerts to server (applies to snort and suricata)
    'snort_agent_enabled' => node[:seconion][:sensor][:sniff][:snort_agent_enabled],
    # barnyard2 sends snort/suricata alerts to the snort agent and other destinations
    'barnyard2_enabled' => node[:seconion][:sensor][:sniff][:barnyard2_enabled],
    # enable the Bro IDS
    'bro_enabled' => node[:seconion][:sensor][:sniff][:bro_enabled],
    # load balance instances for Bro IDS
    'bro_lb_procs' => node[:seconion][:sensor][:sniff][:bro_lb_procs],
    # extract files using bro based on mimetypes
    'bro_extract_files' => node[:seconion][:sensor][:sniff][:bro_extract_files],
    # enable netsniff-ng full packet capture
    'pcap_enabled' => node[:seconion][:sensor][:sniff][:pcap_enabled],
    # enable sguil agent to pull pcaps from the sguil client
    'pcap_agent_enabled' => node[:seconion][:sensor][:sniff][:pcap_agent_enabled],
    # how large to make the pcap files in MB
    'pcap_size' => node[:seconion][:sensor][:sniff][:pcap_size],
    # how big of a ring buffer for netsniff-ng
    'pcap_ring_size' => node[:seconion][:sensor][:sniff][:pcap_ring_size],
    # additional pcap options to be sent to the netsniff-ng command
    'pcap_options' => node[:seconion][:sensor][:sniff][:pcap_options]}
  return sniff
end

apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
end

package ['securityonion-sensor', 'syslog-ng-core']


directories = ['/nsm/sensor_data']

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



###########
#
###########

template '/etc/nsm/securityonion.conf' do
  source 'default/securityonion.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
end

testsensor1 = sniffing_interface()
testsensor2 = sniffing_interface()
testsensor1[:sensorname] = 'testsensor1'
testsensor1[:interface] = 'eth0'

testsensor2[:sensorname] = 'testsensor2'
testsensor2[:interface] = 'eth1'

node.default[:seconion][:sensor][:sniffing_interfaces] << testsensor1
node.default[:seconion][:sensor][:sniffing_interfaces] << testsensor2

############
# Configure Sensors
############
node[:seconion][:sensor][:sniffing_interfaces].each do |sensor|
  directories = ["/etc/nsm/pulledpork/#{sensor[:sensorname]}"]

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
    template "/etc/nsm/pulledpork/#{sensor[:sensorname]}/#{conf}.conf" do
      source "pulledpork/#{conf}.conf.erb"
      owner 'root'
      group 'root'
      mode '0644'
    end
  end  

end


############
# Configure Bro 
############
template '/opt/bro/etc/node.cfg' do
  source 'bro/node.cfg.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables (
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
end


############
# Create GHC Specific rule files for File Extraction
############
folders = ['/opt/bro/share/bro/ghc_extraction',
           '/opt/bro/share/bro/etpro',
           '/opt/bro/share/bro/smtp-embedded-url-bloom']

folders.each do |path|
  directory path do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

# Create files for ET Intelligence in Bro
template '/opt/bro/share/bro/etpro/__load__.bro' do
   source 'bro/extraction/etpro/__load__.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

template '/opt/bro/share/bro/etpro/etpro_intel.bro' do
   source 'bro/extraction/etpro/etpro_intel.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

# Gets dependency files for ET Pro
cron 'test' do
  hour '1'
  command 'wget -q https://rules.emergingthreats.net/#####<authorization code>#####/reputation/brorepdata.tar.gz && tar -xzf bro-repdata.tar.gz -C /opt/bro/share/bro/etpro && rm -rf bro-repdata.tar.gz > /dev/null 2>&1'
end

# Create files for SMTP embedded Url Bloom
template '/opt/bro/share/bro/smtp-embedded-url-bloom/__load__.bro' do
   source 'bro/extraction/smtp-embedded-url-bloom/__load__.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

template '/opt/bro/share/bro/smtp-embedded-url-bloom/smtp-embedded-url-bloom-ghc.bro' do
   source 'bro/extraction/etpro/smtp-embedded-url-bloom-ghc.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

template '/opt/bro/share/bro/smtp-embedded-url-bloom/smtp-embedded-url-cluster.bro' do
   source 'bro/extraction/etpro/smtp-embedded-url-cluster.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

# Create files for GHC File Extraction
template '/opt/bro/share/bro/ghc_extraction/__load__.bro' do
   source 'bro/extraction/etpro/ghc_extraction/__load__.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

template '/opt/bro/share/bro/ghc_extraction/extract.bro' do
   source 'bro/extraction/etpro/ghc_extraction/extract.bro.erb'
   owner 'root'
   group 'root'
   mode '0644'
end

# Insert lines to load GHC, SMTP, and ETPRO file extraction 
ruby_block 'insert_line' do
  block do
    file = Chef::Util::FileEdit.new("/opt/bro/share/bro/site/local.bro")
    file.insert_line_if_no_match(/^@load smtp-embedded-url-bloom$/, "@load smtp-embedded-url-bloom")
    file.insert_line_if_no_match(/^@load ghc_extraction$/, "@load ghc_extraction")
    file.insert_line_if_no_match(/^@load etpro$/, "@load etpro")
    file.write_file
  end
end


# Installing ET intelligence in Bro
cron 'test' do
  hour '1'
  command 'wget -q https://rules.emergingthreats.net/<oinkcode>/reputation/brorepdata.tar.gz && tar -xzf bro-repdata.tar.gz -C /opt/bro/share/bro/etpro && rm -rf bro-repdata.tar.gz > /dev/null 2>&1'
end
