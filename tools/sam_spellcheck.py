"""Small offline spell-check helper for SAM-AI's composer."""

from __future__ import annotations

import argparse
import difflib
import json
import math
import re
from pathlib import Path

from spellchecker import SpellChecker


WORD_RE = re.compile(r"[A-Za-z][A-Za-z'-]{2,}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--ignore", default="")
    args = parser.parse_args()

    text = Path(args.input).read_text(encoding="utf-8", errors="replace")
    spell = SpellChecker(language="en", distance=2)
    ignored = {word.lower() for word in args.ignore.split(",") if word.strip()}
    words = [match.group(0) for match in WORD_RE.finditer(text)]
    candidates = {
        word.lower()
        for word in words
        if word.lower() not in ignored and not any(char.isdigit() for char in word)
    }
    unknown = sorted(spell.unknown(candidates))
    results = []
    for word in unknown[:12]:
        candidates_for_word = sorted(
            spell.candidates(word) or [],
            key=lambda item: (-spell.word_usage_frequency(item), item),
        )[:5]
        # The edit-distance candidate generator can miss phonetic-looking typos
        # such as "knolage" -> "knowledge". Fall back to a broader similarity
        # scan when every direct candidate is extremely uncommon, then weight
        # similarity by normal English word frequency.
        best_frequency = max(
            (spell.word_usage_frequency(item) for item in candidates_for_word),
            default=0.0,
        )
        if not candidates_for_word or best_frequency < 0.000001:
            close = difflib.get_close_matches(
                word,
                spell.word_frequency.dictionary.keys(),
                n=30,
                cutoff=0.62,
            )
            candidates_for_word = sorted(
                set(candidates_for_word + close),
                key=lambda item: -(
                    difflib.SequenceMatcher(None, word, item).ratio()
                    + 0.12
                    * math.log10(max(spell.word_usage_frequency(item), 1e-12))
                ),
            )[:5]
        suggestions = candidates_for_word
        results.append({"word": word, "suggestions": suggestions})
    Path(args.output).write_text(
        json.dumps({"text": text.strip(), "misspellings": results}, ensure_ascii=False),
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
