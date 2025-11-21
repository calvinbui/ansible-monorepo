#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

APP_NAME=$1

set -euo pipefail

if [[ -z $APP_NAME ]]; then
  read -rp "Application name (e.g. joplin): " APP_NAME
  if [[ -z $APP_NAME ]]; then
    echo "Nothing entered"
    exit 1
  fi
fi

PG_PATH="/apps/${APP_NAME}/postgres"

# Check if PG_PATH exists
if [ ! -d "$PG_PATH" ]; then
    echo "Error: Postgres directory $PG_PATH does not exist."
    exit 1
fi

PG_USER=$(podman inspect "${APP_NAME}-postgres" -f '{{json .Config.Env }}' | jq -r '.[] | select(test("^POSTGRES_USER=*")) | sub("POSTGRES_USER="; "")')

PG_OLD_VERSION=$(<"${PG_PATH}"/PG_VERSION)
PG_NEW_VERSION=$((PG_OLD_VERSION + 1))
echo "Upgrading from ${PG_OLD_VERSION} to ${PG_NEW_VERSION}"

echo "Stopping $APP_NAME"
for c in $(podman ps -a --format '{{.Names}}' | grep "^${APP_NAME}" | sort); do
  podman stop "$c" || true
done

# ---------------------------------------------------------
# STEP 1: Enable pg_checksums on the existing database
# ---------------------------------------------------------
echo "Enabling data checksums on existing database (Version ${PG_OLD_VERSION})..."

# We use the image matching the OLD version to ensure binary compatibility for the tool
if [[ $PG_OLD_VERSION -lt 18 ]]; then
  podman run --rm \
    -v "${PG_PATH}:/var/lib/postgresql/data" \
    "public.ecr.aws/docker/library/postgres:${PG_OLD_VERSION}" \
    pg_checksums --enable --progress -D /var/lib/postgresql/data || true

  echo "Checksums enabled."
fi

# ---------------------------------------------------------
# STEP 2: Prepare Upgrade Environment
# ---------------------------------------------------------

work_dir=$(mktemp -d /tmp/postgres_upgrade.XXXXXXXX)
echo "Created temporary directory ${work_dir}"
echo "Creating working directories"

# Handle directory structure based on version
if [[ $PG_NEW_VERSION -ge 18 ]]; then
  # PostgreSQL 18+ uses version-specific PGDATA
  echo "Using PostgreSQL 18+ directory structure for upgrade"
  mkdir -p "${work_dir}/${PG_OLD_VERSION}/data"
  mkdir -p "${work_dir}/${PG_NEW_VERSION}/docker"

  # Copy old data - upgrade container expects it at /OLD_VERSION/data
  cp -R "$PG_PATH"/* "${work_dir}/${PG_OLD_VERSION}/data/"
else
  # Pre-18 uses simple data directory
  echo "Using pre-18 directory structure"
  mkdir -p "${work_dir}/${PG_OLD_VERSION}"
  mkdir -p "${work_dir}/${PG_NEW_VERSION}/data"
  cp -R "$PG_PATH" "${work_dir}/${PG_OLD_VERSION}/data"
fi

chmod -R 777 "${work_dir}"

echo "Starting upgrade container"

# ---------------------------------------------------------
# STEP 3: Run the Upgrade
# ---------------------------------------------------------

if [[ $PG_NEW_VERSION -ge 18 ]]; then
  # For upgrades TO PostgreSQL 18+
  podman run --rm \
    --name "${APP_NAME}-postgres-${PG_NEW_VERSION}-upgrade" \
    -e PGUSER="${PG_USER}" \
    -e POSTGRES_INITDB_ARGS="-U ${PG_USER}" \
    -v "${work_dir}":/var/lib/postgresql \
    "docker.io/tianon/postgres-upgrade:${PG_OLD_VERSION}-to-${PG_NEW_VERSION}" \
    --link

  # pg_hba.conf location inside the temp struct for 18+ is inside /docker
  echo "host all all all md5" >> "${work_dir}/${PG_NEW_VERSION}/docker/pg_hba.conf"

  echo "Creating a backup of old data"
  backup_path="${PG_PATH}-${PG_OLD_VERSION}"
  mv "$PG_PATH" "$backup_path"

  # ---------------------------------------------------------
  # STEP 4: Final Move (New Structure for PG 18+)
  # ---------------------------------------------------------
  echo "Creating new versioned directory structure: ${PG_PATH}/${PG_NEW_VERSION}"

  # Re-create the base app postgres folder
  mkdir -p "${PG_PATH}/${PG_NEW_VERSION}"

  echo "Moving upgraded data to ${PG_PATH}/${PG_NEW_VERSION}/docker"
  # Move the 'docker' directory from temp to the host path
  mv "${work_dir}/${PG_NEW_VERSION}/docker" "${PG_PATH}/${PG_NEW_VERSION}/"

else
  # For upgrades before PostgreSQL 18 (Legacy behavior)
  podman run --rm \
    --name "${APP_NAME}-postgres-${PG_NEW_VERSION}-upgrade" \
    -e PGUSER="${PG_USER}" \
    -e POSTGRES_INITDB_ARGS="-U ${PG_USER}" \
    -v "${work_dir}":/var/lib/postgresql \
    "docker.io/tianon/postgres-upgrade:${PG_OLD_VERSION}-to-${PG_NEW_VERSION}" \
    --link

  echo "host all all all md5" >> "${work_dir}/${PG_NEW_VERSION}/data/pg_hba.conf"

  echo "Creating a backup"
  backup_path="${PG_PATH}-${PG_OLD_VERSION}"
  mv "$PG_PATH" "$backup_path"

  echo "Move upgraded data"
  mv "${work_dir}/${PG_NEW_VERSION}/data" "$PG_PATH"
fi

# Cleanup temp dir
rm -rf "$work_dir"

echo ""
echo ""
echo "${APP_NAME}-postgres has been upgraded from $PG_OLD_VERSION to $PG_NEW_VERSION"
echo "A backup has been created at $backup_path"

if [[ $PG_NEW_VERSION -ge 18 ]]; then
  echo ""
  echo "⚠️  IMPORTANT: PostgreSQL 18+ uses a new directory structure"
  echo "   The data is now located at: ${PG_PATH}/${PG_NEW_VERSION}/docker"
  echo ""
  echo "   You MUST update your container mount in your systemd unit or compose file:"
  echo "   OLD: -v ${PG_PATH}:/var/lib/postgresql/data"
  echo "   NEW: -v ${PG_PATH}:/var/lib/postgresql"
  echo ""
  echo "   (The container will automatically detect the versioned path inside)"
fi

echo "Updated the postgres db to $PG_NEW_VERSION"
