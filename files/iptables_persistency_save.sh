#!/usr/bin/env bash
iptables-save --counters > /etc/iptables.rules
exit 0
