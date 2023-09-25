#!/usr/bin/env bash

set -euo pipefail

mapfile -t containers < <(docker ps --all --format='{{json .}}' | jq -r -c '. | select( .Image | startswith("postgres") ) | .Names')

for c in "${containers[@]}"; do
  echo "Updating $c"
  docker exec -it "$c" bash -c 'psql -w -U $POSTGRES_USER $POSTGRES_DB -c "REINDEX DATABASE \"${POSTGRES_DB}\""'
  docker exec -it "$c" bash -c 'psql -w -U $POSTGRES_USER $POSTGRES_DB -c "ALTER DATABASE \"${POSTGRES_DB}\" REFRESH COLLATION VERSION"'

  docker exec -it "$c" bash -c 'psql -w -U $POSTGRES_USER postgres -c "REINDEX DATABASE postgres"'
  docker exec -it "$c" bash -c 'psql -w -U $POSTGRES_USER postgres -c "ALTER DATABASE postgres REFRESH COLLATION VERSION"'

  echo ""
done
