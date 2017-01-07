#
# Cookbook Name:: seconion
# Recipe:: sensor
#

include_recipe 'seconion::default'


package ['securityonion-sensor', 'syslog-ng-core']

##########################
# Replace existing rule-update
##########################
template '/usr/bin/rule-update' do
  source '/rule-update/rule-update.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

directories = ['/nsm/sensor_data',
               '/opt/bro/share/bro/ghc_extraction',
               '/opt/bro/share/bro/etpro',
               '/opt/bro/share/bro/smtp-embedded-url-bloom',
               '/opt/bro/share/bro/networks',
               '/var/log/nsm',
               '/usr/local/lib/snort_dynamicrules',
               '/usr/local/lib/snort_dynamicrules_backup']

directories.each do |path|
  directory path do
	  owner 'sguil'
	  group 'sguil'
	  mode '0755'
	  action :create
	end
end



###########
# SSH Sensor Config
###########

execute 'ssh-keygen -f "/root/.ssh/securityonion" -N \'\'' do
  not_if do ::File.exists?('/root/.ssh/securityonion') end
end

# Ruby block converge hack
ruby_block "set_pub_ssh_keys_attribute" do
  block do
    if File.exists?('/root/.ssh/securityonion.pub')
      node.default[:seconion][:so_ssh_pub] = File.open('/root/.ssh/securityonion.pub', "r").read 
    else
      node.default[:seconion][:so_ssh_pub] = '' 
    end
  end
end

template '/root/.ssh/securityonion_ssh.conf' do
  source 'sensor/securityonion_ssh.conf.erb'
  mode '0600'
  owner 'sguil'
  group 'sguil'
end


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# TODO Need to remove test in destination
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
###########
# Network Interfaces Config
###########
template '/etc/network/testinterfaces' do
  source 'sensor/interfaces.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables( 
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
end


###########
#
###########

template '/etc/nsm/securityonion.conf' do
  source 'default/securityonion.conf.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
end

file "/etc/nsm/sensortab" do
  mode '0644'
  owner 'sguil'
  group 'sguil'
  action :create
end

