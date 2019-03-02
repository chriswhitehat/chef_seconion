#
# Cookbook Name:: seconion
# Recipe:: commands
#

execute 'nsm_sensor_ps-stop' do
  command "nsm_sensor_ps-stop"
  action :nothing
  ignore_failure true
end


execute 'initial_soup' do
  command 'soup -y'
  action :nothing
  notifies :reboot_now, 'reboot[now]', :immediately
end

reboot 'now' do
  action :nothing
  reason 'Cannot continue Chef run without a reboot.'
  delay_mins 2
end

execute 'deploy_bro' do
  command "/opt/bro/bin/broctl deploy"
  action :nothing
end

execute 'run_rule-update' do
  command "rule-update"
  action :nothing
  notifies :run, 'execute[nsm_restart]', :delayed
end

execute 'nsm_start' do
  command 'nsm --all --start'
  action :nothing
end

execute 'nsm_stop' do
  command 'nsm --all --stop'
  action :nothing
end

execute 'nsm_restart' do
  command 'nsm --all --restart'
  action :nothing
end

execute 'nsm_status' do
  command 'nsm --all --status'
  action :nothing
end

service 'ossec-hids-server' do
  supports :restart => true
  action :nothing
end

execute 'restart_ossec_agent' do
  command '/usr/sbin/nsm_sensor_ps-restart --only-ossec-agent'
  action :nothing
end

execute 'kibana_restart' do
  command 'so-kibana-restart'
  action :nothing
end

execute 'elasticsearch_restart' do
  command 'so-elastic-restart'
  action :nothing
end

execute 'so-allow' do
  action :nothing
end

execute 'so-allow-elastic' do
  action :nothing
end

execute 'so-allow-view' do
  action :nothing
end

execute 'so-allow-view-iptables' do
  action :nothing
end

execute 'so-apache-auth-sguil' do
  action :nothing
end

execute 'so-apt-check' do
  action :nothing
end

execute 'so-autossh-restart' do
  action :nothing
end

execute 'so-autossh-start' do
  action :nothing
end

execute 'so-autossh-status' do
  action :nothing
end

execute 'so-autossh-stop' do
  action :nothing
end

execute 'so-barnyard-restart' do
  action :nothing
end

execute 'so-barnyard-start' do
  action :nothing
end

execute 'so-barnyard-status' do
  action :nothing
end

execute 'so-barnyard-stop' do
  action :nothing
end

execute 'so-boot' do
  action :nothing
end

execute 'so-bro-cron' do
  action :nothing
end

execute 'so-bro-restart' do
  action :nothing
end

execute 'so-bro-start' do
  action :nothing
end

execute 'so-bro-status' do
  action :nothing
end

execute 'so-bro-stop' do
  action :nothing
end

execute 'so-clear-backlog' do
  action :nothing
end

execute 'so-common' do
  action :nothing
end

execute 'so-common-status' do
  action :nothing
end

execute 'so-crossclustercheck' do
  action :nothing
end

execute 'so-curator-closed-delete' do
  action :nothing
end

execute 'so-curator-closed-delete-delete' do
  action :nothing
end

execute 'so-curator-restart' do
  action :nothing
end

execute 'so-curator-start' do
  action :nothing
end

execute 'so-curator-status' do
  action :nothing
end

execute 'so-curator-stop' do
  action :nothing
end

execute 'so-desktop-gnome' do
  action :nothing
end

execute 'so-disallow' do
  action :nothing
end

execute 'so-domainstats-restart' do
  action :nothing
end

execute 'so-domainstats-start' do
  action :nothing
end

execute 'so-domainstats-status' do
  action :nothing
end

execute 'so-domainstats-stop' do
  action :nothing
end

execute 'so-elastalert-create' do
  action :nothing
end

execute 'so-elastalert-create-whiptail' do
  action :nothing
end

execute 'so-elastalert-restart' do
  action :nothing
end

execute 'so-elastalert-start' do
  action :nothing
end

execute 'so-elastalert-status' do
  action :nothing
end

execute 'so-elastalert-stop' do
  action :nothing
end

execute 'so-elastalert-test' do
  action :nothing
end

execute 'so-elastic-clear-queue' do
  action :nothing
end

execute 'so-elastic-common' do
  action :nothing
end

execute 'so-elastic-configure' do
  action :nothing
end

execute 'so-elastic-configure-apache' do
  action :nothing
end

execute 'so-elastic-configure-bro' do
  action :nothing
end

execute 'so-elastic-configure-cron' do
  action :nothing
end

execute 'so-elastic-configure-curator' do
  action :nothing
end

execute 'so-elastic-configure-curator-close' do
  action :nothing
end

execute 'so-elastic-configure-curator-delete' do
  action :nothing
end

execute 'so-elastic-configure-disable-elsa' do
  action :nothing
end

execute 'so-elastic-configure-elastalert' do
  action :nothing
end

execute 'so-elastic-configure-kibana' do
  action :nothing
end

execute 'so-elastic-configure-kibana-config' do
  action :nothing
end

execute 'so-elastic-configure-kibana-dashboards' do
  action :nothing
end

execute 'so-elastic-configure-kibana-dashboards-dark' do
  action :nothing
end

execute 'so-elastic-configure-kibana-dashboards-light' do
  action :nothing
end

execute 'so-elastic-configure-kibana-logrotate' do
  action :nothing
end

execute 'so-elastic-configure-kibana-shortcuts' do
  action :nothing
end

execute 'so-elastic-configure-log-size' do
  action :nothing
end

execute 'so-elastic-configure-network' do
  action :nothing
end

execute 'so-elastic-configure-stack' do
  action :nothing
end

execute 'so-elastic-configure-syslog-ng' do
  action :nothing
end

execute 'so-elastic-configure-ufw' do
  action :nothing
