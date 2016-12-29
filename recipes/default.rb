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
  command 'dpkg-reconfigure --frontend noninteractive tzdata'
  action :nothing
end

user 'sguil' do
  system true
end

apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
end

