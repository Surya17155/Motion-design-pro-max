#!/usr/bin/env bash
# Generate the tiny sample reference video used by the test launch (no downloads needed).
# Usage: bash scripts/make_sample.sh <out.mp4>
set -euo pipefail
OUT="${1:-tests/sample/sample_reference.mp4}"; mkdir -p "$(dirname "$OUT")"
ffmpeg -y -v error \
  -f lavfi -i "testsrc2=size=1280x720:rate=30:duration=4" \
  -f lavfi -i "smptebars=size=1280x720:rate=30:duration=4" \
  -f lavfi -i "sine=frequency=880:beep_factor=4:duration=8" \
  -f lavfi -i "sine=frequency=110:duration=8" \
  -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0[v];[2:a]volume=0.5[b];[3:a]volume=0.15[d];[b][d]amix=inputs=2:normalize=0[a]" \
  -map "[v]" -map "[a]" -c:v libx264 -crf 28 -pix_fmt yuv420p -c:a aac -b:a 128k -shortest "$OUT"
echo "sample: $OUT ($(du -h "$OUT" | cut -f1))"
