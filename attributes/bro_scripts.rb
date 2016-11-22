##########################
# Load Bro Sigs
##########################

# This adds signatures to detect cleartext forward and reverse windows shells.
default[:seconion][:sensor][:bro_sig]['frameworks/signatures/detect-windows-shells'] = true


##########################
# Load Bro Scripts
##########################

# This script logs which scripts were loaded during each run.
default[:seconion][:sensor][:bro_script]['misc/loaded-scripts'] = true

# Apply the default tuning scripts for common tuning settings.
default[:seconion][:sensor][:bro_script]['tuning/defaults'] = true

# Load the scan detection script.
default[:seconion][:sensor][:bro_script]['misc/scan'] = true

# Log some information about web applications being used by users
# on your network.
default[:seconion][:sensor][:bro_script]['misc/app-stats'] = true

# Detect traceroute being run on the network.
default[:seconion][:sensor][:bro_script]['misc/detect-traceroute'] = true

# Generate notices when vulnerable versions of software are discovered.
# The default is to only monitor software found in the address space defined
# as "local".  Refer to the software framework's documentation for more
# information.
default[:seconion][:sensor][:bro_script]['frameworks/software/vulnerable'] = true

# Detect software changing (e.g. attacker installing hacked SSHD).
default[:seconion][:sensor][:bro_script]['frameworks/software/version-changes'] = true

# Load all of the scripts that detect software in various protocols.
default[:seconion][:sensor][:bro_script]['protocols/ftp/software'] = true
default[:seconion][:sensor][:bro_script]['protocols/smtp/software'] = true
default[:seconion][:sensor][:bro_script]['protocols/ssh/software'] = true
default[:seconion][:sensor][:bro_script]['protocols/http/software'] = true
# The detect-webapps script could possibly cause performance trouble when
# running on live traffic.  Enable it cautiously.
default[:seconion][:sensor][:bro_script]['protocols/http/detect-webapps'] = false

# This script detects DNS results pointing toward your Site::local_nets
# where the name is not part of your local DNS zone and is being hosted
# externally.  Requires that the Site::local_zones variable is defined.
default[:seconion][:sensor][:bro_script]['protocols/dns/detect-external-names'] = true

# Script to detect various activity in FTP sessions.
default[:seconion][:sensor][:bro_script]['protocols/ftp/detect'] = true

# Scripts that do asset tracking.
default[:seconion][:sensor][:bro_script]['protocols/conn/known-hosts'] = true
default[:seconion][:sensor][:bro_script]['protocols/conn/known-services'] = true
default[:seconion][:sensor][:bro_script]['protocols/ssl/known-certs'] = true

# This script enables SSL/TLS certificate validation.
default[:seconion][:sensor][:bro_script]['protocols/ssl/validate-certs'] = true

# This script prevents the logging of SSL CA certificates in x509.log
default[:seconion][:sensor][:bro_script]['protocols/ssl/log-hostcerts-only'] = true

# Uncomment the following line to check each SSL certificate hash against the ICSI
# certificate notary service; see http://notary.icsi.berkeley.edu .
default[:seconion][:sensor][:bro_script]['protocols/ssl/notary'] = false

# If you have libGeoIP support built in, do some geographic detections and
# logging for SSH traffic.
default[:seconion][:sensor][:bro_script]['protocols/ssh/geo-data'] = true
# Detect hosts doing SSH bruteforce attacks.
default[:seconion][:sensor][:bro_script]['protocols/ssh/detect-bruteforcing'] = true
# Detect logins using "interesting" hostnames.
default[:seconion][:sensor][:bro_script]['protocols/ssh/interesting-hostnames'] = true

# Detect SQL injection attacks.
default[:seconion][:sensor][:bro_script]['protocols/http/detect-sqli'] = true

#### Network File Handling ####

# Enable MD5 and SHA1 hashing for all files.
default[:seconion][:sensor][:bro_script]['frameworks/files/hash-all-files'] = true

# Detect SHA1 sums in Team Cymru's Malware Hash Registry.
default[:seconion][:sensor][:bro_script]['frameworks/files/detect-MHR'] = true

# Uncomment the following line to enable detection of the heartbleed attack. Enabling
# this might impact performance a bit.
default[:seconion][:sensor][:bro_script]['policy/protocols/ssl/heartbleed'] = false

# Security Onion default scripts
default[:seconion][:sensor][:bro_script]['securityonion'] = true

# File Extraction
default[:seconion][:sensor][:bro_script]['file-extraction'] = false

# Intel from Mandiant APT1 Report
default[:seconion][:sensor][:bro_script]['apt1'] = false

# You can load your own intel into:
# /opt/bro/share/bro/intel/
default[:seconion][:sensor][:bro_script]['intel'] = true

# ShellShock - detects successful exploitation of Bash vulnerability CVE-2014-6271
default[:seconion][:sensor][:bro_script]['shellshock'] = true

# Log urls embedded in email
default[:seconion][:sensor][:bro_script]['smtp-embedded-url-bloom'] = false

# Extract high value file types
default[:seconion][:sensor][:bro_script]['ghc_extraction'] = false

# Load ETPro IOC's into intel framekwork
default[:seconion][:sensor][:bro_script]['etpro'] = false