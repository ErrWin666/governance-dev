# GAPS — Exhaustive gap list (audit 2026-11-09)

> One section per layer. "Owner decision?" = yes means Devin cannot close it alone.
> IDs are referenced by RECOVERY_PLAN.md and the workflow-guard.

## L1 — Enforcement

| Gap ID | Missing | Why it matters | Workaround | Owner decision? |
|---|---|---|---|---|
| GAP-L1-01 | governance-dev ruleset #26818941 has admin bypass — owner pushes directly past required checks | The gate exists but the repo itself can bypass it (ERR-014) | Documented as dev-only exception; prod projects get strict rulesets | YES — keep dev exception or tighten |
| GAP-L1-02 | `devin -p --config` dormant bypass — blocked only by CLI auth wall | One auth state flips a full bypass (ERR-009) | Detection only | YES — accept risk or restrict CLI auth |
| GAP-L1-03 | `permissions.deny` is dead code | Anyone relying on it has no protection (ERR-008) | Never rely on it — documented | no |
| GAP-L1-04 | Local exec of destructive commands — detectable not preventable | Fail-open seam in the Devin hook contract | Audit log review; Managed Devins at L5 | YES — accept or isolate work |
| GAP-L1-05 | WSL/cygheap/hook crash → fail_closed locks the owner out | Proven live today: hook crash (`-1073741502`) blocked a plain `read` | Manual recovery (STATE.md §7) | YES — accept fragility or invest in watchdog |
| ~~GAP-L1-06~~ ✅ CLOSED | gate.sh P12 env wiring + p4 `lower()` fix — committed 82874be | — | — | — |
| GAP-L1-07 | P6/P7 exist only on ci-test + governance-dev | No governed real project yet (that is L6) | none — blocked by L6 | no |
| GAP-L1-08 | P4 anomaly: 10:39:25 deny cited missing `evidence/p3/manifest.json` while the file existed | Current policy set verified correct via `opa eval`, but the historical deny is unexplained — possible transient mid-edit state | re-test needed to close | no |
| GAP-L1-09 | Supply-chain dep check + obfuscated-secret detection uncovered | Documented holes (ROADMAP §6) | deferred by design | YES — when to schedule |

## L2 — Quality

| Gap ID | Missing | Why it matters | Workaround | Owner decision? |
|---|---|---|---|---|
| GAP-L2-01 | SonarQube unconfigured: admin 401 (owner password), S1 gate conditions / S2 custom rules / S3 S2068 untouched; S4 GitHub link impossible (localhost) | Listed in STATE.md §1 as working; it contributes zero gates today | none — dormant | YES — configure or formally defer |
| GAP-L2-02 | D1 JS/TS adapter never tested on a real JS project | "L2d proven" claim only covers Python | D2 covers Python | YES — pick a JS test project or defer |
| GAP-L2-03 | D3 Go adapter never tested | same | none | YES — pick a Go test project or defer |
| GAP-L2-04 | arborist-metrics install failed (404) → radon substitute | B2 semantics differ from the planned tool | radon cc≤15 documented (ERR-015) | no |
| GAP-L2-05 | muti install failed (junk package) → mutmut/Stryker | A5 JS needs per-project stryker.conf — silently skips without it | mutmut for Python works | no |
| GAP-L2-06 | polyscan does not support Python | B3 coupling/cohesion has no Python coverage | deferred to L2d per ROADMAP | YES — accept or find Py tool |
| GAP-L2-07 | pyscn is a pip package, not the planned Go binary | Works — cosmetic vs plan | documented (ERR-015) | no |
| GAP-L2-08 | A6 diff-coverage only runs for Python (+JS if jest); Go/others skip | Coverage gate is uneven per language | documented limits | no |
| GAP-L2-09 | A1 function-size is a brace heuristic for non-Python | Can miss/overshoot vs exact parse | documented limit | no |
| GAP-L2-10 | A3 scans whole changed file, not just the diff | Pre-existing violations fail the PR — intentional but noisy | fail-closed by design | no |
| GAP-L2-11 | L2c skills are advisory-only; nothing tracks whether findings are acted on | Advisory findings can be silently ignored | by design | YES — keep advisory or gate on findings |

## L3 — Planning

