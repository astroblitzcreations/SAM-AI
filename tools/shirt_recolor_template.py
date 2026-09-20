from __future__ import annotations

import colorsys
import os
from pathlib import Path

from PIL import Image, ImageFilter

SOURCE_IMAGE = Path(r"__SOURCE_IMAGE__")
TARGET_COLOR = (__TARGET_COLOR__)


def inside_polygon(x: int, y: int, points: list[tuple[int, int]]) -> bool:
    inside = False
    previous = len(points) - 1
    for current in range(len(points)):
        x1, y1 = points[current]
        x2, y2 = points[previous]
        if (y1 > y) != (y2 > y):
            boundary = (x2 - x1) * (y - y1) / (y2 - y1) + x1
            if x < boundary:
                inside = not inside
        previous = current
    return inside


def recolor_shirt(source_path: Path, target: tuple[int, int, int]) -> Path:
    if not source_path.is_file():
        raise FileNotFoundError(f"Source image not found: {source_path}")
    with Image.open(source_path) as source:
        image = source.convert("RGB")
    width, height = image.size
    # Conservative torso region. Pixel classification prevents skin/background
    # from being included, while the feather preserves natural garment edges.
    normalized = [(0.27, 0.43), (0.73, 0.43), (0.76, 0.88), (0.24, 0.88)]
    region = [(round(x * width), round(y * height)) for x, y in normalized]
    pixels = image.load()
    samples: list[tuple[int, int, int]] = []
    for y in range(round(height * 0.55), round(height * 0.82), max(1, height // 100)):
        for x in range(round(width * 0.36), round(width * 0.64), max(1, width // 100)):
            samples.append(pixels[x, y])
    # The garment is the darker, more repeated color in the center torso sample.
    samples.sort(key=lambda rgb: sum(rgb))
    reference = samples[max(0, len(samples) // 5)] if samples else (30, 30, 30)
    ref_h, ref_s, ref_v = colorsys.rgb_to_hsv(*(value / 255 for value in reference))
    mask = Image.new("L", image.size, 0)
    mask_pixels = mask.load()
    for y in range(height):
        for x in range(width):
            if not inside_polygon(x, y, region):
                continue
            red, green, blue = pixels[x, y]
            hue, saturation, value = colorsys.rgb_to_hsv(red / 255, green / 255, blue / 255)
            hue_distance = min(abs(hue - ref_h), 1.0 - abs(hue - ref_h))
            dark_garment = ref_v < 0.48 and value < 0.48 and saturation <= max(0.72, ref_s + 0.28)
            colored_garment = ref_v >= 0.48 and hue_distance < 0.10 and saturation >= max(0.20, ref_s - 0.28)
            if dark_garment or colored_garment:
                mask_pixels[x, y] = 255
    mask = mask.filter(ImageFilter.GaussianBlur(max(1.4, width / 650)))
    replacement = Image.new("RGB", image.size)
    replacement_pixels = replacement.load()
    target_r, target_g, target_b = target
    for y in range(height):
        for x in range(width):
            red, green, blue = pixels[x, y]
            luminance = (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255
            shade = 0.72 + 0.28 * luminance
            replacement_pixels[x, y] = (
                min(255, round(target_r * shade)),
                min(255, round(target_g * shade)),
                min(255, round(target_b * shade)),
            )
    result = Image.composite(replacement, image, mask)
    output = source_path.with_name(f"{source_path.stem}_shirt_recolored.png")
    result.save(output, "PNG")
    return output


def main() -> None:
    output = recolor_shirt(SOURCE_IMAGE, TARGET_COLOR)
    print(f"Edited image saved as: {output}")
    if os.name == "nt":
        os.startfile(output)  # type: ignore[attr-defined]


if __name__ == "__main__":
    main()
