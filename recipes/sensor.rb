#
# Cookbook Name:: seconion
# Recipe:: sensor
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
end

package ['securityonion-sensor', 'syslog-ng-core']

template '/etc/nsm/securityonion.conf' do
  source 'default/securityonion.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
end


