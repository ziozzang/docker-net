#!/bin/bash
# Code by Jioh L. Jung (ziozzang@gmail.com)

NETNS=/var/run/netns
mkdir -p ${NETNS}

function remove_missed() {
  # Remove purged record.
  for f in ${NETNS}/*
  do
    # Symbolic Link && not exist target
    if [ -L "$f" ] && [ ! \( -e "$f" \) ] ; then
      rm -f $f
    fi
  done
  return
}

remove_missed

while true; do
  # Acquire docker ids. (don't need -a option. fixed)
  DIDS=`docker ps | tail -n +2 | awk '{print $1}'`
  for p in ${DIDS}
  do
    pid=`docker inspect --format {{.State.Pid}} ${p}`

    # pid must not 0
    if [ "$pid" -ne "0" ]; then
      # Create Link if not exist
      if [ ! -e "${NETNS}/${p}" ]; then
        ln -s /proc/${pid}/ns/net ${NETNS}/${p}
      fi
    fi
  done

  remove_missed

  sleep 0.5

done
