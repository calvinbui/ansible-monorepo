#!/usr/bin/env bash

FULLCHAIN=$1
KEYFILE=$2

cat "$FULLCHAIN" "$KEYFILE" > /etc/ssl/snakeoil.pem

systemctl reload haproxy
