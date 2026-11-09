# RECOVERY_PLAN — close every gap, in order

> Rule of this plan: one gap at a time, in priority order. A gap is closed
> only when its evidence exists. No new layer starts while any earlier-layer
> gap is open. Each step lists: what to do, how to verify, when it's done.

## Stage 0 — Make the working tree truthful (blocks everything)

**S0-1** Restore `evidence/P3/manifest.json` from git (`git checkout` that file or re-write the committed content). Closes GAP-L3-06.
- Verify: file matches the committed blob; STATE.md citation is true again.
- Done when: `git diff evidence/P3/manifest.json` is empty.

**S0-2** Decide the pgen stub fate (owner decision — GAP-L3-01/02/03). Options:
(a) restore the real spec/tasks from commit `f02b97a` and regenerate
`.approved` hashes + add the missing approval record; (b) keep the stubs and
record an honest approval entry anyway.
- Verify: `plan/spec.md` has real content or owner explicitly accepts stubs;
  `approvals/approval.md` has an A-XXX entry covering it.
- Done when: hash files certify content a human would call a spec, AND the
  approval is recorded — not hash-only.

**S0-3** Commit the L3 wiring (GAP-L1-06, GAP-L3-08): gate.sh env block, p4
`lower()` fix, STATE.md updates — each with its unplanned edits reviewed
(comment stripping, etc.). Owner reviews the diff first (P4-protected files).
- Verify: `git status` clean for governance files; gate still denies/allows
  correctly post-commit.
- Done when: no governance change lives only in the working tree.

**S0-4** Correct the status docs (GAP-X-01/02): fix STATE.md's overclaims
(L2d, SonarQube placement, P3 citation, "P1–P11"), note GOVERNANCE_SPEC's
real version. Do NOT write v1.2 yet — just stop the drift.
- Done when: no line in STATE.md asserts something AUDIT_CURRENT_STATE.md
  marks unproven.

## Stage 1 — Prove L3 actually completes (ROADMAP criterion)

**S1-1** Clean re-test of the 10:39 anomalies (GAP-L1-08): one positive
(approved env → src/ write allowed) and one negative (manifest missing →
P4 deny) through the real hook, logged in gate.log.
- Done when: both outcomes reproduced and recorded under `evidence/`.

**S1-2** Cold-session resume test (GAP-L3-04): owner opens a fresh session
with no context, invokes `plan-resume`, and judges whether it reports the
true state (stub spec, P4 marker, empty src/) without prompting.
- Done when: the cold session reconstructs status from files alone — the
  ROADMAP L3 criterion. Owner decides pass/fail.

**S1-3** Decide the pilot's fate (GAP-L3-07/09): implement pgen through the
full loop (spec→approve→tasks→approve→code→L2 gates→merge) or archive it and
reset `current_phase`.
- Done when: either a real merged PR exists that walked the whole pipeline,
  or the pilot is formally closed.

## Stage 2 — Close L2 proof gaps

**S2-1** D1 test (GAP-L2-02): run `quality-gate-perlang` against a real JS/TS
change — the ci-test repo or a seeded PR on governance-dev.
- Done when: D1 fires correctly on one bad and one clean JS change.

**S2-2** D3 test (GAP-L2-03): same for Go, or formally defer Go coverage with
an owner decision.
- Done when: proven or explicitly deferred.

**S2-3** SonarQube decision (GAP-L2-01): owner either supplies the password
and configures S1–S3, or SonarQube is removed from STATE.md §1 and deferred
to ERP scale.
- Done when: configured and gating, or honestly documented as dormant.

## Stage 3 — Then, and only then, L4

Per ROADMAP §2 criterion: seeded fabricated file:line citation flagged on a
test PR. Owner approval entry required before starting (R1).

Then L5 (role pipeline on one real feature), then L6 (copier template +
profiles), then GOVERNANCE_SPEC v1.2 last — so the spec audits what exists.

## Gate criteria (after each step)

Before moving to the next step, all must be true:
- the gap's evidence file exists under `evidence/` (or is a recorded owner
  decision in `approvals/approval.md`),
- the verification ran against the real mechanism, not a description of it,
- `git status` shows the change committed,
- docs updated to match reality.

## Final check

Before ANY new layer starts: `docs/GAPS.md` shows zero open gaps in all
earlier layers, the roadmap criterion for the finished layer is met by
evidence, and the owner has an approval entry authorizing the transition.
The `workflow-guard` skill enforces this on every request.
