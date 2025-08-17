#!/usr/bin/env python3

import sys
import re
import argparse
from argparse import RawDescriptionHelpFormatter
import unicodedata
from typing import List, Tuple

DESCRIPTION = """
Generate a numbered Markdown TOC from a Markdown file or stdin.
"""

HEADING_RE = re.compile(r'^(?P<hashes>#{1,6})\s+(?P<title>.+?)\s*#*\s*$')

# Fenced code blocks: ``` ... ```  or ~~~ ... ~~~ (ignore headings inside)
FENCE_OPEN_RE = re.compile(r'^(```|~~~)')
FENCE_CLOSE_RE = re.compile(r'^(```|~~~)\s*$')

# Liquid/Jekyll or HTML-style code fences sometimes used in blogs: {% highlight ... %} ... {% endhighlight %}
HIGHLIGHT_OPEN_RE = re.compile(r'^\s*\{%\s*highlight\b')
HIGHLIGHT_CLOSE_RE = re.compile(r'^\s*\{%\s*endhighlight\s*%\}\s*$')


def slugify(title: str) -> str:
    """
    Approximate GitHub-style slug:
      - lowercase
      - strip accents
      - remove punctuation except hyphens and spaces
      - collapse spaces to single hyphen
      - collapse repeated hyphens
    """
    # Normalize and strip accents
    s = unicodedata.normalize('NFKD', title)
    s = ''.join(c for c in s if not unicodedata.combining(c))
    s = s.lower()

    # Remove Markdown link markup [text](url) → keep visible text only
    s = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', s)

    # Remove inline code backticks
    s = s.replace('`', '')

    # Remove punctuation except spaces and hyphens
    s = re.sub(r'[^\w\s-]', '', s)

    # Replace whitespace with hyphens
    s = re.sub(r'\s+', '-', s.strip())

    # Collapse multiple hyphens
    s = re.sub(r'-{2,}', '-', s)

    return s


def extract_headings(md: str) -> List[Tuple[int, str]]:
    """
    Return list of (level, title) tuples, ignoring headings inside code fences.
    """
    in_fence = False
    in_highlight = False
    headings: List[Tuple[int, str]] = []

    for line in md.splitlines():
        if in_highlight:
            if HIGHLIGHT_CLOSE_RE.search(line):
                in_highlight = False
            continue

        if in_fence:
            if FENCE_CLOSE_RE.match(line):
                in_fence = False
            continue

        if FENCE_OPEN_RE.match(line):
            in_fence = True
            continue

        if HIGHLIGHT_OPEN_RE.search(line):
            in_highlight = True
            continue

        m = HEADING_RE.match(line)
        if m:
            level = len(m.group('hashes'))
            title = m.group('title').strip()
            headings.append((level, title))

    return headings


def number_headings(headings: List[Tuple[int, str]]) -> List[Tuple[str, int, str]]:
    """
    Given (level, title), return list of (number_str, level, title).
    Uses hierarchical numbering like 1., 2., 3.1., 3.2., etc.
    """
    counters = [0] * 6
    out = []
    for level, title in headings:
        idx = level - 1
        counters[idx] += 1
        # zero out deeper levels
        for j in range(idx + 1, len(counters)):
            counters[j] = 0
        # build number like "3.2.1"
        parts = [str(counters[i]) for i in range(level) if counters[i] > 0]
        num = ".".join(parts)
        out.append((num, level, title))
    return out


def make_unique_slugs(titles: List[str]) -> List[str]:
    """
    Ensure anchor slugs are unique by appending -n for duplicates.
    """
    seen = {}
    slugs = []
    for t in titles:
        base = slugify(t)
        if base not in seen:
            seen[base] = 0
            slugs.append(base)
        else:
            seen[base] += 1
            slugs.append(f"{base}-{seen[base]}")
    return slugs


def build_toc(md: str, indent_per_level: int = 4) -> str:
    headings = extract_headings(md)
    if not headings:
        return ""

    titles = [t for _, t in headings]
    slugs = make_unique_slugs(titles)

    counters = [0] * 6
    lines = []
    for (level, title), slug in zip(headings, slugs):
        counters[level-1] += 1
        # reset deeper counters
        for i in range(level, len(counters)):
            counters[i] = 0
        number = counters[level-1]
        indent = " " * indent_per_level * (level - 1)
        lines.append(f"{indent}{number}. [{title}](#{slug})")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser(
        description=DESCRIPTION,
        formatter_class=RawDescriptionHelpFormatter)
    ap.add_argument("file", nargs="?",
                    help="Markdown file path (defaults to stdin)")
    args = ap.parse_args()

    if args.file:
        with open(args.file, "r", encoding="utf-8") as f:
            md = f.read()
    else:
        md = sys.stdin.read()

    toc = build_toc(md)
    print(toc)


if __name__ == "__main__":
    main()
