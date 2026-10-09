#!/usr/bin/env bash
set -euo pipefail

if [ -f /opt/laravel-deploy/deployment.env ]; then
  source /opt/laravel-deploy/deployment.env
fi

docker rm -f "laravel-${APP_COMPONENT:-backend}" 2>/dev/null || true
