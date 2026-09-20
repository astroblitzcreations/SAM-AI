from __future__ import annotations

import gc
import ctypes
import json
import os
import subprocess
import sys
import time
from pathlib import Path

WAN_PYTHON = Path(r"__WAN_PYTHON__")
if WAN_PYTHON.is_file() and Path(sys.executable).resolve() != WAN_PYTHON.resolve():
    # os.execv() does not reliably quote argv[0] on Windows when the executable
    # path contains spaces (for example, "SAM-AI Playground").  Spawn the Wan
    # interpreter explicitly and preserve its exit status instead.
    wan_environment = os.environ.copy()
    # Keep Wan isolated from unrelated packages installed in the Windows user
    # site. The module installer places every required dependency in this venv.
    wan_environment["PYTHONNOUSERSITE"] = "1"
    raise SystemExit(
        subprocess.run(
            [str(WAN_PYTHON), str(Path(__file__).resolve())],
            check=False,
            env=wan_environment,
        ).returncode
    )

import numpy as np
import psutil
import torch
from diffusers import DiffusionPipeline, WanImageToVideoPipeline
from diffusers.utils import export_to_video, load_image
from PIL import Image

MODEL_PATH = Path(r"__MODEL_PATH__")
OFFLOAD_PATH = MODEL_PATH.parent / "offload"
FACE_RUNTIME = Path(os.environ.get("SAM_AI_FACE_RUNTIME", r"E:/sam-ai/FaceRestoreRuntime"))
FACE_PYTHON = FACE_RUNTIME / "venv" / "Scripts" / "python.exe"
FACE_SCRIPT = FACE_RUNTIME / "restore_faces.py"
FACE_MODEL = FACE_RUNTIME / "GFPGANv1.4.pth"
SOURCE_IMAGE = Path(r"__SOURCE_IMAGE__") if r"__SOURCE_IMAGE__" else None
OUTPUT_PATH = Path(r"__OUTPUT_PATH__")
PROGRESS_PATH = Path(r"__PROGRESS_PATH__")
PROMPT = r"""__PROMPT__"""
FRAME_COUNT = __FRAME_COUNT__
OUTPUT_KIND = "__OUTPUT_KIND__"

# Correct a few common speech-to-text spellings before the visual model sees
# them.  This keeps the user's requested garment explicit instead of letting
# the model reinterpret an unknown word.
PROMPT = PROMPT.replace(" braw", " bra").replace("Braw", "Bra")


def write_progress(stage: str, percent: float, title: str, detail: str, eta: str = "") -> None:
    PROGRESS_PATH.parent.mkdir(parents=True, exist_ok=True)
    temporary = PROGRESS_PATH.with_suffix(".tmp")
    temporary.write_text(
        json.dumps(
            {"stage": stage, "percent": percent, "title": title, "detail": detail, "eta": eta, "prompt": PROMPT},
            ensure_ascii=False,
        ),
        encoding="utf-8",
    )
    os.replace(temporary, PROGRESS_PATH)


def generation_size(image) -> tuple[int, int]:
    max_area = 480 * 832
    aspect = (image.width / image.height) if image is not None else (832 / 480)
    width = max(256, round(np.sqrt(max_area * aspect) / 32) * 32)
    height = max(256, round(np.sqrt(max_area / aspect) / 32) * 32)
    return width, height


def frame_to_pil(frame) -> Image.Image:
    """Normalize Diffusers' PIL/NumPy/Tensor frame variants for PNG output."""
    if isinstance(frame, Image.Image):
        return frame.convert("RGB")
    if torch.is_tensor(frame):
        frame = frame.detach().float().cpu().numpy()
    array = np.asarray(frame)
    array = np.squeeze(array)
    if array.ndim != 3:
        raise RuntimeError(f"Wan returned an unsupported image frame shape: {array.shape}")
    # Some pipelines return CHW tensors while Wan normally returns HWC arrays.
    if array.shape[0] in (1, 3, 4) and array.shape[-1] not in (1, 3, 4):
        array = np.transpose(array, (1, 2, 0))
    if np.issubdtype(array.dtype, np.floating):
        # Diffusers image arrays are generally [0, 1]; tolerate [-1, 1] too.
        if float(array.min()) < 0.0:
            array = (array + 1.0) / 2.0
        array = np.clip(array * 255.0, 0, 255).round().astype(np.uint8)
    else:
        array = np.clip(array, 0, 255).astype(np.uint8)
    if array.shape[-1] == 1:
        array = np.repeat(array, 3, axis=-1)
    return Image.fromarray(array[:, :, :3], mode="RGB")


