#!/usr/bin/env bash

set -eo pipefail

allplaybooks=( )

# playbook updates
mapfile -t allplaybooks < <(git show --name-only --diff-filter=ACMRTU HEAD | grep -E "^(\w|-|_)+.y*ml")
echo "Playbooks changed: ${allplaybooks[*]}"

# role updates
mapfile -t roles < <(git show --name-only --diff-filter=ACMRTU HEAD | grep -E "^roles/(\w|-|_)+/.*" | cut -d "/" -f2)
echo "Roles changed: ${roles[*]}"
if (( ${#roles[@]} != 0 )); then
  for role in "${roles[@]}"; do
    mapfile -t playbooks < <(grep "role: ${role}" ./*.yml -l)
    if (( ${#playbooks[@]} != 0 )); then
      for pb in "${playbooks[@]}"; do
        if [[ ! " ${allplaybooks[*]} " =~ $pb ]]; then
          allplaybooks+=( "$pb" )
        fi
      done
    fi
  done
fi

if [[ "${#allplaybooks[@]}" -eq 0 ]]; then
  echo "No playbooks or roles changed"
  exit 0
else
  echo "Playbooks to run: ${allplaybooks[*]}"
fi

if [ ! -f ~/.vault_pass.txt ]; then
  echo "Put vault key"
  echo "$ANSIBLE_VAULT_PASSWORD" > ~/.vault_pass.txt
fi

# shellcheck disable=SC2068
# i want it to split
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook ${allplaybooks[@]}
