#!/usr/bin/env python3
"""Extract translatable UI strings from scenes into assets/locales/ui.csv.

The CSV uses the Chinese source strings as keys (Godot auto-translate looks up
the exact displayed text), so zh column always mirrors the key column. Existing
ja translations are preserved across runs; keys are never removed so manual
entries from code-side tr() calls survive refactors.

Usage: python3 tools/export_ui_translations.py
"""

import csv
import re
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
SCAN_ROOT = PROJECT_ROOT / "src"
CSV_PATH = PROJECT_ROOT / "assets" / "locales" / "ui.csv"

# Standard auto-translated Control properties plus the custom exported
# properties rendered by B-class components (TitleMenuButton, PageTitle,
# PageTabButton, SettingsSectionTitle).
TEXT_PROPERTIES = (
    "text",
    "tooltip_text",
    "placeholder_text",
    "caption",
    "display_name",
    "tab_label",
    "title",
)

PROPERTY_PATTERN = re.compile(
    r"^(?P<name>" + "|".join(TEXT_PROPERTIES) + r')\s*=\s*"(?P<value>.*)"\s*$'
)
CJK_PATTERN = re.compile(r"[一-鿿ぁ-んァ-ヶ]")


def unescape(value: str) -> str:
    return (
        value.replace('\\"', '"')
        .replace("\\n", "\n")
        .replace("\\\\", "\\")
    )


def extract_strings() -> set[str]:
    found: set[str] = set()
    for scene in sorted(SCAN_ROOT.rglob("*.tscn")):
        for line in scene.read_text(encoding="utf-8").splitlines():
            match = PROPERTY_PATTERN.match(line.strip())
            if match is None:
                continue
            value = unescape(match.group("value"))
            if CJK_PATTERN.search(value):
                found.add(value)
    return found


def normalize(value: str) -> str:
    # csv.writer defaults to CRLF; keys must stay byte-stable across runs, so
    # embedded newlines are always normalized back to LF.
    return value.replace("\r\n", "\n")


def load_existing() -> dict[str, str]:
    translations: dict[str, str] = {}
    if not CSV_PATH.exists():
        return translations
    with CSV_PATH.open(encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            key = normalize(row.get("key", ""))
            if key:
                translations[key] = normalize(row.get("ja", ""))
    return translations


def save(translations: dict[str, str]) -> None:
    CSV_PATH.parent.mkdir(parents=True, exist_ok=True)
    with CSV_PATH.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(["key", "zh", "ja"])
        for key in sorted(translations):
            writer.writerow([key, key, translations[key]])


def main() -> int:
    found = extract_strings()
    translations = load_existing()
    added = sorted(found - translations.keys())
    for key in added:
        translations[key] = ""
    save(translations)
    print(f"ui.csv: {len(translations)} keys ({len(added)} new, missing ja: "
          f"{sum(1 for value in translations.values() if not value)})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
