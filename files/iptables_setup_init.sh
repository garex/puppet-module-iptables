#!/usr/bin/env bash

# Set vars
syn_limit="$1"
syn_limit_burst="$2"

# Reset counters and rules
iptables --zero
iptables --flush
iptables --delete-chain

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

# Add custom droplist
iptables --new-chain DROP_LIST

# Add custom SYN-flood
iptables --new-chain SYN_FLOOD
iptables --append INPUT --jump SYN_FLOOD --proto tcp --in-interface eth0 --syn
iptables --append SYN_FLOOD --jump RETURN --match limit --limit $syn_limit --limit-burst $syn_limit_burst
iptables --append SYN_FLOOD --jump DROP

# Make sure NEW tcp connections are SYN packets
iptables --append INPUT --jump DROP --proto tcp --in-interface eth0 ! --syn --match state --state NEW

# Go to *.d intentionally
cd /etc/iptables_setup.d

for rule in $(ls -1 | sort --reverse --numeric-sort)
do
  . ./$rule
done

# Insert custom droplist after all
iptables --insert INPUT --jump DROP_LIST

# Persist rules
iptables-save --counters > /etc/iptables.rules
