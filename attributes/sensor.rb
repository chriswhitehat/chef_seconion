#
# Cookbook Name:: seconion
# Attribute:: sensor
#

# List of sniffing interfaces
default[:seconion][:sensor][:sniffing_interfaces] = []


# Sensor group.  A logical grouping which dictates rolling restarts.
default[:seconion][:sensor][:sensor_group] = 'singleton'

default[:seconion][:sensor][:rule_update_hour][:singleton] = 7
default[:seconion][:sensor][:rule_update_phases][:singleton] = 1
default[:seconion][:sensor][:rule_update_phase_duration][:singleton] = 3600



#########################
# Maintenance
#########################

# At what percentage of disk usage should the NSM scripts warn you?
default[:seconion][:sensor][:warn_disk_usage] = 80

# At what percentage of disk usage should the NSM scripts begin purging old data?
default[:seconion][:sensor][:crit_disk_usage] = 95


################################
# Management Interface
################################
# MGMT_INTERFACE
# Which network interface should be the management interface?
# The management interface has an IP address and is NOT used for sniffing.
# We recommend that you always make this eth0 if possible for consistency.
default[:seconion][:sensor][:mgmt][:configure] = true
default[:seconion][:sensor][:mgmt][:interface] = 'eth0'
default[:seconion][:sensor][:mgmt][:ipv4] = '127.0.0.1'
default[:seconion][:sensor][:mgmt][:netmask] = '255.255.255.0'
default[:seconion][:sensor][:mgmt][:gateway] = '127.0.0.1'
default[:seconion][:sensor][:mgmt][:nameserver] = '127.0.0.1'
default[:seconion][:sensor][:mgmt][:domain] = 'example.com'


#########################
# OSSEC
#########################
default[:seconion][:sensor][:ossec_enabled] = false
default[:seconion][:sensor][:ossec_agent_user] = 'sguil'
default[:seconion][:sensor][:ossec_agent_level] = '5'
default[:seconion][:sensor][:ossec_local_hids_rule_tuning] = 'no'
default[:seconion][:sensor][:ossec_agent_enabled] = 'no'

#########################
# Network IDS
#########################
default[:seconion][:sensor][:ids_engine] = 'snort'


# BRO_USER specifies the user account used to start Bro.
default[:seconion][:sensor][:bro_enabled] = 'yes'
default[:seconion][:sensor][:bro_user] = 'sguil'
default[:seconion][:sensor][:bro_group] = 'sguil'


# The default is 4096.
# High traffic networks may need to increase this.
default[:seconion][:sensor][:pf_ring_slots] = 4096


#####################
# Sniffing Defaults
#####################
# interface to drop into promiscuious mode
default[:seconion][:sensor][:sniff][:interface] = 'eth1'
# interface NUMA node
default[:seconion][:sensor][:sniff][:numa_node] = 0
# mtu for promiscuious nic
default[:seconion][:sensor][:sniff][:mtu] = 1530
# name of sensor in sguil and directory structure
default[:seconion][:sensor][:sniff][:sensorname] = 'sensorname'
# Sensor net group, should be same as sensorname unless breaking down individual services per server.
#default[:seconion][:sensor][:sniff][:sensor_net_group] = 'sensorname'
# homenet definition
default[:seconion][:sensor][:sniff][:homenet] = {'192.168.0.0/16' => 'rfc1918 IP Space',
																									'10.0.0.0/8' => 'rfc1918 IP Space',
																									'172.16.0.0/12' => 'rfc1918 IP Space'
																									}
