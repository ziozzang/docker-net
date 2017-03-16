#!/bin/bash
# Code by Jioh L. Jung (ziozzang@gmail.com)

if [ "$#" -ne 1 ]; then
  echo "$0 [container_name]"
  exit 1
fi

name="$1"
dpid=`docker inspect --format {{.State.Pid}} ${name}`
if [[ -z "$dpid" ]]; then
  exit 1
fi
ip link del e${dpid}
