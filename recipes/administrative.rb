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
# Interface
##########################
ifconfig node[:seconion][:mgmt][:ipv4] do
  bootproto 'static'
  device node[:seconion][:mgmt][:interface]
  mask node[:seconion][:mgmt][:netmask]
  gateway node[:seconion][:mgmt][:gateway]
  only_if node[:seconion][:mgmt][:configure]
end

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

package 'software-properties-common'


directory '/root/.ssh' do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end


##########################
# Security Onion Repo
##########################

apt_repository 'SecurityOnion' do
  uri 'ppa:securityonion/stable'
  not_if do ::File.exists?('/etc/apt/sources.list.d/SecurityOnion.list') end
end


##########################
# Basic nsm directories
##########################

user 'sguil' do
  system true
end

directories = [ '/nsm/',
                '/etc/nsm/',
                '/var/log/nsm' ]


directories.each do |path|
  directory path do
    owner 'sguil'
    group 'sguil'
    mode '0755'
    action :create
  end
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


########################
# Setup SOUP Automation
########################

if node[:seconion][:soup][:enabled]
    soup_hour = node[:seconion][:soup][:hour]
    soup_day = "*"
    soup_month = "*"
    soup_weekday = node[:seconion][:soup][:last_day_of_month]
    soup_command = 'root [ $(date +"\%m") -ne $(date -d 7days +"\%m") ] && /usr/sbin/soup -y -l ' + node[:seconion][:soup][:log_path]

  if node[:seconion][:sensor][:sniffing_interfaces]
    node_type = 'sensor'
    soup_min = node[:seconion][:soup][:sensor_delay]
  else
    node_type = 'server'
    soup_min = "00"
  end
  
  if node[:seconion][node_type][:soup][:cron_overwrite]
    soup_min = node[:seconion][node_type][:soup][:cron][:minute]
    soup_hour = node[:seconion][node_type][:soup][:cron][:hour]
    soup_day = node[:seconion][node_type][:soup][:cron][:day_of_month]
    soup_month = node[:seconion][node_type][:soup][:cron][:month_of_year]
    soup_weekday = node[:seconion][node_type][:soup][:cron][:day_of_week]
    soup_command = "root /usr/sbin/soup -y -l #{node[:seconion][:soup][:log_path]}"
  end

  cron_d 'seconion-soup' do
    minute soup_min
    hour soup_hour
    day soup_day
    month soup_month
    weekday soup_weekday
    command soup_command
    shell '/bin/sh'
    path '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
  end
end
