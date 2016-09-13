#
# Cookbook Name:: seconion
# Recipe:: sensor
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
end

package ['securityonion-sensor', 'syslog-ng-core']


directories = ['/nsm/sensor_data']

directories.each do |path|
  directory dir do
	  owner 'root'
	  group 'root'
	  mode '0700'
	  action :create
	end
end

############
# SSH Keys
############
directory  do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end

execute 'ssh-keygen -f "/root/.ssh/securityonion" -N \'\'' do
  not_if do ::File.exists?('/root/.ssh/securityonion') end
end

if File.exists?('/root/.ssh/securityonion.pub')
  node.default[:seconion][:so_ssh_pub] = File.open('/root/.ssh/securityonion.pub', "r").read 
else
  node.default[:seconion][:so_ssh_pub] = '' 
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


