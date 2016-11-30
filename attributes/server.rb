#
# Cookbook Name:: seconion
# Attribute:: server
#

#########################
# Sguil Server
#########################

# This should be the name/IP of the separate Sguil server:
default[:seconion][:server][:servername] = 'sguilserver.example.com'

# SGUIL_SERVER_NAME
# This is the name of the Sguil server mysql database we'll create.
# You probably shouldn't change this value.
default[:seconion][:server][:sguil_server_name] = 'securityonion'

# SGUIL_CLIENT_USERNAME
# This is the username/password that we'll create
# for Sguil/Squert/ELSA.
default[:seconion][:server][:sguil_client_username] = 'onionuser'
default[:seconion][:server][:sguil_client_password] = 'asdfasdf'


#########################
# NIDS Rules
#########################

# local_nids_rule_tuning = yes
# rule-update will operate on a local copy of the rules instead of downloading rules from the Internet
# local_nids_rule_tuning = no
# rule-update will try to download rules from the Internet
default[:seconion][:server][:local_nids_rule_tuning] = 'no'

# IDS_RULESET
# Which IDS ruleset would you like to use?
# Emerging Threats GPL (no oinkcode required):
# ETGPL
# Emerging Threats PRO (requires ETPRO oinkcode):
# ETPRO
# Sourcefire VRT (requires VRT oinkcode):
# VRT
# VRT and ET (requires VRT oinkcode):
# VRTET
default[:seconion][:server][:ids_rules] = 'ETVRT'


#########################
# Maintenance
#########################

# At what percentage of disk usage should the NSM scripts warn you?
default[:seconion][:server][:warn_disk_usage] = 80

# At what percentage of disk usage should the NSM scripts begin purging old data?
default[:seconion][:server][:crit_disk_usage] = 95

# How many days would you like to keep in the Sguil database archive?
default[:seconion][:server][:days_to_keep] = 30

# How many days worth of tables would you like to repair every day?
default[:seconion][:server][:days_to_repair] = 7

# What is the maximum number of uncategorized events to allow?
# If this number gets too high, then sguild startup may be delayed.
default[:seconion][:server][:uncat_max] = 1000000

