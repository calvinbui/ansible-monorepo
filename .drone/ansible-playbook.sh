#!/usr/bin/env bash

set -eo pipefail

git config --global --add safe.directory /drone/src

if [[ -z $playbooks ]]; then
  mapfile -t allplaybooks < <(git show --name-only --diff-filter=ACMRTU HEAD | grep -E "^(\w|-|_)+.y*ml")
else
  IFS="," read -r -a playbooks <<< "${playbooks[@]}"
  allplaybooks=( )
  for playbook in "${playbooks[@]}"; do
    if [[ $playbook != *.yml ]]; then
      playbook="${playbook}.yml"
    fi

    allplaybooks+=( "$playbook" )
  done
fi

if [[ "${#allplaybooks[@]}" -eq 0 ]]; then
  echo "--- No playbooks changed"
  exit 0
fi

if [ ! -f ~/.vault_pass.txt ]; then
  echo "--- Put vault key"
  echo "$ANSIBLE_VAULT_PASSWORD" > ~/.vault_pass.txt
fi

# shellcheck disable=SC2068
# i want it to split
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook ${allplaybooks[@]}
