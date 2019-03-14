#
# Cookbook Name:: seconion
# Attribute:: snort_override
#

##########################
# Global
##########################

# Example
#default[:seconion][:sensor][:snort_override][:global]['var EXTERNAL_NET = !$HOME_NET'] = true

 
##########################
# Regional
##########################

# Example
#default[:seconion][:sensor][:snort_override][:regional]['portvar SSH_PORTS [22,222]'] = true

##########################
# Host
##########################

# Example
#default[:seconion][:sensor][:snort_override]['hostname.example.com']['var EXTERNAL_NET = !$HOME_NET'] = true

##########################
# Sensor 
##########################

# Example
#default[:seconion][:sensor][:snort_override]['sensorname']['portvar SSH_PORTS [22,222]'] = true
