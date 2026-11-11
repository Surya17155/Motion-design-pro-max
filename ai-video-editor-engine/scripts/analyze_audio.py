#!/usr/bin/env python3
"""Measure an audio or video file: loudness, true peak, silences, onsets, tempo estimate with confidence.
Usage: python3 scripts/analyze_audio.py <file> > audio_facts.json
Needs: ffmpeg on PATH, numpy. Timing comes from measurement, never from a language model's guess.
Tempo caution: a beat tracker always returns a tempo; trust it only when tempo.confidence >= 0.5."""
import json, re, subprocess, sys
import numpy as np

SR = 22050

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)

def loudness(path):
    r = run(["ffmpeg", "-hide_banner", "-nostats", "-i", path, "-vn", "-filter_complex", "ebur128=peak=true", "-f", "null", "-"]).stderr
    tail = r[r.rfind("Summary:"):] if "Summary:" in r else r
    def grab(pat):
        m = re.search(pat, tail)
        return float(m.group(1)) if m else None
    return {"integrated_lufs": grab(r"I:\s+(-?[\d.]+)\s+LUFS"), "lra_lu": grab(r"LRA:\s+(-?[\d.]+)\s+LU"), "true_peak_dbtp": grab(r"Peak:\s+(-?[\d.]+)\s+dBFS")}

def silences(path, noise_db=-45, min_d=0.3):
    r = run(["ffmpeg", "-hide_banner", "-nostats", "-i", path, "-vn", "-af", f"silencedetect=noise={noise_db}dB:d={min_d}", "-f", "null", "-"]).stderr
    starts = [float(x) for x in re.findall(r"silence_start: (-?[\d.]+)", r)]
    ends = [float(x) for x in re.findall(r"silence_end: (-?[\d.]+)", r)]
    return [{"start": round(s, 3), "end": round(e, 3)} for s, e in zip(starts, ends)]

def decode(path):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-vn", "-ac", "1", "-ar", str(SR), "-f", "f32le", "-"], capture_output=True).stdout
    return np.frombuffer(raw, np.float32)

def onsets_and_tempo(x):
    if len(x) < SR:
        return [], {"bpm": None, "confidence": 0.0}
    n_fft, hop = 1024, 256
    win = np.hanning(n_fft)
    frames = 1 + (len(x) - n_fft) // hop
    idx = np.arange(n_fft)[None, :] + hop * np.arange(frames)[:, None]
    mag = np.abs(np.fft.rfft(x[idx] * win, axis=1))
    flux = np.maximum(0, np.diff(np.log1p(mag * 50), axis=0)).sum(axis=1)
    flux = np.concatenate([[0], flux])
    flux = (flux - flux.mean()) / (flux.std() + 1e-9)
    fps = SR / hop
    thr = 1.2
    peaks = [i for i in range(2, len(flux) - 2) if flux[i] > thr and flux[i] >= flux[i-1] and flux[i] > flux[i+1] and flux[i] >= flux[i-2]]
    min_gap = int(0.06 * fps); sel = []
    for i in peaks:
        if not sel or i - sel[-1] >= min_gap: sel.append(i)
    onset_times = [round(i / fps + (n_fft / 2) / SR, 3) for i in sel]   # window-centre time; accuracy about +/-25 ms: refine on the waveform
    # tempo from inter-onset intervals (median), cross-checked with autocorrelation of the onset envelope
    if len(onset_times) < 4:
        return onset_times, {"bpm": None, "confidence": 0.0, "note": "fewer than 4 onsets: no reliable pulse"}
    ioi = np.diff(onset_times)
    med = float(np.median(ioi))
    cv = float(np.std(ioi) / (np.mean(ioi) + 1e-9))
    bpm = 60.0 / med
    while bpm < 50: bpm *= 2
    while bpm > 200: bpm /= 2
    f = np.maximum(flux, 0)
    ac = np.correlate(f, f, "full")[len(f) - 1:]
    lo, hi = int(fps * 60 / 220), min(int(fps * 60 / 40), len(ac) - 1)
    ac_bpm = None
    if hi > lo:
        k = int(np.argmax(ac[lo:hi])) + lo
        ac_bpm = 60 * fps / k
    agree = ac_bpm is not None and any(abs(ac_bpm / (bpm * m) - 1) < 0.05 for m in (0.5, 1, 2))
    conf = float(np.clip(1.0 - cv * 1.5, 0, 1)) * (1.0 if agree else 0.6)
    return onset_times, {"bpm": round(bpm, 1), "alternates_half_double": [round(bpm / 2, 1), round(bpm * 2, 1)],
                         "interval_cv": round(cv, 3), "autocorr_bpm": round(ac_bpm, 1) if ac_bpm else None, "confidence": round(conf, 2)}

def main():
    if len(sys.argv) < 2: sys.exit(__doc__)
    path = sys.argv[1]
    dur = float(run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=nw=1:nk=1", path]).stdout.strip() or 0)
    x = decode(path)
    onsets, tempo = onsets_and_tempo(x)
    out = {"file": path, "duration_s": round(dur, 3), "loudness": loudness(path), "silences": silences(path),
           "tempo": tempo, "onset_count": len(onsets), "onsets_s": onsets[:400],
           "notes": "Trust tempo only if confidence >= 0.5. Onset times are accurate to about +/-25 ms; refine against the waveform before frame-exact SFX placement."}
    json.dump(out, sys.stdout, indent=2); print()

if __name__ == "__main__":
    main()
