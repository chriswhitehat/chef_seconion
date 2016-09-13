#
# Cookbook Name:: seconion
# Attribute:: sensor
#
# Copyright 2013, Chef
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#



#########################
# Maintenance
#########################

# At what percentage of disk usage should the NSM scripts warn you?
default['seconion']['sensor']['warn_disk_usage'] = 80

# At what percentage of disk usage should the NSM scripts begin purging old data?
default['seconion']['sensor']['crit_disk_usage'] = 95


################################
# Management Interface
################################
# MGMT_INTERFACE
# Which network interface should be the management interface?
# The management interface has an IP address and is NOT used for sniffing.
# We recommend that you always make this eth0 if possible for consistency.
default['seconion']['sensor']['mgmt']['interface'] = 'eth0'
default['seconion']['sensor']['mgmt']['ipv4'] = '127.0.0.1'
default['seconion']['sensor']['mgmt']['netmask'] = '255.255.255.0'
default['seconion']['sensor']['mgmt']['gateway'] = '127.0.0.1'
default['seconion']['sensor']['mgmt']['nameserver'] = '127.0.0.1'
default['seconion']['sensor']['mgmt']['domain'] = 'example.com'


#########################
# Network IDS
#########################

default['seconion']['sensor']['ids_engine'] = 'snort'


# BRO_USER specifies the user account used to start Bro.
default['seconion']['sensor']['bro_enabled'] = 'yes'
default['seconion']['sensor']['bro_user'] = 'sguil'
default['seconion']['sensor']['bro_group'] = 'sguil'

# Bro Network Configuration File
default['seconion']['sensor']["bro_network"] = [
  {
    'type' => 'standalone',
    'host' => 'localhost',
    'interface' => 'etho0'
  }   
]

# Bro Node Configuration File
default['seconion']['sensor']['bro_broccoli'] = [
  {
    'debug_messages' => 'yes',
    'debug_calltrace' => 'yes',
    'use_ssl' => 'yes',
    'ca_cert' => '<path>/ca_cert.pem'
    'host_cert' => '<path>/bro_cert.pem'
    'host_pass' =>
  }
]
# The default is 4096.
# High traffic networks may need to increase this.
default['seconion']['sensor']['pf_ring_slots'] = 4096

# The list of sensor definitions to apply to the hosts interfaces
default['seconion']['sensor']['sniffing_interfaces'] = [
  {
    # interface to drop into promiscuious mode
    'interface' => 'eth1',
    # mtu for promiscuious nic
    'mtu' => '1530',
    # name of sensor in sguil and directory structure
    'sensorname' => 'sowan',
    # enable the ids engine 
    'ids_engine_enabled' => true,
    # type of ids engine (snort/suriciata)
    'ids_engine' => 'snort',
    # load balance instances for ids engine
    'ids_lb_procs' => 1,
    # enable squil agent to send ids alerts to server (applies to snort and suricata)
    'snort_agent_enabled' => true,
    # barnyard2 sends snort/suricata alerts to the snort agent and other destinations
    'barnyard2_enabled' => true,
    # enable the Bro IDS
    'bro_enabled' => true,
    # load balance instances for Bro IDS
    'bro_lb_procs' => 1,
    # extract files using bro based on mimetypes
    'bro_extract_files' => false,
    # enable netsniff-ng full packet capture
    'pcap_enabled' => true,
    # enable sguil agent to pull pcaps from the sguil client
    'pcap_agent_enabled' => true,
    # how large to make the pcap files in MB
    'pcap_size' => 150,
    # how big of a ring buffer for netsniff-ng
    'pcap_ring_size' => 128,
    # additional pcap options to be sent to the netsniff-ng command
    'pcap_options' => '--mmap'
  }]

#########################
# Network IDS Rules
#########################

# LOCAL_NIDS_RULE_TUNING=yes
# rule-update will copy rules from master server and then try to run PulledPork locally for tuning
# LOCAL_NIDS_RULE_TUNING=no
# rule-update will copy rules from master server as-is (no changes)
default['seconion']['sensor']['local_nids_rule_tuning'] = 'yes'

