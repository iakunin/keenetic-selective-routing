#!/bin/sh

[ "$type" != "iptables" ] && exit 0
[ "$table" != "mangle" ] && exit 0

IPSET=unblock8bit

echo  Creating rule for $IPSET ipset!
if [ -z "$(iptables-save | grep $IPSET)" ]; then
	iptables -t mangle -A PREROUTING -m conntrack --ctstate NEW -m set --match-set $IPSET dst -j CONNMARK --set-mark 0x1000
	iptables -t mangle -A PREROUTING -j CONNMARK --restore-mark
else
	echo Rule for $IPSET already exists!
fi

iptables -t mangle -A PREROUTING -j CONNMARK --restore-mark
