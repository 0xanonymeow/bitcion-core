#!/usr/bin/env bash
set -e

if [ "$echo "$1" | cut -c1-1" = "-" ]; then
  set -- bitcoind "$@"
fi

if [ "$1" = "bitcoind" ] || [ "$1" = "bitcoin-cli" ]; then
    set -- "$1" -conf="$COIN_CONF_FILE" "${@:2}"
fi

if [ "$1" = "bitcoind" ]; then
    set -- "$@" -printtoconsole
fi

echo "$@"
if [ "$1" = "bitcoind" ] || [ "$1" = "bitcoin-cli" ] || [ "$1" = "bitcoin-tx" ]; then
    exec "$@"
fi
