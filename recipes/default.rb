#
# Cookbook Name:: seconion
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

directories = ['/nsm',
        			 '/var/log/nsm/',
               '/var/log/nsm/securityonion/',
        			 '/root/.ssh/',
        			 '/etc/nsm/',
               '/etc/nsm/rules/',
               '/etc/nsm/rules/backup/',
               '/etc/nsm/pulledpork',
        			 '/usr/local/lib/snort_dynamicrules',
        			 '/etc/mysql/',
               '/etc/mysql/conf.d/',
               '/nsm/bro',
        			 '/nsm/bro/spool',
        			 '/nsm/bro/logs',
        			 '/nsm/bro/extracted']


directories.each do |path|
  directory path do
	  owner 'root'
	  group 'root'
	  mode '0755'
	  action :create
	end
end

##########################
# Timezone
##########################

template '/etc/timezone' do
  source 'default/timezone.erb'
  mode '0655'
  owner 'root'
  group 'root'
  notifies :run, execute['set-timezone'], :immediately
end

execute 'set-timezone' do
  command 'dpkg-reconfigure --frontend noninteractive tzdata'
  action :nothing
end