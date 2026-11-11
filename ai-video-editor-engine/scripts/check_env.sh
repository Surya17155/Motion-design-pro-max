#!/usr/bin/env bash
# Environment report for the Video Director engine. Exit 0 if every CRITICAL tool exists.
# Usage: bash scripts/check_env.sh
crit=0
row() { printf "%-22s %-8s %s\n" "$1" "$2" "$3"; }
need() { # name, command, critical(1/0), install hint, version command
  if command -v "$2" >/dev/null 2>&1; then row "$1" "OK" "$(eval "$5" 2>&1 | head -1 | cut -c1-70)"; else
    if [ "$3" = "1" ]; then row "$1" "MISSING" "REQUIRED. $4"; crit=1; else row "$1" "missing" "optional. $4"; fi; fi; }
echo "== Video Director environment check =="
need "node"       node    1 "Install Node 22+ from nodejs.org"                    "node -v"
need "npm"        npm     1 "Comes with Node"                                     "npm -v"
need "python3"    python3 1 "Install Python 3.10+"                                "python3 --version"
need "git"        git     1 "Install git"                                         "git --version"
need "ffmpeg"     ffmpeg  1 "brew install ffmpeg | sudo apt install ffmpeg"      "ffmpeg -version"
need "ffprobe"    ffprobe 1 "Comes with ffmpeg"                                   "ffprobe -version"
need "yt-dlp"     yt-dlp  0 "python3 -m pip install -U yt-dlp"                    "yt-dlp --version"
need "whisper"    whisper 0 "python3 -m pip install -U openai-whisper"            "whisper --help"
need "bun"        bun     0 "Needed only for the Motion-as-Code kit: bun.sh"      "bun --version"
need "cargo"      cargo   0 "Needed only to build audio-analyzer-rs: rustup.rs"   "cargo --version"
need "claude"     claude  0 "Claude Code CLI (plugins, MCP)"                      "claude --version"
need "blender"    blender 0 "Level 3 product renders: blender.org"               "blender --version"
CH=""; for c in google-chrome chromium chromium-browser; do command -v $c >/dev/null 2>&1 && CH=$c && break; done
[ -z "$CH" ] && for p in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "/usr/bin/google-chrome" "/usr/bin/chromium"; do [ -x "$p" ] && CH="$p" && break; done
[ -n "${CHROME:-}" ] && CH="$CHROME"
if [ -n "$CH" ]; then row "chrome/chromium" "OK" "$CH"; else row "chrome/chromium" "missing" "needed for headless renders. Install Chrome or set CHROME=/path"; fi
if command -v ffmpeg >/dev/null 2>&1; then
  ffmpeg -hide_banner -encoders 2>/dev/null | grep -q libx264 && row "ffmpeg libx264" "OK" "" || { row "ffmpeg libx264" "MISSING" "REQUIRED. Install a full ffmpeg build"; crit=1; }
  ffmpeg -hide_banner -filters 2>/dev/null | grep -q loudnorm && row "ffmpeg loudnorm" "OK" "" || { row "ffmpeg loudnorm" "MISSING" "REQUIRED for loudness"; crit=1; }
  ffmpeg -hide_banner -filters 2>/dev/null | grep -q sidechaincompress && row "ffmpeg sidechain" "OK" "" || row "ffmpeg sidechain" "missing" "needed for ducking"
fi
python3 - <<'PY'
import importlib
for m,c in [("numpy",1),("PIL",1),("scipy",0),("cv2",0)]:
    try: importlib.import_module(m); print("%-22s %-8s" % ("py:"+m,"OK"))
    except Exception: print("%-22s %-8s %s" % ("py:"+m,"missing" if not c else "MISSING","python3 -m pip install numpy pillow scipy opencv-python"))
PY
if command -v nvidia-smi >/dev/null 2>&1; then row "gpu" "OK" "$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)"; else row "gpu" "none" "CPU rendering (use draft settings); Apple GPUs are used automatically by Chrome"; fi
echo; [ $crit = 0 ] && echo "RESULT: ready (all critical tools found)" || echo "RESULT: NOT ready (install the REQUIRED items above)"
exit $crit
