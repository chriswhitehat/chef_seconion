#
# Cookbook Name:: seconion
# Attribute:: bpf
#

# [src|dst] host <host>                       Matches a host as the IP source, destination, or either
# ether [src|dst] host <ehost>                Matches a host as the Ethernet source, destination, or either
# gateway host <host>                         Matches packets which used host as a gateway
# [src|dst] net <network> <len>               Matches packets to or from an endpoint residing in network
# [tcp|udp] [src|dst] port <port>             Matches TCP or UDP packets sent to/from port
# [tcp|udp] [src|dst] portrange <p1> <p2>     Matches TCP or UDP packets to/from a port in the given range
# less <length>                               Matches packets less than or equal to length
# greater <length>                            Matches packets greater than or equal to length
# (ether|ip|ip6) proto <protocol>             Matches an Ethernet, IPv4, or IPv6 protocol
# (ether|ip) broadcasts                       Matches Ethernet or IPv4 broadcasts
# (ether|ip|ip6) multicast                    Matches Ethernet, IPv4, or IPv6 multicasts
# type (mgt|ctl|data) [subtype <subtype>]     Matches 802.11 frames based on type and optional subtype 
# vlan [<vlan>]                               Matches 802.1Q frames, optionally with a VLAN ID of vlan 
# mpls [<label>]                              Matches MPLS packets, optionally with a label of label  
# <expr> <relop> <expr>                       Matches packets by an arbitrary expression

# Modifiers
# !   or  not
# &&  or  and
# ||  or  or

# Protocols
# arp     ether   fddi    icmp    ip
# ip6     link    ppp     radio   rarp
# slip    tcp     tr      udp     wlan

# TCP Flags
# tcp-urg tcp-rst  tcp-ack
# tcp-syn tcp-psh  tcp-fin

# ICMP Types
# icmp-echoreply      icmp-routeradvert   icmp-tstampreply
# icmp-unreach        icmp-routersolicit  icmp-ireq
# icmp-sourcequench   icmp-timxceed       icmp-ireqreply
# icmp-redirect       icmp-paramprob      icmp-maskreq
# icmp-echo           icmp-tstamp         icmp-maskreply

##########################
# Global
##########################

# Example
#default[:seconion][:sensor][:bpf][:global]['udp dst port not 53'] = true

 
##########################
# Regional
##########################

# Example
#default[:seconion][:sensor][:bpf][:regional]['host 10.0.0.1 && host 10.0.0.2'] = true

##########################
# Sensor Group
##########################

# Example
# default[:seconion][:sensor][:bpf]['sensor_group_name']['host 10.0.0.1 && host 10.0.0.2'] = true

##########################
# Host
##########################

# Example
#default[:seconion][:sensor][:bpf]['hostname.example.com']['tcp dst port 80 or 8080'] = true

##########################
# Sensor 
##########################

# Example
#default[:seconion][:sensor][:bpf]['sensorname']['not (host 10.0.0.1 && host 10.0.0.2)'] = true
