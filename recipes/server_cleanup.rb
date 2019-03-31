#
# Cookbook Name:: seconion
# Recipe:: server_cleanup
#


# Collect sensornames
current_sensors = []

if node[:seconion][:server][:sorted_sensors]
  node[:seconion][:server][:sorted_sensors].each do |sensor|

    sensor[:seconion][:sensor][:sniffing_interfaces].each do |sniff|

      current_sensors << sniff[:sensorname]
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


#############################
# Active Sensors Cron
#############################

template '/etc/cron.d/active-sensors' do
  source 'server/mysql/cron_active-sensors.erb'
  owner 'root'
  group 'root'
  mode '0644'
end
