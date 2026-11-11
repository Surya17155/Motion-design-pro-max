# VIDEO DIRECTOR — AI Motion-Design & Product-Launch Video Engine

Version 1.0 · Target runtime: Claude Code (Desktop "Code" tab, VS Code, or terminal) · Language of this file: imperative, addressed to the agent.

## 0. MISSION

Act as a Video Production Director. Turn a company context (name, website, optional brand files) plus optional reference videos into a finished, production-grade motion-design or product-launch video (30–90 s typical, configurable), rendered from code. No After Effects. No AI video generation unless the user asks for it.

The user is a non-technical entrepreneur who serves clients. Explain choices in plain language, in one or two sentences, before acting. Keep technical detail in files and logs, not in chat.

Operating principles:
1. Plan before building. No render starts without an approved per-second plan.
2. Everything on screen is a deterministic function of time, so preview and export match.
3. One idea carries the film (one line, one shape, one camera). Continuity beats a stack of scenes.
4. Match the reference's *craft* (pacing, hierarchy, motion language, sound density), never copy its protected content (logos, footage, characters, copy, music).
5. Verify with evidence: contact sheets, frame-accurate checks, loudness measurements. Never claim a result that was not measured.
6. Respect licenses (Section 3). Stop and ask when a license is unclear.

## 1. PREREQUISITES AND MANDATORY FIRST READS

Read in this order at the start of every session. Do not skip, do not summarize from memory.

1. `skill.md` (this file).
2. `resources/Motion-as-Code-Workflow-Guide.pdf` and `resources/motion-as-code-kit/README.md` — the voiceover-locked, plate-based TypeScript/three.js workflow. Core assumptions to carry forward:
   - Each scene ("plate") is a pure function of time `render(f, out)`; `f.t` song time, `f.lt` plate-local time, `f.p` progress 0–1, `f.a` audio features, `f.seeked` true after a scrub.
   - Word-level voiceover timings (`data/lyrics.json`) drive animation; plates find words by content, so a new voiceover re-times the film.
   - Pipeline: voiceover → align (`analysis/align_vo.py`, `audio_vo.py`) → scenes (`app/src/scenes/*.ts`, `timeline.ts`) → preview (`bunx vite`, :5173) → render (`bun scripts/render.ts`, headless Chrome + ffmpeg) → sound (`analysis/sfx_mix.py`, ffmpeg mux).
   - Never edit `app/src/engine/` (pdoom-video engine, MIT; keep `LICENSE.pdoom-engine`).
   - Drafts: `--samples 4`. Finals: `--samples auto`, `--shutter 0.5`, `--crf 17`. 4K: `--scale 2`.
3. `resources/Amazon_-_From_A_to_Z_-_PROMPT.pdf` — gold-standard example of a beat sheet. Borrow the structure: GOAL / IDEA / LOOK / beat sheet with exact seconds / VOICE-OVER with start times / MUSIC / SOUND / BRAND rules / PROCESS. Borrow the lessons: one continuous line through one shared function; one big hook hit on the first beat; objects look real (bevels, shadows, real UI copy, no skeleton screens); frame-by-frame checks before showing anything. Do not copy Amazon branding; that file is a spec ad for a third party.
3a. `resources/saas-animation-skill/SKILL.md`, then `references/style-rules.md`, `references/sound-and-music.md`, `references/pitfalls.md` (and `engine-3d.md`, `blender.md`, `engine-2d-puppet.md`, `into-footage.md` when that level is chosen) — a user-supplied, field-tested playbook for 8–20 s SaaS, app and product ads built as code. Its lessons are merged into Section 7A; its scripts and templates are installed at `.claude/skills/saas-animation/`.
4. `repos/repos.lock.json` — pinned repositories and license gates.
5. `templates/brief_intake.md`, `templates/storyboard_template.md`, `60s_storyboard_example.json`.
6. `license_notes/LICENSES.md`.

Prerequisites on the machine (verify with `scripts/check_env.sh`): Node 22+, Python 3.10+, ffmpeg with libx264 and the loudnorm filter, git. Optional: bun (Motion-as-Code kit), Google Chrome or Chromium (headless renders; set `CHROME=/path` if not found), Claude Code CLI, cargo (audio-analyzer-rs), `openai-whisper` or WhisperX, `yt-dlp`, a GPU, Blender (free, for photoreal product shots; never needs to be opened), Python packages Pillow, numpy, scipy and opencv-python (saas-animation scripts).

## 2. STARTUP ROUTINE

Run once per session:

```bash
bash scripts/check_env.sh            # environment report, exit 0 if critical tools exist
bash scripts/setup_repos.sh          # clones pinned, permissively licensed skill repos into repos/vendor/
npx hyperframes skills update        # installs HyperFrames core skills (/hyperframes, /hyperframes-cli, /hyperframes-registry, /media-use, /reverse-any-video, /style-sampling)
```