| Gap ID | Missing | Why it matters | Workaround | Owner decision? |
|---|---|---|---|---|
| ~~GAP-L3-01~~ ✅ CLOSED | spec/tasks restored to real committed content | — | — | — |
| ~~GAP-L3-02~~ ✅ CLOSED | stub-certifying .approved hashes deleted; spec is unapproved until owner records A-003 | — | — | — |
| GAP-L3-03 | No approvals/approval.md entry records the pgen spec/tasks approval | plan/README flow requires a record; hash files alone are not owner approval | add A-003 entry | YES |
| GAP-L3-04 | Cold-session resume never tested (ERR-016) | This IS the ROADMAP L3 completion criterion — L3 cannot be called done without it | manual owner test | YES — run a fresh session |
| GAP-L3-05 | spec-writer/task-decomposer skills never produced a verified real spec | "Skills loaded" ≠ "skills produce good output" | none | no |
| ~~GAP-L3-06~~ ✅ CLOSED | evidence/P3/manifest.json restored from git (full Phase-3 proof) | — | — | — |
| GAP-L3-07 | `current_phase=P4` but the pilot has no code (`src/` empty) | Phase marker is ahead of reality — P4's evidence check guards a phase that never happened | reset marker to P0 (owner-only file) | YES |
| ~~GAP-L3-08~~ ✅ CLOSED | all L3 work committed (82874be + a7422f0) | — | — | — |
| GAP-L3-09 | The pgen pilot never produced working software — L3 loop never ran end-to-end | Mechanism proven, lifecycle unproven | resume pilot or archive it | YES |

## L4 — Verification

| Gap ID | Missing | Why it matters | Workaround | Owner decision? |
|---|---|---|---|---|
| GAP-L4-01 | Entire layer: verifier, skeptic, attacker roles | **Clever Hans is unguarded — the stated core gap** | A5/B5 mutation gates only | YES — when to start (after gaps close) |
| GAP-L4-02 | antemortem / citation lint not installed | No fabricated-claim detection exists | none | no |
| GAP-L4-03 | verdict.json / in-toto evidence format not implemented | Manifests remain self-asserted JSON (REASSESSMENT top gap #1) | none | no |
| GAP-L4-04 | Mutation-gate-on-touched-tests at L4 scope | Decided (Q9), not built — partially covered by A5/B5 | L2 mutation gates | no |
| GAP-L4-05 | No verifier input contract implementation | ROADMAP §9-3 default never implemented | none | no |

## L5 — Orchestration

| Gap ID | Missing | Why it matters | Workaround | Owner decision? |
|---|---|---|---|---|
| GAP-L5-01 | No coordinator, no role profiles, no Managed Devin usage | Implementer self-approval hole stays | owner reviews everything manually | YES — start only after L4 |

## L6 — Deployment

| Gap ID | Missing | Why it matters | Workaround | Owner decision? |
|---|---|---|---|---|
| GAP-L6-01 | No copier template, no `deploy/profiles/{small,medium,erp}.yaml`, no sync | Everything stays a governance-dev demo | manual copying | YES — after L5 per roadmap, or earlier if owner reprioritizes |
| GAP-L6-02 | Repo not template-ready: `ci-test/`, `old-version/`, Arabic test project, root test artifacts inside the tree | Template would copy debris | `.gitignore`/cleanup needed first | no |

## Cross-cutting / constitution

| Gap ID | Missing | Why it matters | Workaround | Owner decision? |
|---|---|---|---|---|
| GAP-X-01 | GOVERNANCE_SPEC not at v1.2 — file header says v1.0 while STATE.md calls it v1.1 | The constitution's own version is already false | update at end per roadmap | no |
| ~~GAP-X-02~~ ✅ CLOSED | tree committed; only owner-file `current_phase` remains untracked | — | — | — |
| GAP-X-03 | approval.md holds only A-002; README references A-001 that does not exist; approvals are interim text (ERR-001 mechanism) | Approval record is thinner than the docs imply | keep A-XXX discipline | no |
| GAP-X-04 | No runbook/how-to docs (Diátaxis gap, REASSESSMENT §3) | Ops knowledge lives in STATE.md §7 only | none | no |
| GAP-X-05 | No guard against agent overclaiming / phase-jumping | The exact failure mode that triggered this audit | `workflow-guard` skill + WORKFLOW_GUARD.md created today | no — created this session |

## Self-review (L0)

| Gap ID | Missing | Why it matters | Workaround | Owner decision? |
|---|---|---|---|---|
| GAP-SELF-01 | self-review subagent not built — design finalized (docs/SELF_REVIEW_DESIGN.md), implementation deferred until after Part B + pgen | Philosophy enforcement in governance-dev currently rests on Devin's self-check — the same party it audits | workflow-guard skill (advisory, self-invoked) | YES — build after pgen per owner order |
| GAP-SELF-02 | seed bank not yet authored by owner | The only mechanism keeping the reviewer honest cannot exist until owner writes seeds.json | none | YES — owner authors |
