
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
# Add nsm_sensor_ps-hard-restart
##########################
template '/usr/sbin/nsm_sensor_ps-hard-restart' do
  source 'nsmnow/nsm_sensor_ps-hard-restart.erb'
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


##########################
# Add rule update with hard
# restart
##########################
template '/usr/sbin/rule-update-hard' do
  source 'nsmnow/rule-update-hard.erb'
  mode '0755'
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
  source 'nsmnow/nsm_sensor_ps-rolling-restart.erb'
  mode '0755'
  owner 'root'
  group 'root'
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

if node[:seconion][:sensor][:sniffing_interfaces]

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
end
