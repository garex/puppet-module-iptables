#!/usr/bin/env bash

# Base vars
HERE=$(dirname $0)

# Reset counters and rules
iptables --zero
iptables --flush

# Allow outgoing traffic and disallow any passthroughs
iptables --policy INPUT DROP
iptables --policy OUTPUT ACCEPT
iptables --policy FORWARD DROP

# Allow local loopback services
iptables --append INPUT --jump ACCEPT --in-interface lo

# Allow traffic already established to continue
iptables --append INPUT --jump ACCEPT --match state --state ESTABLISHED,RELATED

# Allow pings
iptables --append INPUT --jump ACCEPT --proto icmp --icmp-type source-quench
iptables --append INPUT --jump ACCEPT --proto icmp --icmp-type time-exceeded
iptables --append INPUT --jump ACCEPT --proto icmp --icmp-type echo-reply
iptables --append INPUT --jump ACCEPT --proto icmp --icmp-type echo-request

# Run custom rules
. $HERE/iptables_setup_custom
