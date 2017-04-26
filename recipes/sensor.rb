#
# Cookbook Name:: seconion
# Recipe:: sensor
#

require 'digest/md5'

include_recipe 'seconion::default'


package ['securityonion-sensor', 'syslog-ng-core']


#############################
# Deploy Notes
#############################
template '/etc/nsm/chef_notes' do
  source 'chef_notes.erb'
  owner 'sguil'
  group 'sguil'
  mode '0644'
end


template '/usr/sbin/seconion_status' do
  source 'sensor/seconion_status.erb'
  owner 'root'
  group 'root'
  mode '0755'
end


execute 'nsm_sensor_ps-stop' do
  command "nsm_sensor_ps-stop"
  action :nothing
end


##########################
# Replace existing rule-update
##########################
template '/usr/sbin/rule-update' do
  source '/rule-update/rule-update.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

##########################
# Add nsm_sensor_ps-hard-restart
##########################
template '/usr/sbin/nsm_sensor_ps-hard-restart' do
  source '/nsmnow/nsm_sensor_ps-hard-restart.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

##########################
# Add rule update with hard
# restart
##########################
template '/usr/sbin/rule-update-hard' do
  source '/rule-update/rule-update-hard.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

##########################
# Calculate rolling restart splay
##########################
if node[:seconion][:sensor][:sensor_group] == 'singleton'
  node.normal[:seconion][:sensor][:restart_splay] = 0
  node.normal[:seconion][:sensor][:restart_hour] = node[:seconion][:sensor][:rule_update_hour]['singleton']
else
  search_sensor_group = "seconion_sensor_sensor_group:\"#{node[:seconion][:sensor][:sensor_group]}\""

  sensors = search(:node, search_sensor_group)

  sorted_sensors = []

  sensors.sort_by!{ |n| n[:fqdn] }.each do |sensor|
    sorted_sensors << sensor[:fqdn]
  end

  if not sorted_sensors.index(node[:fqdn])
    node.normal[:seconion][:sensor][:restart_splay] = 0
    node.normal[:seconion][:sensor][:restart_hour] = node[:seconion][:sensor][:rule_update_hour]['singleton']
  else
    node.normal[:seconion][:sensor][:restart_splay] = (sorted_sensors.index(node[:fqdn]) % node[:seconion][:sensor][:rule_update_phases][node[:seconion][:sensor][:sensor_group]]) * node[:seconion][:sensor][:rule_update_phase_duration][node[:seconion][:sensor][:sensor_group]]
    node.normal[:seconion][:sensor][:restart_hour] = node[:seconion][:sensor][:rule_update_hour][node[:seconion][:sensor][:sensor_group]]
  end
end


##########################
# Replace rule-update cron
##########################
template '/etc/cron.d/rule-update' do
  source '/rule-update/cron_rule-update.erb'
  mode '0644'
  owner 'root'
  group 'root'
end


##########################
# Barnyard2 Restart
##########################
template '/etc/cron.d/sensor-newday' do
  source '/sensor/cron_sensor-newday.erb'
  mode '0644'
  owner 'root'
  group 'root'
end


##########################
# Add nsm_sensor_ps-rolling-restart
##########################
template '/usr/sbin/nsm_sensor_ps-rolling-restart' do
  source '/nsmnow/nsm_sensor_ps-rolling-restart.erb'
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
               '/usr/local/lib/snort_dynamicrules_backup',
               '/etc/nsm/backup']

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

execute 'ssh-keygen -f "/root/.ssh/securityonion" -N \'\'; chmod 755 /root/.ssh' do
  not_if do ::File.exists?('/root/.ssh/securityonion') end
end

execute 'add_soserver_to_known_hosts' do
  command "ssh-keyscan -H #{node[:seconion][:server][:servername]} >> /root/.ssh/known_hosts"
  not_if do ::File.exists?('/root/.ssh/known_hosts') end
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




###########
# Network Interfaces Config
###########

if node[:seconion][:sensor][:mgmt][:configure]

  template '/etc/network/interfaces' do
    source 'sensor/interfaces.erb'
    mode '0644'
    owner 'root'
    group 'root'
    variables(
      :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
    )
    notifies :run, 'execute[initial_soup]', :immediately
  end
end


reboot 'now' do
  action :nothing
  reason 'Cannot continue Chef run without a reboot.'
  delay_mins 2
end


