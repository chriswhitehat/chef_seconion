#
# Cookbook Name:: seconion
# Recipe:: server
#

include_recipe 'seconion::default'


user node[:seconion][:ssh_username]

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# TODO Need to remove test in destination
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
###########
# Network Interfaces Config
###########
template '/etc/network/testinterfaces' do
  source 'server/interfaces.erb'
  mode '0644'
  owner 'root'
  group 'root'
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
  notifies :run, 'ruby_block[get_snort_versions]', :delayed
end

# Collect sensor rule urls
rule_urls = ''

# Collect snort versions
snort_versions = ''

ruby_block "get_snort_versions" do
  block do
    version = `snort --version 2>&1 >/dev/null | egrep -o "Version \\S+" | cut -d ' ' -f 2`
    puts version
    snort_versions << version if not snort_versions.include?(version)
  end
  action :nothing
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

  if sensor[:seconion][:sensor][:snort_version]
    version = sensor[:seconion][:sensor][:snort_version]
    snort_versions << version if not snort_versions.include?(version)
  end

  if sensor[:seconion][:sensor][:rule_urls]
    sensor[:seconion][:sensor][:rule_urls].each do |rule_url|
      rule_urls << rule_url if not rule_urls.include?(rule_url)
    end
  end

  sensor[:seconion][:sensor][:sniffing_interfaces].each do |sniff|

    symlink = "/nsm/server_data/#{node[:seconion][:server][:sguil_server_name]}/rules/#{sniff[:sensorname]}" 
    execute "base_symlink_rules_#{sniff[:sensorname]}" do
      command "ln -f -s /etc/nsm/rules #{symlink}"
      not_if do ::File.exists?("#{symlink}") end
    end

    (1..sniff[:ids_lb_procs]).each do |i| 
      symlink = "/nsm/server_data/#{node[:seconion][:server][:sguil_server_name]}/rules/#{sniff[:sensorname]}-#{i}" 
      puts symlink
      puts (1..sniff[:ids_lb_procs])
      execute "lbproc_symlink_rules_#{sniff[:sensorname]}-#{i}" do
        command "ln -f -s /etc/nsm/rules #{symlink}"
        not_if do ::File.exists?("#{symlink}") end
      end
    end

  end

end

directory "/home/#{node[:seconion][:ssh_username]}" do
  owner node[:seconion][:ssh_username]
  group node[:seconion][:ssh_username]
  mode '0755'
  action :create
end

directory "/home/#{node[:seconion][:ssh_username]}/.ssh/" do
  owner node[:seconion][:ssh_username]
  group node[:seconion][:ssh_username]
  mode '0755'
  action :create
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

template '/etc/nsm/pulledpork/snort_versions.chef' do
  source 'server/snort_versions.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
  variables(
    :snort_versions => snort_versions
  )
end

template '/etc/nsm/pulledpork/pulledpork.conf' do
  source 'server/pulledpork.conf.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
  variables(
    :rule_urls => rule_urls
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
