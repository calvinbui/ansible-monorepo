#!/usr/bin/env bash

set -euo pipefail

mapfile -t playbooks_updated < <(git show --name-only HEAD | grep -E "^(\w|-|_)+.y*ml")

if [[ "${#playbooks_updated[@]}" -eq 0 ]]; then
  echo "--- No playbooks changed"
  exit 0
fi

echo "--- Install dependencies"
pip3 install -r requirements.txt

echo "--- Put SSH key"
mkdir -p ~/.ssh
echo "$SSH_KEY" > ~/.ssh/id_ed25519
chmod -R 400 ~/.ssh

echo "--- Put vault key"
echo "$ANSIBLE_VAULT_PASSWORD" > ~/.vault_pass.txt

for playbook in "${playbooks_updated[@]}"; do
  echo "--- $playbook"
  ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook "$playbook"
done
