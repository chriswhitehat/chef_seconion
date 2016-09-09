#
# Cookbook Name:: seconion
# Recipe:: server
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
end

#directory '/etc/nsm/'

package ['securityonion-server', 'syslog-ng-core']

template '/etc/nsm/securityonion.conf' do
  source 'default/securityonion.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
end


# Collect sensor pub keys
sensor_ssh_keys = ''
sensors = search(:node, 'recipes:seconion\:\:sensor')

sensors.each do |sensor|
  if sensor[:seconion][:so_ssh_pub]
    sensor_ssh_keys << sensor[:seconion][:so_ssh_pub]  
  end
end


template '/root/.ssh/authorized_keys' do
  source 'server/authorized_keys.erb'
  mode '0640'
  owner 'root'
  group 'root'
  variables(
    :ssh_pub_keys => sensor_ssh_keys
  )
end

