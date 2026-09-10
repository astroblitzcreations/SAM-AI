"""Persistent local Kokoro queue worker for low-latency SAM-AI speech."""
from __future__ import annotations
import argparse, json, time
from pathlib import Path
import soundfile as sf
from kokoro_onnx import Kokoro

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--queue-dir", type=Path, required=True)
    parser.add_argument("--kokoro-model", type=Path, required=True)
    parser.add_argument("--kokoro-voices", type=Path, required=True)
    args = parser.parse_args()
    queue_dir = args.queue_dir
    queue_dir.mkdir(parents=True, exist_ok=True)
    kokoro = Kokoro(str(args.kokoro_model), str(args.kokoro_voices))
    kokoro.create("Voice ready.", voice="af_heart", speed=1.08, lang="en-us")
    (queue_dir / "daemon.ready").write_text("ready", encoding="utf-8")
    while True:
        jobs = sorted(queue_dir.glob("*.job"), key=lambda path: path.name)
        if not jobs:
            time.sleep(0.025)
            continue
        job_path = jobs[0]
        try:
            job = json.loads(job_path.read_text(encoding="utf-8"))
            job_id = str(job["id"])
            samples, sample_rate = kokoro.create(str(job["text"]), voice=str(job.get("voice", "af_heart")), speed=float(job.get("speed", 1.0)), lang="en-us")
            sf.write(queue_dir / f"{job_id}.wav", samples, sample_rate, subtype="PCM_16")
            (queue_dir / f"{job_id}.done").write_text("ok", encoding="utf-8")
        except Exception as exc:
            job_id = str(job.get("id", job_path.stem)) if "job" in locals() else job_path.stem
            (queue_dir / f"{job_id}.error").write_text(str(exc), encoding="utf-8")
        finally:
            job_path.unlink(missing_ok=True)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
