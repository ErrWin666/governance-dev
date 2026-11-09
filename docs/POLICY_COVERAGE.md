# POLICY_COVERAGE — spec rules vs actual enforcement (audit 2026-11-09)

> Owner's principle (VISION §4): "What is not machine-enforced is not a rule —
> it is a suggestion." This map scores every spec rule against that bar.
> Sources: GOVERNANCE_SPEC.md v2.3 rules 1-30 + mechanisms M1-M9, policies/*.rego,
> .github/workflows/, gate.log fire counts.

## Rules 1–30 (non-negotiable; 21 retired)

| Rule | Enforced by | Status | Gap / action |
|---|---|---|---|
| 1 No self-review | — | ❌ none | L4 Verifier role — biggest missing piece |
| 2 No claim w/o evidence | P4 + workflow-guard | 🟡 partial | manifests enforced; claims check advisory-only |
| 3 No editing tests | P2 + tests.lock + CI | ✅ enforced | exec bypass (L1-10) |
| 4 No hardcoded secrets | P3 + P7 gitleaks | ✅ enforced | exec bypass; obfuscation (L1-09) |
| 5 file ≤400 / class ≤300 | A1 | 🟡 partial | class-size unimplemented (GAP-L2-12) |
| 6 function ≤40 | A1 | ✅ enforced | — |
| 7 no variable duplication | SonarCloud advisory | 🟡 advisory | SonarQube dormant (L2-01) |
| 8 coverage ≥80% | A6 + D2 | ✅ enforced | — |
| 9 no silent spec change | P12 sha256 seals | ✅ enforced | exec bypass |
| 10 coordination-log | — | ❌ none | needs L5 coordinator; file doesn't exist |
| 11 error registry | docs convention | 🟡 partial | spec wants CI check: each ERR → regression test — unbuilt |
| 12 phase contract | P4a partial | 🟡 partial | `phase-contracts/` files never created (M1) |
| 13 owner sign-off | approval.md + merge | ✅ enforced | — |
| 14 consult KB first | convention | 🟡 partial | `knowledge/` doesn't exist; docs/research is proxy |
| 15 no rewriting existing | convention | 🟡 advisory | no mechanism |
| 16 no over-engineering | advisory | 🟡 advisory | judgment rule |
| 17 CI-only evidence | rulesets required checks | ✅ enforced | — |
| 18 local = detection not prevention | A-002 + audit log | ✅ by design | exec bypass is this clause's cost (L1-10) |
| 19 `size:` in phase contract | — | ❌ none | no phase contracts exist yet |
| 20 build phases → M8 | approval.md | ✅ enforced | — |
| 22 central config module | — | ❌ none | A3 magic-nums is adjacent only |
| 23 structured logging | A8 (added lines) | 🟡 partial | scans diffs not whole files; no logger required |
| 24 no phase-jumping | P4b + P12 + guard | ✅ mostly | phase marker itself is owner-honored |
| 25 resumable pause | plan/ + STATE.md | ✅ proven | cold-resume test passed 2026-11-09 |
| 26 logic verified | logic-flow skill + mutmut | 🟡 advisory | no hard gate on logic review |
| 27 tests obey code limits | A1 | ✅ enforced | — |
| 28 no circular deps | B1 dep-cruiser + lint-imports | 🟡 degraded | importlinter.ini deleted → Py contracts = 0 (GAP-L2-13); JS needs .dependency-cruiser.js |
| 29 review loops converge | — | ❌ none | v2.3 rule, no mechanism |
| 30 review cycles measured | — | ❌ none | v2.3 rule, no mechanism |

## Mechanisms M1–M9

| Mech | Status | Gap |
|---|---|---|
| M1 phase contract | ❌ | `phase-contracts/` + `size:` never implemented (rules 12/19) |
| M2 evidence bundle | ✅ | — |
| M3 frozen spec | ✅ variant | spec.approved hash (not spec.lock) — works |
| M4 test freeze | ✅ | — |
| M5 policy gate | ✅ | exec bypass (L1-10) |
| M6 security scan | 🟡 | gitleaks live; SonarQube dormant; ZAP/dep-audit missing (L1-09) |
| M7 error registry | 🟡 | docs exist; CI "ERR→test" check missing |
| M8 owner approval | ✅ | — |
| M9 knowledge base | 🟡 | docs/research proxy; `knowledge/`+index.json unbuilt |

## What must be ADDED to the policy set (ordered)

1. **p13_exec_write_paths.rego** — inspect `exec` commands for write
   operators (`>` `>>` `tee` `sed -i` `cp` `mv` `dd` `git checkout/restore`)
   against protected paths → closes GAP-L1-10's worst surface.
   Heuristic: documented as raiser-of-bar, not seal.
2. **Add `notebook_edit` to P4 + P8 tool lists** — one-line each (GAP-L1-11).
3. **Extend P10 to exec** outbound patterns (curl/wget/scp/nc) — exfil seam.
4. **opa test suite** (`policies/test/*.rego` deny-vectors) + CI step —
   semantic regression for every policy; prevents silent drift (L1-08 class).
5. **Integrity verify at gate**: gate.sh already hashes spec/tasks; extend to
   policies/*.rego lock so exec-tampered policies are detected at next call
   (detection-tier fix per rule 18).
6. **Class-size check in A1** (rule 5) — GAP-L2-12.
7. **ERR→test CI check** (M7 verification half).
8. **Review-cycle counter** for rules 29/30 — count commits/comments per PR,
   >3 escalates; natural fit in quality-gate summary step.
9. **Real Python dep contract** for rule 28 — needs an actual package first;
   until then B1/D2 Python = skip (GAP-L2-13).
10. **Phase-contract files + `size:` field** (M1/rules 12/19) — structural,
    not a .rego; needs the phase-contract convention implemented.
