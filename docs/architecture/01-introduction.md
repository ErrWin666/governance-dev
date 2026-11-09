# 01 — Introduction and Goals (arc42 §1)

## Purpose

A governance system for AI coding agents (Devin). It intercepts every agent
tool call before execution, evaluates it against OPA policies, audits every
call, and backs local enforcement with CI-based enforcement on GitHub. It
exists because an agent that can execute arbitrary commands and edit any file
cannot be the final authority on what it is allowed to do — enforcement must
live outside the agent's discretion. Built first as a working system, it will
later be applied to large projects (ERP, warehouse management).

## Functional requirements

- Intercept every agent tool call pre-execution (PreToolUse hook) and return
  allow/deny
- Evaluate all calls against OPA policies P1–P5 (deny wsl root, test-edit,
  secrets, evidence/self-protection, unrecognized tool)
- Audit every call with timestamped rows (gate.log) plus a PostToolUse audit
  layer carrying tool_response + tool_use_id
- Block all tool calls when the gate itself fails (fail_closed: true)
- Freeze test evidence (tests.lock) and verify it in CI before merge

## Quality goals (ranked)

1. **Safety — no silent bypass.** Every failure mode must block, never
   silently pass (fail_closed proven, ERR-010)
2. **Detectability.** What cannot be prevented must be logged and listed as
   an honest gap (STATE.md §2)
3. **Verifiability.** Every claim must be proven by a test or log row, never
   asserted (ERR-008 → Rule 27)
4. **Proportionality.** One hook, five policies — not 44 hooks. Mechanism
   cost must stay below the risk it controls

## Stakeholders

| Stakeholder | Role | Concern |
|---|---|---|
| Owner (non-technical) | Operates and recovers the system | Recovery must work via Notepad/PowerShell, no dev tooling |
| Devin agent | The governed party; also edits docs | Cannot weaken its own governance (P4, ADR-003) |
| GitHub | External enforcement platform | Required checks, rulesets, CODEOWNERS (ADR-004) |
