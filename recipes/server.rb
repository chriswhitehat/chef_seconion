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
    execute 'symlink_rules' do
      command "ln -f -s /etc/nsm/rules #{symlink}"
      not_if do ::File.exists?("#{symlink}") end
    end

    (1..sniff[:ids_lb_procs]).each do |i| 
      symlink = "/nsm/server_data/#{ node[:seconion][:server][:sguil_server_name] }/rules/#{ sniff[:sensorname] }-#{i}" 
      execute 'symlink_rules' do
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

template '/etc/mysql/conf.d/securityonion-sguild.cnf' do
  source 'server/mysql/securityonion-sguild.cnf.erb'
  mode '0640'
  owner 'sguil'
  group 'sguil'
  notifies :run, 'execute[restart_mysql]', :delayed
end

template '/etc/mysql/conf.d/securityonion-ibdata1.cnf' do
  source 'server/mysql/securityonion-ibdata1.cnf.erb'
  mode '0640'
  owner 'sguil'
  group 'sguil'
  notifies :run, 'execute[restart_mysql]', :delayed
end

execute 'restart_mysql' do
  command 'pgrep -lf mysqld >/dev/null && restart mysql'
  action :nothing
  notifies :run, 'execute[restart_sguil]', :delayed
end

execute 'restart_sguil' do
  command 'service nsm restart'
  action :nothing
end


execute 'nsm_server_add' do
  command "/usr/sbin/nsm_server_add --server-name=\"#{node[:seconion][:server][:sguil_server_name]}\" --server-sensor-name=NULL --server-sensor-port=7736 --server-client-port=7734 --server-client-user=\"#{node[:seconion][:server][:sguil_client_username]}\" --server-client-pass=\"#{node[:seconion][:server][:sguil_client_password]}\" --server-auto=yes --force-yes"
  not_if do ::File.exists?("/nsm/server_data/#{ node[:seconion][:server][:sguil_server_name] }") end
end
