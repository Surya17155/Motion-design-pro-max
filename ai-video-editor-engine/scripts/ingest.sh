#!/usr/bin/env bash
# Ingest a reference video (URL or local file) into an analysis folder.
# Usage: bash scripts/ingest.sh "<url-or-path>" <outdir> [fps]
# Output: source.mp4 probe.json frames/ contact.jpg audio.wav scenes.txt
# Reference videos are for private analysis only. Never reuse their footage, music, logos or copy.
set -euo pipefail
SRC="${1:?usage: ingest.sh <url-or-path> <outdir> [fps]}"; OUT="${2:?outdir}"; FPS="${3:-2}"
mkdir -p "$OUT/frames"; LOG="$OUT/ingest.log"; : > "$LOG"
if [[ "$SRC" =~ ^https?:// ]]; then
  command -v yt-dlp >/dev/null || { echo "yt-dlp is missing. Install: python3 -m pip install -U yt-dlp"; exit 2; }
  yt-dlp -f "bv*[height<=1080]+ba/b[height<=1080]/b" --merge-output-format mp4 -o "$OUT/source.%(ext)s" "$SRC" >>"$LOG" 2>&1 \
    || { echo "Download failed (see $LOG). Try: python3 -m pip install -U yt-dlp, or use a local file."; exit 3; }
else
  [ -f "$SRC" ] || { echo "File not found: $SRC"; exit 2; }
  ext="${SRC##*.}"; [ "$ext" = "mp4" ] && cp "$SRC" "$OUT/source.mp4" || ffmpeg -y -v error -i "$SRC" -c:v libx264 -crf 18 -c:a aac "$OUT/source.mp4"
fi
V="$OUT/source.mp4"
ffprobe -v error -print_format json -show_format -show_streams "$V" > "$OUT/probe.json"
ffmpeg -y -v error -i "$V" -vf "fps=$FPS,scale=640:-2" "$OUT/frames/f_%04d.jpg"
ffmpeg -y -v error -i "$V" -vn -ac 1 -ar 48000 -c:a pcm_s24le "$OUT/audio.wav" || echo "no audio track" >>"$LOG"
ffmpeg -i "$V" -vf "select='gt(scene,0.30)',showinfo" -an -f null - 2>&1 | grep -o 'pts_time:[0-9.]*' | sed 's/pts_time://' > "$OUT/scenes.txt" || true
# contact sheet: one frame per second, 6 columns
ffmpeg -y -v error -i "$V" -vf "fps=1,scale=320:-2,tile=6x6" -frames:v 1 "$OUT/contact.jpg" || true
DUR=$(python3 -c "import json;print(round(float(json.load(open('$OUT/probe.json'))['format']['duration']),2))")
echo "ingested $V  duration=${DUR}s  frames=$(ls "$OUT/frames" | wc -l)  cuts=$(wc -l < "$OUT/scenes.txt")"
