#!/usr/bin/env bash

# ==============================================================================
# Performs maintenance (COLLATION REFRESH, REINDEX, VACUUM) on PostgreSQL
# databases in Podman containers with names containing '-postgres'.
# ==============================================================================

set -euo pipefail

# --- Configuration ---
CONTAINER_PATTERN='-postgres'

# --- Pre-flight Checks ---
if ! command -v sudo &> /dev/null; then
    echo "ERROR: sudo not found" >&2
    exit 1
fi

if ! sudo podman --version &> /dev/null 2>&1; then
    echo "ERROR: podman not accessible with sudo" >&2
    exit 1
fi

echo "================================================================="
echo "PostgreSQL Maintenance Script - Starting"
echo "================================================================="

# Find containers
CONTAINERS=$(sudo podman ps --format '{{.Names}}' | grep -F -- "$CONTAINER_PATTERN" || true)

if [ -z "$CONTAINERS" ]; then
    echo "No containers found matching pattern: $CONTAINER_PATTERN"
    exit 0
fi

echo "Found containers:"
echo "$CONTAINERS"
echo "-----------------------------------------------------------------"

# Process each container
for CONTAINER in $CONTAINERS; do
    echo ">>> Container: $CONTAINER"

    # Get the PostgreSQL user from container environment
    PG_USER=$(sudo podman exec "$CONTAINER" printenv POSTGRES_USER 2>/dev/null || echo "postgres")

    # Get database list (excluding template0)
    DB_QUERY="SELECT datname FROM pg_database WHERE datname NOT IN ('template0') ORDER BY datname;"

    DATABASES=$(sudo podman exec "$CONTAINER" \
        psql -w -U "$PG_USER" -d postgres -t -A -c "$DB_QUERY" 2>/dev/null | tr -d '\r' || true)

    if [ -z "$DATABASES" ]; then
        echo "  [WARNING] Cannot retrieve databases, skipping container"
        continue
    fi

    # Process each database
    while IFS= read -r DB; do
        DB=$(echo "$DB" | xargs)
        [ -z "$DB" ] && continue

        echo ""
        echo "[$CONTAINER/$DB]"

        # Execute and show everything - no heredoc, direct commands
        sudo podman exec -it "$CONTAINER" \
            psql -U "$PG_USER" -d "$DB" <<-PSQL
\set ON_ERROR_STOP on
\echo 'Refreshing collation version...'
ALTER DATABASE "$DB" REFRESH COLLATION VERSION;
\echo 'Reindexing database...'
REINDEX DATABASE CONCURRENTLY "$DB";
\echo 'Analyzing...'
ANALYZE;
\echo 'Done'
\q
PSQL

        if [ $? -eq 0 ]; then
            echo "[SUCCESS]"
        else
            echo "[FAILED]" >&2
        fi

    done <<< "$DATABASES"

    echo ""

    echo "--- Finished: $CONTAINER"
done

echo "================================================================="
echo "Maintenance Complete"
echo "================================================================="
