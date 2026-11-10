# TASK — Editor / Independent Writer (L4.4)

Write the final report on the exec-write protection review.
You did NOT participate in implementation — use ONLY these evidence files:

- handoffs/l4-4-verifier/verdict.json
- handoffs/l4-4-skeptic/verdict.json
- handoffs/l4-4-attacker/verdict.json (+ poc/ files)
- roles/VERDICT_CONTRACT.md (for format reference)

Produce `handoffs/l4-4-editor/OUTPUT.md`:
1. Verdict summary per role (one line each + evidence pointer)
2. Confirmed holes list — merged/deduped across roles, severity-ordered
3. What IS proven to work (from evidence only)
4. Recommended fix order (critical first) — from the findings, not opinion

Every claim must trace to a file:line in the evidence. Then write
handoffs/l4-4-editor/verdict.json (VERIFIED if every claim traced).
Reply: one line.