end

execute 'so-elastic-diagnose' do
  action :nothing
end

execute 'so-elastic-download' do
  action :nothing
end

execute 'so-elastic-final-text' do
  action :nothing
end

execute 'so-elastic-network' do
  action :nothing
end

execute 'so-elastic-remove' do
  action :nothing
end

execute 'so-elastic-reset' do
  action :nothing
end

execute 'so-elastic-restart' do
  action :nothing
end

execute 'so-elasticsearch-node-list' do
  action :nothing
end

execute 'so-elasticsearch-node-remove' do
  action :nothing
end

execute 'so-elasticsearch-restart' do
  action :nothing
end

execute 'so-elasticsearch-start' do
  action :nothing
end

execute 'so-elasticsearch-status' do
  action :nothing
end

execute 'so-elasticsearch-stop' do
  action :nothing
end

execute 'so-elasticsearch-template-add' do
  action :nothing
end

execute 'so-elasticsearch-template-create' do
  action :nothing
end

execute 'so-elasticsearch-template-list' do
  action :nothing
end

execute 'so-elasticsearch-template-remove' do
  action :nothing
end

execute 'so-elastic-settings' do
  action :nothing
end

execute 'so-elastic-start' do
  action :nothing
end

execute 'so-elastic-stats' do
  action :nothing
end

execute 'so-elastic-status' do
  action :nothing
end

execute 'so-elastic-stop' do
  action :nothing
end

execute 'so-elsa-export' do
  action :nothing
end

execute 'so-email' do
  action :nothing
end

execute 'so-freqserver-restart' do
  action :nothing
end

execute 'so-freqserver-start' do
  action :nothing
end

execute 'so-freqserver-status' do
  action :nothing
end

execute 'so-freqserver-stop' do
  action :nothing
end

execute 'so-import-pcap' do
  action :nothing
end

execute 'so-iso-boot' do
  action :nothing
end

execute 'so-iso-build' do
  action :nothing
end

execute 'so-kibana-reload' do
  action :nothing
end

execute 'so-kibana-restart' do
  action :nothing
end

execute 'so-kibana-start' do
  action :nothing
end

execute 'so-kibana-status' do
  action :nothing
end

execute 'so-kibana-stop' do
  action :nothing
end

execute 'so-logstash-restart' do
  action :nothing
end

execute 'so-logstash-start' do
  action :nothing
end

execute 'so-logstash-status' do
  action :nothing
end

execute 'so-logstash-stop' do
  action :nothing
end

execute 'so-netsniff-ng-cron' do
  action :nothing
end

execute 'so-nids-agent-restart' do
  action :nothing
end

execute 'so-nids-agent-start' do
  action :nothing
end

execute 'so-nids-agent-status' do
  action :nothing
end

execute 'so-nids-agent-stop' do
  action :nothing
end

execute 'so-nids-restart' do
  action :nothing
end

execute 'so-nids-start' do
  action :nothing
end

execute 'so-nids-status' do
  action :nothing
end

execute 'so-nids-stop' do
  action :nothing
end

execute 'so-nsm-common' do
  action :nothing
end

execute 'so-nsm-watchdog' do
  action :nothing
end

execute 'so-ossec-agent-restart' do
  action :nothing
end

execute 'so-ossec-agent-start' do
  action :nothing
end

execute 'so-ossec-agent-status' do
  action :nothing
end

execute 'so-ossec-agent-stop' do
  action :nothing
end

execute 'so-ossec-restart' do
  action :nothing
end

execute 'so-ossec-start' do
  action :nothing
end

execute 'so-ossec-status' do
  action :nothing
end

execute 'so-ossec-stop' do
  action :nothing
end

execute 'so-pcap-agent-restart' do
  action :nothing
end

execute 'so-pcap-agent-start' do
  action :nothing
end

execute 'so-pcap-agent-status' do
  action :nothing
end

execute 'so-pcap-agent-stop' do
  action :nothing
end

execute 'so-pcap-restart' do
  action :nothing
end

execute 'so-pcap-start' do
  action :nothing
end

execute 'so-pcap-status' do
  action :nothing
end

execute 'so-pcap-stop' do
  action :nothing
end

execute 'so-purge-old-kernels' do
  action :nothing
end

execute 'so-redis-restart' do
  action :nothing
end

execute 'so-redis-start' do
  action :nothing
end

execute 'so-redis-status' do
  action :nothing
end

execute 'so-redis-stop' do
  action :nothing
end

execute 'so-replay' do
  action :nothing
end

execute 'so-restart' do
  action :nothing
end

execute 'so-sensor-backup-config' do
  action :nothing
end

execute 'so-sensor-restart' do
  action :nothing
end

execute 'so-sensor-start' do
  action :nothing
end

execute 'so-sensor-status' do
  action :nothing
end

execute 'so-sensor-stop' do
  action :nothing
end

execute 'so-server-backup-config' do
  action :nothing
end

execute 'so-sguild-restart' do
  action :nothing
end

execute 'so-sguild-start' do
  action :nothing
end

execute 'so-sguild-status' do
  action :nothing
end

execute 'so-sguild-stop' do
  action :nothing
end

execute 'so-squert-ip2c' do
  action :nothing
end

execute 'so-squert-ip2c-5min' do
  action :nothing
end

execute 'so-start' do
  action :nothing
end

execute 'so-status' do
  action :nothing
end

execute 'so-stop' do
  action :nothing
end

execute 'so-test' do
  action :nothing
end

execute 'so-test-configure-bro' do
  action :nothing
end

execute 'so-user-add' do
  action :nothing
end

execute 'so-user-disable' do
  action :nothing
end

execute 'so-user-list' do
  action :nothing
end

execute 'so-user-passwd' do
  action :nothing
end



