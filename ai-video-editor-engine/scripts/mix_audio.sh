#!/usr/bin/env bash
# Mix voice-over + music (+ optional SFX stem) with ducking, then two-pass loudness normalization.
# Usage: bash scripts/mix_audio.sh <outdir> <music.wav> [vo.wav|-] [sfx.wav|-] [LUFS=-14] [TP=-1.5]
# Output: <outdir>/master.wav (48 kHz, 24-bit) and <outdir>/loudness.json (measured numbers)
set -euo pipefail
OUT="${1:?outdir}"; MUS="${2:?music}"; VO="${3:--}"; SFX="${4:--}"; LUFS="${5:--14}"; TP="${6:--1.5}"
mkdir -p "$OUT"
IN=(-i "$MUS"); FC="[0:a]aformat=sample_rates=48000:channel_layouts=stereo[m]"; LAST="[m]"; n=1
if [ "$VO" != "-" ]; then
  IN+=(-i "$VO"); FC+=";[${n}:a]aformat=sample_rates=48000:channel_layouts=stereo,asplit=2[vo][vosc]"
  # music sits ~12 dB under the voice and ducks further while the voice speaks
  FC+=";[m]volume=-12dB[mq];[mq][vosc]sidechaincompress=threshold=0.03:ratio=8:attack=20:release=400[md]"
  FC+=";[md][vo]amix=inputs=2:normalize=0:duration=longest[bus]"; LAST="[bus]"; n=$((n+1))
fi
if [ "$SFX" != "-" ]; then
  IN+=(-i "$SFX"); FC+=";[${n}:a]aformat=sample_rates=48000:channel_layouts=stereo[sx];${LAST}[sx]amix=inputs=2:normalize=0:duration=longest[bus2]"; LAST="[bus2]"; n=$((n+1))
fi
ffmpeg -y -v error "${IN[@]}" -filter_complex "$FC" -map "$LAST" -ar 48000 -c:a pcm_s24le "$OUT/premix.wav"
M=$(ffmpeg -hide_banner -nostats -i "$OUT/premix.wav" -af "loudnorm=I=$LUFS:TP=$TP:LRA=11:print_format=json" -f null - 2>&1 | sed -n '/^{/,/^}/p')
get() { echo "$M" | python3 -c "import sys,json; print(json.load(sys.stdin)['$1'])"; }
ffmpeg -y -v error -i "$OUT/premix.wav" -af "loudnorm=I=$LUFS:TP=$TP:LRA=11:measured_I=$(get input_i):measured_TP=$(get input_tp):measured_LRA=$(get input_lra):measured_thresh=$(get input_thresh):offset=$(get target_offset):linear=true" -ar 48000 -c:a pcm_s24le "$OUT/master.wav"
R=$(ffmpeg -hide_banner -nostats -i "$OUT/master.wav" -af ebur128=peak=true -f null - 2>&1 | tail -n 14)
I=$(echo "$R" | grep -E "^\s+I:" | tail -1 | awk '{print $2}'); P=$(echo "$R" | grep -E "Peak:" | tail -1 | awk '{print $2}'); LRA=$(echo "$R" | grep -E "LRA:" | head -1 | awk '{print $2}')
printf '{"target_lufs": %s, "target_tp": %s, "measured_integrated_lufs": %s, "measured_true_peak_dbtp": %s, "measured_lra": %s}\n' "$LUFS" "$TP" "${I:-null}" "${P:-null}" "${LRA:-null}" | tee "$OUT/loudness.json"
