#!/bin/bash
#
# Copyright (C) 2008-2009 SecurixLive   <dev@securixlive.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License Version 2 as
# published by the Free Software Foundation.  You may not use, modify or
# distribute this program under any other version of the GNU General
# Public License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#

# Modified by Doug Burks for Security Onion

#
# INCLUDES
#
INC="/etc/nsm/administration.conf"
. $INC

. $NSM_LIB_DIR/lib-console-utils
. $NSM_LIB_DIR/lib-nsm-common-utils
. $NSM_LIB_DIR/lib-nsm-sensor-utils

#
# USAGE
#
print_usage()
{
	echo 
	echo "The NSMnow Administration scripts come with ABSOLUTELY NO WARRANTY."
	echo 
	echo "Usage: $0 [options]"
	echo
	echo "Options:"
	echo "    -d         Use dialog mode"
	echo "    -y         Force yes"
	echo "    -V         Show version information"
	echo "    -?         Show usage information"
	echo 
	echo "Long Options: "
	echo "    --sensor-name=<name>             Define specific sensor <name> to process"
	echo "    --only-barnyard2                 Only process barnyard2"
	echo "    --only-snort-alert               Only process snort alert"
	echo "    --only-pcap                      Only process packet logger"
	echo "    --only-argus                     Only process argus"
        echo "    --only-prads                     Only process prads"
        echo "    --only-bro                       Only process bro"
	echo
	echo "    --only-pcap-agent                Only process pcap_agent"
	echo "    --only-sancp-agent               Only process sancp_agent"
	echo "    --only-snort-agent               Only process snort_agent"
	echo "    --only-http-agent                Only process http_agent"
        echo "    --only-pads-agent                Only process pads_agent"
        echo "    --only-ossec-agent               Only process ossec_agent"
	echo
	echo "    --skip-barnyard2                 Skip processing of barnyard2"
	echo "    --skip-snort-alert               Skip processing of snort alert"
	echo "    --skip-pcap                      Skip processing of packet logger"
	echo "    --skip-argus                     Skip processing of argus"
        echo "    --skip-prads                     Skip processing of prads"
        echo "    --skip-bro                       Skip processing of bro"
	echo
	echo "    --skip-pcap-agent                Skip processing of pcap_agent"
	echo "    --skip-sancp-agent               Skip processing of sancp_agent"
	echo "    --skip-snort-agent               Skip processing of snort_agent"
	echo "    --skip-http-agent                Skip processing of http_agent"
        echo "    --skip-pads-agent                Skip processing of pads_agent"
        echo "    --skip-ossec-agent               Skip processing of ossec_agent"
	echo
	echo "    --if-stale                       Only restart processes that have crashed"
	echo "    --dialog                         Same as -d"
	echo "    --force-yes                      Same as -y"
	echo
	echo "    --version                        Same as -V"
	echo "    --help                           Same as -?"
	echo 
}

# script specific variables
PROMPT_SCRIPT="Restart Sensor"
PROMPT_MODE=cli
FORCE_YES=""
ACTION="process_restart"
ACTION_PCAP="process_restart_with_overlap"

# sensor specific variables
SENSOR_NAME=""
SENSOR_INTERFACE=""
SENSOR_SERVER_HOST=""
SENSOR_SERVER_PORT=""
SENSOR_BY_PORT=""
SENSOR_NET_GROUP=""
SENSOR_VLAN_TAGGING=""
SENSOR_AUTO=""

PROCESS_LOG_DIR="/var/log/nsm"
PROCESS_PID_DIR="/var/run/nsm"

# processing specific variables
SKIP_INVERT=""
SKIP_SNORT_ALERT=""
SKIP_PCAP=""
SKIP_ARGUS=""
SKIP_PRADS=""
SKIP_BRO=""
SKIP_BARNYARD2=""
SKIP_SNORT_AGENT=""
SKIP_HTTP_AGENT=""
SKIP_SANCP_AGENT=""
SKIP_PCAP_AGENT=""
SKIP_PADS_AGENT=""
SKIP_OSSEC_AGENT=""

