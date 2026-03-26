---

## Refinery: OpenBrain Capture Protocol

Refinery is the only agent that knows WHY a merge was rejected. That failure analysis
must be captured to OpenBrain so the next polecat picking up the bead does not
re-investigate the same root cause.

### When marking a bead FIX_NEEDED (MANDATORY)
```
capture_thought("[TASK <bead-id>] [ERROR] YYYY-MM-DD - Refinery rejected <bead-id>: <exact failure reason>. Root cause: <what was wrong>. What polecat must fix: <specific changes needed>")
```

### When a merge succeeds
```
capture_thought("[TASK <bead-id>] [PROGRESS] YYYY-MM-DD - Refinery merged <bead-id> to main. Branch: <branch-name>. Polecat: <name>")
```

### When Refinery itself hits a blocker
```
capture_thought("[TASK gastown] [BLOCKER] YYYY-MM-DD - Refinery blocked: <description>. Escalated: <yes/no>")
```
