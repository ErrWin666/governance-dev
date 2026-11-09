# Errors Index — Governance Lessons Learned

> Purpose: "What did we learn from failure?" — index of all governance errors.

This index lists every documented error in the governance system, with one-line
summaries. Read this before building new features — most errors describe why
certain approaches failed.

| ID | Title | Type | Status |
|---|---|---|---|
| ERR-001 | M8 required "signed spec" without defining signature mechanism | spec gap | fixed (text-approval interim) |
| ERR-002 | Governance could over-engineer small projects | spec gap | fixed (proportional governance) |
| ERR-003 | UTF-8 required for files but not stdin/stdout | implementation | fixed (reconfigure) |
| ERR-004 | Mid-session hook changes are silently inactive | lifecycle | documented |
| ERR-005 | Tool name matrix from Claude Code ≠ Devin | assumption | fixed (discovery log) |
| ERR-006 | logged tool_name ≠ function name (mcp__*, glob) | assumption | fixed (alias-aware matching) |
| ERR-007 | MSYS2 cygheap fork failures | environment | mitigated (Desktop Heap 4096) |
| ERR-008 | `permissions.deny` is dead code | harness | documented — do not rely on it |
| ERR-009 | `devin -p --config` is dormant bypass | harness | mitigated (no auth login) |
| ERR-010 | `fail_closed:true` proven working | success | proven |
| ERR-011 | sha256sum binary mode breaks gate.sh path parsing | environment | fixed (generate from WSL, -t flag) |
| ERR-012 | P6/P7 are CI-based, not runtime policies — OPA cannot self-inspect | assumption | documented — use CI linters |
| ERR-013 | gitleaks defaults miss alphabet-sequence secrets | assumption | fixed (custom rule, .gitleaks.toml) — Rule 30 |
| ERR-014 | admin bypass deviation on governance-dev ruleset | spec gap | documented — dev-only exception, prod strict |
| ERR-015 | L2 tool install fallbacks (arborist 404, muti junk, pyscn, polyscan) | assumption | documented — substitutes chosen |
| ERR-016 | cold-session resume never tested | lifecycle | tested — see GAP-L3-04 |
| ERR-017 | `pull_request.base.sha` frozen at PR-open → checks diffed polluted file set | infrastructure | resolved (base-toggle refreshes; PR #4+#5 merged) |
| ERR-018 | `numbers.range(1,0)` descends → whole command leaked into P13 path check | rego semantics | fixed (range(0,·)+`i>0` guard; opa test suite added) |

## File locations
- ERR-004..ERR-017: this directory
- ERR-001..ERR-003: `arabic-test-project/docs/errors/` (old-version project, Arabic)

## Template (use for new errors)
Each ERR-XXX.md file should contain:
- Type: bug / assumption / bypass / success / spec gap
- Discovered: date + session
- Description
- Root cause
- Fix / Mitigation
- Lesson
- New rule (if applicable)
