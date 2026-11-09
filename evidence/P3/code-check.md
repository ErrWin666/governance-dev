# Code-Check (advisory, clean-code skill) — PR #3 verification run

Skill: `.devin/skills/clean-code` (adopted: `npx skills add sickn33/agentic-awesome-skills --skill clean-code -a devin`)
Scope: risky PR seed (`risky_pkg/`)

Findings (advisory, non-blocking):

- `risky_pkg/a.py:5-27` — `complex_one` nests 5 decision levels; Clean Code says
  max 2 indent levels — extract predicates. (CI already fails this: B2/D2.)
- `risky_pkg/a.py:3` — dead statements after `return` — remove. (CI: B4.)
- `risky_pkg/blob.py` — 60 near-identical `fn_N` functions — DRY violation;
  generate or data-drive. (advisory only; jscpd stayed under 5%.)
- `risky_pkg/a.py` + `risky_pkg/b.py` — circular import is a dependency-smell;
  extract shared code to a third module. (CI: B1.)
- Naming OK; functions ≤50 lines OK; no magic strings.

Verdict: ADVISORY — 4 smells found, all except blob-DRY already blocked by CI gates.
