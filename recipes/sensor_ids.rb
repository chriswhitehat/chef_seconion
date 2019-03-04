#
# Cookbook Name:: seconion
# Recipe:: sensor_ids
#

include_recipe 'seconion::sensor_nsmnow'

include_recipe 'seconion::sensor_rules'

if node[:seconion][:sensor][:ids_engine].downcase == 'snort'
	include_recipe 'seconion::sensor_pf_ring'
	include_recipe 'seconion::sensor_snort'
elsif node[:seconion][:sensor][:ids_engine].downcase == 'suricata'
	include_recipe 'seconion::sensor_afpacket'
	include_recipe 'seconion::sensor_suricata'
else
	return





