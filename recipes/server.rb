#
# Cookbook Name:: seconion
# Recipe:: server
#

apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
end

user 'sguil' do
  system true
end

package ['securityonion-server', 'syslog-ng-core']


directories = [ '/nsm',
                '/nsm/server_data/',
                '/nsm/server_data/securityonion/',
                '/nsm/server_data/securityonion/archive/',
                '/nsm/server_data/securityonion/load/',
                '/nsm/server_data/securityonion/rules/',]

directories.each do |path|
  directory path do
    owner 'sguil'
    group 'sguil'
    mode '0755'
    action :create
  end
end

template '/etc/nsm/securityonion.conf' do
  source 'default/securityonion.conf.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
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

  sensor[:seconion][:sensor][:sniffing_interfaces].each do |sniff|

    symlink = "/nsm/server_data/#{ node[:seconion][:server][:sguil_server_name] }/rules/#{ sniff[:sensorname] }" 
    execute symlink_rules do
      command "ln -f -s /etc/nsm/rules #{symlink}"
      not_if do ::File.exists?("#{symlink}") end
    end

    range(sniff[:ids_lb_procs]).each do |i| 
      symlink = "/nsm/server_data/#{ node[:seconion][:server][:sguil_server_name] }/rules/#{ sniff[:sensorname] }-#{i}" 
      execute symlink_rules do
        command "ln -f -s /etc/nsm/rules #{symlink}"
        not_if do ::File.exists?("#{symlink}") end
      end
    end

  end

end

directory '/root/.ssh' do
  owner 'sguil'
  group 'sguil'
  mode '0700'
  action :create
end

template '/root/.ssh/authorized_keys' do
  source 'server/authorized_keys.erb'
  mode '0640'
  owner 'sguil'
  group 'sguil'
  variables(
    :ssh_pub_keys => sensor_ssh_keys
  )
end

#TODO look at notifies verb to see if you can queue up the restart
file '/etc/mysql/conf.d/securityonion-sguild.cnf' do
  source 'server/mysql/securityonion-sguild.cnf.erb'
  mode '0640'
  owner 'sguil'
  group 'sguil'
  notifies :run, 'execute[restart_mysql]', :immediately
end

file '/etc/mysql/conf.d/securityonion-ibdata1.cnf' do
  source 'server/mysql/securityonion-ibdata1.cnf.erb'
  mode '0640'
  owner 'sguil'
  group 'sguil'
  notifies :run, 'execute[restart_mysql]', :immediately
end

execute 'restart_mysql' do
  command 'pgrep -lf mysqld >/dev/null && restart mysql'
  action :nothing
end

# Final action 
# Needs idempotency
execute 'nsm_server_add' do
  command "/usr/sbin/nsm_server_add --server-name=\"#{node[:seconion][:server][:sguil_server_name]}\" --server-sensor-name=NULL --server-sensor-port=7736 --server-client-port=7734 --server-client-user=\"#{node[:seconion][:server][:sguil_client_username]}\" --server-client-pass=\"#{node[:seconion][:server][:sguil_client_password]}\" --server-auto=yes --force-yes"
  action :nothing
end
