#!/usr/bin/env bash
# Seed a few sample records through the public API (proves the write path).
set -euo pipefail
API="${API_URL:-http://localhost:8000}"

for name in "Load ATL->DAL" "Load LAX->PHX" "Load CHI->DET"; do
  curl -fsS -X POST "$API/api/items" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$name\"}" > /dev/null
  echo "created: $name"
done
echo "Done. Open http://localhost:5173"
