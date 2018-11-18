#
# Cookbook Name:: seconion
# Attribute:: bro_scripts
#

##########################
# Disable Base Streams
##########################
# Notes: -Expects the Stream name to disable
#        -setting to false will disable, all other values will ignore the attribute


# Syslog Stream (not disabled by default)
default[:seconion][:sensor][:bro_base_streams][:global]['Syslog::LOG'] = true


##########################
# Load Bro Sigs
##########################

# This adds signatures to detect cleartext forward and reverse windows shells.
default[:seconion][:sensor][:bro_sigs][:global]['frameworks/signatures/detect-windows-shells'] = true


##########################
# Load Bro Scripts
##########################

# This script logs which scripts were loaded during each run.
default[:seconion][:sensor][:bro_scripts][:global]['misc/loaded-scripts'] = true

# Apply the default tuning scripts for common tuning settings.
default[:seconion][:sensor][:bro_scripts][:global]['tuning/defaults'] = true

# Load the scan detection script.
default[:seconion][:sensor][:bro_scripts][:global]['misc/scan'] = true

# Estimate and log capture loss.
default[:seconion][:sensor][:bro_scripts][:global]['misc/capture-loss'] = true

# Enable logging of memory, packet and lag statistics.
default[:seconion][:sensor][:bro_scripts][:global]['misc/stats'] = true

# Detect traceroute being run on the network. This could possibly cause
# performance trouble when there are a lot of traceroutes on your network.
# Enable cautiously.
default[:seconion][:sensor][:bro_scripts][:global]['misc/detect-traceroute'] = false

# Generate notices when vulnerable versions of software are discovered.
# The default is to only monitor software found in the address space defined
# as "local".  Refer to the software framework's documentation for more
# information.
default[:seconion][:sensor][:bro_scripts][:global]['frameworks/software/vulnerable'] = true

# Detect software changing (e.g. attacker installing hacked SSHD).
default[:seconion][:sensor][:bro_scripts][:global]['frameworks/software/version-changes'] = true

# Load all of the scripts that detect software in various protocols.
default[:seconion][:sensor][:bro_scripts][:global]['protocols/ftp/software'] = true
default[:seconion][:sensor][:bro_scripts][:global]['protocols/smtp/software'] = true
default[:seconion][:sensor][:bro_scripts][:global]['protocols/ssh/software'] = true
default[:seconion][:sensor][:bro_scripts][:global]['protocols/http/software'] = true

# The detect-webapps script could possibly cause performance trouble when
# running on live traffic.  Enable it cautiously.
default[:seconion][:sensor][:bro_scripts][:global]['protocols/http/detect-webapps'] = false

# This script detects DNS results pointing toward your Site::local_nets
# where the name is not part of your local DNS zone and is being hosted
# externally.  Requires that the Site::local_zones variable is defined.
default[:seconion][:sensor][:bro_scripts][:global]['protocols/dns/detect-external-names'] = true

# Script to detect various activity in FTP sessions.
default[:seconion][:sensor][:bro_scripts][:global]['protocols/ftp/detect'] = true

# Scripts that do asset tracking.
default[:seconion][:sensor][:bro_scripts][:global]['protocols/conn/known-hosts'] = true
default[:seconion][:sensor][:bro_scripts][:global]['protocols/conn/known-services'] = true
default[:seconion][:sensor][:bro_scripts][:global]['protocols/ssl/known-certs'] = true

# This script enables SSL/TLS certificate validation.
default[:seconion][:sensor][:bro_scripts][:global]['protocols/ssl/validate-certs'] = true

# This script prevents the logging of SSL CA certificates in x509.log
default[:seconion][:sensor][:bro_scripts][:global]['protocols/ssl/log-hostcerts-only'] = true

# Uncomment the following line to check each SSL certificate hash against the ICSI
# certificate notary service; see http://notary.icsi.berkeley.edu .
default[:seconion][:sensor][:bro_scripts][:global]['protocols/ssl/notary'] = false

