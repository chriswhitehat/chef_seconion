#
# Cookbook Name:: seconion
# Recipe:: server
#

include_recipe 'seconion::default'


user node[:seconion][:ssh_username]


###########
# Network Interfaces Config
###########
if node[:seconion][:server][:mgmt][:configure]

  template '/etc/network/interfaces' do
    source 'server/interfaces.erb'
    mode '0644'
    owner 'root'
    group 'root'
  end

end

package ['securityonion-server', 'syslog-ng-core']

#############################
# Deploy Notes
#############################
template '/etc/nsm/chef_notes' do
  source 'chef_notes.erb'
  owner 'sguil'
  group 'sguil'
  mode '0644'
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


#TODO touch log files that warn on first run.
touch_files = ["/var/log/nsm/sguild.log"]

touch_files.each do |path|
  file path do
    mode '0644'
    owner 'sguil'
    group 'sguil'
    action :touch
    not_if do ::File.exists?(path) end
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


service 'nsm' do
  supports :status => true, :restart => true, :start => true, :stop => true
  action :nothing
end

##########################
# Replace existing rule-update
##########################
template '/usr/sbin/rule-update' do
  source '/rule-update/rule-update.erb'
  mode '0755'
  owner 'root'
  group 'root'
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
  notifies :restart, 'service[nsm]', :delayed
end




execute 'restart_sguil' do
  command 'service nsm restart'
  action :nothing
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




# Collect sensor rule urls
rule_urls = ''

# Collect sensor pub keys
sensor_ssh_keys = ''

search_server = "recipes:seconion\\:\\:sensor AND seconion_server_servername:\"#{node[:seconion][:server][:servername]}\""
sensors = search(:node, search_server)

sorted_sensors = sensors.sort_by!{ |n| n[:fqdn] }
#sorted_sensors = sensors

sorted_sensors.each do |sensor|
  if sensor[:seconion][:so_ssh_pub]
    sensor_ssh_keys << sensor[:seconion][:so_ssh_pub]  
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
  notifies :restart, 'service[nsm]', :delayed
end


########################
# Setup SOUP Automation
########################

if node[:seconion][:soup][:enabled]
  if node[:seconion][:server][:soup][:cron_overwrite]
    template '/etc/cron.d/seconion-soup-overwrite' do
      source 'soup/seconion-soup-overwrite.erb'
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        :server => true
      )
      notifies :delete, 'file[seconion_soup_cron]', :immediately
    end
  else
    template '/etc/cron.d/seconion-soup' do
      source 'soup/seconion-soup.erb'
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        :server => true
      )
      notifies :delete, 'file[seconion_soup_overwrite_cron]', :immediately
    end
  end
end

file 'seconion_soup_cron' do
  path '/etc/cron.d/seconion-soup'
  action :nothing
end

file 'seconion_soup_overwrite_cron' do
  path '/etc/cron.d/seconion-soup-overwrite'
  action :nothing
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
  command "service nsm stop; mysql -v -uroot #{node[:seconion][:server][:sguil_server_name]}_db < /tmp/autocat.sql.backup"
  only_if do ::File.exists?("/tmp/autocat.sql.backup") end
  notifies :delete, 'file[seconion_autocat]', :immediately
end

file 'seconion_autocat' do
  path '/tmp/autocat.sql.backup'
  action :nothing
  notifies :restart, 'service[nsm]', :immediately
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
