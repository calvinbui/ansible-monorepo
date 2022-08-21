#!/usr/bin/env bash

set -euo pipefail

mapfile -t playbooks_updated < <(git show --name-only HEAD | grep -E "^(\w|-|_)+.y*ml")

if [[ "${#playbooks_updated[@]}" -eq 0 ]]; then
  echo "--- No playbooks changed"
  exit 0
fi

echo "--- Install dependencies"
apt-get update && apt-get install rsync -y

echo "--- Put SSH key"
mkdir -p ~/.ssh
echo "$SSH_KEY" > ~/.ssh/id_ed25519
chmod -R 400 ~/.ssh

echo "--- Put vault key"
echo "$ANSIBLE_VAULT_PASSWORD" > ~/.vault_pass.txt

skip_playbooks=(
  "drone.yml"
  "nvidia.yml"
  "docker.yml"
)

for playbook in "${playbooks_updated[@]}"; do
  # shellcheck disable=SC2076
  if [[ " ${skip_playbooks[*]} " =~ " ${playbook} " ]]; then
    continue
  fi

  echo "--- $playbook"
  ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook "$playbook"
done
