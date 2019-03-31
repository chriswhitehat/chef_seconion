#
# Cookbook Name:: seconion
# Recipe:: server_rules
#

# Collect sensor rule urls
rule_urls = ''

node[:seconion][:server][:sorted_sensors].each do |sensor|

  if sensor[:seconion][:sensor][:rule_urls]
    sensor[:seconion][:sensor][:rule_urls].each do |rule_url|
      rule_urls << rule_url if not rule_urls.include?(rule_url)
    end
  end

  sensor[:seconion][:sensor][:sniffing_interfaces].each do |sniff|

    symlink = "/nsm/server_data/#{node[:seconion][:server][:sguil_server_name]}/rules/#{sniff[:sensorname]}" 
    execute "base_symlink_rules_#{sniff[:sensorname]}" do
      command "ln -f -s /etc/nsm/rules #{symlink}"
      not_if do ::File.exists?("#{symlink}") end
    end

    (1..sniff[:ids_lb_procs]).each do |i| 
      symlink = "/nsm/server_data/#{node[:seconion][:server][:sguil_server_name]}/rules/#{sniff[:sensorname]}-#{i}" 
      puts symlink
      puts (1..sniff[:ids_lb_procs])
      execute "lbproc_symlink_rules_#{sniff[:sensorname]}-#{i}" do
        command "ln -f -s /etc/nsm/rules #{symlink}"
        not_if do ::File.exists?("#{symlink}") end
      end
    end
  end
end


template '/etc/nsm/pulledpork/pulledpork.conf' do
  source 'server/pulledpork.conf.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
  variables(
    :rule_urls => rule_urls
  )
  notifies :run, 'execute[run_rule-update]', :delayed
end
