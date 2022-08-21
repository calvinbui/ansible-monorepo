#!/usr/bin/env bash

set -euo pipefail

echo "--- Put vault key"
echo "$ANSIBLE_VAULT_PASSWORD" > ~/.vault_pass.txt

echo "--- ansible-lint"
ansible-lint ./*.y*l
