#!/bin/sh
# Runs via dumb-init. Fixes named-volume ownership when root, then drops to openwa user
# via gosu. If already non-root (e.g. Render/K8s/PaaS non-root environments), executes CMD directly.
set -e

mkdir -p /app/data/sessions /app/data/media /app/data/plugins 2>/dev/null || true
mkdir -p "${XDG_CONFIG_HOME:-/tmp/.config}" "${XDG_CACHE_HOME:-/tmp/.cache}" 2>/dev/null || true

# Chromium Singleton lock cleanup
rm -f /app/data/sessions/*/Singleton* 2>/dev/null || true

if [ "$(id -u)" = "0" ]; then
  chown -R openwa:openwa /app/data 2>/dev/null || true
  chown openwa:openwa "${XDG_CONFIG_HOME:-/tmp/.config}" "${XDG_CACHE_HOME:-/tmp/.cache}" 2>/dev/null || true
  exec gosu openwa "$@"
else
  exec "$@"
fi
