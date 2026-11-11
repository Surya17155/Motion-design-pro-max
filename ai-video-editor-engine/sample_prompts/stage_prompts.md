# Stage prompts (copy, fill the brackets)

**1. Research** — "Open <url>. Extract name, offer, audience, location, tone (5 headlines, 5 button labels), colors (hex), fonts, UI style. Save brand/brand_profile.json with a confidence per field. Mark guesses."

**2. Reference breakdown** — "Run /watch on <ref> with the question 'list each shot with timestamps, what moves and how, text on screen, colors, camera'. Run rea-video decompose and open report.html. Write analysis/<ref>/style_fingerprint.json (palette, type, average shot length, cuts per 10 s, easing character, camera, depth, text density, hook structure, end card). Show me the contact sheet and a 5-line summary."

**3. Audio facts** — "Run scripts/analyze_audio.py on the reference audio. Report loudness, tempo with confidence, onsets, silences. Use audio-analyzer-rs and sound-ear for structure and SFX map. Trust a tempo only at confidence 0.5 or higher."

**4. Script** — "Write a voice-over script of <N> words (2.2 words per second) for <runtime> s, one line per shot, in the brand voice. Only claims I can back. Add delivery notes and one alternative angle. Give each line a start time on the beat grid."

**5. Storyboard** — "Make a numbered storyboard of 5-10 shots with time ranges, a still frame using the real assets, the on-screen line, what moves, and how each shot turns into the next. Fill templates/storyboard.html or storyboard_template.md. Show it and wait."

**6. Shot planning** — "Expand the approved storyboard into storyboard/storyboard.json (one entry per second: visual, animation with easing and duration, transition, audio with levels, tools). Validate with scripts/validate_storyboard.py."

**7. Asset selection** — "List every asset needed (logo, fonts, screenshots, music, SFX). Mark what the user supplied, what must be requested, and what is free to use (record license and URL in audio/licenses.csv)."

**8. Render** — "Render a 10-second draft at 960x540 (samples 4). Show a contact sheet every 0.5 s. Then wait for my notes."

**9. QA** — "Run templates/qa_checklist.md. Measure loudness. Check each hit within 1 frame. Report what you checked and what you could not (playback, listening)."

**10. Notes round** — "Back up the project. Apply every note: <notes>. Re-render only the changed parts. Report changes in plain words."
