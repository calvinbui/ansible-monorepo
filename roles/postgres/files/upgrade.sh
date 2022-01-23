#!/usr/bin/env bash

set -euo pipefail

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

read -rp "Stop any and all databases and applications before continue. Press <ENTER> to continue"

read -rp "Path to postgres (e.g. /apps/joplin/postgres): " PG_PATH
if [[ -z $PG_PATH ]]; then
  echo "Nothing entered"
  exit 1
fi

read -rp "PostgreSQL username?: " PG_USER
if [[ -z $PG_USER ]]; then
  echo "Nothing entered"
  exit 1
fi

PG_OLD_VERSION=$(<"${PG_PATH}"/PG_VERSION)
echo "Old version found is ${PG_OLD_VERSION}"

read -rp "Enter new version to upgrade to (e.g. 13): " PG_NEW_VERSION
if [[ -z $PG_NEW_VERSION ]]; then
  echo "Nothing entered"
  exit 1
fi

work_dir=$(mktemp -d /tmp/postgres_upgrade.XXXXXXXX)
echo "Created temporary directory ${work_dir}"

mkdir -p "${work_dir}/${PG_OLD_VERSION}"
mkdir -p "${work_dir}/${PG_NEW_VERSION}/data"
cp -R "$PG_PATH" "${work_dir}/${PG_OLD_VERSION}/data"
chmod -R 777 "${work_dir}"

docker run --rm \
  -e PGUSER="${PG_USER}" \
  -e POSTGRES_INITDB_ARGS="-U ${PG_USER}" \
  -v "${work_dir}":/var/lib/postgresql \
  "tianon/postgres-upgrade:${PG_OLD_VERSION}-to-${PG_NEW_VERSION}" \
  --link

echo "host all all all md5" >> "${work_dir}/${PG_NEW_VERSION}/data/pg_hba.conf"

backup_path="${PG_PATH}-${PG_OLD_VERSION}"
mv "$PG_PATH" "$backup_path"
mv "${work_dir}/${PG_NEW_VERSION}/data" "$PG_PATH"

echo ""
echo ""
echo "$PG_PATH has been upgraded from $PG_OLD_VERSION to $PG_NEW_VERSION"
echo "A backup has been created at $backup_path"
echo "Updated the postgres db to $PG_NEW_VERSION"