# extract necessary pre-check arguments from the commandline
while [ "$#" -gt 0 ]
do
	case $1 in
		"-d" | "--dialog")
			PROMPT_MODE=dialog
			;;
		"-y" | "--force-yes")
			FORCE_YES=yes
			;;
		"-?" | "--help")
			SHOW_HELP_ONLY=yes
			;;
		"-V" | "--version")
			SHOW_VERSION_ONLY=yes
			;;
		--if-stale)
			ACTION="process_restart_if_stale"
			ACTION_PCAP="process_restart_if_stale"
			;;
		--sensor-name*)
			SENSOR_NAME="$SENSOR_NAME $(echo $1 | cut -d "=" -f 2)"
			SKIP_BRO=yes
			SKIP_OSSEC_AGENT=yes
			;;
		--only-barnyard2)
			SKIP_INVERT=yes
			SKIP_BARNYARD2=yes
			;;
		--only-snort-alert)
			SKIP_INVERT=yes
			SKIP_SNORT_ALERT=yes
			;;
		--only-pcap)
			SKIP_INVERT=yes
			SKIP_PCAP=yes
			;;
		--only-argus)
			SKIP_INVERT=yes
			SKIP_ARGUS=yes
			;;
		--only-prads)
			SKIP_INVERT=yes
            		SKIP_PRADS=yes
            		;;
		--only-bro)
			SKIP_INVERT=yes
            		SKIP_BRO=yes
            		;;
		--only-pcap-agent)
			SKIP_INVERT=yes
			SKIP_PCAP_AGENT=yes
			;;
		--only-sancp-agent)
			SKIP_INVERT=yes
			SKIP_SANCP_AGENT=yes
			;;
		--only-snort-agent)
			SKIP_INVERT=yes
			SKIP_SNORT_AGENT=yes
			;;
		--only-http-agent)
			SKIP_INVERT=yes
			SKIP_HTTP_AGENT=yes
			;;
		--only-pads-agent)
			SKIP_INVERT=yes
            		SKIP_PADS_AGENT=yes
            		;;
		--only-ossec-agent)
			SKIP_INVERT=yes
            		SKIP_OSSEC_AGENT=yes
            		;;
		--skip-barnyard2)
			SKIP_BARNYARD2=yes
			;;
		--skip-snort-alert)
			SKIP_SNORT_ALERT=yes
			;;
		--skip-pcap)
			SKIP_PCAP=yes
			;;
		--skip-argus)
			SKIP_ARGUS=yes
			;;
		--skip-prads)
            		SKIP_PRADS=yes
            		;;
		--skip-bro)
            		SKIP_BRO=yes
            		;;
		--skip-pcap-agent)
			SKIP_PCAP_AGENT=yes
			;;
		--skip-sancp-agent)
			SKIP_SANCP_AGENT=yes
			;;
		--skip-snort-agent)
			SKIP_SNORT_AGENT=yes
			;;
		--skip-http-agent)
			SKIP_HTTP_AGENT=yes
			;;
		--skip-pads-agent)
            		SKIP_PADS_AGENT=yes
            		;;
		--skip-ossec-agent)
            		SKIP_OSSEC_AGENT=yes
            		;;
		--server*)
			# any server directive is clearly meant for the server
			exit 0
			;;
        *)
			echo_error_msg 0 "OOPS: Unknown option \"${1}\" found!"
			print_usage
			exit 1
            ;;
	esac
	shift
done

# check for help or version requests
if [ -n "$SHOW_HELP_ONLY" ]
then
	print_usage
	exit 0
elif [ -n "$SHOW_VERSION_ONLY" ]
then
	print_version
	exit 0
fi

# ensure we are root user before continuing any further
is_root
if [ "$?" -ne 0 ]
then
	echo_error_msg 0 "OOPS: Must be root to run this script!"
	exit 1
fi

# sanity check what sensors we are using
if [ -z "$SENSOR_NAME" ]
then
	SENSOR_NAME=$(sensortab_names_get_on_auto "1")
fi
	
# invert skip as appropriate
if [ -n "$SKIP_INVERT" ]
then
	[ -z "$SKIP_PCAP_AGENT" ]	&& SKIP_PCAP_AGENT=yes		|| SKIP_PCAP_AGENT=""
	[ -z "$SKIP_SANCP_AGENT" ]	&& SKIP_SANCP_AGENT=yes	|| SKIP_SANCP_AGENT=""
	[ -z "$SKIP_SNORT_AGENT" ]	&& SKIP_SNORT_AGENT=yes	|| SKIP_SNORT_AGENT=""
	[ -z "$SKIP_HTTP_AGENT" ]	&& SKIP_HTTP_AGENT=yes		|| SKIP_HTTP_AGENT=""
	[ -z "$SKIP_PADS_AGENT" ]	&& SKIP_PADS_AGENT=yes		|| SKIP_PADS_AGENT=""
	[ -z "$SKIP_OSSEC_AGENT" ]	&& SKIP_OSSEC_AGENT=yes	|| SKIP_OSSEC_AGENT=""
	[ -z "$SKIP_SNORT_ALERT" ]	&& SKIP_SNORT_ALERT=yes	|| SKIP_SNORT_ALERT=""
	[ -z "$SKIP_BARNYARD2" ]	&& SKIP_BARNYARD2=yes		|| SKIP_BARNYARD2=""
	[ -z "$SKIP_PCAP" ]		&& SKIP_PCAP=yes		|| SKIP_PCAP=""
	[ -z "$SKIP_ARGUS" ]		&& SKIP_ARGUS=yes		|| SKIP_ARGUS=""
	[ -z "$SKIP_PRADS" ]		&& SKIP_PRADS=yes		|| SKIP_PRADS=""
	[ -z "$SKIP_BRO" ]		&& SKIP_BRO=yes		|| SKIP_BRO=""
fi

#
# RESTART
#

# Bro and OSSEC agent need to exist outside of the for-loop

# check for variables in /etc/nsm/securityonion.conf
SO_CONF="/etc/nsm/securityonion.conf"
			
# default values (can override in $SO_CONF)
OSSEC_AGENT_ENABLED="yes"
BRO_ENABLED="yes"

# add parameters to $SO_CONF if they don't already exist
grep OSSEC_AGENT_ENABLED $SO_CONF >/dev/null	|| echo "OSSEC_AGENT_ENABLED=yes" 	>> $SO_CONF
grep BRO_ENABLED $SO_CONF >/dev/null 		|| echo "BRO_ENABLED=yes" 		>> $SO_CONF
if ! grep OSSEC_AGENT_LEVEL $SO_CONF >/dev/null; then
	echo >> $SO_CONF
	echo "# OSSEC_AGENT_LEVEL specifies the level at which OSSEC alerts are sent to sguild." >> $SO_CONF
	echo "OSSEC_AGENT_LEVEL=5" 	>> $SO_CONF
