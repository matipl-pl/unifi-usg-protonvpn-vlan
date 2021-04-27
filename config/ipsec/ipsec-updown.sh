#!/bin/bash
set -o nounset
set -o errexit

# $VTI_IFACE must match the interface in config.gateway.json
VTI_IFACE="vti100"

case "${PLUTO_VERB}" in
    up-client)
        echo "Creating tunnel interface ${VTI_IFACE}"
        ip tunnel add "${VTI_IFACE}" local "${PLUTO_ME}" remote "${PLUTO_PEER}" mode vti

        echo "Activating tunnel interface ${VTI_IFACE}"
        ip link set "${VTI_IFACE}" up

        echo "Adding ${PLUTO_MY_SOURCEIP} to ${VTI_IFACE}"
        ip addr add "${PLUTO_MY_SOURCEIP}" dev "${VTI_IFACE}"

        echo "Disabling IPsec policy (SPD) for ${VTI_IFACE}"
        sysctl -w "net.ipv4.conf.${VTI_IFACE}.disable_policy=1"

        DEFAULT_ROUTE="$(ip route show default | grep default | awk '{print $3}')"
        echo "Identified default route as ${DEFAULT_ROUTE}"
        echo "Adding route: ${PLUTO_PEER} via ${DEFAULT_ROUTE} dev ${PLUTO_INTERFACE}"
        ip route add "${PLUTO_PEER}" via "${DEFAULT_ROUTE}" dev "${PLUTO_INTERFACE}"
        ;;
    down-client)
        echo "Deleting interface ${VTI_IFACE}"
        ip tunnel del "${VTI_IFACE}"

        echo "Deleting route for ${PLUTO_PEER}"
        ip route del "${PLUTO_PEER}"
        ;;
esac
