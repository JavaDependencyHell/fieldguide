#!/usr/bin/env python3
"""
epub-fixup.py — Post-process an EPUB to fix XHTML issues from Quarto rendering.

Fixes:
  1. <p><figure class></p> ... <p></figure></p>  →  <figure> ... </figure>
  2. Unescaped & in text/attributes  →  &amp;
  3. Stray <style> blocks in <body>  →  removed
  4. Broken cross-references (.qmd/.html paths) → correct EPUB chapter links

Usage:
    python3 scripts/epub-fixup.py build/leanpub/Dependency-Hell.epub
"""

import re
import sys
import zipfile
import tempfile
import shutil
from pathlib import Path


# ── Cross-reference mapping ──
# Maps source file paths (as they appear in href attributes) to EPUB chapter
# numbers. The chapter numbers correspond to the book order in _quarto.yml.
# Chapters 1-8 are front matter, 9-25 Maven, 26-42 Gradle, 43-59 SBT,
# 60-63 back matter.

SCENARIO_NAMES = [
    "scenario-1-basic", "scenario-2-conflict", "scenario-3-mgmt",
    "scenario-4-override", "scenario-5-exclusions", "scenario-6-forcing",
    "scenario-7-scopes", "scenario-8-optional", "scenario-9-ranges",
    "scenario-10-circular", "scenario-11-locking", "scenario-12-metadata",
    "scenario-13-variants", "scenario-14-reject", "scenario-15-substitution",
    "scenario-16-private-bom", "scenario-17-private-patch",
]

TOOL_OFFSETS = {
    "maven-demo": 9,    # ch009 - ch025
    "gradle-demo": 26,  # ch026 - ch042
    "sbt-demo": 43,     # ch043 - ch059
}


def build_link_map():
    """Build a mapping from broken link patterns to correct EPUB chapter files."""
    link_map = {}
    for tool, base_ch in TOOL_OFFSETS.items():
        for i, scenario in enumerate(SCENARIO_NAMES):
            chapter = f"ch{base_ch + i:03d}.xhtml"
            # Links appear in various forms:
            #   ../../demos/maven-demo/scenario-1-basic/guide.qmd
            #   ../../demos/maven-demo/scenario-1-basic/guide.html
            #   demos/maven-demo/scenario-1-basic/guide.qmd
            #   demos/maven-demo/scenario-1-basic/guide.html
            for ext in ("qmd", "html"):
                for prefix in ("../../", "../", ""):
                    path = f"{prefix}demos/{tool}/{scenario}/guide.{ext}"
                    link_map[path] = chapter
    return link_map


LINK_MAP = build_link_map()


def get_tool_for_chapter(chapter_num: int) -> str | None:
    """Determine which tool a chapter belongs to based on its number."""
    for tool, base in TOOL_OFFSETS.items():
        if base <= chapter_num < base + len(SCENARIO_NAMES):
            return tool
    return None


def fix_cross_references(content: str, chapter_file: str) -> str:
    """Rewrite broken cross-references to point to correct EPUB chapters."""

    # Determine current chapter number for resolving relative links
    ch_match = re.search(r'ch(\d+)\.xhtml', chapter_file)
    current_ch = int(ch_match.group(1)) if ch_match else None
    current_tool = get_tool_for_chapter(current_ch) if current_ch else None

    def replace_href(match):
        full_match = match.group(0)
        href_value = match.group(1)

        # Try direct lookup first (absolute-style paths from triage/comparison)
        replacement = LINK_MAP.get(href_value)
        if replacement:
            return full_match.replace(href_value, replacement)

        # Try relative intra-tool links like ../scenario-3-mgmt/guide.qmd
        if current_tool:
            rel_match = re.search(r'(scenario-\d+-[^/]+)/guide\.(?:qmd|html)', href_value)
            if rel_match:
                scenario_name = rel_match.group(1)
                if scenario_name in SCENARIO_NAMES:
                    idx = SCENARIO_NAMES.index(scenario_name)
                    target_ch = TOOL_OFFSETS[current_tool] + idx
                    return full_match.replace(href_value, f"ch{target_ch:03d}.xhtml")

        return full_match

    content = re.sub(
        r'href="([^"]*guide\.(?:qmd|html))"',
        replace_href,
        content
    )
    return content


