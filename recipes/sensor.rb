#
# Cookbook Name:: seconion
# Recipe:: sensor
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


def sniffing_interface do
  sniff = {
    # interface to drop into promiscuious mode
    'interface' => default[:seconion][:sensor][:sniff][:interface],
    # mtu for promiscuious nic
    'mtu' => default[:seconion][:sensor][:sniff][:mtu],
    # name of sensor in sguil and directory structure
    'sensorname' => default[:seconion][:sensor][:sniff][:sensorname],
    # enable the ids engine 
    'ids_engine_enabled' => default[:seconion][:sensor][:sniff][:ids_engine_enabled],
    # type of ids engine (snort/suriciata)
    'ids_engine' => default[:seconion][:sensor][:sniff][:ids_engine],
    # load balance instances for ids engine
    'ids_lb_procs' => default[:seconion][:sensor][:sniff][:ids_lb_procs],
    # enable squil agent to send ids alerts to server (applies to snort and suricata)
    'snort_agent_enabled' => default[:seconion][:sensor][:sniff][:snort_agent_enabled],
    # barnyard2 sends snort/suricata alerts to the snort agent and other destinations
    'barnyard2_enabled' => default[:seconion][:sensor][:sniff][:barnyard2_enabled],
    # enable the Bro IDS
    'bro_enabled' => default[:seconion][:sensor][:sniff][:bro_enabled],
    # load balance instances for Bro IDS
    'bro_lb_procs' => default[:seconion][:sensor][:sniff][:bro_lb_procs],
    # extract files using bro based on mimetypes
    'bro_extract_files' => default[:seconion][:sensor][:sniff][:bro_extract_files],
    # enable netsniff-ng full packet capture
    'pcap_enabled' => default[:seconion][:sensor][:sniff][:pcap_enabled],
    # enable sguil agent to pull pcaps from the sguil client
    'pcap_agent_enabled' => default[:seconion][:sensor][:sniff][:pcap_agent_enabled],
    # how large to make the pcap files in MB
    'pcap_size' => default[:seconion][:sensor][:sniff][:pcap_size],
    # how big of a ring buffer for netsniff-ng
    'pcap_ring_size' => default[:seconion][:sensor][:sniff][:pcap_ring_size],
    # additional pcap options to be sent to the netsniff-ng command
    'pcap_options' => default[:seconion][:sensor][:sniff][:pcap_options]}
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


############
# Configure Sensors
############
node[:seconion][:sensor][:sniffing_interfaces].each do |sensor|
  directories = ["/etc/nsm/pulledpork/#{sensor[:sensorname]}"]
  directory sensor do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end


############
# Configure Bro 
############
template ''