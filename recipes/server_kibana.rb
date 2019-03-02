#
# Cookbook Name:: seconion
# Recipe:: server_kibana
#

directory '/var/log/kibana' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


template '/etc/kibana/kibana.yml' do
  source 'server/kibana/kibana.yml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, "execute[so-kibana-restart]", :delayed
end

