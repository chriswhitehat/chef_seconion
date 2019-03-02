#
# Cookbook Name:: seconion
# Recipe:: logstash
#

directory '/var/log/logstash' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


template '/etc/logstash/logstash.yml' do
  source 'logstash/logstash.yml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, "execute[so-logstash-restart]", :delayed
end

