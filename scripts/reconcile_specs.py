#!/usr/bin/env python3
"""
Reconcile specs from incoming directories
De-duplicate by title/slug, prefer newest files
"""

import os
import re
import shutil
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple
import hashlib

INCOMING_DIR = Path("docs/specs/_incoming")
OUTPUT_DIR = Path("docs/specs")
CONFLICTS_FILE = OUTPUT_DIR / "SPEC_CONFLICTS.md"

def kebab_case(text: str) -> str:
    """Convert text to kebab-case"""
    text = re.sub(r'[^\w\s-]', '', text.lower())
    text = re.sub(r'[-\s]+', '-', text)
    return text.strip('-')

def extract_title(file_path: Path) -> str:
    """Extract title from markdown file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                # Check for markdown heading
                if line.startswith('#'):
                    title = line.lstrip('#').strip()
                    if title:
                        return title
                # Check for YAML frontmatter
                if line.startswith('title:'):
                    return line.split(':', 1)[1].strip().strip('"\'')
    except Exception as e:
        print(f"  Warning: Could not extract title from {file_path}: {e}")

    # Fallback to filename
    return file_path.stem.replace('_', ' ').replace('-', ' ').title()

def get_file_hash(file_path: Path) -> str:
    """Get MD5 hash of file content"""
    md5 = hashlib.md5()
    with open(file_path, 'rb') as f:
        md5.update(f.read())
    return md5.hexdigest()

def collect_specs() -> Dict[str, List[Tuple[Path, datetime]]]:
    """Collect all spec files grouped by slug"""
    specs: Dict[str, List[Tuple[Path, datetime]]] = {}

    if not INCOMING_DIR.exists():
        print(f"Incoming directory not found: {INCOMING_DIR}")
        return specs

    # Walk through all incoming directories
    for root, _, files in os.walk(INCOMING_DIR):
        for file in files:
            if file.endswith(('.md', '.txt')):
                file_path = Path(root) / file
                title = extract_title(file_path)
                slug = kebab_case(title)

                # Get file modification time
                mtime = datetime.fromtimestamp(file_path.stat().st_mtime)

                if slug not in specs:
                    specs[slug] = []

                specs[slug].append((file_path, mtime))

    return specs

def reconcile_specs(specs: Dict[str, List[Tuple[Path, datetime]]]):
    """Reconcile specs, handling duplicates and conflicts"""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    conflicts = []

    print(f"Found {len(specs)} unique spec slugs")
    print("")

    for slug, file_list in specs.items():
        if len(file_list) == 1:
            # Single file, just copy
            src_path, _ = file_list[0]
            dest_path = OUTPUT_DIR / f"{slug}.md"
            shutil.copy2(src_path, dest_path)
            print(f"  ✓ {slug}.md")
        else:
            # Multiple files, check for conflicts
            # Sort by modification time (newest first)
            file_list.sort(key=lambda x: x[1], reverse=True)

            # Check if files are identical by hash
            hashes = {get_file_hash(path): path for path, _ in file_list}

            if len(hashes) == 1:
                # All files are identical, just use the first
                src_path, _ = file_list[0]
                dest_path = OUTPUT_DIR / f"{slug}.md"
                shutil.copy2(src_path, dest_path)
                print(f"  ✓ {slug}.md (duplicates removed)")
            else:
                # Files differ, create conflict entry
                print(f"  ⚠ {slug}.md (CONFLICT: {len(file_list)} versions)")

                # Use newest file
                newest_path, newest_time = file_list[0]
                dest_path = OUTPUT_DIR / f"{slug}.md"
                shutil.copy2(newest_path, dest_path)

                # Save all versions for manual review
                conflict_dir = OUTPUT_DIR / "_conflicts" / slug
                conflict_dir.mkdir(parents=True, exist_ok=True)

                conflict_info = {
                    'slug': slug,
                    'files': []
                }

                for idx, (file_path, mtime) in enumerate(file_list, 1):
                    conflict_file = conflict_dir / f"version-{idx}-{file_path.name}"
                    shutil.copy2(file_path, conflict_file)
                    conflict_info['files'].append({
                        'version': idx,
                        'source': str(file_path),
                        'modified': mtime.strftime('%Y-%m-%d %H:%M:%S'),
                        'path': str(conflict_file)
                    })

                conflicts.append(conflict_info)

    # Write conflicts file
    if conflicts:
        write_conflicts_file(conflicts)
        print("")
        print(f"⚠ {len(conflicts)} conflicts found. See {CONFLICTS_FILE}")

def write_conflicts_file(conflicts: List[Dict]):
    """Write conflicts to markdown file"""
    with open(CONFLICTS_FILE, 'w', encoding='utf-8') as f:
        f.write("# Spec Conflicts\n\n")
        f.write("The following specs have multiple conflicting versions. ")
        f.write("Please review and manually resolve.\n\n")

        for conflict in conflicts:
            f.write(f"## {conflict['slug']}\n\n")
            f.write(f"**{len(conflict['files'])} versions found:**\n\n")

            for file_info in conflict['files']:
                f.write(f"### Version {file_info['version']}\n")
                f.write(f"- **Source:** `{file_info['source']}`\n")
                f.write(f"- **Modified:** {file_info['modified']}\n")
                f.write(f"- **Conflict copy:** `{file_info['path']}`\n\n")

            f.write("**Action required:** Review versions and choose the correct one, ")
            f.write(f"or merge manually into `docs/specs/{conflict['slug']}.md`\n\n")
            f.write("---\n\n")

if __name__ == "__main__":
    print("🔄 Reconciling specs...")
    print("")

    specs = collect_specs()

    if not specs:
        print("No specs found to reconcile")
    else:
        reconcile_specs(specs)
        print("")
        print("✅ Reconciliation complete!")
