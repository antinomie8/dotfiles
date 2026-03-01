#!/usr/bin/env python3
"""
Parse Asymptote asyxml documentation blocks.

Extracts:
  - kind (function / variable / struct ...)
  - name
  - type
  - signature
  - documentation

Usage:
    python parse_asyxml.py geometry.asy > symbols.json
"""

import re
import json
import sys
from pathlib import Path


def clean_doc(s: str) -> str:
    """Normalize whitespace in documentation."""
    s = re.sub(r"\s+", " ", s)
    return s.strip()


def extract_name(signature: str) -> str:
    """
    Extract symbol name from signature.
    Example:
        addMargins(picture,real,real)
        -> addMargins
    """
    return signature.split("(")[0].strip()


ASYXML_BLOCK = re.compile(
    r"/\*<asyxml><(?P<kind>\w+)\s+(?P<attrs>.*?)>\s*<code>"
    r".*?"
    r"</code><documentation>(?P<doc>.*?)</documentation>"
    r"</\w+></asyxml>\*/",
    re.DOTALL,
)

ATTR_RE = re.compile(r'(\w+)="([^"]*)"')


def parse_file(text: str):
    results = []

    for m in ASYXML_BLOCK.finditer(text):
        kind = m.group("kind")
        if kind == "operator": continue
        attrs_raw = m.group("attrs")
        doc = clean_doc(m.group("doc"))

        attrs = dict(ATTR_RE.findall(attrs_raw))

        signature = attrs.get("signature", "")
        typ = attrs.get("type", "")

        name = extract_name(signature) if signature else ""

        results.append({
            "kind": kind,
            "name": name,
            "type": typ,
            "signature": signature,
            "documentation": doc,
        })

    return results


def main():
    if len(sys.argv) != 2:
        print("Usage: parse_asyxml.py <file.asy>")
        sys.exit(1)

    path = Path(sys.argv[1])
    text = path.read_text(encoding="utf-8", errors="ignore")

    symbols = parse_file(text)

    json.dump(symbols, sys.stdout, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    main()
