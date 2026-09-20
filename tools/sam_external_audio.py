"""Receive ESP32 PCM frames and emit short WAV segments for SAM/Whisper."""
from __future__ import annotations
import argparse, asyncio, struct, wave, subprocess, json
from pathlib import Path
try:
    from faster_whisper import WhisperModel
except ImportError:
    WhisperModel = None

class ExternalAudio:
    def __init__(self, out_dir: Path, seconds: float, whisper: Path | None):
        self.out_dir = out_dir; self.target = int(16000 * seconds); self.whisper = whisper; self.buf = bytearray(); self.segment = bytearray(); self.n = 0; self.model = None

    def feed(self, data: bytes):
        self.buf.extend(data)
        marker = b'SAM1'
        while len(self.buf) >= 8:
            pos = self.buf.find(marker)
            if pos < 0:
                del self.buf[:-3]; return
            if pos: del self.buf[:pos]
            size = struct.unpack_from('<I', self.buf, 4)[0]
            if size == 0 or size > 65536 or size % 2:
                del self.buf[:4]; continue
            if len(self.buf) < size + 8: return
            pcm = bytes(self.buf[8:size + 8]); del self.buf[:size + 8]
            self.write(pcm)

    def write(self, pcm: bytes):
        self.segment.extend(pcm); self.n += len(pcm) // 2
        if self.n < self.target: return
        self.out_dir.mkdir(parents=True, exist_ok=True)
        path = self.out_dir / f'esp_segment_{int(asyncio.get_running_loop().time()*1000)}.wav'
        with wave.open(str(path), 'wb') as w:
            w.setnchannels(1); w.setsampwidth(2); w.setframerate(16000); w.writeframes(self.segment)
        if self.whisper and self.whisper.exists():
            result = subprocess.run([str(self.whisper), '-m', 'E:/sam-ai/voice/whisper/ggml-base.en-q5_1.bin', '-f', str(path), '--no-timestamps', '-otxt'], capture_output=True, text=True)
            text = result.stdout.strip()
            path.with_suffix('.json').write_text(json.dumps({'type':'transcript','text':text}, ensure_ascii=False), encoding='utf-8')
        elif WhisperModel:
            if self.model is None:
                self.model = WhisperModel('base.en', device='cpu', compute_type='int8')
            segments, _ = self.model.transcribe(str(path), language='en')
            text = ' '.join(s.text.strip() for s in segments).strip()
            path.with_suffix('.json').write_text(json.dumps({'type':'transcript','text':text}, ensure_ascii=False), encoding='utf-8')
        self.n = 0; self.segment.clear()

async def main(host: str, port: int, out_dir: Path, seconds: float, whisper: Path | None):
    audio = ExternalAudio(out_dir, seconds, whisper)
    async def client(reader, writer):
        try:
            while data := await reader.read(65536): audio.feed(data)
        finally: writer.close(); await writer.wait_closed()
    server = await asyncio.start_server(client, host, port)
    print(f'external audio adapter listening on {host}:{port}')
    async with server: await server.serve_forever()

if __name__ == '__main__':
    p = argparse.ArgumentParser(); p.add_argument('--host', default='127.0.0.1'); p.add_argument('--port', type=int, default=8765); p.add_argument('--out', type=Path, default=Path('external_audio')); p.add_argument('--seconds', type=float, default=3.0); p.add_argument('--whisper', type=Path)
    a = p.parse_args(); asyncio.run(main(a.host, a.port, a.out, a.seconds, a.whisper))
