SAM-AI OPTIONAL VOICE RUNTIME

These helper scripts belong in the voice folder beside SAM-AI.exe.

Kokoro text-to-speech requires:
  kokoro-v1.0.onnx
  voices-v1.0.bin

Whisper speech-to-text requires:
  whisper-cli.exe (from the extracted Windows whisper.cpp package)
  ggml-base.en-q5_1.bin

Install Python 3.11 or newer, create a virtual environment, install the packages
listed in requirements.txt, and select that environment's python.exe in SAM-AI's
Modules tab. Select each downloaded model/runtime file there and press
SAVE VOICE MODULE PATHS.

Voice is optional. Text chat works without these components.
