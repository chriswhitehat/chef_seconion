#
# Cookbook Name:: seconion
# Recipe:: sensor_ossec
#

if node[:seconion][:sensor][:ossec_enabled]

  file "/var/ossec/etc/localtime" do
    owner 'root'
    group 'ossec'
    mode 0755
    content lazy{ ::File.open("/etc/localtime").read }
    action :create
    notifies :run, 'execute[so-ossec-restart]', :delayed
  end

  template '/etc/nsm/ossec/ossec_agent.conf' do
    source 'sensor/ossec_agent.conf.erb'
    owner 'root'
    group 'ossec'
    mode '0644'
    notifies :run, 'execute[so-ossec-restart]', :delayed
    notifies :run, 'execute[so-ossec-agent-restart]', :delayed
  end
  

else
  # execute 'disable_ossec' do
  #   command 'service ossec-hids-server stop; update-rc.d -f ossec-hids-server remove'
  #   action :run
  #   only_if do ::File.exists?('/etc/rc0.d/K20ossec-hids-server') end
  # end
end

