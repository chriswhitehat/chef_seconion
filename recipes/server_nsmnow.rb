#
# Cookbook Name:: seconion
# Recipe:: server_nsmnow
#


user node[:seconion][:ssh_username]

directories = ["/home/#{node[:seconion][:ssh_username]}",
               "/home/#{node[:seconion][:ssh_username]}/.ssh/" ]

directories.each do |path| 
  directory path do
    owner node[:seconion][:ssh_username]
    group node[:seconion][:ssh_username]
    mode '0755'
    action :create
  end
end


# Collect sensor pub keys
sensor_ssh_keys = ''

node[:seconion][:server][:sorted_sensors].each do |sensor|

  if sensor[:seconion][:so_ssh_pub]
    sensor_ssh_keys << sensor[:seconion][:so_ssh_pub]  
  end

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


