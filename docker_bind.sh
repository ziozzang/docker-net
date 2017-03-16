#!/bin/bash
# Code by Jioh L. Jung (ziozzang@gmail.com)

if [ "$#" -ne 3 ]; then
  echo "$0 [container_name] [bridge_name] [target_ip_with_subname]"
  exit 1
fi

name="$1"
brname="$2"
targetip="$3"
addr=`echo "${targetip}" | tr '/' '\n' | head -n 1`
dpid=`docker inspect --format {{.State.Pid}} ${name}`
if [[ -z "$dpid" ]]; then
  exit 1
fi
ip link add i${dpid} type veth peer name e${dpid}
brctl addif ${brname} e${dpid}
ip link set netns ${dpid} dev i${dpid}
ip link set e${dpid} up
nsenter -t ${dpid} -n ip link set i${dpid} up
nsenter -t ${dpid} -n ip addr add ${targetip} dev i${dpid}
nsenter -t ${dpid} -n arping -A -c 1 -I i${dpid} ${addr} > /dev/null 2>&1 &
