

# Automate SOUP updates?
default[:seconion][:soup][:enabled] = true
default[:seconion][:soup][:log_path] = '/var/log/nsm/soup.log'
# This is the weekday of the month in cron 1-7, Mon-Sun
# Default is last Wednesday of the Month
default[:seconion][:soup][:last_day_of_month] = '3'
# Hour of the day to start, remember this is UTC
default[:seconion][:soup][:hour] = '17'
# Number of minutes to wait before updating sensors
default[:seconion][:soup][:sensor_delay] = '30'


# Set to cron_overwrite if the last weekday of month method above is not 
# desirable
default[:seconion][:server][:soup][:cron_overwrite] = false
default[:seconion][:server][:soup][:cron][:minute] = '00'
default[:seconion][:server][:soup][:cron][:hour] = '*'
default[:seconion][:server][:soup][:cron][:day_of_month] = '*'
default[:seconion][:server][:soup][:cron][:month_of_year] = '*'
default[:seconion][:server][:soup][:cron][:day_of_week] = '*'

default[:seconion][:sensor][:soup][:cron_overwrite] = false
default[:seconion][:sensor][:soup][:cron][:minute] = '00'
default[:seconion][:sensor][:soup][:cron][:hour] = '*'
default[:seconion][:sensor][:soup][:cron][:day_of_month] = '*'
default[:seconion][:sensor][:soup][:cron][:month_of_year] = '*'
default[:seconion][:sensor][:soup][:cron][:day_of_week] = '*'
