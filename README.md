# Governance System

A governance layer for AI coding agents (Devin). It intercepts every agent
tool call before execution, evaluates it against OPA policies, audits every
call, and backs local checks with CI enforcement on GitHub. It exists to
protect projects from agent errors: modified tests, leaked secrets,
self-edited governance, and unproven claims. Used by a solo owner +
Devin agent; designed to later govern large projects (ERP, warehouse
management).

## Status

**Operational** — local gate (PreToolUse → WSL gate.sh → OPA P1–P5) and
fail_closed proven; CI enforcement proven on the ci-test repo.
Documentation in progress (Phases 1–6, see STATE.md §5).
Details: [STATE.md](STATE.md).

## Quick start (owner returning after a break)

1. Read STATE.md §1 (what works) and §5 (next steps) — 2 minutes
2. If a governance file needs editing, read STATE.md §7 (recovery) first
3. For architecture questions, start at
   [architecture/AGENTS.md](architecture/AGENTS.md)
4. For "why was X done?", read [architecture/adr/](architecture/adr/)

## What this protects against

- Agent modifying frozen tests to make broken code pass (tests.lock + P2 +
  CI check)
- Agent editing its own governance files (P4 self-protection, ADR-003)
- Silent bypass when the hook fails (fail_closed:true, proven — ERR-010)
- `wsl -u root` escaping every file/exec boundary (P1, blocked in gate.log)
- Secrets written into files, commands, or MCP payloads (P3)
- Tool calls outside the verified inventory (P5 catch-all)

## What this does NOT protect (honest limits — STATE.md §2)

- `devin -p --config` — dormant bypass, armed by `devin auth login`
  (ERR-009)
- `permissions.deny` — dead code, never relied upon (ERR-008)
- Local destructive exec — detectable in the audit log, not preventable
  (fail-open seam in Devin's hook contract)
- WSL cold start / crash — fail_closed blocks everything but locks the
  owner out; recovery is manual

## Structure

    C:/governance-dev/
    ├── README.md                     ← this file
    ├── STATE.md                      ← current status (read §1, §5, §7)
    ├── approvals/approval.md         ← owner decisions (A-001, A-002...)
    ├── architecture/                 ← C4 + ADRs (start at AGENTS.md)
    ├── ci-test/                      ← working copy of the CI testbed repo
    ├── docs/
    │   ├── errors/                   ← ERR index (lessons learned)
    │   ├── specs/GOVERNANCE_SPEC.md      ← the constitution (v1.1)
    │   ├── plans/GOVERNANCE_BUILD_PLAN.md ← build plan
    │   └── governance-file-recovery.md
    ├── logs/gate.log                 ← audit trail (+ b1.0 test logs)
    ├── policies/                     ← OPA gate + P1–P5 (.rego)
    │   ├── gate.sh
    │   ├── main.rego
    │   ├── p1..p5_*.rego
    │   └── .governance/tool-inventory.txt
    ├── scripts/apply-governance-acl.ps1
    ├── backups/                      ← pre-ACL snapshot
    └── old-version/, مشروع اختبار/   ← earlier Arabic project
                                        (holds ERR-001..003)

## Key concepts

19 terms defined in
[architecture/12-glossary.md](architecture/12-glossary.md).

## How to read the docs (proportional reading)

Do NOT read everything. Use this order:

- **First visit:** this README (5 min) → architecture/AGENTS.md (2 min)
- **Resuming after a break:** STATE.md §1, §5, §7 (5 min)
- **Before a governance change:** architecture/adr/ (10 min)
- **Debugging / "why is X like this?":**
  [docs/errors/README.md](docs/errors/README.md) (5 min)

## Sources (external)

- Devin CLI docs: https://docs.devin.ai
- OPA: https://openpolicyagent.org
- MADR: https://adr.github.io/madr
- arc42: https://arc42.org
- C4 model: https://c4model.com

## Last updated

2026-11-08
