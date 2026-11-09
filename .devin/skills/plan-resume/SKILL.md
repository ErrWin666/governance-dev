---
name: plan-resume
description: Cold-session resume for the plan/ convention. Reads plan/spec.md, plan/tasks.md, plan/research/, STATE.md and evidence/ then reports status and proposes the next task. Use when a fresh session starts mid-project, or the user asks "where are we" / "continue". NEVER continues autonomously — always presents status and waits for owner confirmation.
allowed-tools: read grep
---

# Plan Resume (read-only, never auto-continues)

Companion to `session-handoff` (which covers generic context transfer);
this skill restores state specifically from the plan/ convention.

## Method

1. Read, in order: `plan/spec.md` (intent), `plan/tasks.md` (checkboxes =
   ground truth of progress), `plan/research/` (prior findings),
   `STATE.md` (system state), `evidence/P*/` (what was proven).
2. Compute: which tasks are `[x]` done vs `[ ]` open; the lowest-numbered
   open task is the candidate next step.
3. Check `plan/spec.approved` / `plan/tasks.approved` exist and match —
   if missing or hash-stale, the next step is re-approval, not code.

## Output (always a proposal, never an action)

```markdown
## Resume status
- Spec: <name, approval state>
- Progress: task N/M done — <one-line summary of what exists>
- Next task: #<n> <title> (<acceptance criterion>)
- Blockers/anomalies: <list or none>
**Confirm next step?** (I will not proceed without your go-ahead.)
```

## Rules

- Read-only: do not edit plan/, src/, or anything else.
- Do not infer progress from conversation — only from files on disk.
- If plan/ is absent, say so and point to spec-driven-development.
- Always end by asking the owner to confirm the next step.
