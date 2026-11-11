# License and usage notes (read before client work)

This is practical guidance, not legal advice. Re-check each license before publishing, and keep a copy of the license text for every asset you use.

## Tools

| Tool | License | What it means for client videos |
|---|---|---|
| HyperFrames (heygen-com/hyperframes) | Apache-2.0 | Free for commercial use; keep notices. |
| Remotion | Remotion License (custom) | Free for individuals and small companies; companies above the free limit need a paid license. Confirm before client work. If unsure, use HyperFrames. |
| three.js, react-three-fiber | MIT | Free for commercial use; keep the notice. |
| GSAP | GSAP "no charge" standard license | Free for these videos; not allowed to build a visual animation-builder product that competes with GSAP. |
| FFmpeg | LGPL-2.1+ (GPL if built with x264) | Fine for rendering. Do not redistribute an ffmpeg binary without following its license. |
| openai/whisper | MIT | Free. |
| yt-dlp (and the user's fork) | Unlicense | Free. Downloading videos is subject to each site's terms and to copyright: private analysis only. |
| claude-video, claude-sound-ear, audio-analyzer-rs, claude-motion, motion-graphics-skills, product-launch-video, brag | MIT | Free; keep the license files with any copy. |
| rea-video | Apache-2.0 | Free; keep LICENSE and NOTICE. |
| metaphrasis | Proprietary, sold per license; the repo says it is not open source and grants no right to copy, repackage or ship it (commits before 2026-10-11 were MIT) | DEFAULT OFF. Not included in this zip. Buy a license if you want it. The free substitute is audio-analyzer-rs + claude-sound-ear + scripts/analyze_audio.py. |
| onetake | PolyForm Noncommercial 1.0.0; commercial license = onetake Pro (one-time purchase) | DEFAULT OFF for client or business work. Not included in this zip. |
| Motion-as-Code kit (user-supplied) | Engine is pdoom-video by mexicat (MIT; LICENSE.pdoom-engine included); the nine plates were written for the original voiceover | Keep LICENSE.pdoom-engine with the project. |
| saas-animation skill (user-supplied) | No license text in the bundle | Fine for your own work. Confirm the author's terms before redistributing this engine publicly or selling it. |
| Blender | GPL | Free; output you render is yours. |
| Kokoro TTS (optional) | Apache-2.0 code | Confirm the model and voice terms before client use. |

## Assets

- **Brand assets:** only use logos, fonts, photos and copy the client supplied or approved. Never redraw or recolor a logo. Spec ads for brands you do not own are practice or portfolio pieces: end with "Spec ad. Not affiliated with <brand>.", do not imitate real campaigns, and do not run them as paid ads.
- **Voice and music:** ElevenLabs and Suno terms depend on your plan; check that your plan allows commercial publishing before using generated audio in a client deliverable.
- **Sound effects:** free libraries differ. Prefer CC0 (Freesound CC0 filter, Kenney). Mixkit and Pixabay have their own licenses: read them. Log every cue in `audio/licenses.csv` (file, source URL, license, date).
- **Fonts:** Google Fonts are OFL. SF Pro is only licensed for Apple platforms and design mockups for them.
- **Photos and footage:** use only what you own or are licensed to use. Remove personal details and get consent from anyone who appears.
- **Reference videos:** never reuse their footage, music, logos or copy. Delete downloaded copies after analysis unless you own them.
- **Claims:** every statistic, quote, review or badge on screen must be true and provable.
