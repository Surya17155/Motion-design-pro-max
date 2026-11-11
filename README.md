# Motion Design Pro Max

**Motion Design Pro Max** is a complete, production-grade motion-design and product-launch video engine. It turns Claude Code into a Video Production Director: give it a company name, website, and (optionally) reference videos, and it plans the video second by second, builds it from code, adds sound, and checks the result — no After Effects, no AI video generation unless you ask for it.

Built for non-technical entrepreneurs, agencies, and AI agents who need professional launch-grade motion videos at scale.

#motiondesign #motion-graphics #product-launch #product-video #product-launch-video #saas-animation #ai-video #claude-code #video-engine #motion-graphics-skills #remotion #hyperframes #ffmpeg #threejs #gsap #videoproduction #launchvideo #productmarketing #creativecoding #generativevideo #aivideogeneration #videodirector #motion-design #product-sales-video #explainer-video #brand-video #motion-engine

---

## What this skill is about

This repository is a **skill file bundle** — a collection of instructions, templates, scripts, and reference materials that teach an AI agent (or a human) how to direct the creation of motion-design and product-launch videos entirely from code.

The core of the bundle is `skill.md` (the **Director**). It encodes the working method of a professional motion designer: brief → analysis → per-second storyboard → draft → QA → finals. Everything — timing, easing, camera moves, sound cues, loudness targets — is deterministic and driven by the Director's rules rather than guesswork.

### What you can make with it

- 30–90 second product-launch and explainer videos (16:9, 9:16, 1:1, 4K)
- 8–20 second SaaS, app, and product ads (Level 1: assets only / Level 2: brand art & puppet / Level 3: Blender photoreal)
- Kinetic type, UI mock panels, shader transitions, social overlays
- 3D product turntables, device fly-throughs, real UI floating in 3D space
- Voiceover-locked explainers where animation follows the spoken words
- Videos that run into your own live-action footage
- Spec ads (marked "Spec ad. Not affiliated with <brand>.")

---

## Where to use this

Use this skill whenever you need a **motion-design or product-launch video made from code**, especially when:

- You have a company website or brand context and want a launch video
- You want to match the *craft* (pacing, motion language, sound density) of a reference video without copying its footage, logos, copy, or music
- You need frame-accurate, deterministic renders where preview matches export
- You want sound design, music, and voice-over locked to the picture timeline
- You need delivery presets for YouTube, LinkedIn, Instagram Reels/Shorts, or broadcast

Do **not** use it for live-action filming, AI video generation (unless the user explicitly asks), or anything requiring a client's protected brand assets without permission.

---

## What the structure is

```
Motion-design-pro-max/
├── README.md                    # This file — how to use the skill
├── skill.md                     # The Director: full workflow, rules, QA, delivery
├── REPO_MANIFEST.md             # Pinned repos, license gates, what each tool does
├── 60s_storyboard_example.json  # 60-row second-by-second storyboard schema + example
├── zip_manifest.txt             # Full file manifest of the bundle
│
├── ai-video-editor-engine/      # The engine folder (installed as the working project)
│   ├── skill.md                 # The Director (active copy for Claude Code)
│   ├── README.md                # Engine quick-start (5 steps)
│   ├── REPO_MANIFEST.md         # Engine manifest
│   ├── zip_manifest.txt         # Engine file manifest
│   ├── scripts/                 # check_env, ingest, analyze_audio, mix_audio, deliver, validate_storyboard, etc.
│   ├── templates/               # brief_intake, storyboard_template, qa_checklist, Remotion + 3D starters, sfx cue sheet
│   ├── resources/               # Motion-as-Code kit, saas-animation skill, two PDFs (Amazon spec, Workflow Guide)
│   ├── .claude/skills/          # Active Claude Code skills: video-director, saas-animation
│   ├── sample_prompts/          # Copy-paste prompts (minimal, maximal, stage-by-stage)
│   ├── tests/                   # Test-launch script + sample reference video + checklist
│   ├── license_notes/LICENSES.md# License gates — read before client work
│   └── repos/repos.lock.json    # Pinned repository versions and license gates
│
└── projects/                    # Created at runtime — per-client work (NOT in the zip)
    └── <client-slug>/
        ├── brief.json
        ├── brand/
        ├── references/
        ├── analysis/
        ├── storyboard/
        ├── build/
        ├── audio/
        ├── renders/
        └── report/
```

### Skill file size

- **`skill.md`**: ~50 KB of text (approximately 420–530 lines depending on line-ending counting)
- **Total bundle**: ~110 MB across ~228 files
- The bulk of the size comes from binary assets: fonts (Motion-as-Code kit), SFX MP3s, a sample reference video, and an ONNX audio model
- The *skill instructions themselves* are text-only and lightweight; nothing needs to be loaded into memory all at once — an agent reads sections on demand

Before publishing anywhere, consider that the bundle includes large binary assets (fonts, audio samples, models). If you need a lighter distribution, ship the text instructions + templates + scripts and list the binary assets as optional downloads.

---

## When to use it