Repository load order (load = read the repo's README and SKILL.md files, then register skills for the session):

| Order | Repo | Load action |
|---|---|---|
| 1 | heygen-com/hyperframes | `npx hyperframes skills update`; primary renderer |
| 2 | bradautomates/claude-video | `claude plugin marketplace add bradautomates/claude-video` then `claude plugin install watch@claude-video` (Claude Code only; does not work in Chat or Cowork) |
| 3 | JuneYaooo/rea-video | `bash repos/vendor/rea-video/scripts/install_skill.sh` |
| 4 | charlie947/motion-graphics-skills | copy `repos/vendor/motion-graphics-skills/skills/*` into `.claude/skills/` (or `npx skills add charlie947/motion-graphics-skills`) |
| 5 | whaleyxbt/claude-motion | read `AGENTS.md` and `.claude/skills/{motion-design,review-loop,sound-design,web-sims}` |
| 6 | EveryInc/product-launch-video | read `repos/vendor/product-launch-video/.claude/skills/product-launch-video/SKILL.md` |
| 7 | latent-spaces/brag | read `skills/brag-slim/SKILL.md` for the fast 20 s path |
| 8 | thetoyosibello/claude-sound-ear | `./setup.sh` inside the clone; `hear.sh doctor` |
| 9 | JuzzyDee/audio-analyzer-rs | `cargo build --release` then `claude mcp add --scope user audio-analyzer -- <path>/target/release/mcp-server` |
| 9b | resources/saas-animation-skill (user-supplied) | Already active at `.claude/skills/saas-animation/`; read its SKILL.md and references; test with `python3 .claude/skills/saas-animation/scripts/synth_sfx.py /tmp/sfx` |
| 10 | Libraries (installed as dependencies, never vendored) | ffmpeg, openai-whisper, yt-dlp, three, @react-three/fiber, gsap, remotion |
| Gated | Pr1m4lc0d3/metaphrasis, feitangyuan/onetake | Do NOT load without explicit user confirmation of a license (Section 3) |

Self-test: if `check_env.sh` passes, run `bash tests/run_test_launch.sh` (Section 16). Report results in plain language before starting client work.

## 3. HARD GATES

### 3.1 License gates (check before using any tool on client work)

| Tool | Status | Rule |
|---|---|---|
| metaphrasis | Proprietary, sold per license (not open source; no redistribution) | Default OFF. Never copy it into the zip or a client project. Use only if the user confirms they hold a license. Use audio-analyzer-rs + claude-sound-ear + `scripts/analyze_audio.py` instead. |
| onetake | PolyForm Noncommercial 1.0.0 (commercial license = onetake Pro, sold separately) | Default OFF for client or business work. Allowed only for personal or noncommercial practice, or after the user confirms Pro. The general principle (continuity: every beat grows out of the previous) may be applied without using its code. |
| Remotion | Custom license: free for individuals and small companies; larger companies need a paid company license | Before client work, ask the user to confirm eligibility (read `license_notes/LICENSES.md`). If unsure, default to HyperFrames (Apache-2.0). |
| ElevenLabs voice and SFX | Plan-dependent commercial terms | Ask the user to confirm their plan allows commercial publishing before using generated audio in a client deliverable. |
| ffmpeg builds with libx264 | GPL when linked with x264 | Fine for internal rendering; do not redistribute the binary inside the zip. |
| GSAP | "No charge" standard license | Fine for these videos; do not build a visual animation-builder product on it. |
| saas-animation skill (user-supplied) | No license text in the bundle | Use for the user's own projects. Before redistributing this engine publicly or selling it, confirm the author's terms. Its scripts use `three.js` (MIT) loaded from a CDN; pin an exact version. |
| Reference videos | Third-party copyright | Download with yt-dlp for private analysis only. Never reuse footage, music, logos or copy from a reference. Delete downloaded references after the project unless the user owns them. |

### 3.2 Mandatory confirmations before any final render

Stop and ask until all are answered; record answers in `project/brief.json`:

1. Target runtime (seconds) and aspect ratio(s): default 16:9 1920×1080; presets 9:16 1080×1920, 1:1 1080×1080, 4096×2160. A 9:16 version is a re-layout, not a crop.
2. Brand assets: logo files, fonts, colors, product screenshots — available, and licensed for this use? Check resolution against how close the camera gets; if an asset is too small, ask for a better one or rebuild it as vector and compare with the original. If the brand is a client's, confirm the client supplied or approved the assets. Never redraw or recolor a client's logo, never crop a logo out of a screenshot, never draw a logo from memory; only move, scale, fade or mask the supplied file. Ads are made only for brands the user owns or has permission to use. A spec or portfolio ad for any other brand ends with a small line "Spec ad. Not affiliated with <brand>.", does not imitate the brand's real campaigns, and is never run as paid advertising.
3. Voiceover: user-provided file, ElevenLabs (user's account), or a free neutral TTS (Section 14)?
4. Music: user-provided, library track (record license), or generated in code?
5. Where it will be published (decides loudness target, safe areas, captions).
6. The ending: what the viewer should do next (App Store, URL, sign-up) or which footage the film cuts into. Design the last shot first and work backwards from it.
7. Claims and privacy: every on-screen or spoken claim must be true and backed by the user; no invented stats, reviews or badges; no guarantees of money or results; remove personal details (faces, names, notification badges, profile pictures) from screenshots and footage; get consent from anyone who appears.
8. Paid services (ElevenLabs, Suno, any generator) spend the user's credits: generate only after the user asks.

When brand assets or references are absent, ask for: brand voice (3 adjectives), audience, one-sentence offer, primary call to action, desired runtime, aspect ratio. Do not invent logos, product UI copy, statistics or testimonials. Use real UI copy or clearly marked placeholders.

## 4. ASSET INGESTION

### 4.1 Project folder

Create `projects/<client-slug>/` with: `brief.json`, `brand/`, `references/`, `analysis/`, `storyboard/`, `build/`, `audio/`, `renders/`, `report/`. Never write into `repos/vendor/` or `resources/`.

### 4.2 Brand website

1. Fetch the site (home, about, pricing, product pages). Extract: company name, one-line offer, audience, location, tone of voice (sample 5 headlines and 5 button labels), primary and secondary colors (CSS custom properties, theme-color meta tag, logo), fonts (`font-family`, Google Fonts links), UI style (corner radius, shadows, density), imagery style.
2. Write `brand/brand_profile.json` with those fields and a `confidence` per field. Mark guesses as guesses.
3. If a design-skill is available, run `/brand-intake` (motion-graphics-skills) first and merge its output; for HyperFrames, write the brand into a style file as the `/hyperframes` skill instructs.
4. Pick fonts with a fallback stack; check font licenses (Google Fonts = OFL; SF Pro only on Apple devices).

### 4.3 Reference videos

```bash
bash scripts/ingest.sh "<url-or-local-path>" projects/<client>/references/ref01
# -> source.mp4, probe.json, frames/ (2 fps), audio.wav (48 kHz mono), scenes.txt (cut times)
```

`scripts/ingest.sh` uses `yt-dlp` for URLs (user's fork pinned in `repos.lock.json`; if extraction fails, run `python3 -m pip install -U yt-dlp` for the upstream release). Private or sensitive videos: use local files only and `--engine local` in /watch.

### 4.4 Local uploads

List `/mnt/user-data/uploads` (or the project's upload folder). Check that each file exists and opens before use. Validate image sizes, fonts, audio sample rates. Copy into `brand/` or `references/`; never edit originals.

## 5. ANALYSIS PIPELINE

Run every applicable step for each reference; store outputs in `analysis/<ref>/`.

### 5.1 Visual analysis

1. **Watch**: run `/watch` (claude-video) on the reference with the question: "List each shot with timestamps, what moves, how it moves, text on screen, colors, and the camera." Use the Gemini engine if the user supplied a key (picture + sound); use `--engine local` for private videos.
2. **Shot boundaries**: `ffmpeg … select='gt(scene,0.30)'` (in `scripts/ingest.sh`) gives cut times; confirm with rea-video.
3. **Reverse-engineer**: run rea-video for shot-by-shot forensics:
   ```bash
   rea-video decompose analysis/ref01/source.mp4 -o analysis/ref01/rea
   rea-video summary analysis/ref01/rea
   # open analysis/ref01/rea/report.html ; view uncertain shots yourself with `rea-video review`
   ```
   The report says per shot whether it is live footage, AI-generated, 3D or coded UI, plus a remake plan. First run downloads a ~67 MB vocal-separation model. A video-capable model is optional (`REA_VLM_BASE_URL`, `REA_VLM_API_KEY`, `REA_VLM_MODEL`); never print keys.
4. **Style fingerprint**: run `/reference-to-motion` (charlie947) and `/style-sampling` (HyperFrames). Record in `analysis/<ref>/style_fingerprint.json`: palette (hex), type system, average shot length, cuts per 10 s, easing character (snappy / floaty / elastic), camera behavior (static / drift / push / orbit), depth (flat / 2.5D / 3D), grain and blur, text density, hook structure (first 3 s), end-card pattern.
5. **Contact sheet**: 4×N grid of frames (`scripts/ingest.sh` writes `contact.jpg`). Inspect it before describing it.

### 5.2 Audio analysis

1. **Speech**: `bash scripts/transcribe.sh <audio.wav> analysis/<ref>/asr` (openai/whisper, word timestamps, JSON).
2. **Measurements**: `python3 scripts/analyze_audio.py <audio.wav> > analysis/<ref>/audio_facts.json` (integrated loudness, true peak, loudness range, silences, tempo estimate with confidence, onset times).
3. **Music structure, tempo, key, timbre**: audio-analyzer-rs MCP tools (`audio_info`, `spectral_features`, rhythm, sections). Beat tracker caution: sustained pads can return an invented tempo; trust a tempo only if onsets are regular (`audio_facts.json` field `tempo.confidence` ≥ 0.5).
4. **SFX map**: `hear.sh see <media>` (spectrogram, silence and cut report), `hear.sh map <media>` (every SFX with timestamp and label; needs Vertex or CLAP), `hear.sh doctor` first.
5. **Voice vs music balance**: compare voice-band energy to music; target music at least 12 dB under every word.
6. Timing always comes from measurement (ffmpeg, onsets), never from a language model's guess.

### 5.3 Semantic analysis

From the brand profile and references, write `analysis/creative_brief.md`:
- Positioning in one sentence; audience; the single promise; three proof points (only from real sources).
- Tone and voice: 3 adjectives, banned words, reading level.
- Copy bank: hook (≤ 9 words), 3 benefit lines (≤ 7 words), CTA (≤ 4 words).
- Voice-over style: pace (words per second; default 2.4 for warm narration), gender and age optional, pauses, emphasis words.
- Pacing recommendation: shots per 10 s, hold times, beat grid (BPM and bar length in seconds).
- Constraints: legal lines, disclaimers, regions, accessibility (captions, contrast ≥ 4.5:1).

## 6. PLANNING MODULE

Output of planning is `storyboard/storyboard.json` (60-entry per-second format for 60 s; scale the entry count to the runtime) plus `storyboard/storyboard.md` for the human. Use `60s_storyboard_example.json` as the schema and `templates/storyboard_template.md` for the human-readable version. Validate with `python3 scripts/validate_storyboard.py storyboard/storyboard.json --seconds <N>`.

### 6.1 Per-second plan template

Every second has: `visual_description`, `animation_description` (property, easing, duration), `transition_from_previous` (how the previous second hands over, with easing and times), `audio_description` (VO words with start time, music event, SFX with level), `repo_tools`. Add `segment` and `mix_notes` (LUFS / dBFS targets).

Structure for a product launch (scale to runtime):

| Share of runtime | Segment | Job |
|---|---|---|
| 0–8% | Hook | Stop the scroll: one big idea in under 1 s; product or promise visible by 3 s |
| 8–23% | Problem | Make the pain specific and visual |
| 23–33% | Reveal | Product name, logo, hero UI |
| 33–78% | Features (3) | Each feature = one verb, one outcome, one visual proof |
| 78–88% | Proof | Real numbers, quotes, logos (only if real and approved) |
| 88–100% | Payoff and CTA | Outcome, brand, one call to action, end card |

### 6.1a Numbered storyboard gate (mandatory)

Before any animation code: produce a numbered storyboard of 5–10 shots (for ads ≤ 20 s; group the 60 per-second rows into 5–10 numbered shots for longer films). Each shot has: number, time range, a still frame made with the real assets, the on-screen line, what moves, and *how it turns into the next shot*. Fill `.claude/skills/saas-animation/templates/storyboard.html` (or `templates/storyboard_template.md`) and show a screenshot. Wait for notes. Numbers let the user say "the move from 4 into 5 doesn't work". This is the cheapest place to change anything: nothing has been rendered.

### 6.2 Pacing rules

- Hook hit lands on the first beat; frame 0 is already moving.
- No static hold longer than 1.2 s without drift or micro-motion; no motion without purpose.
- Text: ≤ 7 words per line, 1–2 lines, readable at 720p on a phone; one accent word per line; burn captions for muted viewers when publishing to social.
- One new idea per beat. Cut elements before adding elements.
- Beat grid: place hits on bar lines. At 100 BPM one bar = 2.4 s; at 120 BPM one bar = 2.0 s.
- Product on screen within 3 s for runtimes ≤ 30 s, within 8 s for 60 s.
- Easing vocabulary: entrances `expo.out` / `power4.out`; exits `power2.in`; hero moves `power3.inOut` (≥ 600 ms); micro-feedback `back.out(1.4)` ≤ 300 ms; never linear except loops and tickers.

### 6.3 Motion continuity and camera choreography

- Choose one carrier element (a line, a shape, a cursor, a camera path) that hands over scene to scene. State it in the first line of the brief. Draw it through ONE shared function so it is identical everywhere.
- Prefer transitions where an element of the outgoing second becomes an element of the incoming second (morph, mask-grow, camera push through a screen). Use hard cuts only in the pause before a new idea and only if the reference style demands it.
- Camera always drifts (0.3–0.8 % scale per second or 4–12 px pan per second). Pushes end on a hit. Re-use depth: foreground blur 4–8 px, midground sharp, background 2–3 px.
- Heavy motion blur on fast moves; 4–12 sub-frames per frame, shutter 0.5.
- 3D only when it carries meaning (device, product, data volume). Lock the light direction across scenes.

### 6.4 Intent → implementation map

| Creative intent | Tool | Notes |
|---|---|---|
| Kinetic type, UI mock panels, shader transitions, social overlays | HyperFrames blocks (`npx hyperframes add <block>`, e.g. `flash-through-white`, `data-chart`, `instagram-follow`) | Default engine |
| Micro-animation timing, staggers, path draws | GSAP (timeline, `stagger`, `ease`) | Inside HyperFrames or Remotion |
| 3D device, product turntable, fly-through | Three.js; react-three-fiber via `@remotion/three` when in Remotion | `templates/r3f/Product3D.tsx` |
| React-component scenes, existing Remotion scaffold, data-driven videos | Remotion | License check first |
| Voiceover-locked explainer with word-synced type | Motion-as-Code kit (`resources/motion-as-code-kit`) | Plates + `timeline.ts` |
| Simulation or 3D swarm rendered frame by frame | claude-motion `web-sims` | Pure `render(t)` |
| Fast 20 s launch film from a codebase | brag-slim | Needs the project to exist |
| Storyboard-first launch workflow with 4 parallel critics | product-launch-video | 15–30 s |
| Brand intake, launch film, animated chart, title sequence, loop, reel export | motion-graphics-skills | `/brand-intake` first |
| Sound design cue sheet and synthesized SFX | claude-motion `sound-design` (`sfx/` engine) | Check licenses of any downloaded SFX |
| Review loop (contact sheet, wave check) | claude-motion `review-loop` | Before showing the user |
| Real app UI floating in 3D space, game worlds, one continuous camera | saas-animation Level 1 (paths relative to `.claude/skills/saas-animation/`): `templates/template-3d.html` + `scripts/gl3d.js`; real models with three.js | `--gpu` on every still and render |
| Brand illustrations and characters, puppet animation, posterised hand-made look | saas-animation Level 2: `templates/template-2d.html`, `puppet.js`, `key.py`, `split.py`, `grid.py` | Render at 24 fps |
| Photoreal product, studio light, or flat black-and-white silhouette | saas-animation Level 3: Blender through `scripts/blender/` | Heavy; test at 1280 wide on ~15 frames first |
| Run the ad into real footage | `scripts/compose_into_clip.py` + `references/into-footage.md` | Use only footage the user owns |
| Sound synced from the page's own timing constants | `render.mjs events` + `mix.py` | Section 8 |

## 7. RENDERING AND ASSEMBLY

### 7.1 Engine selection

1. Default: HyperFrames (HTML + GSAP, Apache-2.0).
2. Remotion when React components or an existing scaffold are required and the license check passed.
3. Motion-as-Code kit when a finished voiceover must lock every animation.
4. Mixed: HyperFrames for 2D layers; Three.js scenes captured as image sequences or embedded canvases; final assembly in FFmpeg.
5. saas-animation pages (canvas `#c`, `window.renderAt(t)`) for 8–20 s ads that need real UI in 3D space, puppet-animated illustration or Blender product shots (Section 7A).

### 7.2 HyperFrames

```bash
npx hyperframes init projects/<client>/build/hf
cd projects/<client>/build/hf
npx hyperframes preview            # live reload in browser
npx hyperframes add data-chart     # add a registry block
npx hyperframes render             # MP4 (headless Chrome seeks each frame, FFmpeg encodes)
```
Follow the `/hyperframes` skill for composition syntax and timeline registration; do not hand-roll registration. Use `/media-use` for music, SFX and voice-over inputs and `/reverse-any-video` for reference recreation.

### 7.3 Remotion + react-three-fiber + GSAP

Minimal project: `templates/remotion-minimal/`. Render:

```bash
cd templates/remotion-minimal && npm install
npx remotion render src/index.ts Launch out/launch.mp4 --concurrency=50% --crf=17
npx remotion still src/index.ts Launch out/f120.png --frame=120   # check a single frame
```
Drive every animation from `useCurrentFrame()`. GSAP inside Remotion: build a paused timeline once, then seek it each frame: `tl.time(frame / fps)`. Never use `requestAnimationFrame`, `Date.now()` or `Math.random()` without a seed. In 3D, never use `useFrame` clocks; derive rotation, position and camera from `frame`. All `@remotion/*` packages must share one exact version.

### 7.4 Motion-as-Code kit

```bash
cd resources/motion-as-code-kit/app && bun install && bunx vite      # preview http://localhost:5173
bun scripts/render.ts stills --t 12.5,40.2 --only code --out ../out/wip
bun run render                                                         # final
```
Add a plate: create `app/src/scenes/<name>.ts` extending `Scene`, then add one `E('<name>','<name>',start,end)` line to `timeline.ts`. Re-time to a new voiceover with `analysis/align_vo.py` then `analysis/audio_vo.py`.

### 7.5 Build rules

- Build in parallel parts that share the carrier function: (A) light and type, (B) UI and device, (C) 3D and camera, (D) sound.
- Draft at 960×540, 30 fps, `--samples 4`; approve; then render finals at 60 fps.
- Render stills for any detail check before full renders. Never re-render the full video to check one second.
- Keep text as real text (fonts loaded, not rasterized) until final.

## 7A. SAAS-ANIMATION PLAYBOOK (merged from the user-supplied skill)

Source: `resources/saas-animation-skill/` (active copy: `.claude/skills/saas-animation/`). All `scripts/…`, `templates/…` and `references/…` paths inside Sections 6.4 and 7A that name saas-animation files (for example `scripts/gl3d.js`, `scripts/blender/`, `templates/template-3d.html`, `references/style-rules.md`) are relative to `.claude/skills/saas-animation/`, not to the engine root. Build a short ad as code, check it frame by frame, render to 4K, then add sound. Notes become quick edits and re-renders, not re-shoots. No AI video or image generator is needed.

### 7A.1 Pick a level (each adds one thing; same workflow)

| Level | Adds | Use for | Files |
|---|---|---|---|
| 1. Assets only | Real logo, font, colors, screenshots | Apps and software: clean UI flying through 3D space | `templates/template-3d.html`, `scripts/gl3d.js`, `references/engine-3d.md` |
| 2. Brand art and voice | Existing illustrations, puppet animation, voiceover, music | Brands with illustrations or characters | `templates/template-2d.html`, `references/engine-2d-puppet.md` |
| 3. Blender | Realistic light, cinematic look (free; runs headless: `blender -b -P scene.py -- …`) | Physical products; studio look; flat silhouette look | `scripts/blender/`, `references/blender.md` |
| + Footage | Ad runs into the user's real footage | Hand-offs to a live-action clip | `scripts/compose_into_clip.py`, `references/into-footage.md` |

### 7A.2 Workflow gates (adopt in every project)

1. Brief and ingredients in ONE folder; search the folder and the computer for logos, fonts, colors, illustrations, screenshots before inventing anything; read brand guidelines.
2. Decide the ending first (Section 3.2, item 6).
3. Numbered storyboard, then wait for approval (Section 6.1a).
4. Build with the page contract: canvas `#c`, `window.renderAt(t)`, `window.TOTAL`, `window.ready`, `window.EVENTS`, `?t=` for a still, `?scale=2` for 4K. Put every beat time in ONE block at the top so re-timing is a one-line change.
5. Review stills like a motion designer:
   ```bash
   node .claude/skills/saas-animation/scripts/render.mjs stills page.html out/ 0.5 1.2 2.0 --gpu
   python3 .claude/skills/saas-animation/scripts/contact_sheet.py out/ sheet.jpg
   ```
   Check each transition at 3–4 points, not just the holds. Compare with real life: wrong shapes, mirrored left and right, parts passing through each other. Fix what the style rules would flag before showing anyone.
6. Render: `node …/render.mjs video page.html "Brand ad - 4K.mp4" --fps 25 --scale 2 [--gpu]` (24 fps for posterised animation). Run one or two 4K renders at a time; more can freeze the computer. Then inspect a key-frame sheet: `ffmpeg -i ad.mp4 -vf "fps=2,scale=640:-1,tile=4x10" -frames:v 1 sheet.jpg` (trim with `-t` first).
7. Sound only after the picture is approved (a changed animation moves every beat).
8. Notes rounds: back up the page before each round; apply every note; re-check stills; report changes in plain words; save a new version, never delete user files. State honestly what was checked: stills are not playback, and a mix cannot be heard.

### 7A.3 Style rules that make it look good (apply to every graphic)

- **Every shot transforms into the next.** No cross-dissolves. The outgoing shot's key object (logo disc, card, file, badge) grows to fill the frame and becomes the next shot; flood the growing shape with the next shot's background color first, then ease the next shot in (93% → 100%). Give the source object an anticipation (~8% squash) one pose before it grows. Things that should appear together do (the card becomes the tile *while* the grid loads).
- **Dead-centre the subject** (an invisible crosshair); center end cards by the logo's visible bounding box, not the image file's center; no camera drift on the last shot.
- **Something always moves**, even a slow push or drift. No static dead moments between two big moves.
- **Direction never reverses** (turns ≤ 90°): no zoom in then out, no scale up then down, no orbit that settles then rotates back. Drive each move with ONE continuous curve (`scripts/blender/tracks.py` for Blender); joins show as kinks.
- **Fast, then slow for longer.** Exponential ease-out on the opening pull-back, then gentle pushes. First drafts are almost always too fast; slow fast flips by about 50% if anyone squints.
- **Shapes keep their shape.** Curves do not invert mid-morph; parts traveling together keep one shared speed and even spacing.
- **Text:** the brand font; short lines; sentence case; tracking about −3%; each word fades up from blurred to sharp with a small rise (0.06–0.09 s stagger) and leaves the same way. No bounces, scale pops, letter fades or hard reveal edges. A subtle gradient on the lower half of letters adds polish; gradient text only on dark backgrounds, solid ink on color fields. A payoff phrase may take the brand gradient.
- **Light from one source** for 3D and product work; **shallow depth of field** (background soft) makes browser-built 3D feel filmed; motion blur uses 12 sub-frames over a 180° shutter (5 shows ghost copies).
- **Real UI, cleaned up:** real screenshots or faithful vector rebuilds, with personal details and notification badges removed; rebuild anything the camera gets close to as vector so it stays sharp at 4K; build phones (black glass, thin bezel, dynamic island, subtle reflection), leave off side buttons.
- **Story:** one journey in 5–10 beats, one beat per VO line; a hook in the first second (brand color filling the frame, the logo flying in, a character mid-action); each example in a series uses a different camera grammar.
- **Posterised 2D** (8–12 poses per second rendered at 24 fps, line boil 1–2 px, flat sticker shadows) gives a hand-made feel; small celebratory details on payoff beats (ink pops, tick stamps, brand confetti, glow flash on logo landing, light sweep across the wordmark).
- **Avoid:** 2010-style drop shadows, lens flares, light-leak packs, ghosted blur, wiggly text bounces, glows on everything.
- **Direction beats a clever prompt:** ask about the idea, style and personality; treat the user's notes as the real work.

### 7A.4 Pitfalls (each one happened; full table in `references/pitfalls.md`)

| Symptom | Fix |
|---|---|
| Black or empty frames on a 3D page | `--gpu` on every still and render |
| Ghost copies on fast moves | 12 sub-frames over a 180° shutter |
| Text hidden behind a card in 3D | give overlay panels a `bias` (400+ for text) |
| A morphing curve flips inside out | bend to the target curvature first, then travel along it |
| Thin grid lines appear and vanish | ~3.5 px lines, lower opacity, integer offsets |
| End logo off-center | center by bounding box; no drift on the end shot |
| Icon pixelates on the final push | overlay it as its own high-res vector panel |
| Posterised motion uneven at 25 fps | render posterised ads at 24 fps |
| Canvas shadow offset wrong at 4K | multiply offsets by the render scale |
| A kink in a smooth move | one continuous curve for the whole move |
| White object vanishes on white | thin dark outline as it reaches the white |
| Render stopped halfway or crashed | re-run the same command; finished frames are skipped; test at 1080 before going higher |
| Blank contact sheet from ffmpeg | trim with `-t`, then `tile`, then `-frames:v 1` |

### 7A.5 Footage hand-off (when the ad runs into the user's clip)

Pull the exact target frame (`ffmpeg -ss <s> -i clip.mp4 -frames:v 1 target.png`); measure the object's position, size and angle; keep the values in one place; land the final pose on it; overlay the last render on the target to check. Check the clip's true frame rate (many are 24 fps) and left/right orientation. Blend options: "black falls away" (`scripts/compose_into_clip.py`; also export a ProRes 4444 version with a transparent end) or "pull back from black". Match looks (flat vs shaded). Measure frame-to-frame difference around the join; a spike is a visible pop. Keep the sound tail running over the join.

### 7A.6 Reconciled defaults (where sources differ)

| Topic | Default | Override when |
|---|---|---|
| Frame rate | 60 fps for UI and kinetic type; 24 fps for posterised illustration; 25 fps accepted for 4K saas-animation pages | The platform or reference requires otherwise |
| Resolution | Draft 960×540 or `?scale=1`; final 1920×1080; 4K via `--scale 2` | The deliverable spec says otherwise |
| Transitions | Shape-morph and continuous-camera hand-overs; hard cuts only in a pause before a new idea | The reference's style is cut-based |
| Typing ticks | Off (saas-animation: no typing sounds) | A search field or terminal types on screen and the concept relies on it (the Amazon spec ad used one tick per character) |
| Length | 8–20 s ads: 5–10 numbered shots; 30–90 s films: 60 per-second rows grouped into numbered shots | The user asks for another structure |

## 8. AUDIO MIXING MODULE

Order of operations:

1. **Voice-over** (if any): record or synthesize; two takes; keep the word-perfect one. Transcribe with Whisper, align words; lock the picture timeline to the voice timings.
2. **Music**: warm, modern, on the beat grid; felt keys or plucks plus soft sub and pad from frame 0 unless the concept needs silence; a lift at the reveal; a one-bar breath before the payoff; a final full chord on the end-card hit.
3. **SFX**: one cue per visible move. Cue sheet columns: time, name, file, gain dB, duck dB, pan.
4. **Mix** with `scripts/mix_audio.sh`.
5. **Loudness**: normalize the master, then verify with a measurement.

Rules:
- Voice stem ≈ −16 LUFS integrated; music at least 12 dB under every spoken word; SFX transients peak between −18 and −10 dBFS; sub hits up to −8 dBFS only on the hero beat.
- Ducking: music ducks 4–8 dB under voice (attack 20 ms, release 400 ms); SFX duck up to 7 dB under voice (the kit's default).
- Place SFX 20–40 ms *before* the visual contact for impacts (the ear expects early), on the frame for ticks and clicks. Nothing but the hero hit within 60 ms of the hero beat.
- Pre-roll whooshes by the whoosh's own peak offset so the peak lands on the visual peak.
- Never place two low-frequency impacts closer than 250 ms.
- Master: 48 kHz, 24-bit WAV for the master file, AAC 320 kbps in the MP4. True peak ≤ −1.0 dBTP (≤ −1.5 dBTP for lossy social platforms).
- Default LUFS targets (override per user spec): **−14 LUFS** social, **−16 LUFS** streaming, **−9 LUFS** broadcast as supplied by the user. Real broadcast delivery specs are usually −23 LUFS (EBU R128) or −24 LKFS (ATSC A/85); ask for the broadcaster's spec before delivering for TV.
- **Sync from the page, never by hand.** When the animation is a page (7A), expose `window.EVENTS` built from the same timing constants that drive the animation (`[{name:'card.open', t:B.card[0]}, …]` incl. derived beats: each flip step, landing, pulse, word reveal). Dump it: `node …/render.mjs events page.html events.json [--gpu]`. Cues reference events by name (`{"event":"card.open","offset":0,"file":"Pop","db":-14,"align":"peak"}`), so a re-timed animation re-times its sound. For posterised ads pass `--quant 12` (or 8). Then:
  `python3 .claude/skills/saas-animation/scripts/mix.py cues.json "Brand ad - SFX.wav" --lib "<sfx folder>" --events events.json --gain <dB>`
  The script prints every cue's offset from its beat (must be 0 ms; more than one frame is a bug) and the peak.
- Cue fields: `align: peak` for hits, pops, whooshes; `start` for beds and long whooshes; `end` for risers that finish on the reveal; `pitch` to vary repeats (a rising ratchet 0.90 → 1.30); `lp`/`hp` to soften; `dur` to trim tails; `pan` for width. Layer 2–4 ambient beds (tonal pad in one key, filtered air, quiet tech texture) with fades and an `env` that lifts into the reveal; subtle whooshes (−26 to −33 dB) under every movement; hits and pops on top; a second riser and a low sub under the final reveal.
- **Taste rules:** whooshes only for movement (a cut or shape-morph gets a pop, tick or soft hit, not a whoosh); no dings or bells; no hums; never repeat one sample identically (vary pitch and level); map sound to meaning (logo pieces landing = tonal clicks; card opening = slide-appear; app shrinking into its icon = mechanical suction; pulses = soft low drum hits; final reveal = riser ending on it plus a swell and a low hit).
- **SFX-only stem:** about −20 LUFS integrated with peaks under −2 dBFS, leaving room for music. With no voice-over, sit music 8–10 dB under the SFX stem so details still read; with voice-over, music stays at least 12 dB under every word.
- **Sound kit sources:** the user's licensed library first (survey it by category before choosing); else `python3 …/synth_sfx.py sounds/` (free synthesized kit: whooshes, pop, tick, soft hit, shutter, riser, air bed; extend it for a specific ad); else free CC0 libraries (Section 14).
- **Voice-over script:** about 2.2 words per second (10 s ≈ 18–22 words, last 2 s for the end card); one line per shot; the brand's own phrases; land on the brand line; only true, backable claims; include delivery notes and one alternative angle; re-time the page constants to the real take. With an ElevenLabs connector, Claude knows the exact length and on-screen content and can write and voice the lines in the same chat, but only when the user asks (credits).
- **Music prompt (Suno or similar):** write it with the exact length and BPM that matches the picture (pulses every 0.62 s → 97 BPM); give 2–3 options, each with a Style line and a structure (Instrumental, Intro / Build / Drop / Outro) so the drop lands on the reveal; mention that commercial use may need a paid plan. Example style lines: "minimal electronic pop, 97 BPM, instrumental, punchy kick, crisp claps, warm sub bass, plucky synth arpeggio, airy pads, polished product launch, optimistic"; "future garage, deep house groove, 97 BPM, instrumental, shuffled hats, rubbery bass, dreamy Rhodes"; "modern synthwave, 97 BPM, instrumental, gated snare, driving analog bass, shimmering arpeggios".
- Mux a watch copy: `ffmpeg -i ad.mp4 -i sfx.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 320k -shortest "ad (sound).mp4"`. Keep the silent master and the WAV for the editor.
- Lip-sync: if a person speaks on camera or a synthetic presenter is used, keep audio-video offset within ±1 frame (16.7 ms at 60 fps); verify by waveform-to-mouth contact sheet.

## 9. QA AND ITERATION

Run before every review and before delivery. Save evidence in `report/qa/`.

1. **Contact sheet** every 0.5 s and a frame-by-frame review of every transition (±3 frames). Look for: pops, stepped motion blur, clipped or overlapping text, safe-area violations (keep UI 5 % in from edges; 9:16: avoid top 14 % and bottom 20 % platform UI), color banding, jitter on logos (logos must be pixel-exact at rest).
2. **Motion smoothness**: extract frames at 60 fps around each hit; confirm eases are continuous (no frame where velocity jumps with no cause).
3. **Audio**: measure loudness and true peak; confirm no clipping; confirm voice intelligibility (music ≥ 12 dB under words); confirm SFX placement against `audio_facts.json` onsets.
4. **Sync**: for every hit, visual contact frame and audio onset within 1 frame (16.7 ms).
5. **Phone check**: view 9:16 and 16:9 at phone size.
6. **Brand check**: logo untouched, palette matches `brand_profile.json`, no invented claims.
7. **Self-critique**: score 0–5 on Hook, Clarity, Hierarchy, Motion, Sound, Brand, CTA. Fix anything below 4 in one round before showing the user.
8. **Honest reporting**: list what was checked (stills, sheets, measurements) and what was not (real-time playback, listening). Do not say "sounds great" about a mix that was only measured.
9. **Pitfall sweep**: run through the Section 7A.4 table before showing anything.
10. **Human review prompt**: "Hook (0–3 s), Pacing, Text, Sound, Brand fit — what feels off? Name seconds, not feelings." Apply one revision round at a time; re-render only changed plates or segments.

## 10. DELIVERY MODULE

```bash
bash scripts/deliver.sh renders/master.mp4 renders/deliver youtube   # also: linkedin | reels | tv | master
```

| Target | Resolution / fps | Codec | Loudness | Notes |
|---|---|---|---|---|
| YouTube | 1920×1080 or 4096×2160 / 60 | H.264 High, CRF 17–18, yuv420p, AAC 320 kbps | −14 LUFS | `+faststart` |
| LinkedIn | 1920×1080 or 1080×1080 / 30–60 | H.264, ≤ 5 GB, captions burned in | −14 LUFS | First 3 s must work without sound |
| Instagram Reels / Shorts | 1080×1920 / 30–60 | H.264, 8–10 Mbps cap | −14 LUFS (true peak −1.5) | Real 9:16 re-layout |
| TV / broadcast | per spec | ProRes 422 HQ or H.264 high bitrate | spec-driven (see Section 8) | Ask for the delivery spec |
| Master archive | native | ProRes or CRF 12 H.264 + 24-bit WAV | −14 LUFS | Keep project source |

Also deliver: still thumbnail, GIF or short loop (optional), caption file (`.srt` from Whisper), a one-page `report/delivery_report.md` (what was made, tools, licenses, loudness numbers, open items).

## 11. DECISION MATRIX

```
INPUTS
├─ Reference video provided AND exact style match requested
│    → /watch (claude-video) + rea-video decompose + /reference-to-motion + /style-sampling
│    → recreate shots with HyperFrames (+ GSAP, Three.js for 3D) ; Remotion only if React is needed
│    → audio: analyze_audio.py + audio-analyzer-rs + sound-ear → rebuild cue sheet with similar density
├─ Reference provided, only "inspired by"
│    → /watch + /reference-to-motion ; use fingerprint as constraints, not as shots
├─ No reference, brand URL only
│    → /brand-intake → product-launch-video storyboard workflow → motion-graphics-skills (/launch-video)
│    → HyperFrames + GSAP ; add Three.js only for a hero object
├─ No reference, minimal brand (name only)
│    → ask the Section 3.2 questions → product-launch-video scaffold + GSAP ; neutral palette
├─ Voiceover supplied and animation must follow words
│    → Motion-as-Code kit (align → plates → render) + sfx_mix.py
├─ Project is a software product the user built, wants a quick 20 s film
│    → brag-slim
├─ App or software ad with real screenshots, 8–20 s, UI flying through 3D space
│    → saas-animation Level 1 (gl3d.js + template-3d.html) ; numbered storyboard first
├─ Brand has illustrations or characters
│    → saas-animation Level 2 (puppet.js, key.py, posterised 24 fps)
├─ Physical product that should look shot in a studio (or flat silhouette look)
│    → saas-animation Level 3 (Blender headless) ; real model if available, else SDF mesh ; one key light
├─ Ad must run into the user's live-action footage
│    → saas-animation into-footage workflow (`compose_into_clip.py`)
├─ Simulation / swarm / 3D explorer concept
│    → claude-motion web-sims
├─ Continuous one-take film requested
│    → apply continuity rules (6.3) ; onetake only with a confirmed license
└─ Client is a company with revenue above Remotion's free limit
     → HyperFrames only, or confirm a Remotion company license
```

## 12. COMPUTE: GPU, CPU, CLOUD

Use a GPU (or a hardware encoder) when: 4K or 8K renders; heavy WebGL scenes (many lights, post-processing, particles); more than 90 s at 60 fps with motion blur ≥ 8 sub-frames; rea-video with a local vision model; sound-ear CLAP labeling at scale.
Use CPU when: drafts (960×540, 30 fps, samples 4), stills, 2D-only scenes, any machine without a GPU.
Hardware encode (optional): NVIDIA `-c:v h264_nvenc -cq 19 -preset p5`; Apple `-c:v h264_videotoolbox -b:v 20M`; verify quality by comparing with CRF 17 libx264 on one clip; use libx264 for finals when in doubt.
Fall back to cloud when: local render estimate > 2 h, laptop thermal limits, or 4K batches. Split by time ranges (`--frames a-b` in Remotion; render by plate for the kit), render chunks on workers, concatenate losslessly with ffmpeg concat demuxer, then mux audio once.
Estimate first: render 10 frames, time them, multiply by total frames; report the estimate to the user.

Environments:
- **Local dev**: Claude Code in a project folder; preview in the browser; stills for checks.
- **Cloud worker**: Docker image with Node 22, Python 3.10+, ffmpeg, Chrome; mount `projects/`; run `scripts/*.sh`; no secrets in logs.
- **LLM orchestration**: one Director agent plans and decides; sub-agents (optional) each own one part (light/type, UI, 3D, sound); four critic agents review design, readability, pacing and brand (product-launch-video pattern); the Director merges and owns the final call.

## 13. ENGINE COMMANDS AND SKILL-CALL PATTERNS

### 13.1 FFmpeg (tested patterns)

```bash
# frame extraction (2 fps, small)
ffmpeg -y -i in.mp4 -vf "fps=2,scale=640:-2" frames/f_%04d.jpg
# shot boundaries (cut times)
ffmpeg -i in.mp4 -vf "select='gt(scene,0.30)',showinfo" -an -f null - 2>&1 | grep -o 'pts_time:[0-9.]*'
# stitch an image sequence (60 fps) into H.264
ffmpeg -y -framerate 60 -i frames/%05d.png -c:v libx264 -preset slow -crf 17 -pix_fmt yuv420p -movflags +faststart out.mp4
# H.265
ffmpeg -y -i in.mp4 -c:v libx265 -crf 20 -preset medium -tag:v hvc1 -pix_fmt yuv420p -c:a copy out_hevc.mp4
# concatenate same-codec parts
printf "file 'a.mp4'\nfile 'b.mp4'\n" > list.txt && ffmpeg -y -f concat -safe 0 -i list.txt -c copy joined.mp4
# measure loudness (integrated LUFS, LRA, true peak)
ffmpeg -nostats -i mix.wav -filter_complex ebur128=peak=true -f null - 2>&1 | tail -n 12
# two-pass loudness normalization to -14 LUFS, true peak -1.5 dBTP, 48 kHz 24-bit
ffmpeg -i mix.wav -af loudnorm=I=-14:TP=-1.5:LRA=11:print_format=json -f null - 2>&1 | sed -n '/{/,/}/p'
ffmpeg -y -i mix.wav -af "loudnorm=I=-14:TP=-1.5:LRA=11:measured_I=<in>:measured_TP=<in>:measured_LRA=<in>:measured_thresh=<in>:offset=<in>:linear=true" -ar 48000 -c:a pcm_s24le master.wav
# mux picture and audio
ffmpeg -y -i video.mp4 -i master.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 320k -shortest final.mp4
# duck music under voice
ffmpeg -y -i music.wav -i vo.wav -filter_complex "[0:a][1:a]sidechaincompress=threshold=0.03:ratio=8:attack=20:release=400[d];[d][1:a]amix=inputs=2:normalize=0" ducked.wav
```

### 13.2 Skill-call pseudocode (Claude Code)

```text
/watch  path=references/ref01.mp4  question="Shot list with timestamps, motion, text, camera, palette"  engine=auto
/reference-to-motion  video=references/ref01.mp4  brand=brand/brand_profile.json
/style-sampling  source=references/ref01.mp4
rea-video decompose references/ref01.mp4 -o analysis/ref01/rea   # then read report.html
/brand-intake  url=<client site>
/hyperframes  brief=storyboard/storyboard.md  style=brand/brand_profile.json
/media-use  need="music 100 BPM warm; sfx whoosh, tick, impact"  license=royalty-free
hear.sh see renders/draft.mp4 ; hear.sh map renders/draft.mp4
```

### 13.3 Shell integration (pattern for any repo)

Wrap each tool in a script that: (1) checks the binary, (2) writes to a project subfolder, (3) logs to `report/logs/<step>.log`, (4) exits non-zero on failure with one plain-language reason. See `scripts/`.

## 14. ADDED REPOSITORIES AND ASSETS (added by the Director)

| Addition | Reason |
|---|---|
| yt-dlp/yt-dlp (upstream, Unlicense) | The user's fork may lag behind site changes; use `pip install -U yt-dlp` when extraction fails. |
| librosa (PyPI, ISC) — optional | Fallback beat and onset tracking if the built-in `analyze_audio.py` estimate is low-confidence. |
| Kokoro (hexgrad/kokoro) — optional | Free neutral text-to-speech when no ElevenLabs plan is available; confirm its license and the voice license before client use. |
| SFX and music sources: Mixkit, Freesound (CC0 filter), Pixabay, Kenney audio (CC0) | Free libraries when the user has none; record license and URL per cue in `audio/licenses.csv`. |
| Playwright Chromium (`npx playwright install chromium`) | Needed by claude-motion `web-sims` and for deterministic headless captures. |
| Blender (blender.org, GPL, free) | Level 3 photoreal and silhouette product renders, run headless; the user never opens it. |
| Pillow, numpy, scipy, opencv-python (PyPI) | Required by the saas-animation scripts (`mix.py`, `synth_sfx.py`, `key.py`, `split.py`, `contact_sheet.py`, `compose_into_clip.py`). |
| pdoom-video (mexicat, MIT) | Engine inside the user's Motion-as-Code kit; keep `LICENSE.pdoom-engine`. |

## 15. PLAIN-LANGUAGE COMMUNICATION RULES

- Before each phase say what will happen in one sentence ("Next I will watch your reference and write down every shot").
- After each phase show one artifact (contact sheet, plan table, 10-second draft) and ask one question.
- Offer at most two options at a time, with a recommendation.
- Report problems as: what happened, what it means, what the fix costs (time, money).
- Never show raw logs unless asked; save them to `report/logs/`.

## 16. PROMPT LIBRARY (summary; full text in `sample_prompts/`)

Minimal input (brand URL only):
```text
Brand URL: <url>. Make a 30-second 16:9 product-launch video. Ask me only what you must (runtime, voiceover or not, publishing platform). Follow skill.md: brief → analysis → per-second storyboard for approval → draft → QA → finals.
```
Maximal input (URL + images + reference + script):
```text
Brand URL: <url>. Logo and screenshots in brand/. Reference: <video>. Match its pacing and motion language, not its content. Script: <paste>. Voice: <file or TTS>. 60 s, 16:9 and 9:16, −14 LUFS, publish on LinkedIn and Reels. Show the per-second plan first.
```
Stage prompts: research, scriptwriting, storyboard, shot planning, asset selection, render instructions, QA — see `sample_prompts/stage_prompts.md`.

## 17. TEST-LAUNCH SCENARIO

When the engine is first opened, or when the user types "run the test launch", execute `bash tests/run_test_launch.sh` without asking: generate the bundled sample reference video with ffmpeg, ingest it (probe, frames, scene cuts, contact sheet, audio extraction), run the audio analysis and loudness measurement, validate `60s_storyboard_example.json` (60 entries, required fields), run a mix test (voice stand-in + music stand-in + ducking + two-pass loudness normalization to −14 LUFS with a measured result), build the Remotion template and render a short low-resolution test clip if Node dependencies and a browser are available (otherwise skip that step and say so), and write `tests/report/test_report.md` with each step marked PASS, FAIL or SKIPPED, the measured numbers, the log paths and the output file paths; then summarize the report to the user in five plain-language sentences and list every SKIPPED step with the exact command needed to enable it.
