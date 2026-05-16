#!/usr/bin/env python3
"""
Extract user-facing strings from compiled .NET DLL and other binary files.

Usage:
    python extract_strings.py <file> [--min-len 4] [--encoding utf16le] [--classify]

Examples:
    python extract_strings.py SpawnManager.dll --classify
    python extract_strings.py mod.exe --min-len 5
    python extract_strings.py mod.dll --encoding auto

Supports:
    - .NET/Mono DLL (UTF-16LE user string heap)
    - Generic binary (ASCII strings)
    - Unity AssetBundle (limited)
"""

import argparse
import re
import sys
from collections import Counter
from pathlib import Path


def extract_ascii(data: bytes, min_len: int = 4) -> list[str]:
    """Extract contiguous ASCII printable sequences."""
    pattern = rb'[\x20-\x7e]{%d,}' % min_len
    return sorted(set(
        m.group().decode('ascii', errors='ignore')
        for m in re.finditer(pattern, data)
    ))


def extract_utf16le(data: bytes, min_len: int = 4) -> list[str]:
    """Extract UTF-16LE encoded strings (common in .NET #US heap)."""
    results = set()
    i = 0
    n = len(data)
    while i < n - 1:
        if 32 <= data[i] < 127 and data[i + 1] == 0:
            chars = []
            j = i
            while (j < n - 1 and
                   32 <= data[j] < 127 and
                   data[j + 1] == 0):
                chars.append(chr(data[j]))
                j += 2
            if len(chars) >= min_len:
                results.add(''.join(chars))
            i = j
        else:
            i += 1
    return sorted(results)


def extract_utf16be(data: bytes, min_len: int = 4) -> list[str]:
    """Extract UTF-16BE encoded strings."""
    results = set()
    i = 0
    n = len(data)
    while i < n - 1:
        if data[i] == 0 and 32 <= data[i + 1] < 127:
            chars = []
            j = i
            while (j < n - 1 and
                   data[j] == 0 and
                   32 <= data[j + 1] < 127):
                chars.append(chr(data[j + 1]))
                j += 2
            if len(chars) >= min_len:
                results.add(''.join(chars))
            i = j
        else:
            i += 1
    return sorted(results)


def is_ui_string(s: str) -> bool:
    """Check if a string looks like user-facing UI text."""
    # Skip metadata/technical strings
    if s.startswith(('<', '.', '#')):
        return False
    if re.match(r'^[0-9A-Fa-f]{8,}$', s):  # hex blobs
        return False
    if re.match(r'^[<>]+$', s):  # angle bracket sequences
        return False
    if len(s) < 4:
        return False
    return True


def classify(s: str) -> str:
    """Classify a UI string into a category."""
    s = s.strip()
    if not s:
        return 'empty'

    # Rich text / sprite tags
    if s.startswith('<sprite') or s.startswith('<color'):
        return 'rich_text'

    # Format strings
    if re.search(r'\{[0-9]\}', s):
        return 'log_format'

    # Questions / dialogs
    if s.rstrip().endswith('?') and len(s) > 10:
        return 'dialog'

    # Long descriptions
    if len(s) > 50 and ('e.g.' in s.lower() or 'example' in s.lower()):
        return 'config_desc'

    # Button actions
    action_words = ('Enable', 'Disable', 'Show', 'Hide', 'Toggle',
                    'Add', 'Remove', 'Save', 'Load', 'Back', 'Refresh')
    if any(s.startswith(w) for w in action_words):
        return 'button'

    # Size/level labels
    if re.match(r'^\d{2}\s+(Tiny|Small|Medium|Big|Wide|Tall|Very)', s):
        return 'size_label'

    # Short labels
    if len(s) <= 30 and not s.startswith(' '):
        return 'label'

    return 'other'


def main():
    parser = argparse.ArgumentParser(
        description='Extract user-facing strings from compiled game mod files'
    )
    parser.add_argument('file', help='Path to DLL/EXE/binary file')
    parser.add_argument('--min-len', type=int, default=4,
                        help='Minimum string length (default: 4)')
    parser.add_argument('--encoding', default='auto',
                        choices=['auto', 'ascii', 'utf16le', 'utf16be'],
                        help='String encoding (default: auto = try all)')
    parser.add_argument('--classify', action='store_true',
                        help='Classify strings into categories')
    parser.add_argument('--ui-only', action='store_true',
                        help='Show only UI-likely strings (filter out metadata)')
    parser.add_argument('--output', '-o',
                        help='Output file (default: stdout)')
    args = parser.parse_args()

    filepath = Path(args.file)
    if not filepath.exists():
        print(f"Error: file not found: {args.file}", file=sys.stderr)
        sys.exit(1)

    data = filepath.read_bytes()
    print(f"Read {len(data):,} bytes from {filepath.name}", file=sys.stderr)

    all_strings = set()

    if args.encoding in ('auto', 'utf16le'):
        utf16 = extract_utf16le(data, args.min_len)
        print(f"UTF-16LE: {len(utf16)} strings", file=sys.stderr)
        all_strings.update(utf16)

    if args.encoding in ('auto', 'utf16be'):
        utf16b = extract_utf16be(data, args.min_len)
        print(f"UTF-16BE: {len(utf16b)} strings", file=sys.stderr)
        all_strings.update(utf16b)

    if args.encoding in ('auto', 'ascii'):
        ascii_s = extract_ascii(data, args.min_len)
        print(f"ASCII: {len(ascii_s)} strings", file=sys.stderr)
        all_strings.update(ascii_s)

    # Filter to UI-likely strings
    if args.ui_only:
        all_strings = {s for s in all_strings if is_ui_string(s)}

    strings = sorted(all_strings)

    # Classify if requested
    if args.classify:
        categories = Counter()
        classified = []
        for s in strings:
            cat = classify(s)
            categories[cat] += 1
            classified.append((cat, s))

        print(f"\nCategory breakdown:", file=sys.stderr)
        for cat, count in categories.most_common():
            print(f"  {cat}: {count}", file=sys.stderr)
        print(file=sys.stderr)

        out_lines = []
        current_cat = None
        cat_labels = {
            'label': '# UI 标签',
            'button': '# 按钮/操作文本',
            'dialog': '# 弹窗/确认文案',
            'config_desc': '# 配置描述',
            'log_format': '# 日志消息',
            'size_label': '# 尺寸/层级标签',
            'rich_text': '# 富文本标签',
            'other': '# 其他',
            'empty': '# 空',
        }
        for cat, s in classified:
            if cat != current_cat:
                current_cat = cat
                out_lines.append(f"\n{cat_labels.get(cat, f'# {cat}')}")
            out_lines.append(s)
        output = '\n'.join(out_lines)
    else:
        output = '\n'.join(strings)

    # Write output
    if args.output:
        Path(args.output).write_text(output, encoding='utf-8')
        print(f"Wrote {len(strings)} strings to {args.output}", file=sys.stderr)
    else:
        print(output)


if __name__ == '__main__':
    main()