execute 'initial_soup' do
  command 'soup -y'
  action :nothing
  notifies :reboot_now, 'reboot[now]', :immediately
end


###########
# OSSEC Disable
###########
if node[:seconion][:sensor][:ossec_enabled]
  execute 'enable_ossec' do
    command 'service ossec-hids-server start; update-rc.d -f ossec-hids-server enable; service ossec-hids-server start'
    action :run
    not_if do ::File.exists?('/etc/rc0.d/K20ossec-hids-server') end
  end
else
  execute 'disable_ossec' do
    command 'service ossec-hids-server stop; update-rc.d -f ossec-hids-server remove'
    action :run
    only_if do ::File.exists?('/etc/rc0.d/K20ossec-hids-server') end
  end
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
  notifies :run, 'execute[nsm_sensor_ps-stop]', :before
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

if node[:seconion][:sensor][:bro][:extracted][:rotate]
  template '/etc/cron.d/bro-rotate-extracted' do
    source 'bro/cron-bro-rotate-extracted.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end
end

if node[:seconion][:sensor][:bro_sigs]
  if node[:seconion][:sensor][:bro_sigs][:global]
    global_sigs = node[:seconion][:sensor][:bro_sigs][:global]
  else
    global_sigs = {}
  end
  if node[:seconion][:sensor][:bro_sigs][:regional]
    regional_sigs = node[:seconion][:sensor][:bro_sigs][:regional]
  else
    regional_sigs = {}
  end
  if node[:seconion][:sensor][:bro_sigs][node[:seconion][:sensor][:sensor_group]]
    sensor_group_sigs = node[:seconion][:sensor][:bro_sigs][node[:seconion][:sensor][:sensor_group]]
  else
    sensor_group_sigs = {}
  end
  if node[:seconion][:sensor][:bro_sigs][node[:fqdn]]
    host_sigs = node[:seconion][:sensor][:bro_sigs][node[:fqdn]]
  else
    host_sigs = {}
  end
else
  global_sigs = {}
  regional_sigs = {}
  sensor_group_sigs = {}
  host_sigs = {}
end

if node[:seconion][:sensor][:bro_scripts]
  if node[:seconion][:sensor][:bro_scripts][:global]
    global = node[:seconion][:sensor][:bro_scripts][:global]
  else
    global = {}
  end
  if node[:seconion][:sensor][:bro_scripts][:regional]
    regional = node[:seconion][:sensor][:bro_scripts][:regional]
  else
    regional = {}
  end
  if node[:seconion][:sensor][:bro_scripts][node[:seconion][:sensor][:sensor_group]]
    sensor_group = node[:seconion][:sensor][:bro_scripts][node[:seconion][:sensor][:sensor_group]]
  else
    sensor_group = {}
  end
  if node[:seconion][:sensor][:bro_scripts][node[:fqdn]]
    host = node[:seconion][:sensor][:bro_scripts][node[:fqdn]]
  else
    host = {}
  end
else
  global = {}
  regional = {}
  sensor_group = {}
  host = {}
end

template '/opt/bro/share/bro/site/local.bro' do
  source 'bro/site/local.bro.erb'
  owner 'sguil'
  group 'sguil'
  mode '0644'
  variables({
    :global_sigs => global_sigs,
    :regional_sigs => regional_sigs,
    :sensor_group_sigs => sensor_group_sigs,
    :host_sigs => host_sigs,
    :global => global,
    :regional => regional,
    :sensor_group => sensor_group,
    :host => host,
  })
  notifies :run, 'execute[deploy_bro]', :delayed
end


#########################################
# Apache configuration
#########################################
#disable apache? Sensors don't use it.


template '/etc/modprobe.d/pf_ring.conf' do
   source 'sensor/pf_ring.conf.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
   notifies :run, 'execute[reload_pf_ring_module]', :delayed
end


