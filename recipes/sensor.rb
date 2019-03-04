#
# Cookbook Name:: seconion
# Recipe:: sensor
#


include_recipe 'seconion::default'

package ['securityonion-sensor', 'syslog-ng-core', 'numactl', 'wireshark-common']


if node[:seconion][:sensor][:ids_engine_enabled]
  include_recipe 'seconion::sensor_ids'
  





template '/usr/sbin/seconion_status' do
  source 'sensor/seconion_status.erb'
  owner 'root'
  group 'root'
  mode '0755'
end


##########################
# Set sensor order
##########################
search_server = "recipes:seconion\\:\\:sensor AND seconion_server_servername:\"#{node[:seconion][:server][:servername]}\""
sensors = search(:node, search_server)

sorted_sensors = []

sensors.sort_by!{ |n| n[:fqdn] }.each do |sensor|
  sorted_sensors << sensor[:fqdn]
end

if sorted_sensors and sorted_sensors.index(node[:fqdn])
  node.normal[:seconion][:sensor][:order] = sorted_sensors.index(node[:fqdn]) + 1
else
  node.normal[:seconion][:sensor][:order] = 1
end


##########################
# Calculate rolling restart splay
##########################
if node[:seconion][:sensor][:sensor_group] == 'singleton'
  node.normal[:seconion][:sensor][:singleton] = 'true'
  node.normal[:seconion][:sensor][:restart_splay] = 0
  node.normal[:seconion][:sensor][:restart_hour] = node[:seconion][:sensor][:rule_update_hour]['singleton']
else
  node.normal[:seconion][:sensor][:singleton] = 'false'
  
  sensors = search(:node, "seconion_sensor_sensor_group:\"#{node[:seconion][:sensor][:sensor_group]}\"")

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





directories = ['/nsm/sensor_data']

directories.each do |path|
  directory path do
          owner 'sguil'
          group 'sguil'
          mode '0755'
          action :create
        end
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





#########################################
# Apache configuration
#########################################
#disable apache? Sensors don't use it.





############
# Configure Sensors
############
# Set default starting barnyard port
barnyard_port = 8000

ids_cluster_id = 51

sensortab = ""

bro_networks = []

node[:seconion][:sensor][:sniffing_interfaces].each do |sniff|

  sensortab += "#{sniff[:sensorname]}\t1\t#{barnyard_port}\t#{sniff[:interface]}\n"

  # List of directories to create
  directories = [ "/var/log/nsm/",
                  "/var/log/nsm/#{sniff[:sensorname]}",
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

  template "/etc/nsm/#{sniff[:sensorname]}/classification.config" do
    source 'sensor/snort/classification.config.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
  end

  template "/etc/nsm/#{sniff[:sensorname]}/reference.config" do
    source 'sensor/snort/reference.config.erb'
    mode '0644'
    owner 'sguil'
    group 'sguil'
    variables({
      :sniff => sniff,
    })
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
    notifies :run, 'execute[deploy_bro]', :delayed
  end
end


execute 'nsm_sensor_ps-restart --only-bro' do
  not_if do ::File.exists?('/nsm/bro/spool/broctl-config.sh') end
  notifies :run, 'execute[deploy_bro]', :immediately
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



##########################
# Purge Rule Stats
##########################

template '/usr/bin/rule_stats_purge' do
  source 'sensor/rule_stats_purge.sh.erb'
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

template '/etc/cron.d/rule-stats-chmod' do
  source 'sensor/cron_rule-stats-chmod.erb'
  owner 'root'
  group 'root'
  mode '0644'
end



