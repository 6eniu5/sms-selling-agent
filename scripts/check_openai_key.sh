#!/usr/bin/env bash
# Verify the OpenAI key works (delegates to the backend submodule).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$ROOT/backend/scripts/check_openai_key.sh" "$@"
