#!/usr/bin/env bash

set -eo pipefail

git config --global --add safe.directory /drone/src

allplaybooks=( )

# playbook updates
if [[ -z $playbooks ]]; then
  mapfile -t allplaybooks < <(git show --name-only --diff-filter=ACMRTU HEAD | grep -E "^(\w|-|_)+.y*ml")
else
  IFS="," read -r -a playbooks <<< "${playbooks[@]}"

  for playbook in "${playbooks[@]}"; do
    if [[ $playbook != *.yml ]]; then
      playbook="${playbook}.yml"
    fi

    allplaybooks+=( "$playbook" )
  done
fi

# role updates
mapfile -t roles < <(git show --name-only --diff-filter=ACMRTU HEAD | grep -E "^roles/(\w|-|_)+/.*" | cut -d "/" -f2)
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
  echo "--- No playbooks or roles changed"
  exit 0
fi

if [ ! -f ~/.vault_pass.txt ]; then
  echo "--- Put vault key"
  echo "$ANSIBLE_VAULT_PASSWORD" > ~/.vault_pass.txt
fi

# shellcheck disable=SC2068
# i want it to split
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook ${allplaybooks[@]}