fi
if ! grep OSSEC_AGENT_USER $SO_CONF >/dev/null; then
        echo >> $SO_CONF
        echo "# OSSEC_AGENT_USER specifies the user account used to start the OSSEC agent for Sguil." >> $SO_CONF
        echo "OSSEC_AGENT_USER=sguil"      >> $SO_CONF
fi
if ! grep BRO_USER $SO_CONF >/dev/null; then         
        echo >> $SO_CONF
        echo "# BRO_USER specifies the user account used to start Bro." >> $SO_CONF
        echo "BRO_USER=sguil"      >> $SO_CONF
        echo "BRO_GROUP=sguil"      >> $SO_CONF
fi

# load in user config
. $SO_CONF

if [ "$OSSEC_AGENT_ENABLED" == "yes" ] && [ -z "$SKIP_OSSEC_AGENT" ]; then

        [ "$ACTION" == "process_restart" ] && echo_msg 0 "Restarting: HIDS"

	OSSEC_AGENT_CONF="/etc/nsm/ossec/ossec_agent.conf"

	# NSM scripts expect spawned processes to NOT daemonize
	sed -i 's|set DAEMON 1|set DAEMON 0|g' $OSSEC_AGENT_CONF

	# Fix default domain
	if grep "set DEFAULT_DNS_DOMAIN test.com" $OSSEC_AGENT_CONF >/dev/null 2>&1; then 
		# in case /etc/resolv.conf doesn't contain any search directives, fall back to localdomain
		DOMAIN="localdomain"
		grep "^search " /etc/resolv.conf >/dev/null 2>&1 && DOMAIN=$(grep "^search " /etc/resolv.conf | tail -1 | awk '{print $2}')
		sed -i "s|set DEFAULT_DNS_DOMAIN test.com|set DEFAULT_DNS_DOMAIN $DOMAIN|g" $OSSEC_AGENT_CONF
	fi

        # Add USE_DNS to ossec_agent.conf
        if ! grep USE_DNS $OSSEC_AGENT_CONF >/dev/null; then
	        echo >> $OSSEC_AGENT_CONF
        	echo "# Do you want to enable DNS lookups?" >> $OSSEC_AGENT_CONF
        	echo "# USE_DNS 1 - hostnames will be converted to IP via DNS" >> $OSSEC_AGENT_CONF
        	echo "# USE_DNS 0 - hostnames will be replaced with 0.0.0.0" >> $OSSEC_AGENT_CONF
        	echo "set USE_DNS 0" >> $OSSEC_AGENT_CONF
	fi

        # Add OSSEC_AGENT_USER to ossec group
        adduser $OSSEC_AGENT_USER ossec 2>&1 >/dev/null

        $ACTION "/usr/bin/ossec_agent.tcl" "-o -f /var/ossec/logs/alerts/alerts.log -i 127.0.0.1 -p $OSSEC_AGENT_LEVEL -c $OSSEC_AGENT_CONF" "$PROCESS_PID_DIR/ossec_agent.pid" "$PROCESS_LOG_DIR/ossec_agent.log" "ossec_agent (sguil)" "$OSSEC_AGENT_USER"

fi

if [ "$BRO_ENABLED" == "yes" ] && [ -z "$SKIP_BRO" ] && [ "$ACTION" == "process_restart" ] && grep -v "^#" /etc/nsm/sensortab>/dev/null ; then
        echo_msg 0 "Restarting: Bro"

        # If Bro is in cluster mode, replace IP address with "localhost"
        if grep "^type=manager$" /opt/bro/etc/node.cfg >/dev/null 2>&1; then
                #IP=`ifconfig |grep "inet addr" | awk '{print $2}' |cut -d\: -f2 |grep -v "127.0.0.1" |head -1`
                sed -i "s|^host=.*$|host=localhost|g" /opt/bro/etc/node.cfg
        fi
	
        # Stop Bro as root in case it was previously running as root
	/opt/bro/bin/broctl stop 2>&1 | grep -v "warning: new bro version detected"

        # set ownership of Bro directories
	chown -R $BRO_USER:$BRO_GROUP /nsm/bro/logs /nsm/bro/spool >/dev/null 2>&1
	chown $BRO_USER:$BRO_GROUP /nsm/bro/extracted >/dev/null 2>&1

        # set capabilities on Bro binaries
        setcap cap_net_raw,cap_net_admin=eip /opt/bro/bin/bro
        setcap cap_net_raw,cap_net_admin=eip /opt/bro/bin/capstats

	# update Dir settings if Bro 2.4 was a fresh installation
	sed -i 's|SpoolDir = /opt/bro/spool|SpoolDir = /nsm/bro/spool|g' /opt/bro/etc/broctl.cfg
	sed -i 's|LogDir = /opt/bro/logs|LogDir = /nsm/bro/logs|g' /opt/bro/etc/broctl.cfg

        # Update Bro config
        su $BRO_USER -c '/opt/bro/bin/broctl install' 2>&1 | grep -v "warning: new bro version detected"

	# Start Bro
        su $BRO_USER -c '/opt/bro/bin/broctl start' 2>&1 | grep -v "warning: new bro version detected"
fi

