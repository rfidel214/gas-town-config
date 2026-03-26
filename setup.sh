#!/usr/bin/env bash
# gastown-config setup script
# Applies OpenBrain capture protocol to an existing Gas Town installation.
# Safe to run multiple times — all patches are idempotent.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== gastown-config setup ==="
echo ""

# ── 1. Locate Gas Town directory ──────────────────────────────────────────────
GT_DIR="${GT_DIR:-$HOME/gt}"
read -rp "Gas Town directory [${GT_DIR}]: " input
GT_DIR="${input:-$GT_DIR}"
GT_DIR="${GT_DIR/#\~/$HOME}"

if [ ! -d "$GT_DIR" ]; then
    echo "ERROR: Gas Town directory not found: $GT_DIR"
    echo "Install Gas Town first: go install github.com/steveyegge/gastown/cmd/gt@latest"
    exit 1
fi
echo "Using Gas Town directory: $GT_DIR"
echo ""

# ── 2. Configure OpenBrain MCP ────────────────────────────────────────────────
OPENCODE_CONFIG="$HOME/.config/opencode/config.json"

if [ -f "$OPENCODE_CONFIG" ] && grep -q "open-brain" "$OPENCODE_CONFIG" 2>/dev/null; then
    echo "SKIP opencode config: open-brain MCP already configured"
else
    echo "OpenBrain MCP setup"
    echo "You need your OpenBrain Supabase Edge Function URL."
    echo "Format: https://<project>.supabase.co/functions/v1/open-brain-mcp?key=<your-key>"
    echo ""
    read -rp "OpenBrain URL (leave blank to skip): " OPENBRAIN_URL

    if [ -n "$OPENBRAIN_URL" ]; then
        mkdir -p "$(dirname "$OPENCODE_CONFIG")"

        if [ -f "$OPENCODE_CONFIG" ]; then
            # Merge into existing config using Python
            python3 - <<PYEOF
import json, sys
with open("$OPENCODE_CONFIG", "r") as f:
    cfg = json.load(f)
cfg.setdefault("mcp", {})["open-brain"] = {"type": "remote", "url": "$OPENBRAIN_URL"}
with open("$OPENCODE_CONFIG", "w") as f:
    json.dump(cfg, f, indent=2)
print("OK   opencode config: open-brain MCP added")
PYEOF
        else
            # Create from template
            sed "s|OPENBRAIN_URL_PLACEHOLDER|$OPENBRAIN_URL|g" \
                "$SCRIPT_DIR/opencode/config-template.json" > "$OPENCODE_CONFIG"
            echo "OK   opencode config: created with open-brain MCP"
        fi
    else
        echo "SKIP opencode config: no URL provided"
    fi
fi
echo ""

# ── 3. Detect rig ─────────────────────────────────────────────────────────────
RIG=""
RIGS_FILE="$GT_DIR/rigs.json"
if [ -f "$RIGS_FILE" ]; then
    RIG=$(python3 -c "
import json
data = json.load(open('$RIGS_FILE'))
rigs = list(data.get('rigs', {}).keys())
print(rigs[0] if rigs else '')
" 2>/dev/null || echo "")
fi

if [ -n "$RIG" ]; then
    echo "Detected rig: $RIG"
else
    read -rp "Rig name (leave blank to skip refinery patch): " RIG
fi
echo ""

# ── 4. Patch AGENTS.md files ──────────────────────────────────────────────────
echo "Patching AGENTS.md files..."
PATCH_ARGS="--gt-dir $GT_DIR"
[ -n "$RIG" ] && PATCH_ARGS="$PATCH_ARGS --rig $RIG"
python3 "$SCRIPT_DIR/scripts/patch-agents.py" $PATCH_ARGS
echo ""

# ── 5. Patch mol-polecat-work formula ────────────────────────────────────────
echo "Patching mol-polecat-work formula..."
python3 "$SCRIPT_DIR/scripts/patch-formula.py" --gt-dir "$GT_DIR"
echo ""

# ── Done ──────────────────────────────────────────────────────────────────────
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Restart Gas Town to pick up new AGENTS.md and opencode config:"
echo "     gt down --all && gt start && gt rig boot <rig>"
echo "  2. Verify opencode MCP: opencode mcp list  (should show 'open-brain connected')"
echo "  3. Run 'gt prime' in any agent session to see updated instructions"
