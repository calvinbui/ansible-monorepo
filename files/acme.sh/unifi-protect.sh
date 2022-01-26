#!/usr/bin/env bash
# shellcheck disable=SC1083

set -euo pipefail

FULLCHAIN=$1
KEYFILE=$2

if ! grep -q "^nvr.{{ common_local_tld }}" /root/.ssh/known_hosts; then
  ssh-keyscan -t rsa nvr.{{ common_local_tld }} >> /root/.ssh/known_hosts
fi

scp "$FULLCHAIN" root@nvr.{{ common_local_tld }}:/data/unifi-core/config/unifi-core.crt
scp "$KEYFILE" root@nvr.{{ common_local_tld }}:/data/unifi-core/config/unifi-core.key

ssh root@nvr.{{ common_local_tld }} 'systemctl restart unifi-protect'
ssh root@nvr.{{ common_local_tld }} 'systemctl restart unifi-core'
