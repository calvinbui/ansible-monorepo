#!/usr/bin/env bash

set -euo pipefail

CERT=$1
KEY=$2

cp "$CERT" "{{ common_directory }}/coturn/turn_server_cert.pem"
cp "$KEY" "{{ common_directory }}/coturn/turn_server_pkey.pem"

chmod 744 "{{ common_directory }}/coturn/*.pem"

docker restart coturn
