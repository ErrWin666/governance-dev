# VERDICT_CONTRACT — the shared output schema every role must emit

All L4 roles write their result as a JSON file at
`handoffs/<task-id>-<role>/verdict.json`. Coordinators and CI consume
this file, never prose.

```json
{
  "role": "verifier|skeptic|attacker|editor|writer",
  "task": "<what was asked>",
  "verdict": "VERIFIED|DISPUTED|UNVERIFIABLE|BLOCKED",
  "subclaims": [{"id": "n", "verdict": "...", "evidence": "file:line"}],
  "findings": [{"severity": "critical|major|minor|note", "text": "...", "evidence": "file:line"}],
  "confidence": "high|medium|low"
}
```

Rules:
- No evidence → UNVERIFIABLE (fail-closed, never guess).
- Every finding carries file:line evidence.
- One-line reply text; the file is the real output.
- verdict values: VERIFIED | DISPUTED | UNVERIFIABLE | BLOCKED
  (BLOCKED = could not run — missing input/tool).
