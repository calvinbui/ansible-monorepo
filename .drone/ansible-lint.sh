#!/usr/bin/env bash

set -euo pipefail

echo "--- Install dependencies"
pip3 install -r requirements.txt

echo "--- Put vault key"
echo "$ANSIBLE_VAULT_PASSWORD" > ~/.vault_pass.txt

echo "--- ansible-lint"
ansible-lint ./*.y*l
