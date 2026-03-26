# gastown-config

Reusable configuration layer for [Gas Town](https://github.com/steveyegge/gastown) multi-agent orchestration.

Gas Town is project-agnostic. This repo is the opinionated config layer that makes it work well across projects — adding OpenBrain memory integration, mandatory capture protocols, and formula enforcement to the default setup.

## What This Adds

| Component | What it does |
|-----------|-------------|
| OpenBrain MCP | Connects all Gas Town agents to shared memory via Supabase Edge Function |
| Capture protocol (all agents) | Every agent knows when and how to capture to OpenBrain |
| Mayor capture rules | Convoy decisions, escalations, and handoffs are captured |
| Refinery capture rules | FIX_NEEDED rejection reasons are captured for next polecat |
| Formula enforcement (polecats) | `mol-polecat-work` has a mandatory `capture-findings` gate step — polecats cannot submit to MQ without capturing |

## Prerequisites

- Gas Town installed (`gt version` works)
- OpenCode 1.3+ installed
- An OpenBrain account (Supabase Edge Function URL + API key)
- Python 3 (for patch scripts)

## Setup

```bash
git clone https://github.com/rfidel214/gas-town-config
cd gastown-config
./setup.sh
```

`setup.sh` will prompt for your Gas Town directory (default: `~/gt`) and your OpenBrain credentials, then apply all patches idempotently.

## Structure

```
agents/
  gt-workspace.md      # Appended to ~/gt/AGENTS.md (all agents read this)
  mayor.md             # Appended to ~/gt/mayor/AGENTS.md (Mayor-specific rules)

formulas/
  capture-step.toml    # The capture-findings step for mol-polecat-work

scripts/
  patch-agents.py      # Patches ~/gt/AGENTS.md and ~/gt/mayor/AGENTS.md
  patch-formula.py     # Patches mol-polecat-work formula with capture gate

opencode/
  config-template.json # opencode config template with OpenBrain MCP server

setup.sh               # Main entry point — applies all patches
```

## Idempotency

All patches are guarded — running `setup.sh` twice is safe. Each patch checks for its guard string before applying.

## Updating

To pull new patches from this repo and re-apply:

```bash
git pull
./setup.sh
```

## Rig-Specific Configuration

The Refinery AGENTS.md patch is rig-specific (it targets the project AGENTS.md in the rig checkout). Run after your rig is configured:

```bash
./scripts/patch-refinery.py --rig <rig-name>
```

## Relation to the Gas Town Fork

This config repo works with vanilla Gas Town. A fork of Gas Town (`steveyegge/gastown`) is planned to add binary-level enforcement (Mayor formula, command hooks). This config repo will track that fork when available.
