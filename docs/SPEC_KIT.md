# Spec-Kit Integration Guide

This repository uses [GitHub Spec-Kit](https://github.com/github/spec-kit) for specification-driven development.

## Directory Structure

```
voygent-mvp/
├── .specify/                   # Spec-Kit configuration
│   ├── memory/                # Project memory and constitution
│   │   └── constitution.md   # Voygent constitution (core principles)
│   ├── scripts/               # Spec-Kit helper scripts
│   │   └── bash/             # Bash utilities
│   └── templates/            # Original Spec-Kit templates
│
├── .claude/                   # Claude Desktop integration
│   ├── commands/             # Custom slash commands
│   └── settings.local.json  # Claude Code settings
│
├── specs/                     # Specifications (renamed from docs/specs)
│   ├── _templates/           # Spec templates for this project
│   ├── _archive/             # Completed/deprecated specs
│   ├── _incoming/            # Import staging area
│   │   ├── local/           # From local filesystem
│   │   └── github/          # From GitHub repos
│   └── [active-specs]/      # Current specifications
│
└── docs/
    ├── specs_status.md       # Generated status table
    └── SPEC_KIT.md          # This file
```

## Workflows

### Creating a New Spec

1. **Use the template:**
   ```bash
   cp specs/_templates/spec-template.md specs/new-feature.md
   ```

2. **Fill in the spec:**
   - Title and overview
   - Requirements
   - Technical design
   - Testing plan
   - Status metadata (front-matter)

3. **Add to git and create PR:**
   ```bash
   git checkout -b spec/new-feature
   git add specs/new-feature.md
   git commit -m "spec: add new feature specification"
   gh pr create --base dev
   ```

### Importing Specs from Other Sources

Use the import script to pull specs from local directories or GitHub repos:

```bash
# Set source paths
export LOCAL_SPEC_PATHS="/path/to/specs1,/path/to/specs2"
export GITHUB_SPEC_URLS="https://github.com/user/repo1,https://github.com/user/repo2"

# Run import
bash scripts/import_specs.sh
```

This will:
1. Copy specs to `specs/_incoming/`
2. Reconcile duplicates (newest wins)
3. Detect conflicts and save for manual resolution
4. Generate status table

### Spec Lifecycle

1. **Planned** - Spec written, not yet approved
2. **In Progress** - Approved, implementation ongoing
3. **Completed** - Implemented and verified
4. **Blocked** - Waiting on dependencies
5. **Archived** - Deprecated or superseded

Move completed specs to archive:
```bash
git mv specs/completed-feature.md specs/_archive/
```

### Generating Status Reports

Generate a status table of all specs:

```bash
python3 scripts/gen_status_table.py
```

Output: `docs/specs_status.md`

Includes:
- Status summary (planned, in-progress, completed, blocked)
- Full spec table with links
- Blocked items with reasons
- In-progress tracking

## Claude Desktop Commands

The `.claude/commands/` directory contains custom commands for Claude Desktop:

- `/constitution` - Show Voygent constitution
- `/specify` - Help writing a new spec
- `/plan` - Create implementation plan from spec
- `/implement` - Guide implementation of spec
- `/clarify` - Ask clarifying questions about spec
- `/tasks` - Break down spec into tasks

To use in Claude Desktop, these commands are automatically available after syncing.

## Spec-Kit Templates

### Available Templates

1. **spec-template.md** - Full feature specification
   - Overview and requirements
   - Technical design
   - API contracts
   - Testing plan
   - Status tracking

2. **plan-template.md** - Implementation plan
   - Phases and milestones
   - Dependencies
   - Risk assessment
   - Timeline

3. **tasks-template.md** - Task breakdown
   - Granular task list
   - Assignees and estimates
   - Blockers and dependencies

4. **agent-file-template.md** - Agent context
   - Project-specific guidance for AI agents
   - Common patterns and anti-patterns

### Customizing Templates

Templates in `specs/_templates/` can be modified for project-specific needs:

```bash
# Copy original
cp .specify/templates/spec-template.md specs/_templates/spec-template.md

# Edit to add Voygent-specific sections
vim specs/_templates/spec-template.md
```

## Integration with Critical Path

All specs must answer the critical path question:

> **"Is this effort on the critical path to getting a functional MVP on Render.com?"**

Add to spec front-matter:

```yaml
---
title: Feature Name
status: planned
critical_path: yes
explanation: "This feature is required for MVP because..."
---
```

## Best Practices

### Writing Good Specs

1. **Start with "Why"** - Explain the problem and business value
2. **Be Specific** - Concrete requirements, not vague ideas
3. **Include Examples** - API samples, UI mockups, data schemas
4. **Define Success** - Clear acceptance criteria
5. **Consider Edge Cases** - Error handling, validation, limits

### Spec Review Process

1. **Author** creates spec in PR
2. **Reviewers** ask clarifying questions
3. **Team** discusses in PR comments
4. **Approval** requires answering critical path question
5. **Merge** to `dev` when approved

### Keeping Specs Updated

- Update spec status as work progresses
- Link PRs that implement the spec
- Archive when complete or superseded
- Document deviations in spec itself

## Scripts Reference

### import_specs.sh

Imports and reconciles specs from multiple sources.

**Environment Variables:**
- `LOCAL_SPEC_PATHS` - Comma-separated local paths
- `GITHUB_SPEC_URLS` - Comma-separated GitHub URLs

**Example:**
```bash
LOCAL_SPEC_PATHS="/home/user/specs" \
GITHUB_SPEC_URLS="https://github.com/org/repo" \
bash scripts/import_specs.sh
```

### reconcile_specs.py

De-duplicates specs by title, prefers newest version.

**Conflict Resolution:**
- Identical files → merged automatically
- Different files → both saved to `specs/_conflicts/`
- Creates `specs/SPEC_CONFLICTS.md` with diff summary

**Manual Resolution:**
```bash
# Review conflicts
cat specs/SPEC_CONFLICTS.md

# Choose version or merge manually
vim specs/conflicting-spec.md

# Remove conflict markers
rm -rf specs/_conflicts/conflicting-spec/
```

### gen_status_table.py

Generates markdown status table from spec metadata.

**Metadata Sources:**
1. YAML front-matter (preferred)
2. Markdown headers and content
3. File modification times

**Output:** `docs/specs_status.md`

## Troubleshooting

### Import Issues

**Problem:** Specs not importing
```bash
# Check incoming directory
ls -la specs/_incoming/

# Verify source paths exist
echo $LOCAL_SPEC_PATHS
ls -la /path/to/specs
```

**Problem:** Conflicts detected
```bash
# Review conflict file
cat specs/SPEC_CONFLICTS.md

# Compare versions
diff specs/_conflicts/name/version-1.md specs/_conflicts/name/version-2.md
```

### Status Table Issues

**Problem:** Specs missing from table
- Ensure files are in `specs/` directory (not `_incoming/`, `_archive/`, or `_templates/`)
- Check file extension is `.md`
- Verify file has title (either in front-matter or as first heading)

**Problem:** Wrong status shown
- Add front-matter with explicit status:
  ```yaml
  ---
  status: in-progress
  ---
  ```

## Contributing

When adding new Spec-Kit features:

1. Document in this guide
2. Update templates if needed
3. Add examples
4. Test with sample specs
5. Update status table generation if adding new metadata fields

## Resources

- [GitHub Spec-Kit Documentation](https://github.com/github/spec-kit)
- [Voygent Constitution](.specify/memory/constitution.md)
- [ROADMAP](../ROADMAP.md) - MVP phases
- [ARCHITECTURE](../ARCHITECTURE.md) - System design
