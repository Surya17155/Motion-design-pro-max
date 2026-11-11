# REPO MANIFEST

Pinned versions and license gates live in `repos/repos.lock.json`. Star counts were checked in November 2026 where noted. "Gate" = do not use on client work until the license question is answered.

---

## 1. heygen-com/hyperframes — https://github.com/heygen-com/hyperframes
- Write HTML, render video, built for agents. About 81.3k stars; Apache-2.0. Ships a CLI, about 450 ready-made blocks and a set of Claude skills.
- Use: the default render engine for 2D motion, kinetic type, UI mock panels, shader transitions, captions; brand-to-style files; `/media-use` for music, SFX and voice inputs; `/reverse-any-video` for recreating a reference.
- Example: `npx hyperframes init projects/acme/build/hf && cd projects/acme/build/hf && npx hyperframes preview` then `npx hyperframes add data-chart` then `npx hyperframes render`. Install skills: `npx hyperframes skills update`.
- Choose it when: no React is needed, license safety matters, or the video is mostly 2D with GSAP timing. Needs Node 22+, FFmpeg, Chrome.

## 2. FFmpeg/FFmpeg — https://github.com/FFmpeg/FFmpeg
- The universal video and audio toolkit: decode, encode, filter, measure.
- Use: frame extraction, shot detection, stitching, final encode (H.264 / H.265 / ProRes), loudness measurement and normalization, ducking, muxing.
- Example: `ffmpeg -y -framerate 60 -i frames/%05d.png -c:v libx264 -preset slow -crf 17 -pix_fmt yuv420p out.mp4`
- Choose it: always, for assembly and delivery. Install the OS package (needs libx264 and the loudnorm filter); do not vendor the source.

## 3. openai/whisper — https://github.com/openai/whisper
- Robust speech recognition with word-level timestamps.
- Use: transcribe reference narration, align a supplied voice-over to the storyboard, produce `.srt` captions.
- Example: `bash scripts/transcribe.sh audio.wav analysis/ref01/asr small`  (runs `whisper audio.wav --model small --word_timestamps True --output_format json`)
- Choose it when: spoken words need timestamps. Use `small` for drafts, `medium` or `large` for final captions; a GPU makes it much faster.