| Situation | Use this skill? | Notes |
|-----------|----------------|-------|
| Company URL only, need a launch video | ✅ Yes | Start with `sample_prompts/minimal_url_only.md` |
| Reference video + "match its style" | ✅ Yes | Copies craft (pacing, motion, sound), never the content |
| Voiceover supplied, animation must follow words | ✅ Yes | Motion-as-Code kit: align → plates → render |
| Need a fast 20 s film from a codebase | ✅ Yes | Use `brag-slim` path |
| Physical product needs studio/3D look | ✅ Yes | saas-animation Level 3 + Blender |
| Ad must run into your own live-action footage | ✅ Yes | saas-animation into-footage workflow |
| Client is a large company (above Remotion free tier) | ⚠️ Conditional | Use HyperFrames (Apache-2.0) or confirm a Remotion company license |
| AI video/image generation required | ❌ No | Not unless the user explicitly asks |
| Client's brand assets without permission | ❌ No | Stop and ask; never use unlicensed brand material |

---

## How to use it (step by step)

### Step 0 — Set up the machine

Open Claude Code (Desktop "Code" tab, VS Code, or terminal) in this folder and run:

```bash
bash scripts/check_env.sh           # reports missing tools; you need Node 22+, Python 3.10+, ffmpeg, git
bash scripts/setup_repos.sh         # clones pinned, permissively licensed skill repos into repos/vendor/
npx hyperframes skills update       # installs HyperFrames core skills
```

Critical prerequisites: Node 22+, Python 3.10+, ffmpeg (with libx264 and loudnorm), git, Chrome/Chromium (for headless renders). Optional but recommended: bun, a GPU, Blender, Whisper/WhisperX, yt-dlp, cargo (audio-analyzer-rs).

### Step 1 — Ingest the brand and any references

1. Create `projects/<client-slug>/` with: `brief.json`, `brand/`, `references/`, `analysis/`, `storyboard/`, `build/`, `audio/`, `renders/`, `report/`
2. If you have a brand website, fetch it and extract: company name, one-line offer, audience, colors, fonts, UI style. Write `brand/brand_profile.json`
3. If you have a reference video, ingest it:
   ```bash
   bash scripts/ingest.sh "<url-or-local-path>" projects/<client>/references/ref01
   ```

### Step 2 — Analyze

Run the analysis pipeline for each reference: visual watch (`/watch`), shot boundaries, reverse-engineer (`rea-video`), style fingerprint, contact sheet, audio analysis (transcribe + loudness + tempo), and write `analysis/creative_brief.md`.

### Step 3 — Plan (mandatory approval gate)

Produce `storyboard/storyboard.json` (per-second, 60 entries for 60 s) plus `storyboard/storyboard.md`. Validate:

```bash
python3 scripts/validate_storyboard.py storyboard/storyboard.json --seconds 60
```

Then create a **numbered storyboard** of 5–10 shots (for ads ≤ 20 s; group 60 per-second rows into numbered shots for longer films). Each shot has: number, time range, a still frame made with real assets, the on-screen line, what moves, and how it turns into the next shot. Fill `templates/storyboard_template.md` (or the saas-animation `storyboard.html`) and show a screenshot. **Wait for approval before animating.**

### Step 4 — Build (from code, not by hand)

Choose your engine based on the decision matrix in `skill.md` Section 11:

- **Default**: HyperFrames (HTML + GSAP, Apache-2.0)
- **Remotion**: when React components or an existing scaffold are required (license check first)
- **Motion-as-Code kit**: when a finished voiceover must lock every animation
- **saas-animation**: 8–20 s ads with real UI in 3D space, puppet illustration, or Blender product shots

Build in parallel parts: (A) light and type, (B) UI and device, (C) 3D and camera, (D) sound. Draft at 960×540, 30 fps; approve; then render finals at 60 fps.

### Step 5 — QA (before every review and delivery)

Run contact sheets, frame-by-frame transition review, motion smoothness, audio loudness/sync measurements, phone check, brand check, self-critique (score 0–5 on Hook, Clarity, Hierarchy, Motion, Sound, Brand, CTA — fix anything below 4), pitfall sweep. Save evidence in `report/qa/`.

### Step 6 — Deliver

```bash
bash scripts/deliver.sh renders/master.mp4 renders/deliver youtube   # also: linkedin | reels | tv | master
```

Delivery presets: YouTube (1920×1080 or 4K, H.264 CRF 17–18, −14 LUFS), LinkedIn (1080p or 1:1, −14 LUFS, captions burned in), Instagram Reels/Shorts (1080×1920, −14 LUFS, true peak −1.5), TV/broadcast (per spec, usually −23 LUFS EBU R128 or −24 LKFS ATSC A/85).

Also deliver: thumbnail, optional GIF/loop, `.srt` caption file from Whisper, and `report/delivery_report.md`.

---

## How to use it in the right way (for AI agents and humans)

If a human or AI agent submits a company website or context to Claude with the goal of creating a motion-design video, here is the exact structured way to use this skill file:

### 1. Start with the Director (`skill.md`)

