#!/usr/bin/env bash

set -eo pipefail

if [[ -z $playbooks ]]; then
  mapfile -t playbooks < <(git show --name-only HEAD | grep -E "^(\w|-|_)+.y*ml")
else
  IFS="," read -r -a playbooks <<< "${playbooks[@]}"
fi

if [[ "${#playbooks[@]}" -eq 0 ]]; then
  echo "--- No playbooks changed"
  exit 0
fi

if [ ! -f ~/.vault_pass.txt ]; then
  echo "--- Put vault key"
  echo "$ANSIBLE_VAULT_PASSWORD" > ~/.vault_pass.txt
fi

for playbook in "${playbooks[@]}"; do
  # if provided without the extension
  if [[ $playbook != *.yml ]]; then
    playbook="${playbook}.yml"
  fi

  echo "--- $playbook"
  ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook "$playbook"
done
