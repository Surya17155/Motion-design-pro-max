#!/usr/bin/env bash
# Render a HyperFrames project to MP4. Usage: bash scripts/render_hyperframes.sh <project-dir>
set -euo pipefail
DIR="${1:?project dir}"; cd "$DIR"
[ -f package.json ] || { echo "Not a HyperFrames project. Create one: npx hyperframes init <dir>"; exit 2; }
npx hyperframes render
