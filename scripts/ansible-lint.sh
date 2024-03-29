#!/usr/bin/env bash

set -eo pipefail

mapfile -t allplaybooks < <(git show --name-only --diff-filter=ACMRTU HEAD | grep -E "^(\w|-|_)+.y*ml" | grep -v requirements.yml)

if [[ "${#allplaybooks[@]}" -eq 0 ]]; then
  echo "No playbooks changed"
  exit 0
else
  echo "Playbooks to lint: ${allplaybooks[*]}"
fi

echo "Put vault key"
echo "$ANSIBLE_VAULT_PASSWORD" > ~/.vault_pass.txt

echo "Run ansible-lint"
# shellcheck disable=SC2068
# i want it to split
ansible-lint ${allplaybooks[@]}
