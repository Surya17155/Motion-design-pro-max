# Test-launch checklist (manual version of tests/run_test_launch.sh)

1. `bash scripts/check_env.sh` -> RESULT: ready
2. `bash scripts/make_sample.sh tests/sample/sample_reference.mp4` (a sample ships in tests/sample/)
3. `bash scripts/ingest.sh tests/sample/sample_reference.mp4 tests/report/out/ref01` -> frames, cuts, contact sheet, audio
4. `python3 scripts/analyze_audio.py tests/report/out/ref01/audio.wav` -> expect about 60 BPM, confidence above 0.9
5. `python3 scripts/validate_storyboard.py 60s_storyboard_example.json --seconds 60` -> PASS
6. `bash scripts/mix_audio.sh …` -> integrated loudness within 1 LU of the target, true peak at or below -1.0 dBTP
7. Optional (needs a browser): Remotion still render; HyperFrames init and render
8. Read tests/report/test_report.md. Every SKIPPED row lists the command that enables it.
