# ESP32 ↔ SAM-AI serial bridge

Transport: USB CDC serial, 921600 baud, UTF-8 newline-delimited frames.

Control frames are JSON objects terminated by `\n`:

```json
{"type":"hello","version":1,"device":"pocket-c3"}
{"type":"state","value":"standby|listening|thinking|speaking","text":"..."}
{"type":"chat","text":"recognized speech"}
{"type":"audio_begin","sample_rate":16000,"channels":1,"format":"pcm_s16le"}
{"type":"audio_end"}
```

Binary audio frames use a 4-byte little-endian payload length followed by PCM
bytes. The ESP32 sends microphone frames; SAM sends speaker frames. OLED state
and animation selection are driven by `state` frames.

This protocol intentionally keeps the Xiaozhi cloud/API out of the loop: SAM-AI
does recognition, local inference, and TTS on Windows.
