---
name: workflow-guard
description: Enforces L1-L6 workflow discipline against any agent (including the owner's assistant). Blocks phase jumps, "done" claims without evidence, decisions made on the owner's behalf, skipped steps, and uncited progress claims. Use on EVERY request to do work — before acting, check the request against rules R1-R5 and either allow it or emit a WORKFLOW-VIOLATION block. Pairs with docs/WORKFLOW_GUARD.md (rule definitions) and docs/GAPS.md (current gap state).
allowed-tools: read grep
---

# Workflow Guard (advisory check — runs before any work request)

## Inputs

- The incoming work request.
- `docs/GAPS.md` — which gaps are open per layer.
- `docs/AUDIT_CURRENT_STATE.md` — honest per-layer status.
- `approvals/approval.md` — what the owner has actually approved.
- `evidence/` — what has actually been proven.

## The rules

- **R1** — No phase transition without: all current-phase gaps closed in
  GAPS.md + evidence file in `evidence/` + owner entry in
  `approvals/approval.md`.
- **R2** — No "complete/done/proven" claim without: evidence file + PASS
  verdict + owner confirmation.
- **R3** — No decisions except the owner's. Proposed decisions are labelled
  `AWAITING OWNER APPROVAL`; dependent work is blocked.
- **R4** — No skipped required steps. If a step is missing: STOP and report.
- **R5** — Progress claims must cite `file:line` or an artifact path.
  Uncited = unproven.

## Method

1. Classify the request: does it (a) start a new phase/layer, (b) claim
   something is done, (c) make a decision, (d) omit a required step, or
   (e) assert progress without a citation?
2. For each match, check the rule:
   - Phase work → verify the preceding phase is complete per GAPS.md,
     evidence exists, and an approval entry covers the transition (R1).
   - Completion claim → look for the evidence file, the verdict, the owner
     confirmation (R2). "File exists" is not "proven".
   - Decision embedded in a request → flag it; mark AWAITING OWNER APPROVAL;
     refuse dependent work (R3).
   - Skipped step → name the missing step and stop (R4).
   - Progress claim → require a citation; downgrade uncited claims to
     "unverified" in your own response (R5).
3. Audit/documentation requests (like this audit) are exempt from R1/R2 —
   they change no phase state — but must still obey R3/R5.

## Output — exactly one of

```
WORKFLOW-VIOLATION DETECTED
Rule: R<n>
Evidence: <what was said vs what the rule requires>
Required action: <what must happen first>
I will NOT proceed until: <specific blocker resolved>
```

or `OK to proceed` followed by the work — with evidence citations for any
status asserted.

## Limits

This skill instructs the agent; it does not hard-block like an OPA policy.
If stricter enforcement is wanted, the same checks could be encoded as a
PreToolUse `.rego` policy or a CI lint on claims-vs-evidence — that is a
proposal for the owner, not built.
