#!/usr/bin/env bash
# Test launch: verifies the engine end to end with a generated sample (no downloads needed).
# Usage: bash tests/run_test_launch.sh
# Output: tests/report/test_report.md, tests/report/logs/*.log, tests/report/out/*
# Each step is PASS, FAIL or SKIPPED (with the exact command that would enable it).
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
R="tests/report"; rm -rf "$R"; mkdir -p "$R/logs" "$R/out"
REPORT="$R/test_report.md"; PASS=0; FAIL=0; SKIP=0
{ echo "# Test launch report"; echo; echo "Date: $(date -u +%FT%TZ)"; echo; echo "| # | Step | Result | Detail |"; echo "|---|---|---|---|"; } > "$REPORT"
N=0
rec() { # status step detail
  N=$((N+1)); echo "| $N | $2 | $1 | $3 |" >> "$REPORT"
  case "$1" in PASS) PASS=$((PASS+1));; FAIL) FAIL=$((FAIL+1));; *) SKIP=$((SKIP+1));; esac
  printf "%-8s %s  %s\n" "$1" "$2" "$3"
}
step() { # name, logname, command... ; sets LAST_OK
  local name="$1" log="$R/logs/$2.log"; shift 2
  if "$@" >"$log" 2>&1; then LAST_OK=1; else LAST_OK=0; fi
}

# 1 environment
step env env bash scripts/check_env.sh
[ "$LAST_OK" = 1 ] && rec PASS "Environment check" "all critical tools found ($R/logs/env.log)" || { rec FAIL "Environment check" "see $R/logs/env.log"; echo "Cannot continue without ffmpeg, Node, Python, git."; cat "$REPORT"; exit 1; }

# 2 sample video
step sample sample bash scripts/make_sample.sh "$R/out/sample_reference.mp4"
[ "$LAST_OK" = 1 ] && rec PASS "Generate sample reference video" "$(tail -1 $R/logs/sample.log)" || rec FAIL "Generate sample reference video" "see $R/logs/sample.log"

# 3 ingest
step ingest ingest bash scripts/ingest.sh "$R/out/sample_reference.mp4" "$R/out/ref01"
[ "$LAST_OK" = 1 ] && rec PASS "Ingest (probe, frames, cuts, contact sheet, audio)" "$(tail -1 $R/logs/ingest.log)" || rec FAIL "Ingest" "see $R/logs/ingest.log"

# 4 audio analysis
python3 scripts/analyze_audio.py "$R/out/ref01/audio.wav" > "$R/out/ref01/audio_facts.json" 2>"$R/logs/analyze.log" && LAST_OK=1 || LAST_OK=0
if [ "$LAST_OK" = 1 ]; then
  S="$(python3 - "$R/out/ref01/audio_facts.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1])); t=d["tempo"]; l=d["loudness"]
print("tempo %s BPM (confidence %s), %s onsets, %s LUFS, true peak %s dBTP" % (t.get("bpm"), t.get("confidence"), d["onset_count"], l["integrated_lufs"], l["true_peak_dbtp"]))
PY
)"; rec PASS "Audio analysis (loudness, onsets, tempo)" "$S"
else rec FAIL "Audio analysis" "see $R/logs/analyze.log"; fi

# 5 storyboard validation
step sb validate python3 scripts/validate_storyboard.py 60s_storyboard_example.json --seconds 60
[ "$LAST_OK" = 1 ] && rec PASS "Validate 60-second storyboard" "$(tail -1 $R/logs/validate.log)" || rec FAIL "Validate storyboard" "see $R/logs/validate.log"

# 6 SFX kit + sync-from-events mix (saas-animation scripts)
SA=".claude/skills/saas-animation/scripts"
python3 -c "import scipy" 2>/dev/null
if [ $? -eq 0 ]; then
  mkdir -p "$R/out/sounds"
  python3 "$SA/synth_sfx.py" "$R/out/sounds" >"$R/logs/synth.log" 2>&1
  cat > "$R/out/events.json" <<'EOF'
[{"name":"hook.slam","t":1.0},{"name":"card.pop","t":2.5},{"name":"final.hit","t":6.0}]
EOF
  cat > "$R/out/cues.json" <<'EOF'
[{"event":"hook.slam","file":"Soft Hit","db":-10,"align":"peak"},
 {"event":"card.pop","file":"Pop","db":-16,"align":"peak"},
 {"event":"card.pop","offset":-0.3,"file":"Whoosh 2","db":-30,"align":"peak"},
 {"event":"final.hit","file":"Soft Hit","db":-8,"align":"peak","pitch":0.9}]
EOF
  python3 "$SA/mix.py" "$R/out/cues.json" "$R/out/sfx.wav" --lib "$R/out/sounds" --events "$R/out/events.json" --len 8 >"$R/logs/sfxmix.log" 2>&1 && LAST_OK=1 || LAST_OK=0
  [ "$LAST_OK" = 1 ] && rec PASS "SFX kit + event-synced SFX stem" "$(grep '^sync:' $R/logs/sfxmix.log)" || rec FAIL "SFX mix" "see $R/logs/sfxmix.log"
