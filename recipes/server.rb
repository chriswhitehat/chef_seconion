#
# Cookbook Name:: seconion
# Recipe:: server
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
end

directories = [ '/nsm',
                '/nsm/server_data/',
                '/nsm/server_data/securityonion/',
                '/nsm/server_data/securityonion/archive/',
                '/nsm/server_data/securityonion/load/',
                '/nsm/server_data/securityonion/rules/',]

directories.each do |path|
  directory path do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

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

sorted_sensors = sensors.sort_by!{ |n| n[:fqdn] }
#sorted_sensors = sensors

sorted_sensors.each do |sensor|
  if sensor[:seconion][:so_ssh_pub]
    sensor_ssh_keys << sensor[:seconion][:so_ssh_pub]  
  end
end

directory '/root/.ssh' do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
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

file '/etc/mysql/conf.d/securityonion-sguild.cnf' do
  source 'server/mysql/securityonion-sguild.cnf'
  mode '0640'
  owner 'root'
  group 'root'
end


