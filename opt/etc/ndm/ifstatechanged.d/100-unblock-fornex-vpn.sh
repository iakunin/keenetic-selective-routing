#!/bin/sh

[ "$1" == "hook" ] || exit 0
[ "$id" == "Wireguard0" ] || exit 0


IF_NAME=nwg0 # fornex-VPN
IF_GW4=$(ip -4 addr show "$IF_NAME" | grep -Po "(?<=inet ).*(?=/)")

case ${id}-${change}-${connected}-${link}-${up} in
    ${id}-config-no-down-down)
        ip -4 rule del fwmark 0xd1001 lookup 1001 priority 1778 2>/dev/null
        ip -4 route flush table 1001
    ;;
    ${id}-connected-yes-up-up)
        ip -4 route add table 1001 default via "$IF_GW4" dev "$IF_NAME" 2>/dev/null
        ip -4 route show table main | grep -Ev ^default | while read ROUTE; do ip -4 route add table 1001 $ROUTE 2>/dev/null; done
        ip -4 rule add fwmark 0xd1001 lookup 1001 priority 1778 2>/dev/null
        ip -4 route flush cache
    ;;
esac

exit 0
