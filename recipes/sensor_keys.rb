#
# Cookbook Name:: seconion
# Recipe:: ./sensor_keys
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

execute 'ssh-keygen -f "/root/.ssh/securityonion" -N \'\'' do
  not_if do ::File.exists?('/root/.ssh/securityonion') end
end

if File.exists?('/root/.ssh/securityonion.pub')
  node.default[:seconion][:so_ssh_pub] = File.open('/root/.ssh/securityonion.pub', "r").read 
else
  node.default[:seconion][:so_ssh_pub] = '' 
end
  