from __future__ import annotations

import argparse
import os
import shutil
import sys
from pathlib import Path


def main() -> int:
    # facexlib resolves its detector/parser cache relative to the working
    # directory. Pin it beside this runtime instead of consuming the system disk.
    os.chdir(Path(__file__).resolve().parent)
    parser = argparse.ArgumentParser(description="Restore detected faces without changing the original image.")
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("model", type=Path)
    parser.add_argument("--weight", type=float, default=0.55)
    args = parser.parse_args()

    if not args.input.is_file():
        raise FileNotFoundError(args.input)
    if not args.model.is_file():
        raise FileNotFoundError(args.model)

    # Keep this optional post-process isolated from user-site Python packages.
    os.environ.setdefault("PYTHONNOUSERSITE", "1")
    import cv2
    from gfpgan import GFPGANer

    source = cv2.imread(str(args.input), cv2.IMREAD_COLOR)
    if source is None:
        raise RuntimeError(f"Could not decode image: {args.input}")

    restorer = GFPGANer(
        model_path=str(args.model),
        upscale=1,
        arch="clean",
        channel_multiplier=2,
        bg_upsampler=None,
        device="cpu",
    )
    _cropped, restored_faces, restored = restorer.enhance(
        source,
        has_aligned=False,
        only_center_face=False,
        paste_back=True,
        weight=max(0.0, min(1.0, args.weight)),
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    if restored is None or not restored_faces:
        shutil.copy2(args.input, args.output)
        print("No face was confidently detected; preserved the original pixels.")
        return 2
    if not cv2.imwrite(str(args.output), restored):
        raise RuntimeError(f"Could not save restored image: {args.output}")
    print(f"Restored {len(restored_faces)} face(s): {args.output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"Face restoration skipped safely: {error}", file=sys.stderr)
        raise SystemExit(1)
