#!/usr/bin/env bash

set -euo pipefail

DOMAIN=$1
PASSWORD=$2
ACMESH_INSTALL_DIRECTORY=$3
CERT_DIRECTORY=$4
PLEX_DIRECTORY=$5

shopt -s expand_aliases
# shellcheck source=/dev/null
source "${ACMESH_INSTALL_DIRECTORY}/acme.sh.env"

acme.sh \
  --toPkcs \
  --domain "$DOMAIN" \
  --password "$PASSWORD" \
  --ecc

cp "${CERT_DIRECTORY}/${DOMAIN}.pfx" "${PLEX_DIRECTORY}/cert.p12"

PLEX_UID="$(docker inspect plex --format='{% raw %}{{range .Config.Env}}{{if eq (index (split . "=") 0) "PLEX_UID"}}{{index (split . "=") 1}}{{end}}{{end}}{% endraw %}')"
PLEX_GID="$(docker inspect plex --format='{% raw %}{{range .Config.Env}}{{if eq (index (split . "=") 0) "PLEX_GID"}}{{index (split . "=") 1}}{{end}}{{end}}{% endraw %}')"

chown "${PLEX_UID}":"${PLEX_GID}" "${PLEX_DIRECTORY}/cert.p12"