else rec SKIPPED "SFX kit + event-synced SFX stem" "needs scipy: python3 -m pip install numpy scipy pillow"; fi

# 7 voice + music + sfx mix with ducking and two-pass loudness (-14 LUFS target)
ffmpeg -y -v error -f lavfi -i "sine=frequency=220:duration=8" -f lavfi -i "sine=frequency=330:duration=8" -filter_complex "amix=inputs=2:normalize=0,tremolo=f=0.5:d=0.3" -ar 48000 "$R/out/music_standin.wav" 2>>"$R/logs/mix.log"
ffmpeg -y -v error -f lavfi -i "sine=frequency=300:duration=8" -af "volume='if(lt(mod(t,2),1),1,0)':eval=frame" -ar 48000 "$R/out/vo_standin.wav" 2>>"$R/logs/mix.log"
SFXARG="-"; [ -f "$R/out/sfx.wav" ] && SFXARG="$R/out/sfx.wav"
bash scripts/mix_audio.sh "$R/out/mix" "$R/out/music_standin.wav" "$R/out/vo_standin.wav" "$SFXARG" -14 -1.5 >"$R/logs/mix.log" 2>&1 && LAST_OK=1 || LAST_OK=0
if [ "$LAST_OK" = 1 ]; then
  CHK="$(python3 - "$R/out/mix/loudness.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1])); I=d["measured_integrated_lufs"]; P=d["measured_true_peak_dbtp"]
ok = I is not None and abs(float(I)+14) <= 1.0 and P is not None and float(P) <= -1.0
print(("OK" if ok else "OUT-OF-TARGET") + " | integrated %s LUFS (target -14), true peak %s dBTP (<= -1.0)" % (I,P))
PY
)"; case "$CHK" in OK*) rec PASS "Mix with ducking + loudness normalization" "$CHK";; *) rec FAIL "Mix with ducking + loudness normalization" "$CHK";; esac
else rec FAIL "Mix with ducking" "see $R/logs/mix.log"; fi

# 8 mux + delivery preset
if [ -f "$R/out/mix/master.wav" ]; then
  ffmpeg -y -v error -i "$R/out/sample_reference.mp4" -i "$R/out/mix/master.wav" -map 0:v -map 1:a -c:v copy -c:a aac -b:a 320k -shortest "$R/out/test_master.mp4" >"$R/logs/mux.log" 2>&1 \
   && bash scripts/deliver.sh "$R/out/test_master.mp4" "$R/out/deliver" youtube >>"$R/logs/mux.log" 2>&1 && LAST_OK=1 || LAST_OK=0
  [ "$LAST_OK" = 1 ] && rec PASS "Mux picture + master audio, deliver YouTube preset" "$(ls $R/out/deliver | tr '\n' ' ')" || rec FAIL "Mux / deliver" "see $R/logs/mux.log"
else rec SKIPPED "Mux / deliver" "no master.wav (mix step failed)"; fi

# 9 Remotion template render (needs npm install + a browser)
TP="templates/remotion-minimal"
if [ -d "$TP/node_modules" ] && { command -v google-chrome >/dev/null || command -v chromium >/dev/null || [ -n "${CHROME:-}" ] || [ -d "$TP/node_modules/.remotion" ]; }; then
  (cd "$TP" && npx remotion still src/index.ts Launch "../../$R/out/remotion_frame.png" --frame=120) >"$R/logs/remotion.log" 2>&1 && LAST_OK=1 || LAST_OK=0
  [ "$LAST_OK" = 1 ] && rec PASS "Remotion template still render" "$R/out/remotion_frame.png" || rec FAIL "Remotion template still render" "see $R/logs/remotion.log"
else
  rec SKIPPED "Remotion template still render" "enable with: (cd $TP && npm install && npx remotion still src/index.ts Launch out/frame.png --frame=120). Requires Node deps, a browser, and a Remotion license check."
fi

# 10 HyperFrames CLI present?
if command -v npx >/dev/null 2>&1 && [ -d node_modules/hyperframes ]; then rec PASS "HyperFrames installed" "node_modules/hyperframes"
else rec SKIPPED "HyperFrames render" "enable with: npx hyperframes init test-hf && cd test-hf && npx hyperframes render (Node 22+, FFmpeg, Chrome)"; fi

{ echo; echo "**Totals:** PASS $PASS, FAIL $FAIL, SKIPPED $SKIP"; echo; echo "Evidence: tests/report/out/ (media, JSON) and tests/report/logs/ (one log per step)."; echo "Not covered by this test: real-time playback, listening to the mix, and full-resolution renders."; } >> "$REPORT"
echo; echo "Report: $REPORT  (PASS $PASS, FAIL $FAIL, SKIPPED $SKIP)"
[ "$FAIL" -eq 0 ]
