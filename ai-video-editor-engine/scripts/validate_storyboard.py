#!/usr/bin/env python3
"""Validate a per-second storyboard JSON.
Usage: python3 scripts/validate_storyboard.py <storyboard.json> [--seconds 60]
Checks: list of entries, consecutive integer seconds from 1, required fields non-empty, repo_tools is a non-empty list,
and flags duplicate visual descriptions. Exit 0 = valid."""
import json, sys
REQ = ["second", "visual_description", "animation_description", "transition_from_previous", "audio_description", "repo_tools"]
def main():
    if len(sys.argv) < 2: sys.exit(__doc__)
    path = sys.argv[1]; secs = int(sys.argv[sys.argv.index("--seconds") + 1]) if "--seconds" in sys.argv else None
    d = json.load(open(path, encoding="utf-8"))
    rows = d["storyboard"] if isinstance(d, dict) and "storyboard" in d else d
    errs = []
    if not isinstance(rows, list): sys.exit("FAIL: storyboard must be a list (or an object with a 'storyboard' list)")
    if secs and len(rows) != secs: errs.append(f"expected {secs} entries, found {len(rows)}")
    seen = set()
    for i, r in enumerate(rows, 1):
        if r.get("second") != i: errs.append(f"entry {i}: 'second' should be {i}, got {r.get('second')}")
        for k in REQ:
            v = r.get(k)
            if v in (None, "", []): errs.append(f"second {i}: missing '{k}'")
        if not isinstance(r.get("repo_tools"), list): errs.append(f"second {i}: repo_tools must be a list")
        v = (r.get("visual_description") or "").strip().lower()
        if v in seen: errs.append(f"second {i}: duplicate visual_description")
        seen.add(v)
    if errs:
        print("FAIL"); [print(" -", e) for e in errs[:30]]; sys.exit(1)
    print(f"PASS: {len(rows)} entries, seconds 1..{len(rows)}, all required fields present")
if __name__ == "__main__":
    main()
