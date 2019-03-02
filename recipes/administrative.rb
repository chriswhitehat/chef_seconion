#
# Cookbook Name:: seconion
# Recipe:: administrative
#

require 'digest/md5'


##########################
# Timezone
##########################
timezone 'UTC'


##########################
# LTS/HWE Kernel and headers
##########################
package "linux-generic-hwe-#{node[:platform_version]}" do
  action :install
  notifies :reboot_now, 'reboot[now]', :immediately
end

package 'linux_headers' do
  package_name "linux-headers-#{node[:kernel][:release]}"
  action :install
end

##########################
# Security Onion Deps
##########################

# Standard sguil user
user 'sguil' do
  system true
end

package 'software-properties-common'

apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
  not_if do ::File.exists?('/etc/apt/sources.list.d/SecurityOnion.list') end
end


#############################
# Deploy Notes
#############################
template '/etc/nsm/chef_notes' do
  source 'chef_notes.erb'
  owner 'sguil'
  group 'sguil'
  mode '0644'
end


#############################
# Backup Autocat
#############################

sleep_time = Digest::MD5.hexdigest(node['fqdn'] || 'unknown-hostname').to_s.hex % 300

template '/etc/cron.d/autocat-backup-pull' do
  source 'autocat/autocat-backup-pull.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :sleep_time => sleep_time
  )
end
