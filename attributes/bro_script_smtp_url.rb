# embedded url script settings
## Ignore HTTP tracking if the links from these domains are seen/clicked, list of domains
default[:seconion][:sensor][:bro_scripts]['smtp-embedded-url-bloom'][:link_already_seen] = ['example.org']
## expects regex
default[:seconion][:sensor][:bro_scripts]['smtp-embedded-url-bloom'][:ignore_site_links] = '/.*\.example\.org\//'
## Careful: Since Bro watches all the emails (including the alerts it sends, this
## can create an Email storm because an alert including a malicious URL can cause another alert email
## ignore email going to these addresses.
default[:seconion][:sensor][:bro_scripts]['smtp-embedded-url-bloom'][:ignore_mails_to] = ["bro-alerts@example.com", "alerts@example.com", "reports@example.com"]
# Ignore emails from the following sender
default[:seconion][:sensor][:bro_scripts]['smtp-embedded-url-bloom'][:ignore_mailfroms] = '/bro@|alerts@|security@|reports/'
### Ignore emails originating from these subnets
## For IP address please use x.y.w.z/32
default[:seconion][:sensor][:bro_scripts]['smtp-embedded-url-bloom'][:ignore_mail_originators] = ['2.3.4.5/24', '3.4.5.6/24']
### ignore further processing on the following file types embedded in the url - too much volume not useful dataset
default[:seconion][:sensor][:bro_scripts]['smtp-embedded-url-bloom'][:ignore_file_types] = '/\.gif$|\.png$|\.jpg$|\.xml$|\.PNG$|\.jpeg$|\.css$/'
## alert on these file types: generates SMTP_WatchedFileType
default[:seconion][:sensor][:bro_scripts]['smtp-embedded-url-bloom'][:suspicious_file_types] = '/\.doc$|\.docx|\.xlsx|\.xls|\.rar$|\.exe$|\.zip$/'
### Alert on text in URI : generates SMTP_Embeded_Malicious_URL
default[:seconion][:sensor][:bro_scripts]['smtp-embedded-url-bloom'][:suspicious_text_in_url] = '/googledoc|googledocs|ph\.ly\/|webs\.com\/|jimdo\.com/'
## Alert on the text in the body of the message: generates
default[:seconion][:sensor][:bro_scripts]['smtp-embedded-url-bloom'][:suspicious_text_in_body] = '/[Pp][Ee][Rr][Ss][Oo][Nn][Aa][Ll] [Ee][Mm][Aa][Ll]|[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]|[Uu][Ss][Ee][Rr] [Nn][Aa][Mm][Ee]|[Uu][Ss][Ee][Rr][Nn][Aa][Mm][Ee]/'