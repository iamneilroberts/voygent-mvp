#!/bin/bash
# Import and consolidate specs from local and GitHub sources

set -e

echo "📚 Importing Spec-Kit specifications..."
echo ""

# Configuration
LOCAL_SPEC_PATHS="${LOCAL_SPEC_PATHS:-}"
GITHUB_SPEC_URLS="${GITHUB_SPEC_URLS:-}"
INCOMING_DIR="docs/specs/_incoming"
LOCAL_INCOMING="$INCOMING_DIR/local"
GITHUB_INCOMING="$INCOMING_DIR/github"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create incoming directories
mkdir -p "$LOCAL_INCOMING" "$GITHUB_INCOMING"

# Import from local paths
if [ -n "$LOCAL_SPEC_PATHS" ]; then
  echo -e "${BLUE}📂 Importing from local paths...${NC}"
  IFS=',' read -ra PATHS <<< "$LOCAL_SPEC_PATHS"

  for path in "${PATHS[@]}"; do
    path=$(echo "$path" | xargs)  # Trim whitespace

    if [ -d "$path" ]; then
      dirname=$(basename "$path")
      echo "  Copying from: $path"

      # Copy all spec files
      if [ -d "$path/specs" ]; then
        cp -r "$path/specs" "$LOCAL_INCOMING/$dirname/"
      elif [ -f "$path"/*.md ] || [ -f "$path"/*.txt ]; then
        mkdir -p "$LOCAL_INCOMING/$dirname"
        cp "$path"/*.md "$LOCAL_INCOMING/$dirname/" 2>/dev/null || true
        cp "$path"/*.txt "$LOCAL_INCOMING/$dirname/" 2>/dev/null || true
      fi

      echo -e "  ${GREEN}✓${NC} Imported from $dirname"
    else
      echo "  ⚠ Path not found: $path (skipping)"
    fi
  done
  echo ""
fi

# Import from GitHub URLs
if [ -n "$GITHUB_SPEC_URLS" ]; then
  echo -e "${BLUE}🌐 Importing from GitHub...${NC}"
  IFS=',' read -ra URLS <<< "$GITHUB_SPEC_URLS"

  for url in "${URLS[@]}"; do
    url=$(echo "$url" | xargs)  # Trim whitespace

    # Extract repo name from URL
    repo_name=$(echo "$url" | sed 's#.*/##' | sed 's/\.git$//')
    clone_dir="$GITHUB_INCOMING/$repo_name"

    echo "  Cloning: $url"

    # Clone or pull
    if [ -d "$clone_dir" ]; then
      echo "  Repository already exists, pulling latest..."
      (cd "$clone_dir" && git pull -q)
    else
      git clone -q "$url" "$clone_dir"
    fi

    # Copy spec files
    if [ -d "$clone_dir/specs" ]; then
      echo "  Found specs/ directory"
    elif [ -d "$clone_dir/docs/specs" ]; then
      mv "$clone_dir/docs/specs" "$clone_dir/specs"
      echo "  Found docs/specs/ directory"
    fi

    echo -e "  ${GREEN}✓${NC} Imported from $repo_name"
  done
  echo ""
fi

# Run reconciliation
echo -e "${BLUE}🔄 Reconciling specs...${NC}"
if [ -f "scripts/reconcile_specs.py" ]; then
  python3 scripts/reconcile_specs.py
  echo -e "${GREEN}✓${NC} Reconciliation complete"
else
  echo "⚠ reconcile_specs.py not found, skipping reconciliation"
fi
echo ""

# Generate status table
echo -e "${BLUE}📊 Generating status table...${NC}"
if [ -f "scripts/gen_status_table.py" ]; then
  python3 scripts/gen_status_table.py
  echo -e "${GREEN}✓${NC} Status table generated"
else
  echo "⚠ gen_status_table.py not found, skipping status generation"
fi
echo ""

echo -e "${GREEN}✅ Spec import completed!${NC}"
echo "Check docs/specs/ for reconciled specs"
echo "Check docs/specs_status.md for status overview"
