#
# Cookbook Name:: seconion
# Recipe:: sensor_snort
#


node[:seconion][:sensor][:sniffing_interfaces].each do |sniff|


  directories = [ "/usr/local/lib/snort_dynamicrules/",
                  "/usr/local/lib/snort_dynamicrules/#{sniff[:sensorname]}",
                  "/usr/local/lib/snort_dynamicrules_backup/",
                  "/usr/local/lib/snort_dynamicrules_backup/#{sniff[:sensorname]}"]

  directories.each do |path|
    directory path do
      owner 'sguil'
      group 'sguil'
      mode '0755'
      action :create
    end
  end


  file "/etc/nsm/#{sniff[:sensorname]}/attribute_table.dtd" do
    mode '0644'
    owner 'sguil'
    group 'sguil'
    content lazy {::File.open("/etc/nsm/templates/snort/attribute_table.dtd").read }
    action :create
  end

  file "/etc/nsm/#{sniff[:sensorname]}/unicode.map" do
    mode '0644'
    owner 'sguil'
    group 'sguil'
    content lazy {::File.open("/etc/nsm/templates/snort/unicode.map").read }
    action :create
  end

  file "/etc/nsm/rules/#{sniff[:sensorname]}/gen-msg.map" do
    mode '0644'
    owner 'sguil'
    group 'sguil'
    content lazy {::File.open("/etc/nsm/templates/snort/gen-msg.map").read }
    action :create
  end

  rules = [ 'white_list.rules',
            'black_list.rules',
            'app-layer-events.rules',
            'decoder-events.rules',
            'dnp3-events.rules',
            'dns-events.rules',
            'files.rules',
            'http-events.rules',
            'modbus-events.rules',
            'smtp-events.rules',
            'stream-events.rules',
            'tls-events.rules']

  rules.each do |rule|
    template  "/etc/nsm/rules/#{sniff[:sensorname]}/#{rule}" do
      source "sensor/snort/#{rule}.erb"
      mode '0644'
      owner 'sguil'
      group 'sguil'
      variables({
        :sniff => sniff,
      })
      action :create
    end
  end


  sigs = {
    :global_sigs => {},
    :regional_sigs => {},
    :sensor_group_sigs => {},
    :host_sigs => {},
    :sensor_sigs => {}
    }

  if node[:seconion][:sensor][:threshold]

    scopes = [('global_sigs', 'global'),  
              ('regional_sigs', 'regional'), 
              ('sensor_group_sigs', node[:seconion][:sensor][:sensor_group]), 
              ('host_sigs', node[:fqdn]),
              ('sensor_sigs', sniff[:sensorname]) ]

    scopes.each do |scope, sig|
      if node[:seconion][:sensor][:threshold][sig]
        sigs[scope] = node[:seconion][:sensor][:threshold][sig]
      end
    end
  end

  template "/etc/nsm/#{sniff[:sensorname]}/threshold.conf" do
    source "sensor/snort/threshold.conf.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff,
      :sigs => sigs
    })
  end
end