############
# Configure Bro 
############
template '/opt/bro/etc/node.cfg' do
  source 'bro/node.cfg.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
  variables( 
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
end

template '/opt/bro/etc/network.cfg' do
  source 'bro/network.cfg.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
  variables( 
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
end

template '/opt/bro/share/bro/networks/__load__.bro' do
  source 'bro/networks/__load__.bro.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
  variables( 
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
end

############
# Configure Bro Continued
# Create GHC Specific rule files for File Extraction
############

# Create files for ET Intelligence in Bro
# template '/opt/bro/share/bro/etpro/__load__.bro' do
#    source 'bro/etpro/__load__.bro.erb'
#    owner 'sguil'
#    group 'sguil'
#    mode '0644'
# end

# template '/opt/bro/share/bro/etpro/etpro_intel.bro' do
#    source 'bro/etpro/etpro_intel.bro.erb'
#    owner 'sguil'
#    group 'sguil'
#    mode '0644'
# end

# Installing ET intelligence in Bro
# cron 'etpro_intel' do
#   hour '1'
#   command 'wget -q https://rules.emergingthreats.net/#{oinkcode}/reputation/brorepdata.tar.gz && tar -xzf bro-repdata.tar.gz -C /opt/bro/share/bro/etpro && rm -rf bro-repdata.tar.gz > /dev/null 2>&1'
# end

# Create files for SMTP embedded Url Bloom
template '/opt/bro/share/bro/smtp-embedded-url-bloom/__load__.bro' do
   source 'bro/smtp-embedded-url-bloom/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/smtp-embedded-url-bloom/smtp-embedded-url-bloom-ghc.bro' do
   source 'bro/smtp-embedded-url-bloom/smtp-embedded-url-bloom-ghc.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/smtp-embedded-url-bloom/smtp-embedded-url-cluster.bro' do
   source 'bro/smtp-embedded-url-bloom/smtp-embedded-url-cluster.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

# Create files for GHC File Extraction
template '/opt/bro/share/bro/ghc_extraction/__load__.bro' do
   source 'bro/extraction/ghc/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/ghc_extraction/extract.bro' do
   source 'bro/extraction/ghc/extract.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/site/local.bro' do
   source 'bro/site/local.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
   variables({
    :bro_scripts => node[:seconion][:sensor][:bro_script],
    :bro_sigs => node[:seconion][:sensor][:bro_sig]
  })
  notifies :run, 'execute[deploy_bro]', :delayed
end

execute 'deploy_bro' do
  command "/opt/bro/bin/broctl deploy"
  action :nothing
end


#########################################
# Download rules using Pulledpork
#########################################


# TODO investigate pulledpork run/rule-update
# An error occurred: ERROR: /etc/nsm/templates/snort//etc/nsm/rules/downloaded.rules(0) Unable to open rules file "/etc/nsm/templates/snort//etc/nsm/rules/downloaded.rules": No such file or directory.


#########################################
# Apache configuration
#########################################
#disable apache? Sensors don't use it. 


template '/etc/modprobe.d/pf_ring.conf' do
   source 'sensor/pf_ring.conf.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end



############
# Configure Sensors
############
# Set default starting barnyard port
barnyard_port = 8000

ids_cluster_id = 51

sensortab = ""

rule_urls = []

bro_networks = []

node[:seconion][:sensor][:sniffing_interfaces].each do |sniff|

  sensortab += "#{sniff[:sensorname]}    1    #{barnyard_port}    #{sniff[:interface]}\n"

  # List of directories to create
  directories = ["/etc/nsm/pulledpork/#{sniff[:sensorname]}",
                  "/etc/nsm/rules/#{sniff[:sensorname]}",
                  "/etc/nsm/rules/#{sniff[:sensorname]}/backup",
                  "/usr/local/lib/snort_dynamicrules/#{sniff[:sensorname]}",
                  "/usr/local/lib/snort_dynamicrules_backup/#{sniff[:sensorname]}"]

  directories.each do |path|
    directory path do
      owner 'sguil'
      group 'sguil'
      mode '0755'
      action :create
    end
  end

  #TODO touch log files that warn on first run.
  touch_files = ["/var/log/nsm/#{sniff[:sensorname]}/netsniff-ng.log",
                 "/var/log/nsm/#{sniff[:sensorname]}/sid_changes.log"]

  touch_files.each do |path|
    file path do
      mode '0644'
      owner 'sguil'
      group 'sguil'
      action :touch
      not_if do ::File.exists?(path) end
    end
  end

  # Run sensor add command creating directories and other state
  execute "nsm_sensor_add_#{sniff[:sensorname]}" do
    command "/usr/sbin/nsm_sensor_add --sensor-name=\"#{sniff[:sensorname]}\" --sensor-interface=\"#{sniff[:interface]}\" --sensor-interface-auto=no "\
                                          "--sensor-server-host=\"#{node[:seconion][:server][:servername]}\" --sensor-server-port=7736 "\
                                          "--sensor-barnyard2-port=#{barnyard_port} --sensor-auto=yes --sensor-utc=yes "\
                                          "--sensor-vlan-tagging=no --sensor-net-group=\"#{sniff[:sensor_net_group]}\" --force-yes"
    not_if do ::File.exists?("/etc/nsm/#{sniff[:sensorname]}") end
    notifies :run, 'execute[chown-nsm]', :immediately
  end
  
  execute "chown-nsm-#{sniff[:snesorname]}" do
    command "chown -R sguil:sguil /nsm"
    user "root"
    action :nothing
  end


  template "/etc/nsm/#{sniff[:sensorname]}/sensor.conf" do
    source "sensor/sensor.conf.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff,
      :barnyard_port => barnyard_port
    })
  end
  
  template "/etc/nsm/#{sniff[:sensorname]}/barnyard2.conf" do
    source "sensor/barnyard2.conf.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff,
      :barnyard_port => barnyard_port
    })
  end

  template "/etc/nsm/#{sniff[:sensorname]}/snort.conf" do
    source 'snort/snort.conf.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
      :ids_cluster_id => ids_cluster_id
    })
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

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/local.rules" do
    source 'snort/local.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/white_list.rules" do
    source 'snort/white_list.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/black_list.rules" do
    source 'snort/black_list.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end
  template  "/etc/nsm/rules/#{sniff[:sensorname]}/app-layer-events.rules" do
    source 'snort/app-layer-events.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/decoder-events.rules" do
    source 'snort/decoder-events.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/dnp3-events.rules" do
    source 'snort/dnp3-events.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/dns-events.rules" do
    source 'snort/dns-events.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    action :create
    variables({
      :sniff => sniff,
    })
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/files.rules" do
    source 'snort/files.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/http-events.rules" do
    source 'snort/http-events.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/modbus-events.rules" do
    source 'snort/modbus-events.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/smtp-events.rules" do
    source 'snort/smtp-events.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/so_rules.rules" do
    source 'snort/so_rules.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/stream-events.rules" do
    source 'snort/stream-events.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end

  template  "/etc/nsm/rules/#{sniff[:sensorname]}/tls-events.rules" do
    source 'snort/tls-events.rules.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
    action :create
  end
  
  template "/etc/nsm/#{sniff[:sensorname]}/suricata.yaml" do
    source 'suricata/suricata.yaml.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
      :barnyard_port => barnyard_port,
      :ids_cluster_id => ids_cluster_id
    })
  end

  template "/etc/nsm/#{sniff[:sensorname]}/classification.config" do
    source 'snort/classification.config.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
  end

  template "/etc/nsm/#{sniff[:sensorname]}/reference.config" do
    source 'snort/reference.config.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
  end


  if node[:seconion][:sensor][:threshold] 
    if node[:seconion][:sensor][:threshold][:global] 
      global = node[:seconion][:sensor][:threshold][:global]
    else
      global = {}
    end
    if node[:seconion][:sensor][:threshold][:regional] 
      regional = node[:seconion][:sensor][:threshold][:regional]
    else
      regional = {}
    end
    if node[:seconion][:sensor][:threshold][node[:fqdn]] 
      host = node[:seconion][:sensor][:threshold][node[:fqdn]]
    else
      host = {}
    end
    if node[:seconion][:sensor][:threshold][sniff[:sensorname]] 
      sensor = node[:seconion][:sensor][:threshold][sniff[:sensorname]]
    else
      sensor = {}
    end
  else
    global = {}
    regional = {}
    host = {}
    sensor = {}
  end

  template "/etc/nsm/#{sniff[:sensorname]}/threshold.conf" do
    source "snort/threshold.conf.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff,
      :global_sigs => global,
      :regional_sigs => regional,
      :host_sigs => host,
      :sensor_sigs => sensor
    })
  end

  if node[:seconion][:sensor][:bpf] 
    if node[:seconion][:sensor][:bpf][:global] 
      global = node[:seconion][:sensor][:bpf][:global]
    else
      global = {}
    end
    if node[:seconion][:sensor][:bpf][:regional] 
      regional = node[:seconion][:sensor][:bpf][:regional]
    else
      regional = {}
    end
    if node[:seconion][:sensor][:bpf][node[:fqdn]] 
      host = node[:seconion][:sensor][:bpf][node[:fqdn]]
    else
      host = {}
    end
    if node[:seconion][:sensor][:bpf][sniff[:sensorname]] 
      sensor = node[:seconion][:sensor][:bpf][sniff[:sensorname]]
    else
      sensor = {}
    end
  else
    global = {}
    regional = {}
    host = {}
    sensor = {}
  end

  bpf_confs = ["bpf.conf", "bpf-bro.conf", "bpf-ids.conf", "bpf-pcap.conf", "bpf-prads.conf"]
  bpf_confs.each do |bpf_conf|
 
    template "/etc/nsm/#{sniff[:sensorname]}/#{bpf_conf}" do
      source "sensor/bpf.conf.erb"
      owner 'sguil'
      group 'sguil'
      mode '0644'
      variables({
        :sniff => sniff,
        :global_sigs => global,
        :regional_sigs => regional,
        :host_sigs => host,
        :sensor_sigs => sensor
      })
    end
  end

  template "/etc/nsm/pulledpork/#{sniff[:sensorname]}/pulledpork.conf" do
      source "pulledpork/pulledpork.conf.erb"
      owner 'sguil'
      group 'sguil'
      mode '0644'
      variables({
        :sniff => sniff,
      })
    end

  pulledpork_confs = ['disablesid', 'dropsid', 'enablesid', 'modifysid']
  pulledpork_confs.each do |conf|

    if node[:seconion][:sensor][:pulledpork] && node[:seconion][:sensor][:pulledpork][conf] 
      if node[:seconion][:sensor][:pulledpork][conf][:global] 
        global = node[:seconion][:sensor][:pulledpork][conf][:global]
      else
        global = {}
      end
      if node[:seconion][:sensor][:pulledpork][conf][:regional] 
        regional = node[:seconion][:sensor][:pulledpork][conf][:regional]
      else
        regional = {}
      end
      if node[:seconion][:sensor][:pulledpork][conf][node[:fqdn]] 
        host = node[:seconion][:sensor][:pulledpork][conf][node[:fqdn]]
      else
        host = {}
      end
      if node[:seconion][:sensor][:pulledpork][conf][sniff[:sensorname]] 
        sensor = node[:seconion][:sensor][:pulledpork][conf][sniff[:sensorname]]
      else
        sensor = {}
      end
    else
      global = {}
      regional = {}
      host = {}
      sensor = {}
    end

    template "/etc/nsm/pulledpork/#{sniff[:sensorname]}/#{conf}.conf" do
      source "pulledpork/#{conf}.conf.erb"
      owner 'sguil'
      group 'sguil'
      mode '0644'
      variables({
        :sniff => sniff,
        :global_sigs => global,
        :regional_sigs => regional,
        :host_sigs => host,
        :sensor_sigs => sensor
      })
    end
  end  

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

  
  # Increment baryard port by 100 for next interface
  barnyard_port = barnyard_port + 100

  ids_cluster_id = ids_cluster_id + 1


  template "/opt/bro/share/bro/networks/#{sniff[:sensorname]}.bro" do
    source 'bro/networks/sniff_networks.bro.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables(
      :sniff => sniff
    )
  end

end


template "/etc/nsm/sensortab" do
  source "sensor/sensortab.erb"
  owner 'sguil'
  group 'sguil'
  mode '0644'
  variables({
    :sensortab => sensortab,
  })
end