execute 'reload_pf_ring_module' do
  command 'nsm_sensor_ps-stop; modprobe -r pf_ring; modprobe -a pf_ring; nsm_sensor_ps-start' 
  action :nothing
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

  sensortab += "#{sniff[:sensorname]}\t1\t#{barnyard_port}\t#{sniff[:interface]}\n"

  # List of directories to create
  directories = ["/var/log/nsm/#{sniff[:sensorname]}",
                  "/etc/nsm/pulledpork/#{sniff[:sensorname]}",
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
                 "/var/log/nsm/#{sniff[:sensorname]}/pcap_agent.log"]

  touch_files.each do |path|
    file path do
      mode '0644'
      owner 'sguil'
      group 'sguil'
      action :touch
      not_if do ::File.exists?(path) end
    end
  end

  touch_lb_files = ["/var/log/nsm/#{sniff[:sensorname]}/snort_agent",
                    "/var/log/nsm/#{sniff[:sensorname]}/snortu",
                    "/var/log/nsm/#{sniff[:sensorname]}/barnyard2"]

  touch_lb_files.each do |path|
    (1..sniff[:ids_lb_procs]).each do |i|
      lb_path = "#{path}-#{i}.log"
      file lb_path do
        mode '0644'
        owner 'sguil'
        group 'sguil'
        action :touch
        not_if do ::File.exists?(lb_path) end
      end
    end
  end

  # Run sensor add command creating directories and other state
  execute "nsm_sensor_add_#{sniff[:sensorname]}" do
    command "/usr/sbin/nsm_sensor_add --sensor-name=\"#{sniff[:sensorname]}\" --sensor-interface=\"#{sniff[:interface]}\" --sensor-interface-auto=no "\
                                          "--sensor-server-host=\"#{node[:seconion][:server][:servername]}\" --sensor-server-port=7736 "\
                                          "--sensor-barnyard2-port=#{barnyard_port} --sensor-auto=yes --sensor-utc=yes "\
                                          "--sensor-vlan-tagging=no --sensor-net-group=\"#{sniff[:sensorname]}\" --force-yes"
    not_if do ::File.exists?("/etc/nsm/#{sniff[:sensorname]}") end
    notifies :run, "execute[chown-nsm-#{sniff[:sensorname]}]", :immediately
  end

  execute "check-for-downloaded.rules_#{sniff[:sensorname]}" do
    command "ls /etc/nsm/rules/#{sniff[:sensorname]}"
    not_if do ::File.exists?("/etc/nsm/rules/#{sniff[:sensorname]}/downloaded.rules") end
    notifies :run, "execute[run_rule-update]", :delayed
  end

  execute "chown-nsm-#{sniff[:sensorname]}" do
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
            'so_rules.rules',
            'stream-events.rules',
            'tls-events.rules']

  rules.each do |rule|
    template  "/etc/nsm/rules/#{sniff[:sensorname]}/#{rule}" do
      source "snort/#{rule}.erb"
      mode '0644'
      owner 'sguil'
      group 'sguil'
      variables({
        :sniff => sniff,
      })
      action :create
    end
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
    if node[:seconion][:sensor][:threshold][node[:seconion][:sensor][:sensor_group]]
      sensor_group = node[:seconion][:sensor][:threshold][node[:seconion][:sensor][:sensor_group]]
    else
      sensor_group = {}
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
    sensor_group = {}
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
      :sensor_group_sigs => sensor_group,
      :host_sigs => host,
      :sensor_sigs => sensor
    })
  end

  if node[:seconion][:sensor][:local_rules]
    if node[:seconion][:sensor][:local_rules][:global]
      global = node[:seconion][:sensor][:local_rules][:global]
    else
      global = {}
    end
    if node[:seconion][:sensor][:local_rules][:regional]
      regional = node[:seconion][:sensor][:local_rules][:regional]
    else
      regional = {}
    end
    if node[:seconion][:sensor][:local_rules][node[:seconion][:sensor][:sensor_group]]
      sensor_group = node[:seconion][:sensor][:local_rules][node[:seconion][:sensor][:sensor_group]]
    else
      sensor_group = {}
    end
    if node[:seconion][:sensor][:local_rules][node[:fqdn]]
      host = node[:seconion][:sensor][:local_rules][node[:fqdn]]
    else
      host = {}
    end
    if node[:seconion][:sensor][:local_rules][sniff[:sensorname]]
      sensor = node[:seconion][:sensor][:local_rules][sniff[:sensorname]]
    else
      sensor = {}
    end
  else
    global = {}
    regional = {}
    sensor_group = {}
    host = {}
    sensor = {}
  end

  template "/etc/nsm/rules/#{sniff[:sensorname]}/local.rules" do
    source "snort/local.rules.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff,
      :global_sigs => global,
      :regional_sigs => regional,
      :sensor_group_sigs => sensor_group,
      :host_sigs => host,
      :sensor_sigs => sensor
    })
  end


  template "/etc/nsm/#{sniff[:sensorname]}/bpf-bro.conf" do
    source "sensor/bpf-bro.conf.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff,
    })
  end

  template "/etc/nsm/#{sniff[:sensorname]}/bpf-ids.conf" do
    source "sensor/bpf-ids.conf.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff,
    })
  end

  template "/etc/nsm/#{sniff[:sensorname]}/bpf-pcap.conf" do
    source "sensor/bpf-pcap.conf.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff,
    })
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
      if node[:seconion][:sensor][:pulledpork][node[:seconion][:sensor][:sensor_group]]
        sensor_group = node[:seconion][:sensor][:pulledpork][node[:seconion][:sensor][:sensor_group]]
      else
        sensor_group = {}
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
      sensor_group = {}
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
        :sensor_group_sigs => sensor_group,
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




