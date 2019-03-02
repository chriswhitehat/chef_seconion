#
# Cookbook Name:: seconion
# Recipe:: soup
#
# Copyright (c) 2017 The Authors, All Rights Reserved.


########################
# Setup SOUP Automation
########################

if node[:seconion][:sensor][:sniffing_interfaces]
  sensor = true
  server = false
else
  sensor = false
  server = true
end

if node[:seconion][:soup][:enabled]
  if ( server and node[:seconion][:server][:soup][:cron_overwrite] ) or ( sensor and node[:seconion][:sensor][:soup][:cron_overwrite] ) 
    template '/etc/cron.d/seconion-soup-overwrite' do
      source 'soup/seconion-soup-overwrite.erb'
      owner 'root'
      group 'root'
      mode '0644'
      notifies :delete, 'file[seconion_soup_cron]', :immediately
    end
  else
    template '/etc/cron.d/seconion-soup' do
      source 'soup/seconion-soup.erb'
      owner 'root'
      group 'root'
      mode '0644'
      notifies :delete, 'file[seconion_soup_overwrite_cron]', :immediately
    end
  end
end

file 'seconion_soup_cron' do
  path '/etc/cron.d/seconion-soup'
  action :nothing
end

file 'seconion_soup_overwrite_cron' do
  path '/etc/cron.d/seconion-soup-overwrite'
  action :nothing
end

