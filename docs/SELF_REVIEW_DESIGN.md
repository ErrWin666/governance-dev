# SELF_REVIEW_DESIGN — L0 "watchtower" (design finalized, NOT built)

> Status: **designed, not built.** Implementation deferred until after the
> pgen spec (Part B) and pilot work. This document records the finalized
> design and the owner's scope decisions. Nothing here is implemented.

## 1. What it is

`self-review` is a subagent role that checks Devin's own responses against
the governance philosophy (workflow-guard R1–R5) **before the response is
sent**. It is the enforcement mechanism for *truth-telling* in
governance-dev, where policy enforcement is deliberately suspended.

## 2. The boundary (owner decisions — semantic, not naming)

| | governance-dev (building the gate) | production projects (living behind it) |
|---|---|---|
| Flow-tier policies (P4a/b, P12, future P13) | **SUSPENDED** — enforcing them would halt the build | **ACTIVE** — all policies enforced |
| Safety-tier policies (P1,P2,P3,P4c,P5,P8,P9,P10, CI P6/P7) | **ACTIVE** — protect against catastrophic mistakes without blocking work | **ACTIVE** |
| Philosophy | enforced via `self-review` advisory only — only the owner halts | advisory AND findings attach to PR evidence bundles |
| Seeded violations | **1 scheduled per session + owner ad-hoc** | **ZERO — never shipped** |

Suspension carrier: `policies/.governance/dev-suspensions.json` —
P4(c)-protected → owner-only write. Containment walls: (a) copier template
excludes `.governance/`; (b) CI policy-lint rejects a non-empty suspensions
file in any production project; (c) CI lint rejects `is_suspended` references
outside the suspendable allowlist; (d) gate.log records active suspensions
per call — silent suspension is impossible.

## 3. The subagent

- **Input:** the draft response + read-only file access. Pre-send review —
  the only point where correction is free.
- **Cadence:** **EVERY response** (owner decision — risk-gating rejected;
  drift doesn't announce itself). Latency target ≤30s — the checklist is
  mechanical (pattern-match + file-reads), not open-ended reasoning.
- **Reviewer slow/failed:** draft still sends, marked
  `self-review: unavailable` + logged — a failed advisory check must not
  recreate lockout at the meta level.
- **Output:** findings = rule + quoted span + severity (must-fix/note) +
  required correction → back to drafting session + appended to
  `logs/self-review.log`.
- **Authority:** report + request rewrite **once**; cannot block; persistent
  disagreement escalates to owner with both positions.
- **Anti-theatrical:** must resolve ≥1 citation per response (forces real
  file reads); findings without quoted spans log as invalid; never-finds-
  anything for 3+ sessions gets flagged as suspect; seeded violations
  test it directly.

## 4. Checklist (C1–C7, all mechanical)

| # | Looks for | Pass | Fail action |
|---|---|---|---|
| C1 | claim terms (built/proven/works/complete/done/verified/running) | citation resolves on disk | must-fix: cite or rewrite "unverified" |
| C2 | "DONE/complete" on a stage | criterion evidence + zero gaps + approval row — all three | restate as actual status |
| C3 | decision-language on open questions | A-XXX cite or `AWAITING OWNER APPROVAL` tag | relabel as proposal |
| C4 | files cited as evidence | file exists AND contains claimed substance | report actual bytes vs claim |
| C5 | request items vs response coverage | every item marked done/deferred/blocked+reason | name the skipped item |
| C6 | "I verified" with no artifact | external artifact exists (log, eval, CI) | downgrade to "asserted" |
| C7 | deliverables beyond request scope | extras only under explicit proposal label | relabel or remove |

## 5. Placement and limits

- **Placement: L0** — watches the governor's speech; not a worker role (so
  not L5), not artifact-level (so not L4). It is workflow-guard R1–R5 with
  an independent executor, a log, and an escalation path.
- **Will miss:** semantic lies inside evidence files; side effects of tool
  calls; cross-response drift (partially covered by sweep); shared blind
  spots (same model family). "self-review: clean" is a lint result, never
  proof. Owner still personally reviews all irreversibles: approvals,
  transitions, merges, governance-file diffs, credential/CI changes.

## 6. Workflow (per response)

1. Devin drafts. 2. Draft → self-review. 3. Findings → corrected once,
   re-reviewed; still contested → owner arbitrates. 4. Clean → send.
5. Log line + marker shown: `self-review: clean | N corrected | unavailable`.

## 7. Seeded violations — scope (owner decisions recorded 2026-11-09)

- **Scope: governance-dev ONLY.** Production projects receive **ZERO**
  seeded violations: `seeds.json` ships only here, is absent from the
  copier template, and CI policy-lint rejects it in any production project.
- **Authoring: owner writes seeds** (assistant may help draft); Devin does
  NOT author them — authorship secrecy is the collusion-breaker.
  File: `policies/.governance/seeds.json` (owner-only write via P4c).
- **Cadence:** 1 scheduled seed per session + owner ad-hoc at will.
- **Verification:** `caught` field + `SEED`/`SEED-MISS` log lines + session
  sweep counts (planted/caught/missed).
- **On a miss:** SEED-MISS logged → sweep surfaces it → meta-review
  (checklist gap vs reviewer failure) → cadence doubles until 3 catches →
  ERR entry.
- **Rollback signal:** theatrical findings or 3 sessions of 100% catch with
  thin findings → fallback = transition-seeds + monthly audit; owner decides.

## 8. Devin commitments (recorded)

Commit: route every draft through self-review; cite resolvable evidence;
label proposals; name skipped steps; show the marker.
Refuse: write approvals without explicit owner "approve"; claim
done/proven/working without runtime evidence; pass checkpoints early;
edit gate.sh/.governance//config.json; delete evidence; author seeds.

## 9. Build prerequisites (when approved)

seeds.json (owner content) · self-review subagent profile ·
logs/self-review.log convention · sweep/health line · CI lint rules for
suspensions+seeds containment · dev-suspensions.json (owner writes).
