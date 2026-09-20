"""Offline speech bridge used by the SAM-AI Godot client."""
from __future__ import annotations
import argparse, json, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent

def synthesize(text_file: Path, output: Path, voice: str, speed: float, model: Path, voices: Path) -> None:
    import soundfile as sf
    from kokoro_onnx import Kokoro
    text = text_file.read_text(encoding="utf-8").strip()
    if not text:
        raise ValueError("No text was supplied for speech synthesis")
    kokoro = Kokoro(str(model), str(voices))
    samples, sample_rate = kokoro.create(text, voice=voice, speed=speed, lang="en-us")
    output.parent.mkdir(parents=True, exist_ok=True)
    sf.write(output, samples, sample_rate, subtype="PCM_16")
    print(json.dumps({"ok": True, "output": str(output), "sample_rate": sample_rate}))

def transcribe(audio: Path, output: Path, executable: Path, model: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    prefix = output.with_suffix("")
    command = [
        str(executable), "-m", str(model), "-f", str(audio),
        "-otxt", "-of", str(prefix), "-nt", "-np", "-l", "en", "-sns",
        "-nth", "0.45", "-et", "2.0", "-lpt", "-0.7",
        "--prompt", "Clear conversational English speech. Transcribe only words actually spoken by a person.",
    ]
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    generated = prefix.with_suffix(".txt")
    if result.returncode != 0 or not generated.exists():
        detail = result.stderr.strip() or result.stdout.strip() or "Whisper failed"
        raise RuntimeError(detail[-1000:])
    text = generated.read_text(encoding="utf-8").strip()
    if generated != output:
        output.write_text(text, encoding="utf-8")
        generated.unlink(missing_ok=True)
    print(json.dumps({"ok": True, "output": str(output), "text": text}))

def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    tts = subparsers.add_parser("tts")
    tts.add_argument("--text-file", type=Path, required=True)
    tts.add_argument("--output", type=Path, required=True)
    tts.add_argument("--voice", default="af_heart")
    tts.add_argument("--speed", type=float, default=1.0)
    tts.add_argument("--kokoro-model", type=Path, required=True)
    tts.add_argument("--kokoro-voices", type=Path, required=True)
    stt = subparsers.add_parser("stt")
    stt.add_argument("--audio", type=Path, required=True)
    stt.add_argument("--output", type=Path, required=True)
    stt.add_argument("--whisper-exe", type=Path, required=True)
    stt.add_argument("--whisper-model", type=Path, required=True)
    args = parser.parse_args()
    try:
        if args.command == "tts":
            synthesize(args.text_file, args.output, args.voice, args.speed, args.kokoro_model, args.kokoro_voices)
        else:
            transcribe(args.audio, args.output, args.whisper_exe, args.whisper_model)
        return 0
    except Exception as exc:
        print(json.dumps({"ok": False, "error": str(exc)}), file=sys.stderr)
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