## 4. Surya17155/yt-dlp (your fork) — https://github.com/Surya17155/yt-dlp
- Command-line audio/video downloader (fork pinned at commit fada868, version 2026.10.26).
- Use: bring reference videos from YouTube, Instagram, X, Vimeo and similar sites into a local file for private analysis.
- Example: `bash scripts/ingest.sh "https://…" projects/acme/references/ref01`  (calls `yt-dlp -f "bv*[height<=1080]+ba/b[height<=1080]/b" --merge-output-format mp4 …`)
- Choose it for any URL input. If a site fails, run `python3 -m pip install -U yt-dlp` (upstream is the Director's fallback). Never reuse downloaded content.

## 5. bradautomates/claude-video — https://github.com/bradautomates/claude-video
- Gives Claude Code the ability to watch any video: downloads, extracts frames, transcribes, hands it all to Claude. About 20.2k stars; MIT.
- Use: first look at every reference; ask for shot lists, text on screen, pacing, palette. With a free Gemini key it passes picture and sound together.
- Example: `claude plugin marketplace add bradautomates/claude-video` then `/watch <url-or-path> "List each shot with timestamps, motion, text, camera"`.
- Choose it for fast understanding. Claude Code only (not Chat or Cowork). Use `--engine local` for private videos.

## 6. Pr1m4lc0d3/metaphrasis — https://github.com/Pr1m4lc0d3/metaphrasis   (GATE: proprietary)
- Claude Code skill that turns music and narrated video into measurements (tempo, key, loudness, structure, cut points, voice-burying check).
- Status: the repository states it is not open source and is sold per license. It is NOT included in this zip and is OFF by default.
- Use only after you buy a license and the user confirms. Free substitute: audio-analyzer-rs + claude-sound-ear + `scripts/analyze_audio.py`.
- Choose it when: the user holds a license and wants its music-cutting workflow.

## 7. thetoyosibello/claude-sound-ear — https://github.com/thetoyosibello/claude-sound-ear
- Eyes and ears for audio: readable spectrogram, objective loudness and timing facts, a semantic map of every sound effect, offline transcription. MIT. (The README clone URL shows tysitv/claude-sound-ear.)
- Use: map the SFX in a reference with timestamps and labels; check silences and cuts in your own draft.
- Example: `./setup.sh` then `hear.sh doctor`, `hear.sh see renders/draft.mp4`, `hear.sh map renders/draft.mp4`.
- Choose it when: you need to know where sounds happen in a reference. The SFX labeling step needs a Vertex or CLAP backend; `see` works without it.

## 8. JuzzyDee/audio-analyzer-rs — https://github.com/JuzzyDee/audio-analyzer-rs
- MCP server that lets Claude hear music: pure Rust spectral, harmonic, rhythm and timbre analysis returned as structured data. MIT.
- Use: tempo, key, sections and timbre of a reference track or your own music bed; confirm the beat grid before placing hits.
- Example: `cargo build --release && claude mcp add --scope user audio-analyzer -- $(pwd)/target/release/mcp-server`, then ask Claude for the audio analysis tools on `music.wav`.
- Choose it when: you need numbers about music rather than a description. Local MCP server: needs Claude Code or Claude Desktop.

## 9. whaleyxbt/claude-motion — https://github.com/whaleyxbt/claude-motion
- A motion-design toolkit for coding agents with four skills: motion-design, review-loop, sound-design, web-sims. MIT. (About 391 stars: small, so used as a quality layer, not the main engine.)
- Use: motion rules, a contact-sheet review loop, a synthesized sound-design engine and cue sheets, deterministic simulations rendered frame by frame.
- Example: `cd repos/vendor/claude-motion && npm install && npm run build && npm run studio`; read `AGENTS.md`.
- Choose it when: you want the review loop or procedural simulation scenes.

## 10. remotion-dev/remotion — https://github.com/remotion-dev/remotion   (GATE: license check)
- Make videos programmatically with React. About 50k stars. Custom license: free for individuals and small companies, paid above that.
- Use: React-component scenes, data-driven videos, existing Remotion scaffolds, `@remotion/three` for 3D.
- Example: `cd templates/remotion-minimal && npm install && npx remotion render src/index.ts Launch out/launch.mp4 --crf=17`
- Choose it when: React components or a Remotion scaffold are needed and the license is cleared. Otherwise use HyperFrames. The template type-checks; a render needs a browser download that the build environment did not allow.

## 11. mrdoob/three.js — https://github.com/mrdoob/three.js
- The standard JavaScript 3D library (about 117.6k stars, MIT).
- Use: 3D devices, product turntables, fly-throughs, particle fields, lighting with one key light and shallow depth of field.
- Example: inside Remotion, `templates/r3f/Product3D.tsx`; in HyperFrames and saas-animation pages, load a pinned `three@0.186.1`.
- Choose it when: 3D carries meaning. Skip it for flat typography scenes.

## 12. pmndrs/react-three-fiber — https://github.com/pmndrs/react-three-fiber
- A React renderer for three.js (MIT; v9 pairs with React 19).
- Use: declarative 3D inside React and Remotion via `@remotion/three`'s `ThreeCanvas`.
- Example: see `templates/r3f/Product3D.tsx` (all values derived from `useCurrentFrame()`).
- Choose it when: the project is already React/Remotion. Use plain three.js elsewhere.

## 13. greensock/GSAP — https://github.com/greensock/GSAP
- JavaScript animation library: timelines, staggers, easing, path drawing. "No charge" license.
- Use: micro-animation timing, word-by-word text reveals, path draws, stagger waves; the timing layer inside HyperFrames pages.
- Example: in Remotion, build a paused timeline once and seek it each frame: `tl.time(frame / fps)`.
- Choose it for any timeline-based motion. Do not build a competing visual animation-builder on it.

## 14. JuneYaooo/rea-video — https://github.com/JuneYaooo/rea-video
- Reverse-engineer any video shot by shot: tells you which shots are filmed, AI-generated or coded, and how to remake them. Apache-2.0. Your key tool for "copy the style of this reference".
- Use: decompose a reference into shots, stems (vocals/music), measurements, an HTML report, and a remake plan.
- Example: `bash repos/vendor/rea-video/scripts/install_skill.sh` then `rea-video decompose ref.mp4 -o analysis/ref01/rea` and `rea-video summary analysis/ref01/rea`; open `report.html`.
- Choose it whenever a reference video is provided. The first run downloads a model of about 67 MB. A vision model is optional (`REA_VLM_*` variables).

## 15. charlie947/motion-graphics-skills — https://github.com/charlie947/motion-graphics-skills
- Fifteen Claude Code skills for launch-grade motion graphics where every frame is code: brand-intake, launch-video, reference-to-motion, motion-prompt-writer, title-sequence-3d, animated-chart and more. MIT.
- Use: brand intake first; reference-to-motion for style fingerprints; launch-video and title sequences for builds.
- Example: copy `repos/vendor/motion-graphics-skills/skills/*` into `.claude/skills/`, then run `/brand-intake` with the company URL.
- Choose it when: you want ready-made, opinionated motion recipes.

## 16. EveryInc/product-launch-video — https://github.com/EveryInc/product-launch-video
- Claude Code skill plus a Remotion scaffold for polished product launch videos; storyboard first, then four parallel critic passes. MIT.
- Use: structure for 15–30 s launch films and the critic-agent QA pattern.
- Example: read `repos/vendor/product-launch-video/.claude/skills/product-launch-video/SKILL.md`; scaffold: `npm install`.
- Choose it when: the video is a classic product launch. The scaffold uses Remotion (license check).

## 17. latent-spaces/brag — https://github.com/latent-spaces/brag
- Turn the project you just built into a short shareable launch video with one command; built on HyperFrames.
- Use: fast 20 s films for a codebase or an app the user built; `/brag-slim` suits newer models.
- Example: `npx skills add https://github.com/latent-spaces/brag --skill brag-slim`, then `/brag-slim` inside the project folder.
- Choose it when: there is a real repository to showcase and speed matters.

## 18. feitangyuan/onetake — https://github.com/feitangyuan/onetake   (GATE: noncommercial)
- Motion films that never cut: every beat grows out of the previous one, one continuous camera, continuity checked by a measuring tool. PolyForm Noncommercial 1.0.0.
- Status: NOT included in this zip and OFF for client work. Commercial use needs onetake Pro.
- Use: personal or practice films, or a commercial project after the user buys Pro. The continuity principle itself is applied in the Director (Section 6.3) without its code.
- Choose it when: a one-take film is requested and the license is cleared.

---

## Added by the Director (not in your list)

| Name | Why |
|---|---|
| yt-dlp/yt-dlp (upstream) | Fallback if your fork lags behind site changes. |
| librosa (optional) | Beat and onset tracking fallback. |
| hexgrad/kokoro (optional) | Free neutral TTS when no ElevenLabs plan exists; confirm voice terms. |
| Blender | Level 3 photoreal and silhouette product renders (from the saas-animation skill). |
| Playwright Chromium | Headless browser for claude-motion simulations and captures. |
| SFX sources: Mixkit, Freesound (CC0), Pixabay, Kenney audio | Free sound libraries; log each license. |
| User resources: Motion-as-Code kit, saas-animation skill, two PDFs | Included under `resources/`; the saas-animation skill is also active at `.claude/skills/saas-animation/`. |
