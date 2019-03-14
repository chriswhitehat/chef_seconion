
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


##########################
# Replace existing rule-update
##########################
template '/usr/sbin/rule-update' do
  source 'nsmnow/rule-update.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

##########################
# Replace existing nsmnow scripts
##########################
template '/usr/sbin/nsm_sensor_ps-start' do
  source 'nsmnow/nsm_sensor_ps-start.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

template '/usr/sbin/nsm_sensor_ps-restart' do
  source 'nsmnow/nsm_sensor_ps-restart.erb'
  owner 'root'
  group 'root'
  mode '0755'
end




##########################
# Add rule update with hard
# restart
##########################
template '/usr/sbin/rule-update-hard' do
  source 'rule-update/rule-update-hard.erb'
  mode '0755'
  owner 'root'
  group 'root'
end


cron_d 'rule-update' do
  shell '/bin/sh'
  path '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
  minute '01'
  hour node[:seconion][:sensor][:restart_hour]
  command "/bin/sleep #{node[:seconion][:sensor][:restart_splay]}; /usr/sbin/rule-update-hard > /dev/null 2>&1"
  only_if node[:seconion][:sensor][:sniff][:ids_engine_enabled]
end


##########################
# Add nsm_sensor_ps-rolling-restart
##########################
template '/usr/sbin/nsm_sensor_ps-rolling-restart' do
  source 'nsmnow/nsm_sensor_ps-rolling-restart.erb'
  mode '0755'
  owner 'root'
  group 'root'
end



##########################
# Add nsm_sensor_ps-hard-restart
##########################
template '/usr/sbin/nsm_sensor_ps-watch-snort_agent' do
  source 'nsmnow/nsm_sensor_ps-watch-snort_agent.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

cron_d 'watch-snort-agent' do
  shell '/bin/sh'
  path '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
  minute (node[:seconion][:sensor][:order] % 15).to_s.rjust(2, "0") + "/15"
  hour "12-23"
  command "/usr/bin/python /usr/sbin/nsm_sensor_ps-watch-snort_agent > /dev/null 2>&1"
  only_if node[:seconion][:sensor][:sniff][:ids_engine_enabled]
end



##########################
# Add nsm_sensor_ps-hard-restart
##########################
template '/usr/sbin/nsm_sensor_ps-hard-restart' do
  source 'nsmnow/nsm_sensor_ps-hard-restart.erb'
  mode '0755'
  owner 'root'
  group 'root'
end


min = 0
['sancp-agent', 'http-agent', 'ossec-agent', 'pads-agent', 'pcap-agent', 'snort-agent', 'barnyard2'].each do |component|
  cron_d "sensor-daily#{min}-#{component}" do
    shell '/bin/sh'
    path '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
    minute min
    hour "12"
    command "/usr/sbin/nsm_sensor_ps-restart --only-#{component} >/dev/null"
    only_if node[:seconion][:sensor][:sniff][:ids_engine_enabled]
  end

  min+=1
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
  notifies :run, 'execute[so-stop]', :before
end




sensortab = ""

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
end