def fix_xhtml(content: str) -> str:
    """Apply all XHTML fixes to a single file's content."""

    # 1. Fix broken figure wrapping:
    #    <p><figure class></p>  →  <figure>
    #    <p></figure></p>       →  </figure>
    content = re.sub(
        r'<p><figure\s+class\s*>\s*</p>',
        '<figure>',
        content
    )
    content = re.sub(
        r'<p>\s*</figure>\s*</p>',
        '</figure>',
        content
    )
    # Also handle <figure class=""> (with empty class value)
    content = re.sub(
        r'<p><figure\s+class=""\s*>\s*</p>',
        '<figure>',
        content
    )

    # 2. Remove <style> blocks from <body>
    #    EPUB requires styles in <head> or external CSS, not inline in body.
    body_split = content.split('<body', 1)
    if len(body_split) == 2:
        head_part = body_split[0]
        body_part = body_split[1]
        body_part = re.sub(
            r'<style[^>]*>.*?</style>',
            '',
            body_part,
            flags=re.DOTALL
        )
        content = head_part + '<body' + body_part

    # 3. Fix unescaped & in body text and attributes.
    #    Match & not followed by a valid entity reference.
    content = re.sub(
        r'&(?!(?:amp|lt|gt|quot|apos|#[0-9]+|#x[0-9a-fA-F]+);)',
        '&amp;',
        content
    )

    return content


def fix_all(content: str, filename: str) -> str:
    """Apply all fixes including cross-references (needs filename context)."""
    content = fix_xhtml(content)
    content = fix_cross_references(content, filename)
    return content


def process_epub(epub_path: str) -> None:
    """Unzip, fix, and re-zip an EPUB file in place."""
    epub_path = Path(epub_path)

    if not epub_path.exists():
        print(f"Error: {epub_path} not found", file=sys.stderr)
        sys.exit(1)

    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = Path(tmpdir)

        with zipfile.ZipFile(epub_path, 'r') as zin:
            zin.extractall(tmpdir)

        fixes_applied = 0

        for xhtml_file in sorted(tmpdir.rglob('*.xhtml')):
            original = xhtml_file.read_text(encoding='utf-8')
            fixed = fix_all(original, xhtml_file.name)
            if fixed != original:
                xhtml_file.write_text(fixed, encoding='utf-8')
                fixes_applied += 1
                print(f"  Fixed: {xhtml_file.relative_to(tmpdir)}")

        if fixes_applied == 0:
            print("  No XHTML fixes needed.")
            return

        # Re-create EPUB — mimetype MUST be first entry and uncompressed
        new_epub = epub_path.with_suffix('.epub.tmp')
        with zipfile.ZipFile(new_epub, 'w') as zout:
            mimetype_path = tmpdir / 'mimetype'
            if mimetype_path.exists():
                zout.write(mimetype_path, 'mimetype',
                           compress_type=zipfile.ZIP_STORED)

            for file_path in sorted(tmpdir.rglob('*')):
                if file_path.is_file() and file_path.name != 'mimetype':
                    arcname = str(file_path.relative_to(tmpdir))
                    zout.write(file_path, arcname,
                               compress_type=zipfile.ZIP_DEFLATED)

        shutil.move(str(new_epub), str(epub_path))
        print(f"  Applied fixes to {fixes_applied} file(s).")


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <path-to-epub>", file=sys.stderr)
        sys.exit(1)

    print(f"Fixing EPUB: {sys.argv[1]}")
    process_epub(sys.argv[1])
    print("Done.")
