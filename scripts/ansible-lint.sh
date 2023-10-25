#!/usr/bin/env bash

set -eo pipefail

if [[ -z $playbooks ]]; then
  mapfile -t allplaybooks < <(git diff --name-only -r HEAD^1 HEAD | grep -E "^(\w|-|_)+.y*ml")
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
  echo "No playbooks changed"
  exit 0
else
  echo "Playbooks to lint: ${playbooks[*]}"
fi


echo "Put vault key"
echo "$ANSIBLE_VAULT_PASSWORD" > ~/.vault_pass.txt

echo "Run ansible-lint"
# shellcheck disable=SC2068
# i want it to split
ansible-lint ${allplaybooks[@]}