for SENSOR in $SENSOR_NAME
do

	[ "$ACTION" == "process_restart" ] && echo_msg 0 "Restarting: ${SENSOR}"

	# check for sensor configuration file
	SENSOR_CONF="/etc/nsm/$SENSOR/sensor.conf"
	if [ ! -f "$SENSOR_CONF" ]
	then
		echo_error_msg 1 "sensor does not exist!"
		exit 1
	fi
				
	# default values (can override in $SENSOR_CONF)
	PCAP_ENABLED="yes"
	PCAP_AGENT_ENABLED="yes"
	SNORT_AGENT_ENABLED="yes"
	IDS_ENGINE_ENABLED="yes"
	BARNYARD2_ENABLED="yes"
	PRADS_ENABLED="yes"
	SANCP_AGENT_ENABLED="yes"
	PADS_AGENT_ENABLED="yes"
	ARGUS_ENABLED="yes"
	HTTP_AGENT_ENABLED="yes"
	PCAP_SIZE="150MiB"
	PCAP_RING_SIZE="64MiB"

	# add parameters to $SENSOR_CONF if they don't already exist
	grep PCAP_ENABLED $SENSOR_CONF >/dev/null 		|| echo "PCAP_ENABLED=\"yes\""		>> $SENSOR_CONF
	grep PCAP_AGENT_ENABLED $SENSOR_CONF >/dev/null 	|| echo "PCAP_AGENT_ENABLED=\"yes\"" 	>> $SENSOR_CONF
	grep SNORT_AGENT_ENABLED $SENSOR_CONF >/dev/null 	|| echo "SNORT_AGENT_ENABLED=\"yes\"" 	>> $SENSOR_CONF
	grep IDS_ENGINE_ENABLED $SENSOR_CONF >/dev/null	|| echo "IDS_ENGINE_ENABLED=\"yes\""	>> $SENSOR_CONF
	grep BARNYARD2_ENABLED $SENSOR_CONF >/dev/null		|| echo "BARNYARD2_ENABLED=\"yes\"" 	>> $SENSOR_CONF
	grep PRADS_ENABLED $SENSOR_CONF >/dev/null 		|| echo "PRADS_ENABLED=\"yes\"" 	>> $SENSOR_CONF
	grep SANCP_AGENT_ENABLED $SENSOR_CONF >/dev/null 	|| echo "SANCP_AGENT_ENABLED=\"yes\"" 	>> $SENSOR_CONF
	grep PADS_AGENT_ENABLED $SENSOR_CONF >/dev/null 	|| echo "PADS_AGENT_ENABLED=\"yes\"" 	>> $SENSOR_CONF
	grep ARGUS_ENABLED $SENSOR_CONF >/dev/null 		|| echo "ARGUS_ENABLED=\"yes\"" 	>> $SENSOR_CONF
	grep HTTP_AGENT_ENABLED $SENSOR_CONF >/dev/null 	|| echo "HTTP_AGENT_ENABLED=\"yes\"" 	>> $SENSOR_CONF
	grep PCAP_SIZE $SENSOR_CONF >/dev/null			|| echo "PCAP_SIZE=\"150MiB\""		>> $SENSOR_CONF
	grep PCAP_RING_SIZE $SENSOR_CONF >/dev/null		|| echo "PCAP_RING_SIZE=\"64MiB\""	>> $SENSOR_CONF				
        # NSM scripts originally defaulted to running Snort with "-m 112" which results in 606 permissions
        # on the unified2 output file.  Remove the "-m 112" so that Snort will set permissions to
        # 600 correctly.
        sed -i 's|^SNORT_OPTIONS="-m 112|SNORT_OPTIONS="|g' $SENSOR_CONF

	# load in sensor specific details
	. $SENSOR_CONF

        # create sensor log directory if it doesn't exist
        mkdir -p $PROCESS_LOG_DIR/$SENSOR

        # fix permissions
        chown -R $SENSOR_USER:$SENSOR_GROUP $PROCESS_LOG_DIR/$SENSOR

	# ensure interfaces are up if autoconfigure enabled
	[ "$SENSOR_INTERFACE_AUTO" == "Y" ] && interface_up $SENSOR_INTERFACE

	# grab short name of interface, just in case bonding is configured
	SENSOR_INTERFACE_SHORT="${SENSOR_INTERFACE%%:*}"

	# restart pcap logger
	if [ "$PCAP_ENABLED" == "yes" ] && [ -z "$SKIP_PCAP" ]; then
        	TODAY=$(date $DATE_OPTIONS "+%Y-%m-%d")      #-u option sets TZ to GMT
		if [ ! -d "$SENSOR_LOG_DIR/dailylogs/$TODAY" ]; then
			mkdir -p $SENSOR_LOG_DIR/dailylogs/$TODAY
			chown $SENSOR_USER:$SENSOR_GROUP $SENSOR_LOG_DIR/dailylogs/$TODAY
			chmod 775 $SENSOR_LOG_DIR/dailylogs/$TODAY
		fi
		# Did the user supply a BPF?
	        if [ -s /etc/nsm/$SENSOR/bpf-pcap.conf ]; then
	                # User supplied a BPF, so we need to convert it
	                BPF=`grep -v "^#" /etc/nsm/$SENSOR/bpf-pcap.conf`
	                tcpdump -i $SENSOR_INTERFACE_SHORT -dd $BPF > /etc/nsm/$SENSOR/bpf-pcap.ops 2>/dev/null
	                BPF_OPTION="--filter /etc/nsm/$SENSOR/bpf-pcap.ops"
	        else
	                BPF_OPTION=""
	        fi
	    if [ "$PCAP_NUMA_TUNE" == "yes" ]; then
			$ACTION_PCAP "numactl" "--physcpubind=$PCAP_NUMA_CPU --membind=$SENSOR_NUMA_NODE -- netsniff-ng -i $SENSOR_INTERFACE_SHORT -o $SENSOR_LOG_DIR/dailylogs/$TODAY/ --user `id -u $SENSOR_USER` --group `id -g $SENSOR_GROUP` -s --prefix snort.log. --verbose --ring-size $PCAP_RING_SIZE --interval $PCAP_SIZE $PCAP_OPTIONS $BPF_OPTION" "$PROCESS_PID_DIR/$SENSOR/netsniff-ng.pid" "$PROCESS_LOG_DIR/$SENSOR/netsniff-ng.log" "netsniff-ng (full packet data)"
		else
			$ACTION_PCAP "netsniff-ng" "-i $SENSOR_INTERFACE_SHORT -o $SENSOR_LOG_DIR/dailylogs/$TODAY/ --user `id -u $SENSOR_USER` --group `id -g $SENSOR_GROUP` -s --prefix snort.log. --verbose --ring-size $PCAP_RING_SIZE --interval $PCAP_SIZE $PCAP_OPTIONS $BPF_OPTION" "$PROCESS_PID_DIR/$SENSOR/netsniff-ng.pid" "$PROCESS_LOG_DIR/$SENSOR/netsniff-ng.log" "netsniff-ng (full packet data)"
		fi
	fi

	# restart pcap_agent
	[ "$PCAP_AGENT_ENABLED" == "yes" ] && [ -z "$SKIP_PCAP_AGENT" ] && $ACTION "/usr/bin/pcap_agent.tcl" "-c $PCAP_AGENT_CONFIG" "$PROCESS_PID_DIR/$SENSOR/pcap_agent.pid" "$PROCESS_LOG_DIR/$SENSOR/pcap_agent.log" "pcap_agent (sguil)" "$SENSOR_USER"

	# restart snort_agent
        if [ "$ENGINE" == "suricata" ]; then
		[ "$SNORT_AGENT_ENABLED" == "yes" ] && [ -z "$SKIP_SNORT_AGENT" ] && $ACTION "/usr/bin/snort_agent.tcl" "-c $SNORT_AGENT_CONFIG" "$PROCESS_PID_DIR/$SENSOR/snort_agent.pid" "$PROCESS_LOG_DIR/$SENSOR/snort_agent.log" "snort_agent (sguil)" "$SENSOR_USER"
	else
		for i in `seq 1 $IDS_LB_PROCS`; do
			SNORT_AGENT_CONFIG=/etc/nsm/$SENSOR/snort_agent-$i.conf
			SNORT_AGENT_PID=$PROCESS_PID_DIR/$SENSOR/snort_agent-$i.pid
			SNORT_AGENT_LOG=$PROCESS_LOG_DIR/$SENSOR/snort_agent-$i.log
			mkdir -p $SENSOR_LOG_DIR/snort-$i/
			if [ ! -f $SNORT_AGENT_CONFIG ]; then
				cp /etc/nsm/$SENSOR/snort_agent.conf $SNORT_AGENT_CONFIG
				sed -i "s|^set HOSTNAME.*$|set HOSTNAME $SENSOR-$i|g" $SNORT_AGENT_CONFIG
				OLD_PORT=`grep BY_PORT /etc/nsm/$SENSOR/snort_agent-$i.conf |awk '{print $3}'`
				let NEW_PORT=OLD_PORT+$i
				sed -i "s|^set BY_PORT.*$|set BY_PORT $NEW_PORT|g" $SNORT_AGENT_CONFIG
				sed -i "s|^set SNORT_PERF_FILE.*$|set SNORT_PERF_FILE /nsm/sensor_data/$SENSOR/snort-$i.stats|g" $SNORT_AGENT_CONFIG
				sed -i "s|^set PORTSCAN_DIR.*$|set PORTSCAN_DIR /nsm/sensor_data/$SENSOR/portscans-$i|g" $SNORT_AGENT_CONFIG
				sed -i "s|^set WATCH_DIR.*$|set WATCH_DIR /nsm/sensor_data/$SENSOR|g" $SNORT_AGENT_CONFIG
			fi
			[ "$SNORT_AGENT_ENABLED" == "yes" ] && [ -z "$SKIP_SNORT_AGENT" ] && $ACTION "/usr/bin/snort_agent.tcl" "-c $SNORT_AGENT_CONFIG" "$SNORT_AGENT_PID" "$SNORT_AGENT_LOG" "snort_agent-$i (sguil)" "$SENSOR_USER"
		done
	fi

        TODAY=$(date $DATE_OPTIONS "+%Y-%m-%d")      #-u option sets TZ to GMT

	# UTC specific options
	if [ "$SENSOR_UTC" == "Y" ]
	then 
		SNORT_OPTIONS="-U ${SNORT_OPTIONS}"
		BARNYARD2_OPTIONS="-U ${BARNYARD2_OPTIONS}"
		DATE_OPTIONS="-u"
	fi

	# grab any early snort specific requirements
	is_snort_version "2.8.4.1-"
	if [ ${?} -eq 0 ]
	then
		SNORT_OPTIONS="${SNORT_OPTIONS} -o"
	fi

	# restart the IDS engine
        # Need to set a unique PF_RING CLUSTER_ID for each interface
        CLUSTER_ID=`awk '{print $1}' /etc/nsm/sensortab |grep -n "^$SENSOR$" |cut -d\: -f1`; let CLUSTER_ID+=50
        # Update snort.conf with new $CLUSTER_ID
        sed -i "s|^config daq_var: clusterid=.*$|config daq_var: clusterid=$CLUSTER_ID|g" /etc/nsm/$SENSOR/snort.conf
        # Update suricata.yaml with new $CLUSTER_ID
        sed -i "s|cluster-id:.*$|cluster-id: $CLUSTER_ID|g" /etc/nsm/$SENSOR/suricata.yaml
	# Disable local.rules in snort.conf since they are included in downloaded.rules
	sed -i 's|^include $RULE_PATH/local.rules$|#include $RULE_PATH/local.rules|g' /etc/nsm/$SENSOR/snort.conf
	# Disable local.rules in suricata.yaml since they are included in downloaded.rules
	sed -i 's|^ - local.rules$|# - local.rules|g' /etc/nsm/$SENSOR/suricata.yaml
	# PF_RING 6.2.0 won't allow an empty BPF file
	BPF_OPTION=""
	BPF_IDS=/etc/nsm/$SENSOR/bpf-ids.conf
	[ -s $BPF_IDS ] && BPF_OPTION="-F $BPF_IDS"
	# Suricata or Snort?
        if [ "$ENGINE" == "suricata" ]; then
		# copy IDS_LB_PROCS from sensor.conf
		IDS_LB_PROCS=`grep IDS_LB_PROCS /etc/nsm/$SENSOR/sensor.conf | cut -d\= -f2`
                sed -i "s|    threads: .*|    threads: $IDS_LB_PROCS|g" /etc/nsm/$SENSOR/suricata.yaml
		# wipe stats.log if doing a full restart of Suricata, but not if we're just doing the watchdog check for stale processes
                [ "$ACTION" == "process_restart" ] && rm -f /nsm/sensor_data/$SENSOR/stats.log
		# start Suricata
                [ "$IDS_ENGINE_ENABLED" == "yes" ] && [ -z "$SKIP_SNORT_ALERT" ] && $ACTION "suricata" "--user $SENSOR_USER --group $SENSOR_GROUP -c /etc/nsm/$SENSOR/suricata.yaml --pfring=$SENSOR_INTERFACE_SHORT $BPF_OPTION -l $SENSOR_LOG_DIR " "$PROCESS_PID_DIR/$SENSOR/suricata.pid" "$PROCESS_LOG_DIR/$SENSOR/suricata.log" "suricata (alert data)"
	else
		# Grab MTU for interface(s) and add 24 to snaplen for VLAN-tagging, etc
		MTU=`cat /sys/class/net/$SENSOR_INTERFACE_SHORT/mtu`
		MTU_FIN=`echo $(($MTU+24))`
		# Need to set a unique PF_RING CLUSTER_ID for each interface
                CLUSTER_ID=`grep -n $SENSOR /etc/nsm/sensortab |cut -d\: -f1`; let CLUSTER_ID+=50
                sed -i "s|^config daq_var: clusterid=.*$|config daq_var: clusterid=$CLUSTER_ID|g" /etc/nsm/$SENSOR/snort.conf
                # Restart $IDS_LB_PROCS instances of Snort using pfring load-balancing
		for i in `seq 1 $IDS_LB_PROCS`; do
                        PID=$PROCESS_PID_DIR/$SENSOR/snortu-$i.pid
                        LOG=$PROCESS_LOG_DIR/$SENSOR/snortu-$i.log
                        PERFMON=$SENSOR_LOG_DIR/snort-$i.stats
                        UNI_DIR=$SENSOR_LOG_DIR/snort-$i
			mkdir -p $UNI_DIR
			chown $SENSOR_USER:$SENSOR_GROUP $UNI_DIR
			if [ "$IDS_NUMA_TUNE" == "yes" ]; then
				if [ "$IDS_NUMA_CPU_MODE" == "numa" ]; then
					CPU_BIND_MODE="--cpunodebind=$SENSOR_NUMA_NODE"
				elif [ "$IDS_NUMA_CPU_MODE" == "range" ]; then
					CPU_BIND_MODE="--physcpubind=$IDS_NUMA_CPU"
				elif [ "$IDS_NUMA_CPU_MODE" == "increment" ]; then
				 	CPU_BIND_MODE="--physcpubind=$IDS_NUMA_CPU"
				 	IDS_NUMA_CPU=$((IDS_NUMA_CPU+IDS_NUMA_CPU_STEP))
				else
					CPU_BIND_MODE="--cpunodebind=$SENSOR_NUMA_NODE"
				fi
				[ "$IDS_ENGINE_ENABLED" == "yes" ] && [ -z "$SKIP_SNORT_ALERT" ] && $ACTION "numactl" "$CPU_BIND_MODE --membind=$SENSOR_NUMA_NODE -- snort -c $SNORT_CONFIG -u $SENSOR_USER -g $SENSOR_GROUP -i $SENSOR_INTERFACE_SHORT $BPF_OPTION -l $UNI_DIR --perfmon-file $PERFMON $SNORT_OPTIONS --snaplen $MTU_FIN" "$PID" "$LOG" "snort-$i (alert data)"
			else
				[ "$IDS_ENGINE_ENABLED" == "yes" ] && [ -z "$SKIP_SNORT_ALERT" ] && $ACTION "snort" "-c $SNORT_CONFIG -u $SENSOR_USER -g $SENSOR_GROUP -i $SENSOR_INTERFACE_SHORT $BPF_OPTION -l $UNI_DIR --perfmon-file $PERFMON $SNORT_OPTIONS --snaplen $MTU_FIN" "$PID" "$LOG" "snort-$i (alert data)"
			fi
		done
	fi

	# restart barnyard2
	# If running Suricata, we only have a single instance of barnyard2.
        # If running Snort with pfring load-balancing, we have one instance of barnyard2 per Snort instance.
        if [ "$ENGINE" == "suricata" ]; then
                # we only have a single instance of barnyard2

		# make sure the waldo file exists and is owned by proper user
		touch $BARNYARD2_WALDO
		chown $SENSOR_USER:$SENSOR_GROUP $BARNYARD2_WALDO

                # add option to barnyard config
                if ! grep "config alert_with_interface_name" $BARNYARD2_CONFIG >/dev/null 2>&1; then
                        sed -i '/^# barnyard2.conf: /a config alert_with_interface_name' $BARNYARD2_CONFIG
                fi

		# start barnyard2
		[ "$BARNYARD2_ENABLED" == "yes" ] && [ -z "$SKIP_BARNYARD2" ] && $ACTION "barnyard2" "-c $BARNYARD2_CONFIG -u $SENSOR_USER -g $SENSOR_GROUP -d $SENSOR_LOG_DIR -f snort.unified2 -w $BARNYARD2_WALDO -i $SENSOR_NAME $BARNYARD2_OPTIONS" "$PROCESS_PID_DIR/$SENSOR/barnyard2.pid" "$PROCESS_LOG_DIR/$SENSOR/barnyard2.log" "barnyard2 (spooler, unified2 format)"
	else
		# we have one instance of barnyard2 per Snort instance
                for i in `seq 1 $IDS_LB_PROCS`; do
			BARNYARD2_CONFIG=/etc/nsm/$SENSOR/barnyard2-$i.conf
                        UNI_DIR=$SENSOR_LOG_DIR/snort-$i
                        WALDO=$BARNYARD2_WALDO-$i
                        PID=$PROCESS_PID_DIR/$SENSOR/barnyard2-$i.pid
                        LOG=$PROCESS_LOG_DIR/$SENSOR/barnyard2-$i.log
			mkdir -p $SENSOR_LOG_DIR/snort-$i/
			if [ ! -f $BARNYARD2_CONFIG ]; then
				cp /etc/nsm/$SENSOR/barnyard2.conf $BARNYARD2_CONFIG
				PORT=`grep BY_PORT /etc/nsm/$SENSOR/snort_agent-$i.conf |awk '{print $3}'`
				sed -i "s|output sguil:.*$|output sguil: sensor_name=$SENSOR-$i agent_port=$PORT|g" $BARNYARD2_CONFIG
			fi

			# make sure the waldo file exists and is owned by proper user
			touch $WALDO
			chown $SENSOR_USER:$SENSOR_GROUP $WALDO

	                # add option to barnyard config
        	        if ! grep "config alert_with_interface_name" $BARNYARD2_CONFIG >/dev/null 2>&1; then
                	        sed -i '/^# barnyard2.conf: /a config alert_with_interface_name' $BARNYARD2_CONFIG
	                fi

			# start barnyard2
			[ "$BARNYARD2_ENABLED" == "yes" ] && [ -z "$SKIP_BARNYARD2" ] && $ACTION "barnyard2" "-c $BARNYARD2_CONFIG -u $SENSOR_USER -g $SENSOR_GROUP -d $UNI_DIR -f snort.unified2 -w $WALDO -i $SENSOR_NAME-$i $BARNYARD2_OPTIONS" "$PID" "$LOG" "barnyard2-$i (spooler, unified2 format)"
		done
	fi

	# restart prads
	# If the user supplies a BPF, use theirs; otherwise, exclude IPv6
        if [ -s /etc/nsm/$SENSOR/bpf-prads.conf ]; then
                BPF=`grep -v "^#" /etc/nsm/$SENSOR/bpf-prads.conf`
	else
		# By default, we need to exclude IPv6 traffic from prads since Sguil doesn't grok it (yet)
		BPF="ip or (vlan and ip)"
	fi
	#[ "$PRADS_ENABLED" == "yes" ] && [ -z "$SKIP_PRADS" ] && $ACTION "prads" "-i $SENSOR_INTERFACE_SHORT -c /etc/nsm/$SENSOR/prads.conf -u $SENSOR_USER -g $SENSOR_GROUP -L /nsm/sensor_data/$SENSOR/sancp/ -f /nsm/sensor_data/$SENSOR/pads.fifo $PADS_OPTIONS -b \"$BPF\"" "$PROCESS_PID_DIR/$SENSOR/prads.pid" "$PROCESS_LOG_DIR/$SENSOR/prads.log" "prads (sessions/assets)"
        [ "$PRADS_ENABLED" == "yes" ] && [ -z "$SKIP_PRADS" ] && [ "$PADS_AGENT_ENABLED" == "yes" ] && [ "$SANCP_AGENT_ENABLED" == "yes" ] && $ACTION "prads" "-i $SENSOR_INTERFACE_SHORT -c /etc/nsm/$SENSOR/prads.conf -u $SENSOR_USER -g $SENSOR_GROUP -L /nsm/sensor_data/$SENSOR/sancp/ -f /nsm/sensor_data/$SENSOR/pads.fifo $PADS_OPTIONS -b \"$BPF\"" "$PROCESS_PID_DIR/$SENSOR/prads.pid" "$PROCESS_LOG_DIR/$SENSOR/prads.log" "prads (sessions/assets)"
        [ "$PRADS_ENABLED" == "yes" ] && [ -z "$SKIP_PRADS" ] && [ "$PADS_AGENT_ENABLED" == "no" ]  && [ "$SANCP_AGENT_ENABLED" == "yes" ] && $ACTION "prads" "-i $SENSOR_INTERFACE_SHORT -c /etc/nsm/$SENSOR/prads.conf -u $SENSOR_USER -g $SENSOR_GROUP -L /nsm/sensor_data/$SENSOR/sancp/ -b \"$BPF\"" "$PROCESS_PID_DIR/$SENSOR/prads.pid" "$PROCESS_LOG_DIR/$SENSOR/prads.log" "prads (sessions/assets)"
        [ "$PRADS_ENABLED" == "yes" ] && [ -z "$SKIP_PRADS" ] && [ "$PADS_AGENT_ENABLED" == "yes" ] && [ "$SANCP_AGENT_ENABLED" == "no" ]  && $ACTION "prads" "-i $SENSOR_INTERFACE_SHORT -c /etc/nsm/$SENSOR/prads.conf -u $SENSOR_USER -g $SENSOR_GROUP -f /nsm/sensor_data/$SENSOR/pads.fifo $PADS_OPTIONS -b \"$BPF\"" "$PROCESS_PID_DIR/$SENSOR/prads.pid" "$PROCESS_LOG_DIR/$SENSOR/prads.log" "prads (sessions/assets)"
        [ "$PRADS_ENABLED" == "yes" ] && [ -z "$SKIP_PRADS" ] && [ "$PADS_AGENT_ENABLED" == "no" ]  && [ "$SANCP_AGENT_ENABLED" == "no" ]  && echo_error_msg 1 "Warning: PRADS is enabled but will not start because both SANCP AGENT and PADS AGENT are disabled!"

	# restart pads_agent
	if [ "$PADS_AGENT_ENABLED" == "yes" ] && [ -z "$SKIP_PADS_AGENT" ]; then
        	chown $SENSOR_USER:$SENSOR_GROUP $SENSOR_LOG_DIR/pads.fifo
		$ACTION "/usr/bin/pads_agent.tcl" "-c $PADS_AGENT_CONFIG" "$PROCESS_PID_DIR/$SENSOR/pads_agent.pid" "$PROCESS_LOG_DIR/$SENSOR/pads_agent.log" "pads_agent (sguil)" "$SENSOR_USER"
	fi

	# restart sancp_agent
	[ "$SANCP_AGENT_ENABLED" == "yes" ] && [ -z "$SKIP_SANCP_AGENT" ] && $ACTION "/usr/bin/sancp_agent.tcl" "-c $SANCP_AGENT_CONFIG" "$PROCESS_PID_DIR/$SENSOR/sancp_agent.pid" "$PROCESS_LOG_DIR/$SENSOR/sancp_agent.log" "sancp_agent (sguil)" "$SENSOR_USER"

	# restart argus
	if [ "$ARGUS_ENABLED" == "yes" ] && [ -z "$SKIP_ARGUS" ]
	then
		mkdir -p $SENSOR_LOG_DIR/argus
        	chown $SENSOR_USER:$SENSOR_GROUP $SENSOR_LOG_DIR/argus
        	chmod 775 $SENSOR_LOG_DIR/argus
        	TODAY=$(date $DATE_OPTIONS "+%Y-%m-%d")      #-u option sets TZ to GMT
		# OLD
		# $ACTION "argus" "-P0 -u $SENSOR_USER -g $SENSOR_GROUP -i $SENSOR_INTERFACE_SHORT -w $SENSOR_LOG_DIR/argus/$TODAY.log" "$PROCESS_PID_DIR/$SENSOR/argus.pid" "$PROCESS_LOG_DIR/$SENSOR/argus.log" "argus"
		# NEW
		# If /etc/nsm/$SENSOR/argus.conf does not exist, copy it from /etc/nsm/templates/argus/
		[ ! -f /etc/nsm/$SENSOR/argus.conf ] && cp /etc/nsm/templates/argus/argus.conf /etc/nsm/$SENSOR/argus.conf
		$ACTION "argus" "-i $SENSOR_INTERFACE_SHORT -F /etc/nsm/$SENSOR/argus.conf -w $SENSOR_LOG_DIR/argus/$TODAY.log" "$PROCESS_PID_DIR/$SENSOR/argus.pid" "$PROCESS_LOG_DIR/$SENSOR/argus.log" "argus"
	fi

        # start http_agent
        # http_agent is going to read the Bro http.log
        # If Bro is running in standalone mode, it will be http.log
        # If Bro is running in cluster mode, then http.log will be per-interface:
        # http_eth0.log, http_eth1.log, etc.
        if grep "type=standalone" /opt/bro/etc/node.cfg >/dev/null; then
                BRO_HTTP_LOG=/nsm/bro/logs/current/http.log
        else
                BRO_HTTP_LOG=/nsm/bro/logs/current/http_$SENSOR_INTERFACE_SHORT.log
        fi
        [ "$HTTP_AGENT_ENABLED" == "yes" ] && [ -z "$SKIP_HTTP_AGENT" ] && $ACTION "/usr/bin/http_agent.tcl" "-c /etc/nsm/$SENSOR/http_agent.conf -e /etc/nsm/$SENSOR/http_agent.exclude -f $BRO_HTTP_LOG" "$PROCESS_PID_DIR/$SENSOR/http_agent.pid" "$PROCESS_LOG_DIR/$SENSOR/http_agent.log" "http_agent (sguil)" "$SENSOR_USER"

	# clean disk/check crontab entry for daily restarts
	# commented out because we're going to run this hourly now
	# sensor_cleandisk $SENSOR_LOG_DIR
	sensor_stat_cronjob
done
