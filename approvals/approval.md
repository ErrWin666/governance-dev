# approvals/approval.md — Governance-level owner decisions

| # | Date | Decision | Details |
|---|---|---|---|
| A-002 | 2026-11-09 | APPROVED: GOVERNANCE_SPEC.md v1.1 clauses 17, 18, 19, 20 | Clauses: (17) CI is the only pass/fail evidence source; (18) local execution = detection not prevention; (19) `size:` field mandatory in phase contracts; (20) build phases follow M8. Procedural note: recorded as a standard M8 decision — clause 20 not yet active at the time of this approval; becomes active from B1 onwards. DEFERRED: B6 integration target — owner will decide after B5 completes and is reviewed. Candidates (uncommitted): mail-assistant, n8n-yahoo, lint-clean-copy, app, or new project. |

Owner: approved in-session, 2026-11-09 (text approval — per ERR-001 interim mechanism)

| A-003 | 2026-11-09 | APPROVED: pgen plan/spec.md + plan/tasks.md | Owner approved the pilot spec and task list verbally in-session (per ERR-001 interim mechanism). sha256 seals generated: plan/spec.approved, plan/tasks.approved. Execution held pending owner-requested tools discussion. |

Owner: approved in-session, 2026-11-09 (text approval — per ERR-001 interim mechanism)

| A-004 | 2026-11-10 | ACCEPTED/CLOSED/DEFERRED: L1 gaps — L1 sealed | L1-01 admin bypass: ACCEPTED dev-only exception, prod strict (ERR-014).<br>L1-02 `devin -p` dormant bypass: ACCEPTED — mitigated by no-auth-login.<br>L1-04/L1-10 exec seam: ACCEPTED residual — p13 AST layer + policies.lock (PRs #6/#7); interpreter evasion detection-only per clause 18.<br>L1-05 hook/WSL crash lockout: ACCEPTED — recovery documented STATE.md §7.<br>L1-09 supply-chain dep check: CLOSED — osv-scanner CI shipped (PR #7).<br>L1-12 exec exfil: CLOSED — P10 exec outbound rules shipped (PR #7).<br>L1-07 P6/P7 unproven on real project: DEFERRED — blocked by L6. |

Owner: approved in-session, 2026-11-10 (text approval — per ERR-001 interim mechanism)

| A-005 | 2026-11-10 | ACCEPTED/DEFERRED: L2 residual — L2 sealed | D1 JS: DEFERRED — no package.json; activates on first governed JS project.<br>D3 Go: DEFERRED — same.<br>SonarQube local: DECLARED DORMANT — SonarCloud advisory already runs.<br>L2-13 Python dep contracts: DEFERRED — needs real package (L6).<br>L2-18 naming: DEFERRED — per-language config on real project.<br>L2-19 process cycles/deadlock: DEFERRED — blocked by L4/L5; A9 gives early signal. |

Owner: approved in-session, 2026-11-10 (text approval — per ERR-001 interim mechanism)