# enable the ids engine 
default[:seconion][:sensor][:sniff][:ids_engine_enabled] = true
# type of ids engine (snort/suriciata)
default[:seconion][:sensor][:sniff][:ids_engine] = 'snort'
# load balance instances for ids engine
default[:seconion][:sensor][:sniff][:ids_lb_procs] = 1
# enable IDS Numa and CPU affinity
default[:seconion][:sensor][:sniff][:ids_numa_tune] = false
# NUMA CPU affinity mode (numa|increment|range)
default[:seconion][:sensor][:sniff][:ids_numa_cpu_mode] = "increment"
# IDS NUMA pyhsical cpu start 
#    zero based beginning of range to ping lb procs
#    ignored if mode is numa 
default[:seconion][:sensor][:sniff][:ids_numa_cpu] = 0
# IDS NUMA pyhsical cpu step 
#    negative to go in reverse (20,19,...)
#    ignored if mode is numa or range
default[:seconion][:sensor][:sniff][:ids_numa_cpu_step] = 1
# enable squil agent to send ids alerts to server (applies to snort and suricata)
default[:seconion][:sensor][:sniff][:snort_agent_enabled] = true
# choose which search method to use, ac-split (cpu/memory neutral), ac (favor cpu, heavy memory usage)
default[:seconion][:sensor][:sniff][:snort_search_method] = 'ac'
# The max size of the snort unified2 alert file
default[:seconion][:sensor][:sniff][:snort_unified2_size] = 128
# bpf for snort/suricata
default[:seconion][:sensor][:sniff][:ids_bpf] = ''
# barnyard2 sends snort/suricata alerts to the snort agent and other destinations
default[:seconion][:sensor][:sniff][:barnyard2_enabled] = true
# enable the Bro IDS
default[:seconion][:sensor][:sniff][:bro_enabled] = true
# load balance instances for Bro IDS
default[:seconion][:sensor][:sniff][:bro_lb_procs] = 1
# extract files using bro based on mimetypes
default[:seconion][:sensor][:sniff][:bro_extract_files] = false
# bpf for bro
default[:seconion][:sensor][:sniff][:bro_bpf] = ''
# enable BRO Numa and CPU affinity
default[:seconion][:sensor][:sniff][:bro_numa_tune] = false
# BRO NUMA pyhsical cpu start 
#    zero based beginning of range to pin lb procs
default[:seconion][:sensor][:sniff][:bro_numa_cpu] = 0
# enable netsniff-ng full packet capture
default[:seconion][:sensor][:sniff][:pcap_enabled] = true
# enable sguil agent to pull pcaps from the sguil client
default[:seconion][:sensor][:sniff][:pcap_agent_enabled] = true
# how large to make the pcap files in MB
default[:seconion][:sensor][:sniff][:pcap_size] = 150
# how big of a ring buffer for netsniff-ng
default[:seconion][:sensor][:sniff][:pcap_ring_size] = 128
# additional pcap options to be sent to the netsniff-ng command
default[:seconion][:sensor][:sniff][:pcap_options] = '--mmap'
# bpf for pcaps
default[:seconion][:sensor][:sniff][:pcap_bpf] = ''
# enable pcap Numa and CPU affinity
default[:seconion][:sensor][:sniff][:pcap_numa_tune] = false
# pcap NUMA pyhsical cpu single cpu
default[:seconion][:sensor][:sniff][:pcap_numa_cpu] = 2

# This is a convenience variable, copy and paste into sensor recipes.
=begin
template = {
  'interface' => node[:seconion][:sensor][:sniff][:interface],
  'mtu' => node[:seconion][:sensor][:sniff][:mtu],
  'sensorname' => node[:seconion][:sensor][:sniff][:sensorname],
  'homenet' => node[:seconion][:sensor][:sniff][:homenet],
  'ids_engine_enabled' => node[:seconion][:sensor][:sniff][:ids_engine_enabled],
  'ids_engine' => node[:seconion][:sensor][:sniff][:ids_engine],
  'ids_lb_procs' => node[:seconion][:sensor][:sniff][:ids_lb_procs],
  'snort_search_method' => node[:seconion][:sensor][:sniff][:snort_search_method],
  'snort_agent_enabled' => node[:seconion][:sensor][:sniff][:snort_agent_enabled],
  'snort_unified2_size' => node[:seconion][:sensor][:sniff][:snort_unified2_size],
  'ids_bpf' => node[:seconion][:sensor][:sniff][:ids_bpf],
  'barnyard2_enabled' => node[:seconion][:sensor][:sniff][:barnyard2_enabled],
  'bro_enabled' => node[:seconion][:sensor][:sniff][:bro_enabled],
  'bro_lb_procs' => node[:seconion][:sensor][:sniff][:bro_lb_procs],
  'bro_extract_files' => node[:seconion][:sensor][:sniff][:bro_extract_files],
  'bro_bpf' => node[:seconion][:sensor][:sniff][:bro_bpf],
  'pcap_enabled' => node[:seconion][:sensor][:sniff][:pcap_enabled],
  'pcap_agent_enabled' => node[:seconion][:sensor][:sniff][:pcap_agent_enabled],
  'pcap_size' => node[:seconion][:sensor][:sniff][:pcap_size],
  'pcap_ring_size' => node[:seconion][:sensor][:sniff][:pcap_ring_size],
  'pcap_options' => node[:seconion][:sensor][:sniff][:pcap_options],
  'pcap_bpf' => node[:seconion][:sensor][:sniff][:pcap_bpf]
}
=end

#########################
# Network IDS Rules
#########################

# LOCAL_NIDS_RULE_TUNING=yes
# rule-update will copy rules from master server and then try to run PulledPork locally for tuning
# LOCAL_NIDS_RULE_TUNING=no
# rule-update will copy rules from master server as-is (no changes)

default[:seconion][:sensor][:vrt_rules_enabled] = true
default[:seconion][:sensor][:vrtopen_rules_enabled] = false
default[:seconion][:sensor][:etpro_rules_enabled] = true
default[:seconion][:sensor][:etgpl_rules_enabled] = false

default[:seconion][:sensor][:local_nids_rule_tuning] = 'yes'



##########################
# Misc
##########################

# Rotate bro extracted files off after set time
default[:seconion][:sensor][:bro][:extracted][:rotate] = true
default[:seconion][:sensor][:bro][:extracted][:days_to_keep] = 7

