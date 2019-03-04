#
# Cookbook Name:: seconion
# Attribute:: default
#


# This is the account sensors will SSH to 
default[:seconion][:ssh_username] = 'sosystem'

default[:seconion][:ids_engine] = 'snort'

# OINKCODE
# If you're running VRT or ETPRO rulesets, you'll need to supply your
# oinkcode here.
default[:seconion][:vrt_oinkcode] = ''
default[:seconion][:etpro_oinkcode] = ''

default[:seconion][:timezone] = 'Etc/UTC'
default[:seconion][:physical_timezone_offset] = '-07:00'



# Which IDS engine would you like to run?
default[:seconion][:default][:engine] = 'snort'

# How many days would you like to keep in the Sguil database archive?
default[:seconion][:default][:daystokeep] = '30'

# How many days worth of tables would you like to repair every day?
default[:seconion][:default][:daystorepair] = '7'

# At what percentage of disk usage should the NSM scripts warn you?
default[:seconion][:default][:warn_disk_usage] = '80'

# At what percentage of disk usage should the NSM scripts begin purging old data?
default[:seconion][:default][:crit_disk_usage] = '90'

# Do you want to run Bro?  yes/no
default[:seconion][:default][:bro_enabled] = 'yes'

# BRO_USER specifies the user account used to start Bro.
default[:seconion][:default][:bro_user] = 'sguil'
default[:seconion][:default][:bro_group] = 'sguil'

# The OSSEC agent sends OSSEC HIDS alerts into the Sguil database.
# Do you want to run the OSSEC Agent?  yes/no
default[:seconion][:default][:ossec_agent_enabled] = 'yes'

# OSSEC_AGENT_LEVEL specifies the level at which OSSEC alerts are sent to sguild.
default[:seconion][:default][:ossec_agent_level] = '5'

# Xplico is no longer included in Security Onion
default[:seconion][:default][:xplico_enabled] = 'no'

# LOCAL_HIDS_RULE_TUNING
# If set to no (default), this node will copy OSSEC rules from master server as-is (no changes).
# If set to yes, this node will keep its own copy of the OSSEC rules.
default[:seconion][:default][:local_hids_rule_tuning] = 'no'

# LOCAL_NIDS_RULE_TUNING
# The effect of this option is different depending on whether this box is a server or not.
# SERVER
# LOCAL_NIDS_RULE_TUNING=yes
# rule-update will operate on a local copy of the rules instead of downloading rules from the Internet
# LOCAL_NIDS_RULE_TUNING=no
# rule-update will try to download rules from the Internet
# SENSOR-ONLY
# LOCAL_NIDS_RULE_TUNING=yes
# rule-update will copy rules from master server and then try to run PulledPork locally for tuning
# LOCAL_NIDS_RULE_TUNING=no
# rule-update will copy rules from master server as-is (no changes)
default[:seconion][:default][:local_nids_rule_tuning] = 'yes'

# OSSEC_AGENT_USER specifies the user account used to start the OSSEC agent for Sguil.
default[:seconion][:default][:ossec_agent_user] = 'sguil'

# Log size limit (GB) for Elasticsearch logs
default[:seconion][:default][:log_size_limit] = '9'

# Docker options
default[:seconion][:default][:dockernet] = 'so-elastic-net'
default[:seconion][:default][:docker_bridge] = '172.17.0.1/24'

# Elasticsearch options
default[:seconion][:default][:elasticsearch_enabled] = 'yes'
default[:seconion][:default][:elasticsearch_host] = 'localhost'
default[:seconion][:default][:elasticsearch_port] = '9200'
default[:seconion][:default][:elasticsearch_publish_ip] = '127.0.0.1'
default[:seconion][:default][:elasticsearch_options] = ''

# Logstash options
default[:seconion][:default][:logstash_enabled] = 'yes'
default[:seconion][:default][:logstash_host] = 'localhost'
default[:seconion][:default][:logstash_port] = '9600'
default[:seconion][:default][:logstash_publish_ip] = '0.0.0.0'
default[:seconion][:default][:logstash_input_redis] = 'no'
default[:seconion][:default][:logstash_output_redis] = 'no'
default[:seconion][:default][:logstash_options] = ''

# Kibana options
default[:seconion][:default][:kibana_enabled] = 'yes'
default[:seconion][:default][:kibana_dark_theme] = 'yes'
default[:seconion][:default][:kibana_index] = 'kibana'
default[:seconion][:default][:kibana_version] = '6.5.4'
default[:seconion][:default][:kibana_defaultappid] = 'dashboard/94b52620-342a-11e7-9d52-4f090484f59e'
default[:seconion][:default][:kibana_options] = ''

# ElastAlert options
default[:seconion][:default][:elastalert_enabled] = 'yes'
default[:seconion][:default][:elastalert_index] = 'elastalert_status'
default[:seconion][:default][:elastalert_options] = ''

# Curator options
default[:seconion][:default][:curator_enabled] = 'yes'
default[:seconion][:default][:curator_close_days] = '30'
default[:seconion][:default][:curator_options] = ''

# Freq_server default options
default[:seconion][:default][:freq_server_enabled] = 'yes'
default[:seconion][:default][:freq_server_options] = ''

# Domain_stats options
default[:seconion][:default][:domain_stats_enabled] = 'no'
default[:seconion][:default][:domain_stats_options] = ''

# What is the maximum number of uncategorized events to allow?
# If this number gets too high, then sguild startup may be delayed.
default[:seconion][:default][:uncat_max] = '100000'
