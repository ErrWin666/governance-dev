# Logic-Flow Review — PR #3

Skill: `.devin/skills/logic-flow-review` (custom — no skills.sh match found 2026-11-09)

- pyscn findings: `risky_pkg/a.py:5` — `unreachable_after_return` (critical)
- Dead branches: `risky_pkg/a.py:4` — `y = 42` and second `return` never execute
- Silent cycles: none found in changed code
- Spec coverage: no plan/spec.md in this PR — flow-vs-spec check skipped
- tracelint: deferred to L4 (needs real Devin execution traces)

Verdict: ADVISORY — dead code confirmed by both CFG and manual walk;
recommend removing `a.py:4-5`. This review cannot block merge (CI B4 already blocks it).
