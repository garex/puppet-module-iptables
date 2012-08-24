#!/usr/bin/env bash

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

# Run custom rules in the order of their define
#   * puppet will check each file by default md5
#   * and after check file access time will change
#   * based on this we sort files in the strict order of their defines
set -f
IFS='
'
for rule in $(ls --sort time --time access --reverse -1)
do
  . "$rule"
done
unset IFS
set +f
