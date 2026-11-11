#!/usr/bin/env bash
# Transcode a master MP4 into delivery presets.
# Usage: bash scripts/deliver.sh <master.mp4> <outdir> <youtube|linkedin|reels|tv|master>
set -euo pipefail
IN="${1:?master.mp4}"; OUT="${2:?outdir}"; P="${3:-youtube}"; mkdir -p "$OUT"; B="$(basename "${IN%.*}")"
case "$P" in
  youtube)  ffmpeg -y -v error -i "$IN" -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -profile:v high -movflags +faststart -c:a aac -b:a 320k -ar 48000 "$OUT/${B}_youtube.mp4";;
  linkedin) ffmpeg -y -v error -i "$IN" -c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p -movflags +faststart -r 30 -c:a aac -b:a 256k -ar 48000 "$OUT/${B}_linkedin.mp4";;
  reels)    ffmpeg -y -v error -i "$IN" -c:v libx264 -preset slow -crf 20 -maxrate 10M -bufsize 20M -pix_fmt yuv420p -movflags +faststart -r 30 -c:a aac -b:a 256k -ar 48000 "$OUT/${B}_reels.mp4";;
  tv)       ffmpeg -y -v error -i "$IN" -c:v prores_ks -profile:v 3 -pix_fmt yuv422p10le -c:a pcm_s24le -ar 48000 "$OUT/${B}_tv_prores422hq.mov"; echo "NOTE: confirm the broadcaster's loudness spec (often -23 LUFS EBU R128 / -24 LKFS ATSC) and re-run mix_audio.sh with that target";;
  master)   ffmpeg -y -v error -i "$IN" -c:v libx264 -preset slow -crf 12 -pix_fmt yuv420p -c:a pcm_s24le "$OUT/${B}_master.mov";;
  *) echo "unknown preset: $P"; exit 2;;
esac
ffmpeg -y -v error -ss 1 -i "$IN" -frames:v 1 "$OUT/${B}_thumb.jpg" || true
echo "delivered ($P) -> $OUT"
