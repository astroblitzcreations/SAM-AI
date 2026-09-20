# SAM-AI v1.0.4

SAM-AI is a private, local and offline desktop AI interface created by Steadyforge
of Astroblitz Creations and Makazhan.

## Setup and reliability update

- Bundles an official Windows x64 CPU llama.cpp runtime, so new users no longer
  need to find `llama-server.exe` before starting SAM.
- Automatically detects the bundled runtime and re-checks setup after the
  Microsoft Visual C++ installer finishes.
- Blocks models that cannot safely fit into a CPU-only machine's physical RAM
  and points users to the lightweight 3B model or a GPU runtime.
- Uses CPU-safe GPU-layer settings when CUDA/Vulkan libraries are unavailable.
- Adds an official latest-release link for llama.cpp runtime updates.
- Adds llama.cpp file logging and a 90-second first-token timeout so startup or
  inference failures produce an actionable error instead of thinking forever.
- Uses safer context/output defaults on computers with 6 GB RAM or less.
- Corrects Windows Sandbox memory reporting and clarifies CPU versus GPU loading.

## Install

1. Extract the complete ZIP into one folder.
2. Keep `SAM-AI.exe`, `SAM-AI.pck`, and the `engine` and `voice` folders together.
3. Run `SAM-AI.exe`.
4. Open Modules and use the setup checker to select or download a GGUF model and llama.cpp runtime.
5. Optional: configure Kokoro and Whisper using `voice/README.txt`.

Large GGUF and voice model files are intentionally not bundled. Users select their
own compatible local models from the Modules tab.

Support development: https://buymeacoffee.com/astroblitzcreations