execute 'nsm_sensor_ps-restart --only-bro' do
  not_if do ::File.exists?('/nsm/bro/spool/broctl-config.sh') end
  notifies :run, 'execute[deploy_bro]', :immediately
end

execute 'deploy_bro' do
  command "/opt/bro/bin/broctl deploy"
  action :nothing
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

execute 'run_rule-update' do
  command "rule-update"
  action :nothing
  notifies :restart, 'service[nsm]', :delayed
end

service 'nsm' do
  action :nothing
end



########################
# Setup SOUP Automation
########################

if node[:seconion][:soup][:enabled]
  if node[:seconion][:sensor][:soup][:cron_overwrite]
    template '/etc/cron.d/seconion-soup-overwrite' do
      source 'soup/seconion-soup-overwrite.erb'
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        :server => false
      )
      notifies :delete, 'file[seconion_soup_cron]', :immediately
    end
  else
    template '/etc/cron.d/seconion-soup' do
      source 'soup/seconion-soup.erb'
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        :server => false
      )
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




#############################
# Backup Autocat
#############################

sleep_time = Digest::MD5.hexdigest(node['fqdn'] || 'unknown-hostname').to_s.hex % 300

template '/etc/cron.d/autocat-backup-pull' do
  source 'autocat/autocat-backup-pull.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :sleep_time => sleep_time
  )
end


#############################
# Cleanup Sensors that are no longer valid
#############################


ruby_block "rm_old_sensors" do
  block do
    current_sensors = []

    node[:seconion][:sensor][:sniffing_interfaces].each do |sensor|
      current_sensors << sensor[:sensorname]
    end

    existing_sensors = Dir.entries('/nsm/sensor_data/').select {|entry| File.directory? File.join('/nsm/sensor_data/',entry) and !(entry =='.' || entry == '..') }

    (existing_sensors - current_sensors).each do |sensor|
      
      sensor_data_dir = Chef::Resource::Directory.new("rm_sensor_data_#{sensor}", run_context)
      sensor_data_dir.path       "/nsm/sensor_data/#{sensor}"
      sensor_data_dir.recursive  true
      sensor_data_dir.run_action :delete

      sensor_config_dir = Chef::Resource::Directory.new("rm_config_#{sensor}", run_context)
      sensor_config_dir.path       "/etc/nsm/#{sensor}"
      sensor_config_dir.recursive  true
      sensor_config_dir.run_action :delete

      sensor_rules_dir = Chef::Resource::Directory.new("rm_rules_#{sensor}", run_context)
      sensor_rules_dir.path       "/etc/nsm/rules/#{sensor}"
      sensor_rules_dir.recursive  true
      sensor_rules_dir.run_action :delete

      sensor_pulledpork_dir = Chef::Resource::Directory.new("rm_pulledpork_#{sensor}", run_context)
      sensor_pulledpork_dir.path       "/etc/nsm/pulledpork/#{sensor}"
      sensor_pulledpork_dir.recursive  true
      sensor_pulledpork_dir.run_action :delete

      sensor_log_dir = Chef::Resource::Directory.new("rm_log_#{sensor}", run_context)
      sensor_log_dir.path       "/var/log/nsm/#{sensor}"
      sensor_log_dir.recursive  true
      sensor_log_dir.run_action :delete

    end

  end
end


##########################
# Purge Rule Stats
##########################

template '/usr/bin/rule_stats_purge' do
  source '/sensor/rule_stats_purge.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/cron.d/rule-stats-purge' do
  source 'sensor/cron_rule-stats-purge.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


##########################
# SO Health
##########################

template '/etc/cron.d/bro-stats' do
  source '/sensor/cron_bro-stats.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

