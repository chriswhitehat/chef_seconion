#
# Cookbook Name:: seconion
# Attribute:: bro_base_streams
#

# The following attributes control base streams in Bro. E.g. Disable Syslog

# Disable Syslog Stream
default[:seconion][:sensor][:bro_base_streams][:global]['base/protocols/syslog'] = false
