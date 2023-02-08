#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
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

PG_USER=$(docker inspect "${APP_NAME}-postgres" -f '{{json .Config.Env }}' | jq -r '.[] | select(test("^POSTGRES_USER=*")) | sub("POSTGRES_USER="; "")')

PG_OLD_VERSION=$(<"${PG_PATH}"/PG_VERSION)
PG_NEW_VERSION=$(( PG_OLD_VERSION + 1))
echo "Upgrading from ${PG_OLD_VERSION} to ${PG_NEW_VERSION}"

work_dir=$(mktemp -d /tmp/postgres_upgrade.XXXXXXXX)
echo "Created temporary directory ${work_dir}"

echo "Stopping $APP_NAME"
docker stop "$APP_NAME"
docker stop "${APP_NAME}-postgres"

echo "Creating working directories"
mkdir -p "${work_dir}/${PG_OLD_VERSION}"
mkdir -p "${work_dir}/${PG_NEW_VERSION}/data"
cp -R "$PG_PATH" "${work_dir}/${PG_OLD_VERSION}/data"
chmod -R 777 "${work_dir}"

echo "Starting upgrade container"
docker run --rm \
  --name "${APP_NAME}-postgres-${PG_NEW_VERSION}-upgrade" \
  -e PGUSER="${PG_USER}" \
  -e POSTGRES_INITDB_ARGS="-U ${PG_USER}" \
  -v "${work_dir}":/var/lib/postgresql \
  "tianon/postgres-upgrade:${PG_OLD_VERSION}-to-${PG_NEW_VERSION}" \
  --link

echo "host all all all md5" >> "${work_dir}/${PG_NEW_VERSION}/data/pg_hba.conf"

echo "Creating a backup"
backup_path="${PG_PATH}-${PG_OLD_VERSION}"
mv "$PG_PATH" "$backup_path"

echo "Move upgraded data"
mv "${work_dir}/${PG_NEW_VERSION}/data" "$PG_PATH"

echo ""
echo ""
echo "${APP_NAME}-postgres has been upgraded from $PG_OLD_VERSION to $PG_NEW_VERSION"
echo "A backup has been created at $backup_path"
echo "Updated the postgres db to $PG_NEW_VERSION"
