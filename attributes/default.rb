
# This is the account sensors will SSH to 
default[:seconion][:ssh_username] = 'sosystem'

default[:seconion][:ids_engine] = 'snort'

# OINKCODE
# If you're running VRT or ETPRO rulesets, you'll need to supply your
# oinkcode here.
default[:seconion][:vrt_oinkcode] = ''
default[:seconion][:etpro_oinkcode] = ''

default[:seconion][:timezone] = 'Etc/UTC'