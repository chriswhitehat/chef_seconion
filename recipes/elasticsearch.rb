#
# Cookbook Name:: seconion
# Recipe:: elasticsearch
#

directory '/var/log/elasticsearch' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch/elasticsearch.yml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, "execute[so-elasticsearch-restart]", :delayed
end

template '/etc/elasticsearch/jvm.options' do
  source 'elasticsearch/jvm.options.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, "execute[so-elasticsearch-restart]", :delayed
end

template '/etc/elasticsearch/log4j2.properties' do
  source 'elasticsearch/log4j2.properties.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, "execute[so-elasticsearch-restart]", :delayed
end
