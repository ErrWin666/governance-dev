---
name: logic-flow-review
description: Advisory review of a diff's control flow — dead branches, silent cycles, unreachable code, and whether the flow matches the spec. Never blocks merges; writes findings to evidence/P<n>/logic-flow.md. Use after implementation, before the verifier role.
allowed-tools: read exec write grep
---

# Logic-Flow Review (advisory — never blocks)

Skills.sh discovery (2026-11-09) found no logic-flow review skill — this is a
custom skill filling that gap.

## Inputs

- The PR diff (or `git diff <base>...HEAD`)
- `plan/spec.md` if present — the declared intent the flow must match
- Optional machine evidence: `pyscn check` CFG output per changed .py file

## Method

1. **CFG evidence.** Run `pyscn check <changed .py files>` (pip install pyscn).
   Its CFG pass reports `unreachable_after_return`, unreachable branches, and
   silent infinite loops. Record every finding verbatim.
2. **Flow walk.** For each changed function, trace entry → every exit. Flag:
   - Dead branches (condition provably always/never true)
   - Silent cycles (loop that always exits via same edge / never terminates
     but yields no signal)
   - Exception swallowing that hides which edge was taken
   - Return paths that skip cleanup the spec requires
3. **Spec match.** If plan/spec.md exists, map each spec behavior to a flow
   path. Flag spec behaviors with no path, and paths with no spec behavior.
4. **tracelint note.** Agent-execution trace linting (`pip install tracelint`)
   is deferred to L4 — it needs real Devin session traces as input.

## Output

Write `evidence/P<n>/logic-flow.md`:

```markdown
# Logic-Flow Review — PR #<n>
- pyscn findings: <list or "none">
- Dead branches: <list or "none">
- Silent cycles: <list or "none">
- Spec coverage: <mapped behaviors> / gaps: <list>
- Verdict: ADVISORY — <summary>. This review cannot block merge.
```

## Rules

- Advisory only — never exit non-zero, never mark a check failed.
- Cite file:line for every finding (no vague claims).
- When unsure, say so — hypotheses, not assertions.
