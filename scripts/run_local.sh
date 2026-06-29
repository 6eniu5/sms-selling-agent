#!/usr/bin/env bash
# Boot the backend locally (delegates to the backend submodule).
# Requires submodules initialized:  git submodule update --init --recursive
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$ROOT/backend/scripts/run_local.sh" "$@"
