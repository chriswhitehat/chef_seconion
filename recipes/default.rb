#
# Cookbook Name:: seconion
# Recipe:: default
#

##########################
# Timezone
##########################

template '/etc/timezone' do
  source 'default/timezone.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :run, 'execute[set-timezone]', :immediately
end

execute 'set-timezone' do
  command "dpkg-reconfigure --frontend noninteractive tzdata; timedatectl set-timezone #{node[:seconion][:timezone]}"
  action :nothing
end

user 'sguil' do
  system true
end

apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
end


package 'install_hwe' do
  package_name ['linux-image-generic-lts-xenial', 'linux-generic-lts-xenial']
  action :install
  notifies :reboot_now, 'reboot[hwe_upgraded]', :immediately
end

reboot 'hwe_upgraded' do
	action :nothing
end	

package 'linux_headers' do
  package_name "linux-headers-#{node[:kernel][:release]}"
  action :install
end


# Bad idea, core O/S needs python2.7
# link '/usr/bin/python' do
#   to '/usr/bin/python3'
#   link_type :symbolic
# end