def main() -> None:
    write_progress("preparing", 3, "PREPARING WAN 2.2", "Checking the local model and CUDA runtime")
    if os.name == "nt":
        # Keep Windows, Godot, and the progress overlay responsive while Wan is
        # consuming nearly all CPU, RAM, and GPU resources. BELOW_NORMAL does
        # not reduce output quality; it only lets interactive UI work win ties.
        ctypes.windll.kernel32.SetPriorityClass(  # type: ignore[attr-defined]
            ctypes.windll.kernel32.GetCurrentProcess(), 0x00004000
        )
    torch.set_num_threads(max(2, min(4, os.cpu_count() or 4)))
    if not MODEL_PATH.is_dir():
        raise FileNotFoundError(f"Wan model is not installed: {MODEL_PATH}")
    if not torch.cuda.is_available():
        raise RuntimeError(
            f"Wan generation requires CUDA-enabled PyTorch; installed torch is {torch.__version__}"
        )
    source = load_image(str(SOURCE_IMAGE)).convert("RGB") if SOURCE_IMAGE and SOURCE_IMAGE.is_file() else None
    width, height = generation_size(source)
    if source is not None:
        source = source.resize((width, height))
    gpu_name = torch.cuda.get_device_name(0)
    gpu_vram = torch.cuda.get_device_properties(0).total_memory / (1024 ** 3)
    memory = psutil.virtual_memory()
    swap = psutil.swap_memory()
    available_commit_gb = (memory.available + swap.free) / (1024 ** 3)
    if available_commit_gb < 18.0:
        write_progress(
            "memory_blocked",
            8,
            "WAN NEEDS MORE FREE MEMORY",
            f"Only {available_commit_gb:.1f} GB RAM/pagefile is available • close another model or app and retry",
        )
        raise RuntimeError(
            f"Wan was stopped before model loading to prevent an out-of-memory crash. "
            f"Available RAM plus pagefile: {available_commit_gb:.1f} GB; at least 18 GB is required."
        )
    write_progress(
        "loading",
        8,
        "LOADING WAN 2.2",
        f"Loading local weights on {gpu_name} ({gpu_vram:.1f} GB VRAM) • target {width}x{height} • {FRAME_COUNT} frame(s)",
    )
    pipeline_class = WanImageToVideoPipeline if source is not None else DiffusionPipeline
    gc.collect()
    torch.cuda.empty_cache()
    OFFLOAD_PATH.mkdir(parents=True, exist_ok=True)
    try:
        # Place whole components while their shards are loading. Loading the
        # complete 31+ GB pipeline into RAM first and enabling offload afterward
        # can exhaust Windows commit memory before offload ever takes effect.
        pipe = pipeline_class.from_pretrained(
            str(MODEL_PATH),
            dtype=torch.bfloat16,
            local_files_only=True,
            low_cpu_mem_usage=True,
            device_map="balanced",
            max_memory={0: "10GiB", "cpu": "20GiB"},
            offload_folder=str(OFFLOAD_PATH),
        )

        # `balanced` is used only to survive loading on a 12 GB card. Wan's
        # prompt encoder cannot run correctly with that component-level map:
        # it can leave embedding weights on CPU while token indices are CUDA.
        # Convert the fully loaded pipeline to Diffusers' supported execution
        # offload hooks so each complete component and its inputs move together.
        write_progress(
            "offloading",
            24,
            "CONFIGURING LOW-MEMORY EXECUTION",
            "Converting temporary balanced loading into sequential component offload",
        )
        pipe.reset_device_map()
        gc.collect()
        torch.cuda.empty_cache()
        pipe.enable_model_cpu_offload(gpu_id=0)
    except OSError as error:
        if getattr(error, "winerror", None) == 1455 or "paging file is too small" in str(error).lower():
            write_progress(
                "memory_blocked",
                8,
                "WINDOWS PAGEFILE IS TOO SMALL",
                "Wan is a 31.85 GB model. Enable a system-managed pagefile or reserve about 48-64 GB, restart Windows, and retry.",
            )
            raise RuntimeError(
                "Wan could not reserve enough Windows commit memory. Set Virtual Memory to "
                "System managed size (or approximately 48-64 GB), restart Windows, and retry."
            ) from error
        raise
    if hasattr(pipe, "enable_vae_tiling"):
        pipe.enable_vae_tiling()
    human_terms = ("girl", "woman", "man", "boy", "person", "people", "human", "face")
    human_quality = (
        ", detailed symmetrical face, natural proportional eyes, realistic skin texture, "
        "anatomically correct, sharp facial features"
        if any(term in PROMPT.lower() for term in human_terms)
        else ""
    )
    quality_prompt = PROMPT + human_quality + ", photorealistic, cinematic natural lighting, coherent motion"
    inference_steps = 40 if OUTPUT_KIND == "image" else 30
    generation_started = time.monotonic()

    def progress_callback(_pipe, step_index, _timestep, callback_kwargs):
        completed = step_index + 1
        elapsed_seconds = max(0.001, time.monotonic() - generation_started)
        remaining_seconds = max(0, round((elapsed_seconds / completed) * (inference_steps - completed)))
        eta = time.strftime("%M:%S", time.gmtime(remaining_seconds))
        elapsed = time.strftime("%M:%S", time.gmtime(round(elapsed_seconds)))
        if completed >= inference_steps:
            write_progress(
                "decoding",
                95,
                f"DECODING FINISHED {OUTPUT_KIND.upper()}",
                f"Diffusion complete • decoding pixels with the VAE • elapsed {elapsed}",
            )
        else:
            stage_percent = completed * 100.0 / inference_steps
            write_progress(
                "generating",
                30 + stage_percent * 0.64,
                f"GENERATING {OUTPUT_KIND.upper()} • {stage_percent:.0f}%",
                f"Wan diffusion step {completed}/{inference_steps} • elapsed {elapsed} • ETA {eta}",
                eta,
            )
        return callback_kwargs

    write_progress(
        "pipeline_ready",
        28,
        "WAN PIPELINE READY",
        f"Starting {inference_steps} diffusion steps at {width}x{height} with {FRAME_COUNT} frame(s) • CUDA warm-up can make the first step slower",
    )
    kwargs = {
        "prompt": quality_prompt,
        "negative_prompt": (
            "low quality, blurry face, deformed face, asymmetrical eyes, oversized eyes, crossed eyes, "
            "plastic skin, doll face, extra fingers, distorted hands, distorted body, duplicate limbs, "
            "text, watermark"
        ),
        "height": height,
        "width": width,
        "num_frames": FRAME_COUNT,
        "num_inference_steps": inference_steps,
        "guidance_scale": 7.5,  # <--- Changed from 5.0 to 7.5
        "generator": torch.Generator(device="cpu").manual_seed(
            int(torch.randint(0, 2**31 - 1, (1,)).item())
        ),  # <--- Randomized seed instead of static 42
        "callback_on_step_end": progress_callback,
        "callback_on_step_end_tensor_inputs": [],
    }
    if source is not None:
        kwargs["image"] = source
    with torch.inference_mode():
        frames = pipe(**kwargs).frames[0]
    write_progress("saving", 98, "SAVING RESULT", "Converting the generated pixels and writing the output file")
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    completion_detail = f"Saved: {OUTPUT_PATH.name}"
    if OUTPUT_KIND == "image":
        # Text-to-image has one frame. Reference-image jobs deliberately create
        # a short I2V sequence and use its last frame so the requested change is
        # visible instead of simply returning the source-like first frame.
        output_image = frame_to_pil(frames[-1] if source is not None else frames[0])
        output_image.save(OUTPUT_PATH, "PNG")
        if source is not None:
            comparison = np.asarray(output_image.resize(source.size), dtype=np.float32)
            source_pixels = np.asarray(source, dtype=np.float32)
            mean_change = float(np.abs(comparison - source_pixels).mean())
            if mean_change < 2.0:
                completion_detail += " • Warning: result remained extremely close to the reference image"
                print("Warning: Wan produced a near-copy of the reference; the requested still transformation was not achieved reliably.")
        print(f"Generated image saved as: {OUTPUT_PATH}")
    else:
        export_to_video(frames, str(OUTPUT_PATH), fps=16)
        print(f"Generated video saved as: {OUTPUT_PATH}")
    del pipe
    del frames
    gc.collect()
    torch.cuda.empty_cache()
    display_path = OUTPUT_PATH
    if OUTPUT_KIND == "image" and FACE_PYTHON.is_file() and FACE_SCRIPT.is_file() and FACE_MODEL.is_file():
        restored_path = OUTPUT_PATH.with_name(OUTPUT_PATH.stem + "_face_restored.png")
        write_progress("face_restore", 99, "REFINING DETECTED FACES", "Wan is unloaded • running the separate CPU-only face restorer")
        face_result = subprocess.run(
            [str(FACE_PYTHON), str(FACE_SCRIPT), str(OUTPUT_PATH), str(restored_path), str(FACE_MODEL)],
            check=False,
            env={**os.environ, "PYTHONNOUSERSITE": "1", "CUDA_VISIBLE_DEVICES": ""},
        )
        if face_result.returncode == 0 and restored_path.is_file():
            display_path = restored_path
            completion_detail += f" • face-restored copy: {restored_path.name}"
        else:
            completion_detail += " • face restoration skipped; original preserved"
    write_progress("complete", 100, "VISUAL GENERATION COMPLETE", completion_detail)
    if os.name == "nt":
        os.startfile(display_path)  # type: ignore[attr-defined]


if __name__ == "__main__":
    main()
