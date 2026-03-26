---

## OpenBrain Capture Protocol (All Gas Town Agents)

OpenBrain (`capture_thought` MCP tool) is the shared memory layer across all agents and sessions.
**All Gas Town agents MUST capture to OpenBrain** at key lifecycle moments.
Skipped captures force the next agent to re-derive context from scratch — wasted hours.

OpenBrain MCP is configured in `~/.config/opencode/config.json` (server: `open-brain`).
Call it with: `capture_thought("<text>")`

### Required capture triggers

| Event | Category tag | Who |
|-------|-------------|-----|
| Key decision made | `[DECISION]` | Any |
| Error hit and fixed | `[ERROR]` | Any |
| Non-obvious discovery | `[DISCOVERY]` | Any |
| Significant work completed | `[PROGRESS]` | Any |
| Blocker encountered | `[BLOCKER]` | Any |
| Session ending | `[HANDOFF]` | Any |

### Format

```
capture_thought("[TASK <id>] [CATEGORY] YYYY-MM-DD - <summary>")
```

Use `[TASK gastown]` for Mayor/coordinator-level decisions.
Use `[TASK <bead-id>]` for bead-specific work (e.g. `[TASK hq-cv-v3u4i]`).

### Why OpenBrain over beads notes

Beads notes are short status strings. OpenBrain holds full structured reasoning:
error context, decision rationale, architectural discoveries, failure analysis.
Both matter. Neither replaces the other. Beads = what. OpenBrain = why + how.
