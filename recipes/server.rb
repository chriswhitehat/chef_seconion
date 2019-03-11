#
# Cookbook Name:: seconion
# Recipe:: server
#

include_recipe 'seconion::default'


package ['securityonion-server', 'syslog-ng-core', 'mysqltuner', 'wireshark-common']


include_recipe 'seconion::nsmnow'


user node[:seconion][:ssh_username]

directories = ["/home/#{node[:seconion][:ssh_username]}",
               "/home/#{node[:seconion][:ssh_username]}/.ssh/" ]

directories.each do |path| 
  directory do
    owner node[:seconion][:ssh_username]
    group node[:seconion][:ssh_username]
    mode '0755'
    action :create
  end
end


directories = ['/etc/nsm/backup']

directories.each do |path|
  directory path do
    owner 'sguil'
    group 'sguil'
    mode '0755'
    action :create
  end
end


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
  

##########################
# Replace existing rule-update
##########################

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








if File.exists?('/etc/nsm/active_sensors')
  ########################
  # Deactivate sensors that have been removed
  ########################

  active_sensors = File.read('/etc/nsm/active_sensors').split("\n")

  ###############################
  # Sensors to mark active
  ###############################
  puts "current - active"
  puts current_sensors - active_sensors

  reactivate_sensors = current_sensors - active_sensors

  ruby_block "reactivate" do
    block do
      reactivate_sensors.each do |sensor|
        r = Chef::Resource::Execute.new("reactivate_#{sensor}", run_context)
        r.command "mysql -u root -A -D #{node[:seconion][:server][:sguil_server_name]}_db -e 'UPDATE sensor SET active = \"Y\" WHERE net_name = \"#{sensor}\";'"
        r.run_action :run
        r.notifies :run, 'execute[set_active_sensors]', :delayed
      end
    end
  end



  ###############################
  # Sensors to mark inactive
  ###############################
  puts "active - current"
  puts active_sensors - current_sensors

  deactivate_sensors = active_sensors - current_sensors

  ruby_block "deactivate" do
    block do
      deactivate_sensors.each do |sensor|
        r = Chef::Resource::Execute.new("deactivate_#{sensor}", run_context)
        r.command "mysql -u root -A -D #{node[:seconion][:server][:sguil_server_name]}_db -e 'UPDATE sensor SET active = \"N\" WHERE net_name = \"#{sensor}\";'"
        r.run_action :run
        r.notifies :run, 'execute[set_active_sensors]', :delayed
      end
    end
  end


  execute 'set_active_sensors' do
    command "/usr/bin/mysql -u root -A  -D #{node[:seconion][:server][:sguil_server_name]}_db -e 'SELECT net_name FROM sensor WHERE active=\"Y\";' | egrep -v net_name | sort | uniq > /etc/nsm/active_sensors"
    action :nothing
  end
end


template '/etc/nsm/pulledpork/pulledpork.conf' do
  source 'server/pulledpork.conf.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
  variables(
    :rule_urls => rule_urls
  )
  notifies :run, 'execute[run_rule-update]', :delayed
end

template "/home/#{node[:seconion][:ssh_username]}/.ssh/authorized_keys" do
  source 'server/authorized_keys.erb'
  mode '0640'
  owner node[:seconion][:ssh_username]
  group node[:seconion][:ssh_username]
  variables(
    :ssh_pub_keys => sensor_ssh_keys
  )
end

execute 'run_rule-update' do
  command "rule-update"
  action :nothing
  notifies :run, 'execute[so-restart]', :delayed
end




#############################
# Active Sensors Cron
#############################

template '/etc/cron.d/active-sensors' do
  source 'server/mysql/cron_active-sensors.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


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
