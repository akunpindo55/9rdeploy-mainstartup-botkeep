#!/bin/sh
set -eu

BASE=${BOTKEEP_ROOT:-/home/container}
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RELEASE="$BASE/9r-standalone-d24d98a"

if [ ! -f "$RELEASE/custom-server.js" ] || [ ! -f "$RELEASE/.next/BUILD_ID" ] || [ ! -d "$RELEASE/node_modules" ]; then
  sh "$SCRIPT_DIR/bootstrap.sh"
fi

if [ ! -f "$RELEASE/custom-server.js" ] || [ ! -f "$RELEASE/.next/BUILD_ID" ] || [ ! -d "$RELEASE/node_modules" ]; then
  echo "9Router runtime is not ready at $RELEASE" >&2
  exit 1
fi

mkdir -p "$BASE/.9router"
cd "$RELEASE"
export NODE_ENV=production
export HOSTNAME=0.0.0.0
export DATA_DIR="$BASE/.9router"
export PORT="${SERVER_PORT:?SERVER_PORT is required by Botkeep}"
exec node custom-server.js --port "$PORT" --hostname 0.0.0.0
