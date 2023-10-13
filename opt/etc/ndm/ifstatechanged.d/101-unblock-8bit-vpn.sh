#!/bin/sh

[ "$1" == "hook" ] || exit 0
[ "$id" == "L2TP0" ] || exit 0


IF_NAME=ppp0 # 8bit-L2TP-VPN
TABLE=1000
MARK=0x1000

case ${id}-${change}-${connected}-${link}-${up} in
    ${id}-config-no-down-down)
        ip rule del fwmark "$MARK" table "$TABLE" priority 1000
        ip route flush table "$TABLE"
    ;;
    ${id}-connected-yes-up-up)
        ip rule add fwmark "$MARK" table "$TABLE" priority 1000
	ip route add table "$TABLE" default dev "$IF_NAME"
	ip route add table "$TABLE" 192.168.1.0/24 via 192.168.1.1 dev br0
    ;;
esac

exit 0
