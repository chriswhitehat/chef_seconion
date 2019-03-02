#
# Cookbook Name:: seconion
# Recipe:: sensor_ssh
#


###########
# SSH Sensor Config
###########

execute 'ssh-keygen -f "/root/.ssh/securityonion" -N \'\'; chmod 755 /root/.ssh' do
  not_if do ::File.exists?('/root/.ssh/securityonion') end
end

execute 'add_soserver_to_known_hosts' do
  command "ssh-keyscan -H #{node[:seconion][:server][:servername]} >> /root/.ssh/known_hosts"
  not_if do ::File.exists?('/root/.ssh/known_hosts') end
end

# Ruby block converge hack
ruby_block "set_pub_ssh_keys_attribute" do
  block do
    if File.exists?('/root/.ssh/securityonion.pub')
      node.default[:seconion][:so_ssh_pub] = File.open('/root/.ssh/securityonion.pub', "r").read
    else
      node.default[:seconion][:so_ssh_pub] = ''
    end
  end
end

template '/root/.ssh/securityonion_ssh.conf' do
  source 'sensor/securityonion_ssh.conf.erb'
  mode '0600'
  owner 'sguil'
  group 'sguil'
end