Read `skill.md` in full at the start of every session. Do not skip sections. The Director is written as imperative instructions to the agent — it tells you what to do, in what order, and when to stop and ask the user.

### 2. Gather the brief (do not invent anything)

Ask the Section 3.2 questions until all are answered, and record them in `project/brief.json`:
- Target runtime and aspect ratio(s)
- Brand assets (logo, fonts, colors, screenshots) — available and licensed?
- Voiceover source: user file, ElevenLabs, or free TTS?
- Music source
- Where it will be published (decides loudness, safe areas, captions)
- The ending: what the viewer should do next
- Claims and privacy: every claim must be true and backed; remove personal details from screenshots

If brand assets are absent, ask for: brand voice (3 adjectives), audience, one-sentence offer, primary call to action, desired runtime, aspect ratio. **Never invent logos, product UI copy, statistics, or testimonials.**

### 3. Ingest and analyze before planning

Watch the reference, extract shot boundaries, build a style fingerprint, analyze audio (tempo, key, loudness, silences), and write the creative brief. Timing always comes from measurement (ffmpeg, onsets), never from a language model's guess.

### 4. Plan and get approval before building

Produce the per-second storyboard and the numbered 5–10 shot storyboard. Show still frames made with real assets. Wait for notes. This is the cheapest place to change anything — nothing has been rendered.

### 5. Build from code using one carrier element

Choose one carrier element (a line, a shape, a cursor, a camera path) that hands over scene to scene. Draw it through ONE shared function so it is identical everywhere. Prefer transitions where an element of the outgoing shot becomes an element of the incoming shot (morph, mask-grow, camera push). Use hard cuts only in the pause before a new idea.

### 6. Add sound only after the picture is approved

A changed animation moves every beat. Lock the picture timeline to voice timings, then add music (at least 12 dB under every spoken word), SFX (one cue per visible move), and mix to the target loudness (−14 LUFS social, −16 streaming, broadcast per spec).

### 7. QA with evidence, then deliver

Run contact sheets, frame-by-frame checks, loudness and sync measurements, brand checks, and the pitfall sweep. Score 0–5 on Hook, Clarity, Hierarchy, Motion, Sound, Brand, CTA. Fix anything below 4. Deliver with the right preset, a thumbnail, captions, and a delivery report.

### 8. Report honestly

Before each phase, say what will happen in one sentence. After each phase, show one artifact and ask one question. Never claim a result that was not measured. List what was checked (stills, sheets, measurements) and what was not (real-time playback, listening).

---

## License gates (read before client work)

| Tool | Status | Rule |
|------|--------|------|
| HyperFrames | Apache-2.0 | Default engine; safe for client work |
| FFmpeg (libx264) | GPL when linked | Fine for internal rendering; do not redistribute the binary |
| Remotion | Custom license | Free for individuals/small companies; paid above that. Confirm eligibility before client work |
| saas-animation skill (user-supplied) | No license text in bundle | Use for your own projects. Confirm the author's terms before redistributing or selling |
| metaphrasis | Proprietary | OFF by default; never copy into the zip |
| onetake | PolyForm Noncommercial | OFF for client work; personal/practice only or after Pro license |
| Reference videos | Third-party copyright | Private analysis only; delete after the project unless you own them |
| ElevenLabs / Suno | Plan-dependent | Confirm commercial use is allowed before publishing |

Two repos are intentionally **not included**: `metaphrasis` (proprietary) and `onetake` (noncommercial). Both are OFF by default.

---

## Quick-start prompts

Copy from `sample_prompts/`:

**Minimal (brand URL only):**
```
Brand URL: <url>. Make a 30-second 16:9 product-launch video. Ask me only what you must (runtime, voiceover or not, publishing platform). Follow skill.md: brief → analysis → per-second storyboard for approval → draft → QA → finals.
```

**Maximal (URL + images + reference + script):**
```
Brand URL: <url>. Logo and screenshots in brand/. Reference: <video>. Match its pacing and motion language, not its content. Script: <paste>. Voice: <file or TTS>. 60 s, 16:9 and 9:16, −14 LUFS, publish on LinkedIn and Reels. Show the per-second plan first.
```

---

## Publishing to GitHub

This folder is published as the repository **Motion-design-pro-max** under the GitHub account **Surya17155**.

To clone:
```bash
git clone https://github.com/Surya17155/Motion-design-pro-max.git
```

To use, open the cloned folder in Claude Code and follow the 5-step start in `ai-video-editor-engine/README.md` or the step-by-step guide above.

---

## What was tested

Passed on the build machine: environment check, sample video generation, ingest (frames, cuts, contact sheet), audio analysis, storyboard validation, sound-effect synthesis and event-synced mixing, voice + music + SFX mixing with ducking and loudness normalization, muxing and the YouTube preset, pinned-commit cloning, and TypeScript checks of the Remotion and 3D templates.

Not tested on the build machine (no browser available): actual Remotion, HyperFrames, Three.js, and Motion-as-Code renders, Blender scenes, and Claude Code plugin installs. Expect to fix small setup issues the first time; the test launch lists each skipped step with its command.
