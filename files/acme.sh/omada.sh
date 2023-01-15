#!/usr/bin/env bash

set -euo pipefail

CERT=$1
KEY=$2

mkdir -p "{{ common_directory }}/omada/cert/"

cp "$CERT" "{{ common_directory }}/omada/cert/tls.crt"
cp "$KEY" "{{ common_directory }}/omada/cert/tls.key"

# Restart Omada controller
docker restart omada
