# AI Video Editor Engine

A folder that turns Claude Code into a motion-graphics and product-launch video studio. You give it a company name, website and (optionally) reference videos. Claude plans the video second by second, shows you the plan, and only then builds it from code, adds sound and checks the result.

Everything is driven by one file: **`skill.md`** (the "Director"). Claude reads it first.

## Start in 5 steps

1. **Unzip** this folder anywhere. Keep the folder structure as it is.
2. **Open Claude Code in this folder** (Claude Desktop → Code tab → choose the folder).
3. **Check the machine:** ask Claude to run `bash scripts/check_env.sh`. It lists anything missing and how to install it (you need Node 22+, Python 3.10+, ffmpeg, git; Chrome is needed for renders).
4. **Install the helpers:** ask Claude to run `bash scripts/setup_repos.sh` and follow `repos/repos.lock.json` for the libraries.
5. **Paste a prompt** from `sample_prompts/` (start with `minimal_url_only.md`). Claude will ask a few questions, show a numbered storyboard, and wait for your approval before building.

Optional first run: say "run the test launch". It checks that the tools work using a tiny generated sample.

## What is inside

| Folder or file | What it is |
|---|---|
| `skill.md` | The Director: rules, workflow, tool choices, audio, QA, delivery |
| `60s_storyboard_example.json` | A 60-row, second-by-second template for a product launch |
| `REPO_MANIFEST.md`, `zip_manifest.txt` | What each repository does and the full file list |
| `repos/repos.lock.json`, `scripts/setup_repos.sh` | Pinned versions and the installer for the skill repos |
| `resources/` | Your Motion-as-Code kit, the saas-animation skill, and the two PDFs |
| `.claude/skills/` | The Director and saas-animation, ready for Claude Code |
| `scripts/` | Helpers: environment check, ingest, audio analysis, mixing, delivery |
| `templates/` | Brief form, storyboard template, QA checklist, Remotion and 3D starters |
| `sample_prompts/` | Copy-paste prompts |
| `tests/` | Sample reference video and the test-launch script |
| `license_notes/LICENSES.md` | Read before client work |

## Things you must know

- **Two repos are not included on purpose.** `metaphrasis` is now proprietary (sold per license) and `onetake` is free only for noncommercial use. Both are off by default for client work. Free replacements for the hearing part are built in.
- **Remotion** has its own license: free for small teams, paid above that. HyperFrames is Apache-2.0 and is the default engine.
- **Reference videos are for study only.** Claude copies the craft (pacing, motion style, sound density), never the footage, logos, copy or music.
- **Paid services** (ElevenLabs, Suno, cloud rendering) are used only when you ask.
- **Spec ads** for brands you do not own are practice pieces and end with "Spec ad. Not affiliated with <brand>."
- Broadcast TV loudness is normally -23 LUFS (EBU R128) or -24 LKFS (US), not -9. Ask the broadcaster.

## What was tested when this was built

Passed on the build machine: environment check, sample video generation, ingest (frames, cuts, contact sheet), audio analysis (tempo on 60 and 120 BPM clicks, a sustained pad correctly flagged as low confidence), storyboard validation, sound-effect synthesis and event-synced mixing (0 ms offset), voice + music + SFX mixing with ducking and loudness normalization (-14.1 LUFS, -1.5 dBTP), muxing and the YouTube preset, pinned-commit cloning, and TypeScript checks of the Remotion and 3D templates.

Not tested (the build machine had no browser): actual Remotion, HyperFrames, Three.js and Motion-as-Code renders, Blender scenes, and the Claude Code plugin installs (`/watch`, rea-video skill, audio-analyzer MCP). Expect to fix small setup issues the first time; the test launch lists each skipped step with its command.
