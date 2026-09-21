# SAM-AI

SAM-AI is a private, local and offline desktop AI interface built with Godot 4.6.
It runs GGUF language and vision models through llama.cpp, supports attachments,
local memory, Kokoro speech output, and Whisper speech-to-text.

Image and video generation are isolated in the **Image + Video Studio** tab.
Normal Chat handles conversation, coding, and artifact building and cannot start a
visual module accidentally. Studio includes dedicated prompts, engine selection,
reference images, presets, video duration/FPS, and module installation controls.

Created by Steadyforge of Astroblitz Creations and Makazhan.

## Windows release

Download the Windows ZIP from the repository's Releases page, extract the complete
archive, and run `SAM-AI.exe`. Keep the executable, `.pck`, and `voice` folder together.

SAM-AI intentionally does not bundle multi-gigabyte AI models. On first launch, use
the Modules tab and its setup checker to download or select a compatible GGUF model,
Windows llama.cpp runtime, and any optional vision or voice modules.

On NVIDIA systems, first-run setup and Modules provide an **Install / Repair
NVIDIA CUDA** action. SAM downloads the two matching official llama.cpp CUDA
packages, installs them into its private app-data folder, selects the GPU engine,
and keeps the bundled CPU runtime available as a fallback. Windows Sandbox may
display the host GPU name even when CUDA passthrough is unavailable; verify GPU
acceleration on a normal Windows installation.

## Development

Open `project.godot` in Godot 4.6. Model, engine, memory, appearance, and voice paths
are stored in Godot's per-user application data rather than committed here.

## Privacy

Inference, memory, attachments, speech recognition, and speech synthesis remain on
the user's computer when local modules are selected. Microphone capture starts only
after the user presses Start Talking.

## Support

[Buy Me a Coffee](https://buymeacoffee.com/astroblitzcreations)
