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
  notifies :run, 'execute[so-restart]', :delayed
end

