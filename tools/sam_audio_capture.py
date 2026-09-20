"""Reliable Windows audio capture for SAM-AI Knowledge Vault."""
from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

import numpy as np
import sounddevice as sd
import soundfile as sf
import pyaudiowpatch as pyaudio


def choose_source(mode: str, device_name: str):
    if mode.startswith("PC output"):
        audio = pyaudio.PyAudio()
        try:
            source = audio.get_default_wasapi_loopback()
        finally:
            audio.terminate()
        if not source:
            raise RuntimeError("Windows has no default WASAPI speaker-loopback endpoint")
        sample_rate = int(float(source["defaultSampleRate"]))
        # WASAPI shared-loopback endpoints must be opened with their complete
        # native channel layout (this Realtek device is 5.1 / six channels).
        # Opening it as stereo returns PaError -9996 even though the endpoint is
        # valid. The capture loop downmixes all channels to mono for Whisper.
        channels = max(1, int(source["maxInputChannels"]))
        return "wasapi_loopback", source, f"PC output: {source['name']}", sample_rate, channels
    host_apis = sd.query_hostapis()
    candidates = [
        (index, info, str(host_apis[int(info["hostapi"])]["name"]))
        for index, info in enumerate(sd.query_devices())
        if int(info["max_input_channels"]) > 0 and (
            device_name == "Default"
            or str(info["name"]) == device_name
            or device_name.startswith(str(info["name"]).rstrip())
        )
    ]
    if not candidates:
        default_index = int(sd.default.device[0])
        if default_index < 0:
            raise RuntimeError(f"PortAudio could not find input device: {device_name}")
        info = sd.query_devices(default_index)
        candidates = [(default_index, info, str(host_apis[int(info["hostapi"])]["name"]))]
    # This machine's Godot/WASAPI route produces sparse, very quiet samples.
    # Prefer DirectSound for USB microphones, with MME as the next stable choice.
    priorities = {"Windows WASAPI": 4, "MME": 3, "Windows DirectSound": 2, "Windows WDM-KS": 1}
    index, info, host_name = max(candidates, key=lambda item: (priorities.get(item[2], 0), float(item[1]["default_samplerate"])))
    sample_rate = int(float(info["default_samplerate"]))
    capture_channels = 2 if host_name == "Windows WASAPI" and int(info["max_input_channels"]) >= 2 else 1
    return "microphone", index, f"Input: {info['name']} via {host_name}", sample_rate, capture_channels


def prepare_audio_for_speech(audio: np.ndarray) -> np.ndarray:
    """Remove DC and raise quiet speech without allowing digital clipping."""
    if audio.size == 0:
        return audio
    audio = audio.astype(np.float32, copy=False)
    audio -= np.mean(audio, axis=0, keepdims=True)
    peak = float(np.max(np.abs(audio)))
    if peak < 1e-5:
        return audio
    gain = min(12.0, 0.88 / peak)
    return np.clip(audio * gain, -0.98, 0.98)


def write_status(path: Path, **values) -> None:
    temporary = path.with_suffix(".tmp")
    payload = json.dumps(values)
    try:
        temporary.write_text(payload, encoding="utf-8")
        temporary.replace(path)
    except OSError:
        # Windows may briefly lock the JSON while Godot reads it. Status is
        # advisory; never let that interrupt the actual audio recording.
        try:
            path.write_text(payload, encoding="utf-8")
        except OSError:
            pass


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", required=True)
    parser.add_argument("--device", default="Default")
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--session", required=True)
    parser.add_argument("--status", type=Path, required=True)
    parser.add_argument("--stop-file", type=Path, required=True)
    parser.add_argument("--chunk-seconds", type=float, default=45.0)
    parser.add_argument("--format", choices=("wav", "flac"), default="wav")
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    backend, source, source_label, sample_rate, capture_channels = choose_source(args.mode, args.device)
    block_frames = max(1024, sample_rate // 10)
    chunk_target = int(sample_rate * args.chunk_seconds)
    sequence = 1
    buffered: list[np.ndarray] = []
    buffered_frames = 0
    write_status(args.status, state="starting", level_db=-60.0, source=source_label, chunks=0)

    wasapi_audio = None
    if backend == "wasapi_loopback":
        wasapi_audio = pyaudio.PyAudio()
        recorder_context = wasapi_audio.open(
            format=pyaudio.paFloat32,
            channels=capture_channels,
            rate=sample_rate,
            input=True,
            input_device_index=int(source["index"]),
            frames_per_buffer=block_frames,
        )
    else:
        recorder_context = sd.InputStream(device=source, samplerate=sample_rate, channels=capture_channels, blocksize=block_frames, dtype="float32")
    try:
        if backend != "wasapi_loopback":
            recorder_context.start()
        while not args.stop_file.exists():
            if backend == "wasapi_loopback":
                raw = recorder_context.read(block_frames, exception_on_overflow=False)
                data = np.frombuffer(raw, dtype=np.float32).reshape(-1, capture_channels)
            else:
                data, _overflowed = recorder_context.read(block_frames)
            if data.ndim == 1:
                data = data[:, None]
            if data.shape[1] > 1:
                data = np.mean(data, axis=1, keepdims=True)
            buffered.append(data.copy())
            buffered_frames += len(data)
            rms = float(np.sqrt(np.mean(np.square(data), dtype=np.float64)))
            level_db = max(-60.0, 20.0 * np.log10(max(rms, 1e-6)))
            write_status(args.status, state="recording", level_db=level_db, source=source_label, chunks=sequence - 1)
            if buffered_frames >= chunk_target:
                audio = prepare_audio_for_speech(np.concatenate(buffered, axis=0))
                path = args.output_dir / f"chunk_{args.session}_{sequence:04d}.{args.format}"
                sf.write(path, audio, sample_rate, subtype="PCM_16" if args.format == "wav" else None)
                sequence += 1
                buffered.clear()
                buffered_frames = 0
    finally:
        if backend == "wasapi_loopback":
            recorder_context.stop_stream()
            recorder_context.close()
            wasapi_audio.terminate()
        else:
            recorder_context.stop()
            recorder_context.close()

    if buffered_frames >= sample_rate // 2:
        audio = prepare_audio_for_speech(np.concatenate(buffered, axis=0))
        path = args.output_dir / f"chunk_{args.session}_{sequence:04d}.{args.format}"
        sf.write(path, audio, sample_rate, subtype="PCM_16" if args.format == "wav" else None)
        sequence += 1
    write_status(args.status, state="stopped", level_db=-60.0, source=source_label, chunks=sequence - 1)
    args.stop_file.unlink(missing_ok=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
