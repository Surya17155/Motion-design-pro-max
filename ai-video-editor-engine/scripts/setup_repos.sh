#!/usr/bin/env bash
# Clone the small skill repos listed in repos/repos.lock.json (vendor=true) at their pinned commits into repos/vendor/.
# Libraries (ffmpeg, whisper, three, GSAP, Remotion, HyperFrames...) are installed with their package managers: see the
# "install" field in the lock file. License-gated repos (metaphrasis, onetake) are skipped unless ALLOW_GATED=1 is set
# AFTER the user has confirmed a license.
# Usage: bash scripts/setup_repos.sh [repo-name ...]     (no names = every vendor=true, non-gated repo)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOCK="$ROOT/repos/repos.lock.json"
DEST="$ROOT/repos/vendor"
mkdir -p "$DEST"
command -v git >/dev/null 2>&1 || { echo "git is missing: install git first."; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "python3 is missing: install Python 3.10+ first."; exit 1; }

LIST="$(python3 - "$LOCK" "${ALLOW_GATED:-0}" "$@" <<'PY'
import json, sys
lock = json.load(open(sys.argv[1])); allow = sys.argv[2] == "1"; want = sys.argv[3:]
for r in lock["repos"]:
    short = r["name"].split("/")[-1]
    if not r.get("vendor"):
        continue
    if want and short not in want and r["name"] not in want:
        continue
    if r.get("license_gate") and not allow:
        print("SKIP|%s|%s|" % (r["name"], r.get("license")))
        continue
    print("CLONE|%s|%s|%s" % (r["name"], r["url"], r.get("pinned_sha", "")))
PY
)"

echo "$LIST" | while IFS='|' read -r action name url sha; do
  [ -z "$action" ] && continue
  if [ "$action" = "SKIP" ]; then echo "SKIPPED (license gate): $name -> $url"; continue; fi
  dir="$DEST/$(basename "$name")"
  if [ -d "$dir/.git" ]; then echo "present: $name"; continue; fi
  echo "cloning $name @ ${sha:-latest}"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" remote add origin "$url"
  if [ -n "$sha" ] && git -C "$dir" fetch -q --depth 1 origin "$sha" 2>/dev/null; then :; else git -C "$dir" fetch -q --depth 1 origin || { echo "  FAILED: $name (check the network, then re-run)"; continue; }; fi
  git -C "$dir" checkout -q FETCH_HEAD && echo "  ok: $(git -C "$dir" rev-parse --short HEAD)"
done
echo "Done. Library installs are listed in repos/repos.lock.json (field: install)."
