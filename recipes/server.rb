#
# Cookbook Name:: seconion
# Recipe:: server
#

include_recipe 'seconion::default'


package ['securityonion-server', 'syslog-ng-core', 'mysqltuner', 'wireshark-common']


include_recipe 'seconion::nsmnow'

include_recipe 'seconion::server_nsmnow'

include_recipe 'seconion::server_cleanup'




touch_files = ["/var/log/nsm/sguild.log",
               "/etc/nsm/active_sensors"]

touch_files.each do |path|
  file path do
    mode '0644'
    owner 'sguil'
    group 'sguil'
    action :touch
    not_if do ::File.exists?(path) end
  end
end




##########################
# Web Services
##########################
if !node[:seconion][:server][:apache][:enabled]
  service 'apache2' do
    action :disable
  end
end 
  

template '/etc/nsm/securityonion.conf' do
  source 'default/securityonion.conf.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
end


file "/etc/nsm/sensortab" do
  mode '0644'
  owner 'sguil'
  group 'sguil'
  action :create
end


execute 'nsm_server_add' do
  command "/usr/sbin/nsm_server_add --server-name=\"#{node[:seconion][:server][:sguil_server_name]}\" --server-sensor-name=NULL --server-sensor-port=7736 --server-client-port=7734 --server-client-user=\"#{node[:seconion][:server][:sguil_client_username]}\" --server-client-pass=\"#{node[:seconion][:server][:sguil_client_password]}\" --server-auto=yes --force-yes"
  not_if do ::File.exists?("/nsm/server_data/#{ node[:seconion][:server][:sguil_server_name] }") end
end


template '/etc/nsm/securityonion/sguild.conf' do
  source 'server/sguild.conf.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
end


search_server = "recipes:seconion\\:\\:sensor AND seconion_server_servername:\"#{node[:seconion][:server][:servername]}\""
sensors = search(:node, search_server)

node.normal[:seconion][:server][:sorted_sensors] = sensors.sort_by!{ |n| n[:fqdn] }





#############################
# Backup Autocat
#############################
template '/etc/cron.d/autocat-backup' do
  source 'autocat/autocat-backup.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


#############################
# Load Autocat
#############################

execute "autocat_import" do
  command "nsm --all --stop; mysql -v -uroot #{node[:seconion][:server][:sguil_server_name]}_db < /tmp/autocat.sql.backup"
  only_if do ::File.exists?("/tmp/autocat.sql.backup") end
  notifies :delete, 'file[seconion_autocat]', :immediately
end

file 'seconion_autocat' do
  path '/tmp/autocat.sql.backup'
  action :nothing
  notifies :run, 'execute[so-restart]', :immediately
end


#############################
# On reboot run rule-update
# to stage /tmp with tarballs
#############################

template '/etc/cron.d/onboot-rule-update' do
  source 'server/cron_onboot-rule-update.erb'
  owner 'root'
  group 'root'
  mode '0644'
end
