#
# Cookbook Name:: seconion
# Recipe:: default
#


include_recipe 'seconion::commands'

include_recipe 'seconion::administrative'


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


directory '/root/.ssh' do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end
