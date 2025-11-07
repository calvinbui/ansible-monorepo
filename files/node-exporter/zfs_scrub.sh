#!/usr/bin/env bash

set -euo pipefail

OUTPUT_FILE="/textfiles/zfs_scrub.prom"
TMP_FILE="/tmp/zfs_scrub.prom.tmp"

while true; do
  if zpool status | grep -q "scan: scrub in progress"; then
    echo 'zfs_pool_scrub_in_progress 1' > $TMP_FILE
  else
    echo 'zfs_pool_scrub_in_progress 0' > $TMP_FILE
  fi

  mv $TMP_FILE $OUTPUT_FILE

  sleep 60
done
