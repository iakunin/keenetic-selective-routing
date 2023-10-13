#!/bin/sh

[ "$type" != "iptables" ] && exit 0
[ "$table" != "mangle" ] && exit 0

ip4t() {
    if ! iptables -C "$@" &>/dev/null; then
        iptables -A "$@"
    fi
}

# VPN
ipset create unblockfornex hash:net family inet -exist

# С отключением fastnat и ускорителей
#ip4t PREROUTING -t mangle -i br0 -p tcp -m set --match-set unblockfornex dst -j MARK --set-mark 0xd1000
#ip4t PREROUTING -t mangle -i br0 -p udp -m set --match-set unblockfornex dst -j MARK --set-mark 0xd1000

# Без отключения
ip4t PREROUTING -t mangle -m conntrack --ctstate NEW -m set --match-set unblockfornex dst -j CONNMARK --set-mark 0xd1001
ip4t PREROUTING -t mangle -j CONNMARK --restore-mark

exit 0
