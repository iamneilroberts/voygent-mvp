#!/usr/bin/env python3
"""
Generate status table from spec files
Parses front-matter or markdown for status, owner, dates
"""

import os
import re
from pathlib import Path
from typing import Dict, List
from datetime import datetime

SPECS_DIR = Path("specs")
OUTPUT_FILE = Path("docs/specs_status.md")

def parse_frontmatter(content: str) -> Dict[str, str]:
    """Parse YAML frontmatter from markdown"""
    frontmatter = {}

    # Check for YAML frontmatter
    if content.startswith('---'):
        parts = content.split('---', 2)
        if len(parts) >= 2:
            yaml_content = parts[1]
            for line in yaml_content.split('\n'):
                line = line.strip()
                if ':' in line:
                    key, value = line.split(':', 1)
                    frontmatter[key.strip()] = value.strip().strip('"\'')

    return frontmatter

def extract_metadata(file_path: Path) -> Dict[str, str]:
    """Extract metadata from spec file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        metadata = parse_frontmatter(content)

        # Extract title
        if 'title' not in metadata:
            # Find first heading
            match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
            if match:
                metadata['title'] = match.group(1).strip()
            else:
                metadata['title'] = file_path.stem.replace('-', ' ').title()

        # Default values
        metadata.setdefault('status', 'planned')
        metadata.setdefault('owner', 'unassigned')

        # Get last modified from file system if not in frontmatter
        if 'last_updated' not in metadata:
            mtime = datetime.fromtimestamp(file_path.stat().st_mtime)
            metadata['last_updated'] = mtime.strftime('%Y-%m-%d')

        # Extract blockers from content
        blockers = re.findall(r'(?:blocked by|blocker|depends on):\s*(.+)', content, re.IGNORECASE)
        if blockers:
            metadata['blockers'] = ', '.join(blockers)

        return metadata

    except Exception as e:
        print(f"  Warning: Could not parse {file_path}: {e}")
        return {
            'title': file_path.stem.replace('-', ' ').title(),
            'status': 'unknown',
            'owner': 'unassigned',
            'last_updated': 'unknown'
        }

def collect_specs() -> List[Dict[str, str]]:
    """Collect all specs with metadata"""
    specs = []

    if not SPECS_DIR.exists():
        print(f"Specs directory not found: {SPECS_DIR}")
        return specs

    for file_path in sorted(SPECS_DIR.glob("*.md")):
        # Skip generated files
        if file_path.name in ['specs_status.md', 'SPEC_CONFLICTS.md']:
            continue

        metadata = extract_metadata(file_path)
        metadata['file'] = file_path.name
        metadata['path'] = str(file_path.relative_to(Path('.')))

        specs.append(metadata)

    return specs

def generate_status_table(specs: List[Dict[str, str]]):
    """Generate markdown status table"""
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write("# Spec Status Overview\n\n")
        f.write(f"*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n")
        f.write(f"**Total Specs:** {len(specs)}\n\n")

        # Status summary
        status_counts = {}
        for spec in specs:
            status = spec.get('status', 'unknown')
            status_counts[status] = status_counts.get(status, 0) + 1

        f.write("## Status Summary\n\n")
        for status, count in sorted(status_counts.items()):
            f.write(f"- **{status.title()}:** {count}\n")
        f.write("\n")

        # Main table
        f.write("## All Specs\n\n")
        f.write("| Title | Status | Owner | Last Updated | File |\n")
        f.write("|-------|--------|-------|--------------|------|\n")

        for spec in specs:
            title = spec.get('title', 'Untitled')
            status = spec.get('status', 'unknown').title()
            owner = spec.get('owner', 'unassigned')
            updated = spec.get('last_updated', 'unknown')
            file_link = f"[{spec['file']}]({spec['path']})"

            f.write(f"| {title} | {status} | {owner} | {updated} | {file_link} |\n")

        f.write("\n")

        # Blocked items
        blocked = [s for s in specs if 'blockers' in s or s.get('status') == 'blocked']
        if blocked:
            f.write("## Blocked Items\n\n")
            f.write("These specs are blocked or have dependencies:\n\n")

            for spec in blocked:
                f.write(f"### {spec.get('title', 'Untitled')}\n")
                f.write(f"- **Status:** {spec.get('status', 'unknown')}\n")
                f.write(f"- **File:** [{spec['file']}]({spec['path']})\n")

                if 'blockers' in spec:
                    f.write(f"- **Blockers:** {spec['blockers']}\n")

                f.write("\n")

        # In Progress
        in_progress = [s for s in specs if s.get('status') == 'in-progress']
        if in_progress:
            f.write("## In Progress\n\n")
            for spec in in_progress:
                title = spec.get('title', 'Untitled')
                owner = spec.get('owner', 'unassigned')
                f.write(f"- **{title}** (Owner: {owner}) - [{spec['file']}]({spec['path']})\n")
            f.write("\n")

        # Completed
        completed = [s for s in specs if s.get('status') in ['done', 'completed']]
        if completed:
            f.write(f"## Completed ({len(completed)})\n\n")
            for spec in completed:
                title = spec.get('title', 'Untitled')
                f.write(f"- {title}\n")
            f.write("\n")

if __name__ == "__main__":
    print("📊 Generating status table...")
    print("")

    specs = collect_specs()

    if not specs:
        print("No specs found")
    else:
        print(f"Found {len(specs)} specs")
        generate_status_table(specs)
        print("")
        print(f"✅ Status table generated: {OUTPUT_FILE}")
