# Collect sensor rule urls
rule_urls = ''

# Collect sensor pub keys
sensor_ssh_keys = ''

# Collect sensornames
current_sensors = []

search_server = "recipes:seconion\\:\\:sensor AND seconion_server_servername:\"#{node[:seconion][:server][:servername]}\""
sensors = search(:node, search_server)

sorted_sensors = sensors.sort_by!{ |n| n[:fqdn] }
#sorted_sensors = sensors

sorted_sensors.each do |sensor|
  if sensor[:seconion][:so_ssh_pub]
    sensor_ssh_keys << sensor[:seconion][:so_ssh_pub]  
  end

  if sensor[:seconion][:sensor][:rule_urls]
    sensor[:seconion][:sensor][:rule_urls].each do |rule_url|
      rule_urls << rule_url if not rule_urls.include?(rule_url)
    end
  end

  sensor[:seconion][:sensor][:sniffing_interfaces].each do |sniff|

    current_sensors << sniff[:sensorname]

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

