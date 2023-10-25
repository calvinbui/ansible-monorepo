#!/usr/bin/env bash

set -eo pipefail

mapfile -t allplaybooks < <(git diff --name-only -r HEAD^1 HEAD | grep -E "^(\w|-|_)+.y*ml")

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