# If you have libGeoIP support built in, do some geographic detections and
# logging for SSH traffic.
default[:seconion][:sensor][:bro_scripts][:global]['protocols/ssh/geo-data'] = true
# Detect hosts doing SSH bruteforce attacks.
default[:seconion][:sensor][:bro_scripts][:global]['protocols/ssh/detect-bruteforcing'] = true
# Detect logins using "interesting" hostnames.
default[:seconion][:sensor][:bro_scripts][:global]['protocols/ssh/interesting-hostnames'] = true

# Detect SQL injection attacks.
default[:seconion][:sensor][:bro_scripts][:global]['protocols/http/detect-sqli'] = true

#### Network File Handling ####

# Enable MD5 and SHA1 hashing for all files.
default[:seconion][:sensor][:bro_scripts][:global]['frameworks/files/hash-all-files'] = true

# Detect SHA1 sums in Team Cymru's Malware Hash Registry.
default[:seconion][:sensor][:bro_scripts][:global]['frameworks/files/detect-MHR'] = true

# Uncomment the following line to enable detection of the heartbleed attack. Enabling
# this might impact performance a bit.
default[:seconion][:sensor][:bro_scripts][:global]['policy/protocols/ssl/heartbleed'] = false

# Uncomment the following line to enable logging of connection VLANs. Enabling
# this adds two VLAN fields to the conn.log file.
default[:seconion][:sensor][:bro_scripts][:global]['policy/protocols/conn/vlan-logging'] = false

# Uncomment the following line to enable logging of link-layer addresses. Enabling
# this adds the link-layer address for each connection endpoint to the conn.log file.
default[:seconion][:sensor][:bro_scripts][:global]['policy/protocols/conn/mac-logging'] = false

# Uncomment the following line to enable the SMB analyzer.  The analyzer
# is currently considered a preview and therefore not loaded by default.
default[:seconion][:sensor][:bro_scripts][:global]['policy/protocols/smb'] = true

# Security Onion default scripts
default[:seconion][:sensor][:bro_scripts][:global]['securityonion'] = true

# File Extraction
default[:seconion][:sensor][:bro_scripts][:global]['file-extraction'] = false

# Add the base streams disable script
default[:seconion][:sensor][:bro_scripts][:global]['base_streams'] = true

# Intel from Mandiant APT1 Report
default[:seconion][:sensor][:bro_scripts][:global]['apt1'] = false

# You can load your own intel into:
# /opt/bro/share/bro/intel/
default[:seconion][:sensor][:bro_scripts][:global]['intel'] = true

# ShellShock - detects successful exploitation of Bash vulnerability CVE-2014-6271
default[:seconion][:sensor][:bro_scripts][:global]['shellshock'] = true


# Load ETPro IOC's into intel framekwork
default[:seconion][:sensor][:bro_scripts][:global]['etpro'] = false

# Load Certificate Authorities to improve certificate validation
default[:seconion][:sensor][:bro_scripts][:global]['cert_authorities']  = false

# Log urls embedded in email
default[:seconion][:sensor][:bro_scripts][:global]['smtp-embedded-url-bloom'] = false

# Extract high value file types
default[:seconion][:sensor][:bro_scripts][:global]['extractions'] = false

# Add ssl handshake ja3 hash fingerprint to ssl log
default[:seconion][:sensor][:bro_scripts][:global]['ja3'] = false

# Add producer consumer ratio PCR to the conn log
default[:seconion][:sensor][:bro_scripts][:global]['pcr'] = false

# Change default bro config for Scan script
default[:seconion][:sensor][:bro_scripts][:global]['scan_conf'] = false

# Add the peer description to every bro log
default[:seconion][:sensor][:bro_scripts][:global]['peers'] = false



############
# Deprectated in 2.5
############
# Log some information about web applications being used by users
# on your network.
# default[:seconion][:sensor][:bro_scripts][:global]['misc/app-stats'] = true