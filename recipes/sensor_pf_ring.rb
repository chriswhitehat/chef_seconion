#
# Cookbook Name:: seconion
# Recipe:: sensor_pf_ring
#


template '/etc/modprobe.d/pf_ring.conf' do
  source 'sensor/pf_ring/pf_ring.conf.erb'
  owner 'sguil'
  group 'sguil'
  mode '0644'
  notifies :run, 'execute[so-stop]', :delayed
  notifies :uninstall, 'kernel_module[pf_ring]', :delayed
  notifies :install, 'kernel_module[pf_ring]', :delayed
  notifies :run, 'excute[so-start]', :delayed
end


kernel_module 'pf_ring' do
  action :nothing
end
