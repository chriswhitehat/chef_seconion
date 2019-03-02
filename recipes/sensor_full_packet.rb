#
# Cookbook Name:: seconion
# Recipe:: sensor_full_packet
#


node[:seconion][:sensor][:sniffing_interfaces].each do |sniff|

  # List of directories to create
  directories = [ "/nsm/sensor_data/",
                  "/nsm/sensor_data/#{sniff[:sensorname]}",
                  "/nsm/sensor_data/#{sniff[:sensorname]}/dailylogs" ]

  directories.each do |path|
    directory path do
      owner 'sguil'
      group 'sguil'
      mode '0755'
      action :create
    end
  end
end
