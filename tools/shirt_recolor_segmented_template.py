from __future__ import annotations

import os
from pathlib import Path

import numpy as np
import torch
import torch.nn.functional as functional
from PIL import Image, ImageFilter
from transformers import AutoModelForSemanticSegmentation, SegformerImageProcessor

SOURCE_IMAGE = Path(r"__SOURCE_IMAGE__")
TARGET_COLOR = (__TARGET_COLOR__)
SEGMENTER_PATH = Path(r"__SEGMENTER_PATH__")


def recolor_shirt(source_path: Path, target: tuple[int, int, int]) -> Path:
    if not source_path.is_file():
        raise FileNotFoundError(f"Source image not found: {source_path}")
    if not SEGMENTER_PATH.is_dir():
        raise FileNotFoundError(f"Clothing segmentation model is missing: {SEGMENTER_PATH}")

    image = Image.open(source_path).convert("RGB")
    processor = SegformerImageProcessor.from_pretrained(SEGMENTER_PATH, local_files_only=True)
    model = AutoModelForSemanticSegmentation.from_pretrained(SEGMENTER_PATH, local_files_only=True)
    model.eval()
    inputs = processor(images=image, return_tensors="pt")
    with torch.inference_mode():
        logits = model(**inputs).logits
    logits = functional.interpolate(
        logits, size=(image.height, image.width), mode="bilinear", align_corners=False
    )
    classes = logits.argmax(dim=1)[0].cpu().numpy()
    labels = {int(key): str(value).lower() for key, value in model.config.id2label.items()}
    shirt_words = ("upper", "shirt", "top", "blouse", "coat", "dress", "torso")
    shirt_ids = [identifier for identifier, label in labels.items() if any(word in label for word in shirt_words)]
    if not shirt_ids:
        raise RuntimeError(f"Segmentation model has no shirt-compatible labels: {labels}")

    mask_array = np.isin(classes, shirt_ids).astype(np.uint8) * 255
    # Limit to the upper body; this keeps trousers/skirts unchanged if a model
    # uses a broad clothing label.
    mask_array[round(image.height * 0.82) :, :] = 0
    mask = Image.fromarray(mask_array, mode="L").filter(ImageFilter.GaussianBlur(1.6))
    source = np.asarray(image).astype(np.float32)
    luminance = (0.2126 * source[:, :, 0] + 0.7152 * source[:, :, 1] + 0.0722 * source[:, :, 2]) / 255.0
    target_array = np.array(target, dtype=np.float32)
    shade = (0.58 + 0.42 * luminance)[:, :, None]
    replacement = np.clip(target_array[None, None, :] * shade, 0, 255).astype(np.uint8)
    edited = Image.composite(Image.fromarray(replacement, "RGB"), image, mask)
    output = source_path.with_name(f"{source_path.stem}_shirt_recolored.png")
    edited.save(output, "PNG")
    print(f"Edited image saved as: {output}")
    return output


if __name__ == "__main__":
    result = recolor_shirt(SOURCE_IMAGE, TARGET_COLOR)
    if os.name == "nt":
        os.startfile(result)  # type: ignore[attr-defined]
