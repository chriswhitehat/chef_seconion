#
# Cookbook Name:: seconion
# Recipe:: sensor_rules
#


node[:seconion][:sensor][:sniffing_interfaces].each do |sniff|

  directories = [ "/etc/nsm/pulledpork/",
                  "/etc/nsm/pulledpork/#{sniff[:sensorname]}",
                  "/etc/nsm/rules/",
                  "/etc/nsm/rules/#{sniff[:sensorname]}",
                  "/etc/nsm/rules/#{sniff[:sensorname]}/backup" ]

  directories.each do |path|
    directory path do
      owner 'sguil'
      group 'sguil'
      mode '0755'
      action :create
    end
  end


  execute "check-for-downloaded.rules_#{sniff[:sensorname]}" do
    command "ls /etc/nsm/rules/#{sniff[:sensorname]}"
    not_if do ::File.exists?("/etc/nsm/rules/#{sniff[:sensorname]}/downloaded.rules") end
    notifies :run, "execute[run_rule-update]", :delayed
  end




##################
# Local Rules
##################

  sigs = {
      :global_sigs => {},
      :regional_sigs => {},
      :sensor_group_sigs => {},
      :host_sigs => {},
      :sensor_sigs => {}
    }

  if node[:seconion][:sensor][:local_rules]

    scopes = [('global_sigs', 'global'),  
              ('regional_sigs', 'regional'), 
              ('sensor_group_sigs', node[:seconion][:sensor][:sensor_group]), 
              ('host_sigs', node[:fqdn]),
              ('sensor_sigs', sniff[:sensorname]) ]

    scopes.each do |scope, sig|
      if node[:seconion][:sensor][:local_rules][sig]
        sigs[scope] = node[:seconion][:sensor][:local_rules][sig]
      end
    end
  end

  template "/etc/nsm/rules/#{sniff[:sensorname]}/local.rules" do
    source "sensor/rules/local.rules.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff,
      :sigs =. sigs
    })
  end


  ###################
  # Pulledpork confs
  ###################

  pulledpork_confs = ['disablesid', 'dropsid', 'enablesid', 'modifysid']
  pulledpork_confs.each do |conf|

    sigs = {
        :global_sigs => {},
        :regional_sigs => {},
        :sensor_group_sigs => {},
        :host_sigs => {},
        :sensor_sigs => {}
      }

    if node[:seconion][:sensor][:pulledpork] && node[:seconion][:sensor][:pulledpork][conf]

      scopes = [('global_sigs', 'global'),  
                ('regional_sigs', 'regional'), 
                ('sensor_group_sigs', node[:seconion][:sensor][:sensor_group]), 
                ('host_sigs', node[:fqdn]),
                ('sensor_sigs', sniff[:sensorname]) ]

      scopes.each do |scope, sig|
        if node[:seconion][:sensor][:pulledpork][conf][sig]
          sigs[scope] = node[:seconion][:sensor][:pulledpork][conf][sig]
        end
      end

    template "/etc/nsm/pulledpork/#{sniff[:sensorname]}/#{conf}.conf" do
      source "pulledpork/#{conf}.conf.erb"
      owner 'sguil'
      group 'sguil'
      mode '0644'
      variables({
        :sniff => sniff,
        :sigs => sigs
      })
    end
  end


  template "/etc/nsm/pulledpork/#{sniff[:sensorname]}/pulledpork.conf" do
    source "pulledpork/pulledpork.conf.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff
    })
  end


  rule_urls = []

  ruby_block "get_rule_urls_#{sniff[:sensorname]}" do
    block do
      # Collect all rule_url entries in pulledpork for each sensor
      File.open("/etc/nsm/pulledpork/#{sniff[:sensorname]}/pulledpork.conf").each_line do |li|
        if (li[/^rule_url/]) and not rule_urls.include?(li)
          rule_urls << li
        end
      end
      node.default[:seconion][:sensor][:rule_urls] = rule_urls
    end
  end
end
