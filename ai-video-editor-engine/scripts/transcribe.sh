#!/usr/bin/env bash
# Speech-to-text with word timestamps using openai/whisper.
# Usage: bash scripts/transcribe.sh <audio-or-video> <outdir> [model=small] [language]
set -euo pipefail
IN="${1:?usage: transcribe.sh <media> <outdir> [model] [language]}"; OUT="${2:?outdir}"; MODEL="${3:-small}"; LANG_ARG="${4:-}"
command -v whisper >/dev/null || { echo "whisper is missing. Install: python3 -m pip install -U openai-whisper (needs ffmpeg). Or ask claude-video for captions."; exit 2; }
mkdir -p "$OUT"
whisper "$IN" --model "$MODEL" --word_timestamps True --output_format json --output_dir "$OUT" ${LANG_ARG:+--language "$LANG_ARG"} >"$OUT/whisper.log" 2>&1
whisper "$IN" --model "$MODEL" --output_format srt --output_dir "$OUT" ${LANG_ARG:+--language "$LANG_ARG"} >>"$OUT/whisper.log" 2>&1 || true
echo "transcript: $OUT/$(basename "${IN%.*}").json (and .srt)"
