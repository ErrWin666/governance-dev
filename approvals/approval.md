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

| A-006 | 2026-11-10 | RESOLVED: SonarQube local superseded | SonarCloud runs on every PR (advisory, evidence: PRs #6/#7/#8) — local SonarQube installation declared unnecessary. No credentials stored. |

Owner: approved in-session, 2026-11-10 (text approval — per ERR-001 interim mechanism)

| A-007 | 2026-11-10 | RATIFIED: current_phase=B6 + resume-test verdict | Owner set current_phase B6 (post-B5 pilot, pre-L6 decision). Cold-resume test PASSED — drift items fixed same day; L3-08 seal-forgery logged as open gap. |

Owner: approved in-session, 2026-11-10 (text approval — per ERR-001 interim mechanism)


| A-008 | 2026-11-10 | DEFERRED: L3 residual — L3 sealed | L3-05 spec-writer unproven: DEFERRED — proof point = the L4 spec itself (written via the skill + verified).<br>X-03 A-001 record, X-04 runbook: DEFERRED to L4 governance-docs pass.<br>X-05 workflow-guard advisory: ACCEPTED (advisory by design).<br>L3-08 seal-forgery: CLOSED via P14 (PR #10). L3-04 resume: CLOSED (passed). |

Owner: approved in-session, 2026-11-10 (text approval — per ERR-001 interim mechanism)

| A-009 | 2026-11-10 | ACKNOWLEDGED: L4.4+L4.5 adversarial reviews | Verifier/Skeptic/Attacker all DISPUTED exec-gate completeness — 15+9 holes found, criticals fixed (9b29641, 9a30751); documented residuals are clause-18 detection-tier. Armed attacker proved SAST (semgrep, 690 rules) misses logic holes the agent found. |

Owner: approved in-session, 2026-11-10 (text approval — per ERR-001 interim mechanism)

| A-010 | 2026-11-10 | BATCH: L1–L4 residual disposition — owner signs once | **Closed by fix**: L1-11 notebook_edit (verified in all 8 policies), L3-08 P14, X-04 runbook shipped, L4-03 verdict contract, #9 README rewritten + R1 src/ exec barrier = HARD (documented).<br>**Acknowledged as accepted/deferred**: L1-01 admin bypass (dev repo), L1-02 CLI auth, L1-04/05 exec+hook residuals, L1-10/12 exec+exfil residual tier, L2-01 SonarQube (now in tool-adoption plan), L2-02/03 JS+Go adapters deferred to L6 project, L3-03 A-001 never recorded — historical, noted here as record, L3-07 current_phase=B6 correct per A-007, X-03 closed by this row, X-06 conventions accepted, L4-04 mutation-gate stays at L2 scope, SELF-01/02 await L5+owner seeds, R3 profile-enforcement test = fresh-session task, R4 self-reseal + R5 indirection = L5 scope.<br>**L1–L4 status after this row**: every gap is either closed-with-evidence or owner-acknowledged residual. |

Owner: approved in-session, 2026-11-11 (text approval — per ERR-001 interim mechanism)