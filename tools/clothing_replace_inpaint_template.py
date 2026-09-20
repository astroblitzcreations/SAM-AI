from __future__ import annotations

import os
from pathlib import Path

import numpy as np
import torch
import torch.nn.functional as functional
from diffusers import StableDiffusionInpaintPipeline
from PIL import Image, ImageDraw, ImageFilter
from transformers import AutoModelForSemanticSegmentation, SegformerImageProcessor

SOURCE_IMAGE = Path(r"__SOURCE_IMAGE__")
OUTPUT_PATH = Path(r"__OUTPUT_PATH__")
INPAINT_MODEL = Path(r"__INPAINT_MODEL__")
SEGMENTER_MODEL = Path(r"__SEGMENTER_MODEL__")
EDIT_PROMPT = r"""__EDIT_PROMPT__"""


def fitted_size(width: int, height: int, longest: int = 768) -> tuple[int, int]:
    scale = min(1.0, longest / max(width, height))
    return max(256, round(width * scale / 8) * 8), max(256, round(height * scale / 8) * 8)


def _label_ids(labels: dict[int, str], *names: str) -> list[int]:
    return [identifier for identifier, label in labels.items() if any(name in label for name in names)]


def _bounds(mask: np.ndarray) -> tuple[int, int, int, int] | None:
    ys, xs = np.where(mask)
    if not len(xs):
        return None
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def inferred_item_mask(classes: np.ndarray, labels: dict[int, str], prompt: str) -> np.ndarray:
    """Infer a useful add-item region when the requested item is not present."""
    height, width = classes.shape
    person_ids = _label_ids(labels, "hair", "face", "upper-clothes", "arm", "leg", "pants", "skirt", "dress", "shoe")
    person = np.isin(classes, person_ids)
    person_box = _bounds(person) or (width // 4, height // 8, width * 3 // 4, height * 7 // 8)
    left, top, right, bottom = person_box
    result = np.zeros((height, width), dtype=np.uint8)

    def rectangle(x0: int, y0: int, x1: int, y1: int) -> None:
        result[max(0, y0):min(height, y1), max(0, x0):min(width, x1)] = 255

    leg_ids = _label_ids(labels, "leg")
    legs = np.isin(classes, leg_ids)
    leg_box = _bounds(legs)
    face = np.isin(classes, _label_ids(labels, "face"))
    face_box = _bounds(face)
    hair = np.isin(classes, _label_ids(labels, "hair"))
    hair_box = _bounds(hair)

    if any(word in prompt for word in ("sock", "stocking", "leg warmer")):
        if leg_box:
            lx0, ly0, lx1, ly1 = leg_box
            cutoff = ly0 + int((ly1 - ly0) * 0.48)
            result[(legs) & (np.indices(legs.shape)[0] >= cutoff)] = 255
        else:
            rectangle(left, top + int((bottom - top) * 0.70), right, bottom)
    elif any(word in prompt for word in ("shoe", "boot", "sneaker", "heel", "footwear")):
        shoes = np.isin(classes, _label_ids(labels, "shoe"))
        if shoes.any():
            result[shoes] = 255
        elif leg_box:
            lx0, ly0, lx1, ly1 = leg_box
            rectangle(lx0, ly0 + int((ly1 - ly0) * 0.78), lx1, min(height, ly1 + int(height * 0.04)))
        else:
            rectangle(left, top + int((bottom - top) * 0.82), right, bottom)
    elif any(word in prompt for word in ("hat", "cap", "beanie", "crown", "headband")):
        anchor = hair_box or face_box
        if anchor:
            hx0, hy0, hx1, hy1 = anchor
            margin_x = max(8, (hx1 - hx0) // 5)
            rectangle(hx0 - margin_x, hy0 - int((hy1 - hy0) * 0.45), hx1 + margin_x, hy0 + int((hy1 - hy0) * 0.28))
        else:
            rectangle(left, max(0, top - int(height * 0.10)), right, top + int((bottom - top) * 0.16))
    elif any(word in prompt for word in ("glasses", "sunglasses", "eyeglasses")) and face_box:
        fx0, fy0, fx1, fy1 = face_box
        rectangle(fx0, fy0 + int((fy1 - fy0) * 0.25), fx1, fy0 + int((fy1 - fy0) * 0.58))
    elif any(word in prompt for word in ("scarf", "necklace", "tie")):
        if face_box:
            fx0, fy0, fx1, fy1 = face_box
            margin = max(8, (fx1 - fx0) // 3)
            rectangle(fx0 - margin, fy1 - int((fy1 - fy0) * 0.10), fx1 + margin, fy1 + int((bottom - top) * 0.18))
        else:
            rectangle(left, top + int((bottom - top) * 0.18), right, top + int((bottom - top) * 0.38))
    elif "belt" in prompt:
        rectangle(left, top + int((bottom - top) * 0.48), right, top + int((bottom - top) * 0.59))
    elif any(word in prompt for word in ("bag", "handbag", "purse", "backpack")):
        person_width = right - left
        rectangle(right - int(person_width * 0.18), top + int((bottom - top) * 0.34), right + int(person_width * 0.28), top + int((bottom - top) * 0.76))
    elif any(word in prompt for word in ("earring", "earrings")) and face_box:
        fx0, fy0, fx1, fy1 = face_box
        ear_width = max(5, (fx1 - fx0) // 7)
        rectangle(fx0 - ear_width, fy0 + (fy1 - fy0) // 3, fx0 + ear_width, fy1)
        rectangle(fx1 - ear_width, fy0 + (fy1 - fy0) // 3, fx1 + ear_width, fy1)
    elif any(word in prompt for word in ("glove", "watch", "bracelet", "ring")):
        arms = np.isin(classes, _label_ids(labels, "arm"))
        arm_box = _bounds(arms)
        if arm_box:
            ax0, ay0, ax1, ay1 = arm_box
            cutoff = ay0 + int((ay1 - ay0) * 0.62)
            result[arms & (np.indices(arms.shape)[0] >= cutoff)] = 255
        else:
            rectangle(left, top + int((bottom - top) * 0.42), right, top + int((bottom - top) * 0.72))
    elif any(word in prompt for word in ("pants", "trousers", "jeans", "shorts", "skirt")):
        rectangle(left, top + int((bottom - top) * 0.48), right, bottom)
    else:
        # Missing shirt/dress/jacket or a generic new garment: use the torso,
        # constrained to the detected person's horizontal extent.
        rectangle(left, top + int((bottom - top) * 0.24), right, top + int((bottom - top) * 0.70))
    return result


def clothing_mask(image: Image.Image) -> Image.Image:
    processor = SegformerImageProcessor.from_pretrained(SEGMENTER_MODEL, local_files_only=True)
    segmenter = AutoModelForSemanticSegmentation.from_pretrained(
        SEGMENTER_MODEL, local_files_only=True
    ).eval()
    inputs = processor(images=image, return_tensors="pt")
    with torch.inference_mode():
        logits = segmenter(**inputs).logits
    logits = functional.interpolate(
        logits, size=(image.height, image.width), mode="bilinear", align_corners=False
    )
    classes = logits.argmax(dim=1)[0].cpu().numpy()
    labels = {int(key): str(value).lower() for key, value in segmenter.config.id2label.items()}
    prompt = EDIT_PROMPT.lower()
    upper_words = ("shirt", "top", "blouse", "t-shirt", "tshirt", "sweater", "hoodie", "jacket", "coat", "bra", "braw")
    lower_words = ("pants", "trousers", "jeans", "shorts")
    skirt_words = ("skirt",)
    dress_words = ("dress", "gown")
    accessory_words = ("sock", "stocking", "shoe", "boot", "sneaker", "heel", "hat", "cap", "beanie", "crown", "headband", "glasses", "sunglasses", "scarf", "necklace", "tie", "belt", "bag", "handbag", "purse", "backpack", "earring", "glove", "watch", "bracelet", "ring")
    face_words = ("face", "eye", "eyes", "eyebrow", "eyelash", "nose", "mouth", "lips", "beard", "mustache", "moustache", "smile", "laugh", "serious", "older", "younger", "makeup")
    pose_words = ("change pose", "laying", "lying", "lie down", "sitting", "sit down", "seated", "standing", "stand up", "turn around", "kneeling", "crouching")
    background_words = ("background", "scene", "forest", "beach", "city", "cyberpunk", "bedroom", "room", "snow", "sunset", "sunrise", "rainy night", "golden hour", "neon-lit", "neon lit")
    wants_background = any(word in prompt for word in background_words)
    wants_pose = any(word in prompt for word in pose_words)
    wants_hair = "hair" in prompt or "ponytail" in prompt
    wants_face = any(word in prompt for word in face_words)
    wants_accessory = any(word in prompt for word in accessory_words)
    wants_dress = any(word in prompt for word in dress_words)
    wants_upper = any(word in prompt for word in upper_words)
    wants_lower = any(word in prompt for word in lower_words + skirt_words)

    # Compose every requested region. Earlier versions used an elif chain, so
    # "change her hair and shirt" edited only the first matching category.
    # Union masks let a single natural-language request alter any combination
    # of face, hair, pose, wardrobe, accessories, and scene.
    mask_array = np.zeros(classes.shape, dtype=np.uint8)
    person_label_names = ("hair", "face", "upper-clothes", "skirt", "pants", "dress", "leg", "arm", "shoe")

    def add_labels(*wanted: str) -> None:
        ids = _label_ids(labels, *wanted)
        if ids:
            mask_array[np.isin(classes, ids)] = 255

    if wants_background:
        person = np.isin(classes, _label_ids(labels, *person_label_names))
        mask_array[~person] = 255
    if wants_pose:
        add_labels(*person_label_names)
    if wants_hair:
        add_labels("hair")
    if wants_face:
        add_labels("face")
    if wants_dress:
        add_labels("upper-clothes", "shirt", "top", "skirt", "pants", "dress", "belt")
    else:
        if wants_upper:
            add_labels("upper-clothes", "shirt", "top")
        if wants_lower:
            add_labels("pants", "trousers", "jeans", "shorts", "skirt")
        if ("underwear" in prompt or "lingerie" in prompt) and not (wants_upper or wants_lower):
            add_labels("upper-clothes", "shirt", "top", "pants", "trousers", "jeans", "shorts", "skirt")
    if wants_accessory:
        accessory_labels = tuple(word for word in accessory_words if word in prompt)
        before_accessory = mask_array.copy()
        add_labels(*accessory_labels)
        # Most accessories have no dedicated SegFormer class. Add a localized
        # inferred region even when another requested edit already has a mask.
        if np.array_equal(before_accessory, mask_array):
            mask_array = np.maximum(mask_array, inferred_item_mask(classes, labels, prompt))
    if not any((wants_background, wants_pose, wants_hair, wants_face, wants_accessory, wants_dress, wants_upper, wants_lower, "underwear" in prompt, "lingerie" in prompt)):
        add_labels("upper-clothes", "shirt", "top", "skirt", "pants", "dress", "belt")
    if mask_array.max() == 0:
        print("Requested garment is not present; inferring an add-item region from body segmentation")
        mask_array = inferred_item_mask(classes, labels, prompt)
    mask = Image.fromarray(mask_array, mode="L")
    # Expand a little so the model can replace garment edges, while the semantic
    # mask continues to protect face, hair, arms, skin, bag, and background.
    mask = mask.filter(ImageFilter.MaxFilter(17)).filter(ImageFilter.GaussianBlur(2.5))
    if np.asarray(mask).max() == 0:
        # Last-resort localized torso region. This keeps the run recoverable for
        # unusual crops while avoiding the old failure and whole-frame edits.
        fallback = Image.new("L", image.size, 0)
        draw = ImageDraw.Draw(fallback)
        draw.rounded_rectangle(
            (image.width * 0.25, image.height * 0.28, image.width * 0.75, image.height * 0.72),
            radius=max(8, image.width // 20), fill=255,
        )
        mask = fallback.filter(ImageFilter.GaussianBlur(2.5))
    return mask


def expanded_edit_prompt() -> str:
    prompt = EDIT_PROMPT.strip().replace("braw", "bra").replace("pushup", "push-up")
    lowered = prompt.lower()
    if "push-up bra" in lowered or "push up bra" in lowered:
        prompt += (
            ", clearly redesigned as a structured push-up bra, distinct molded supportive cups, "
            "supportive underband, clean bra straps, tailored lingerie construction"
        )
    changes_top_to_bra = any(word in lowered for word in ("shirt", "top", "blouse")) and any(word in lowered for word in ("bra", "braw"))
    changes_bottom_to_underwear = any(word in lowered for word in ("pants", "trousers", "jeans", "shorts")) and any(word in lowered for word in ("underwear", "panties", "briefs", "lingerie"))
    if changes_top_to_bra:
        prompt += ", completely remove and replace the original shirt with one clearly visible opaque bra, bare midriff, bare shoulders and arms, no shirt remains"
    if changes_bottom_to_underwear:
        prompt += ", completely remove and replace the original pants with clearly visible opaque adult underwear, bare legs, no pants or trouser legs remain"
    if any(word in lowered for word in ("sock", "stocking", "shoe", "boot", "hat", "cap", "glasses", "scarf", "necklace", "belt", "bag", "earring", "glove", "watch", "bracelet")):
        prompt += ", clearly visible newly added requested item, correctly fitted and naturally integrated"
    if "remove the background" in lowered or "remove background" in lowered:
        prompt += ", replace the old background with a clean simple neutral studio background"
    if "skirt" in lowered and any(word in lowered for word in ("pants", "trousers", "jeans", "shorts")):
        prompt += ", completely replace the original trousers with one clearly visible skirt, distinct skirt hem, uncovered lower legs, no trousers remain"
    elif any(phrase in lowered for phrase in ("to a skirt", "into a skirt", "wearing a skirt")):
        prompt += ", one clearly visible skirt with a distinct natural hem and uncovered lower legs"
    return prompt


def preservation_prompt() -> str:
    """Do not tell the model to preserve something the user asked to change."""
    lowered = EDIT_PROMPT.lower()
    face_words = ("face", "eye", "eyes", "eyebrow", "eyelash", "nose", "mouth", "lips", "beard", "mustache", "moustache", "smile", "laugh", "serious", "older", "younger", "makeup")
    pose_words = ("pose", "laying", "lying", "sit", "seated", "stand", "turn around", "kneel", "crouch")
    background_words = ("background", "scene", "forest", "beach", "city", "cyberpunk", "bedroom", "room", "snow", "sunset", "sunrise", "rainy night", "golden hour", "neon-lit", "neon lit")
    constraints = ["same person", "same camera and lighting", "preserve anatomy"]
    if not any(word in lowered for word in face_words):
        constraints.append("preserve face")
    if "hair" not in lowered and "ponytail" not in lowered:
        constraints.append("preserve hair")
    if not any(word in lowered for word in pose_words):
        constraints.append("same pose")
    if not any(word in lowered for word in background_words):
        constraints.append("preserve background")
    return ", ".join(constraints)


def clip_safe_prompt(tokenizer, text: str, token_budget: int = 75) -> str:
    """Pre-truncate deliberately so CLIP never drops text with a noisy warning."""
    encoded = tokenizer(
        text,
        add_special_tokens=False,
        truncation=True,
        max_length=token_budget,
    )["input_ids"]
    return tokenizer.decode(encoded, skip_special_tokens=True).strip()


def main() -> None:
    if not SOURCE_IMAGE.is_file():
        raise FileNotFoundError(f"Source image not found: {SOURCE_IMAGE}")
    if not INPAINT_MODEL.is_dir() or not SEGMENTER_MODEL.is_dir():
        raise FileNotFoundError("SAM's local inpainting or clothing-segmentation model is missing")
    if not torch.cuda.is_available():
        raise RuntimeError("This clothing replacement requires CUDA-enabled PyTorch")

    original = Image.open(SOURCE_IMAGE).convert("RGB")
    width, height = fitted_size(original.width, original.height)
    image = original.resize((width, height), Image.Resampling.LANCZOS)
    mask = clothing_mask(image)
    pipe = StableDiffusionInpaintPipeline.from_pretrained(
        INPAINT_MODEL,
        dtype=torch.float16,
        local_files_only=True,
        use_safetensors=False,
        safety_checker=None,
        requires_safety_checker=False,
    )
    # The primary chat model is unloaded before this script starts, so keep the
    # complete SD 1.5 inpainting pipeline on the RTX GPU instead of repeatedly
    # offloading layers through system RAM. This is faster on a 12 GB card.
    pipe.to("cuda")
    pipe.enable_attention_slicing()
    prompt = (
        expanded_edit_prompt()
        + ", visibly distinct requested design, realistic materials, natural fabric folds and texture, "
        + preservation_prompt()
        + ", photorealistic"
    )
    negative = (
        "different person, changed face, changed hair, changed pose, deformed body, extra limbs, "
        "nudity, exposed breasts, exposed genitals, transparent clothing, blurry, low quality, "
        "painting, illustration, text, watermark"
    )
    lowered_edit = EDIT_PROMPT.lower()
    if "skirt" in lowered_edit and any(word in lowered_edit for word in ("pants", "trousers", "jeans", "shorts")):
        negative += ", pants, trousers, jeans, shorts, leggings"
    if any(word in lowered_edit for word in ("shirt", "top", "blouse")) and any(word in lowered_edit for word in ("bra", "braw")):
        negative += ", shirt, t-shirt, blouse, sweater, covered midriff"
    if any(word in lowered_edit for word in ("pants", "trousers", "jeans", "shorts")) and any(word in lowered_edit for word in ("underwear", "panties", "briefs", "lingerie")):
        negative += ", pants, trousers, jeans, shorts, leggings, covered legs"
    prompt = clip_safe_prompt(pipe.tokenizer, prompt)
    negative = clip_safe_prompt(pipe.tokenizer, negative)
    with torch.inference_mode():
        result = pipe(
            prompt=prompt,
            negative_prompt=negative,
            image=image,
            mask_image=mask,
            height=height,
            width=width,
            num_inference_steps=40,
            guidance_scale=8.5,
            generator=torch.Generator(device="cpu").manual_seed(42),
        ).images[0]
    # Inpainting pipelines decode the complete latent frame, which can subtly
    # redraw the face and background even when they were outside the requested
    # edit. Restore every unmasked pixel from the source image exactly; only the
    # feathered garment region is allowed to come from the generated result.
    result = result.convert("RGB")
    if result.size != image.size:
        result = result.resize(image.size, Image.Resampling.LANCZOS)
    if mask.size != image.size:
        mask = mask.resize(image.size, Image.Resampling.LANCZOS)
    mask = mask.convert("L")
    result = Image.composite(result, image, mask)
    result = result.resize(original.size, Image.Resampling.LANCZOS)
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    result.save(OUTPUT_PATH, "PNG")
    print(f"Edited image saved as: {OUTPUT_PATH}")
    os.startfile(OUTPUT_PATH)  # type: ignore[attr-defined]


if __name__ == "__main__":
    main()
