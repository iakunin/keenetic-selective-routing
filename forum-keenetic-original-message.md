Все проще с dnsmasq. Он сам добавит нужные ip в маршрутизацию:

/opt/etc/unblock-vpn.dnsmasq
```shell
ipset=/face****.com/**cdn.net/unblock4-vpn
```

/opt/etc/dnsmasq.conf
```shell
conf-file=/opt/etc/unblock-vpn.dnsmasq
```

/opt/etc/ndm/netfilter.d/10m-mark4.sh
```shell
#!/bin/sh

[ "$type" != "iptables" ] && exit 0
[ "$table" != "mangle" ] && exit 0

ip4t() {
    if ! iptables -C "$@" &>/dev/null; then
        iptables -A "$@"
    fi
}

# VPN
ipset create unblock4-vpn hash:net family inet -exist

# С отключением fastnat и ускорителей
#ip4t PREROUTING -t mangle -i br0 -p tcp -m set --match-set unblock4-vpn dst -j MARK --set-mark 0xd1000
#ip4t PREROUTING -t mangle -i br0 -p udp -m set --match-set unblock4-vpn dst -j MARK --set-mark 0xd1000

# Без отключения
ip4t PREROUTING -t mangle -m conntrack --ctstate NEW -m set --match-set unblock4-vpn dst -j CONNMARK --set-mark 0xd1000
ip4t PREROUTING -t mangle -j CONNMARK --restore-mark

exit 0
```

/opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh
```shell
#!/bin/sh

[ "$1" == "hook" ] || exit 0
[ "$change" == "link" ] || exit 0
[ "$id" == "Wireguard2" ] || exit 0

IF_NAME=nwg2
IF_GW4=$(ip -4 addr show "$IF_NAME" | grep -Po "(?<=inet ).*(?=/)")

case ${id}-${change}-${connected}-${link}-${up} in
    ${id}-link-no-down-down)
        ip -4 rule del fwmark 0xd1000 lookup 1001 priority 1778 2>/dev/null
        ip -4 route flush table 1001
    ;;
    ${id}-link-yes-up-up)
        ip -4 route add table 1001 default via "$IF_GW4" dev "$IF_NAME" 2>/dev/null
        ip -4 route show table main |grep -Ev ^default |while read ROUTE; do ip -4 route add table 1001 $ROUTE 2>/dev/null; done
        ip -4 rule add fwmark 0xd1000 lookup 1001 priority 1778 2>/dev/null
        ip -4 route flush cache
    ;;
esac

exit 0
```
