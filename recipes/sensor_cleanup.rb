#
# Cookbook Name:: seconion
# Recipe:: sensor_cleanup
#

#############################
# Cleanup Sensors that are no longer valid
#############################


ruby_block "rm_old_sensors" do
  block do
    current_sensors = []

    node[:seconion][:sensor][:sniffing_interfaces].each do |sensor|
      current_sensors << sensor[:sensorname]
    end

    existing_sensors = Dir.entries('/nsm/sensor_data/').select {|entry| File.directory? File.join('/nsm/sensor_data/',entry) and !(entry =='.' || entry == '..') }

    (existing_sensors - current_sensors).each do |sensor|
      
      sensor_data_dir = Chef::Resource::Directory.new("rm_sensor_data_#{sensor}", run_context)
      sensor_data_dir.path       "/nsm/sensor_data/#{sensor}"
      sensor_data_dir.recursive  true
      sensor_data_dir.run_action :delete

      sensor_config_dir = Chef::Resource::Directory.new("rm_config_#{sensor}", run_context)
      sensor_config_dir.path       "/etc/nsm/#{sensor}"
      sensor_config_dir.recursive  true
      sensor_config_dir.run_action :delete

      sensor_rules_dir = Chef::Resource::Directory.new("rm_rules_#{sensor}", run_context)
      sensor_rules_dir.path       "/etc/nsm/rules/#{sensor}"
      sensor_rules_dir.recursive  true
      sensor_rules_dir.run_action :delete

      sensor_pulledpork_dir = Chef::Resource::Directory.new("rm_pulledpork_#{sensor}", run_context)
      sensor_pulledpork_dir.path       "/etc/nsm/pulledpork/#{sensor}"
      sensor_pulledpork_dir.recursive  true
      sensor_pulledpork_dir.run_action :delete

      sensor_log_dir = Chef::Resource::Directory.new("rm_log_#{sensor}", run_context)
      sensor_log_dir.path       "/var/log/nsm/#{sensor}"
      sensor_log_dir.recursive  true
      sensor_log_dir.run_action :delete

    end

  end
end
