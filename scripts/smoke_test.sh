#!/usr/bin/env bash
# Run the end-to-end smoke test against a running backend (delegates to backend).
#   ./scripts/smoke_test.sh         # tests http://localhost:8000
#   BASE=http://host:port ./scripts/smoke_test.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$ROOT/backend/scripts/smoke_test.sh" "$@"
