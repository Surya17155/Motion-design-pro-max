#!/usr/bin/env bash
# Render a Remotion composition. Usage: bash scripts/render_remotion.sh <project-dir> <composition-id> <out.mp4> [draft|final]
# Remotion has its own license: confirm eligibility before client work (license_notes/LICENSES.md).
set -euo pipefail
DIR="${1:?project dir}"; ID="${2:?composition id}"; OUT="${3:?out.mp4}"; MODE="${4:-draft}"
cd "$DIR"; [ -d node_modules ] || npm install
if [ "$MODE" = "draft" ]; then npx remotion render src/index.ts "$ID" "$OUT" --scale=0.5 --crf=28 --concurrency=50%
else npx remotion render src/index.ts "$ID" "$OUT" --crf=17 --concurrency=50%; fi
echo "rendered $OUT ($MODE)"
