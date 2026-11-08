# ADR-004: CI + Ruleset + CODEOWNERS = final enforcement wall

## Status
Accepted

## Context
All local layers (PreToolUse hooks, OPA policies) are detection-tier:
they run inside the agent's own OS user, under a hook contract with a
documented fail-open seam (STATE.md §2), and can be bypassed by vectors
like `devin -p --config` (ERR-009) or direct local exec. True enforcement
must live outside the environment the agent controls.

## Decision
Final enforcement runs on GitHub: Actions workflow with a required status
check ("Verify test files are frozen"), a Ruleset protecting main
(#26814146), and CODEOWNERS covering tests.lock, *.test.js, and the
.github/ directory itself. Branch protection blocks force pushes.

## Consequences
**Positive:**
- Proven on the ci-test repo: PR #1 blocked by the failing required check;
  force pushes blocked
- Runs on GitHub's servers — the agent has no credential path to weaken it
- CODEOWNERS on .github/ prevents the agent from editing the workflow that
  enforces it

**Negative:**
- Only applies to projects pushed to GitHub — local-only work has no
  final wall
- Protection depends on the workflow file itself being protected;
  CODEOWNERS on .github/ is mandatory, not optional
- Ruleset/workflow changes require gh CLI (WSL-only) — added operational
  dependency

## Alternatives considered
- **Local enforcement only**: rejected — every local layer is detection-
  tier with a documented fail-open seam
- **MCP proxy enforcement only**: rejected — covers MCP tools but not
  Devin's native tools (exec, edit), which are the dangerous surface

## References
- STATE.md §1 (CI enforcement proven), §6 (ci-test testbed, ruleset
  #26814146)
- docs/errors/ERR-009.md
- github.com/ErrWin666/ci-test
