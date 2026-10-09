#!/usr/bin/env bash
set -euo pipefail

for attempt in $(seq 1 12); do
  if curl --fail --silent --show-error http://localhost/ >/dev/null; then
    exit 0
  fi
  sleep 5
done

exit 1
