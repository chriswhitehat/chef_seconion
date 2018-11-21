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

package ['securityonion-server', 'syslog-ng-core', 'mysqltuner', 'wireshark-common']

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

execute 'nsm_start' do
  command 'nsm --all --start'
  action :nothing
end

execute 'nsm_stop' do
  command 'nsm --all --stop'
  action :nothing
end

execute 'nsm_restart' do
  command 'nsm --all --restart'
  action :nothing
end

execute 'nsm_status' do
  command 'nsm --all --status'
  action :nothing
end

# service 'nsm' do
#   supports :status => true, :restart => true, :start => true, :stop => true
#   action :nothing
# end

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


############################
# MySQL tuning
############################

directory '/etc/systemd/system/mysql.service.d' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


template '/etc/systemd/system/mysql.service.d/override.conf' do
  source 'server/mysql/override.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl_reload]', :immediately
end

execute 'systemctl_reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

template '/etc/security/limits.d/99-openfiles.conf' do
  source 'server/99-openfiles.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[restart_mysql]', :delayed
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

execute 'set_root_auth_strategy' do
  command "mysql -u root -D #{node[:seconion][:server][:sguil_server_name]}_db -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';\""
  action :run
  not_if do ::File.exists?("/root/mysql_native_#{ node[:seconion][:server][:sguil_server_name] }") end
end



# Only optimize on the first Monday of the month at noon local to the physical location of the server
chef_runtime = Time.now.utc.localtime(node[:seconion][:physical_timezone_offset])
if chef_runtime.day < 8 and chef_runtime.wday == 1 and chef_runtime.hour == 12

  tuned_total = 0

  # Ruby block converge hack
  ruby_block "set_mysql_tuning_variables" do
    block do
      #tricky way to load this Chef::Mixin::ShellOut utilities
      Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
      recommendations = shell_out('mysqltuner').stdout.strip
      #puts recommendations

      recommendations.lines do |line|
        line_match = line.match(/\s+(?<variable>\w+)\s\(\>\=?\s(?<value>[0-9\.]+)(?<unit>\w)?/)
        if line_match
          if line_match[:unit]
            if line_match[:unit] == 'K'
              tuned_value = line_match[:value].to_i * 100
              tuned_total += tuned_value
            elsif line_match[:unit] == 'M'
              tuned_value = line_match[:value].to_i * 10 
              tuned_total += tuned_value * 1024
            elsif line_match[:unit] == 'G'
              tuned_value = line_match[:value].to_f.floor + 1 
              tuned_total += tuned_value * 1024 * 1024
            end
            #puts "#{line_match[:variable]} = #{tuned_value}#{line_match[:unit]}"
            node.normal[:seconion][:mysql][:tuning][line_match[:variable]] = "#{tuned_value}#{line_match[:unit]}"
            
          else
            tuned_value = line_match[:value].to_i * 2
            #puts "#{line_match[:variable]} = #{tuned_value}"
            #node.normal[:seconion][:mysql][:tuning][line_match[:variable]] = "#{tuned_value}"
          end
        end
      end
      #puts tuned_total
    end
  end


  if (tuned_total / node[:memory][:cached].match(/[0-9]+/)[0].to_i) < 0.8
    template '/etc/mysql/conf.d/securityonion-tuning.cnf' do
      source 'server/mysql/securityonion-tuning.cnf.erb'
      owner 'root'
      group 'root'
      mode '0644'
    end
  end
end

execute 'restart_mysql' do
  command 'pgrep -lf mysqld >/dev/null && service mysql restart'
  action :nothing
  notifies :run, 'execute[nsm_restart]', :delayed
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

# Collect sensornames
current_sensors = []

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

    current_sensors << sniff[:sensorname]

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
  notifies :run, 'execute[nsm_restart]', :delayed
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
  notifies :run, 'execute[nsm_restart]', :immediately
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
