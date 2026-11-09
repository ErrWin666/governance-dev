# 08 — Crosscutting Concepts (arc42 §8)

## Security

- **fail_closed mandatory** — every PreToolUse hook runs with
  fail_closed:true; any hook failure or timeout blocks the call (ADR-002)
- **Self-protection (P4)** — gate.sh, *.rego, .governance/*, config.json and
  mcp_config.json are read-only through agent tools; the agent cannot edit
  the layer that governs it (ADR-003)
- **Dormant bypass** — `devin -p --config` spawns a governed-config-free
  subprocess; mitigated only by never running `devin auth login` (ERR-009)
- **No permissions.deny** — proven dead code; all denies live in Rego
  (ADR-005, ERR-008)
- **Honest gaps** — unprotected seams are listed in STATE.md §2, not hidden

## Logging and audit

gate.log is the audit spine — append-only, one row per event:

| Marker | Meaning |
|---|---|
| `PWD-PROOF cwd=...` | every call: timestamp + working directory of the payload |
| `DENY <reasons> input=<payload>` | blocked call with policy reason codes (e.g. P1-GOVERNANCE-FILE) |
| `GOV_GATE_DOWN` | gate failure (opa-not-found, nonzero rc) — visible, never masked |
| `FORK-RETRY` | fork retry after transient failure (ERR-007 mitigation) |

PostToolUse hook adds the second half of the ledger: tool_response +
tool_use_id for every executed call. Match policies on the *logged*
tool_name — MCP calls log as `mcp__<server>__<tool>`, find_file_by_name as
`glob` (ERR-005, ERR-006).

## Error handling

- Hook contract: exit 0 = allow, 2 = block, other = logged-not-blocking —
  **unless** fail_closed:true, which makes any non-2 exit a block and counts
  timeout as failure
- gate.sh retries OPA once after 100 ms on fork failure, then returns
  GOV_GATE_DOWN (fail closed) — instability is logged, not masked
- Worst case: gate down + fail_closed = owner locked out of all tools.
  Recovery is manual, outside Devin (STATE.md §7): edit config.json in
  Notepad, restore config.json.bak-failclosed, or `wsl --shutdown`

## Policy enforcement

- Single PDP: main.rego aggregates every `deny` from P1–P5 into
  `decision := {allow, reasons}` — one evaluation, one verdict
- Catch-all: P5 denies any tool_name absent from
  policies/.governance/tool-inventory.txt — unproven territory defaults to
  deny (ERR-006); owner exception path: approvals/approval.md → append name
- Denies are proven, not assumed: P1 block of `wsl -u root` is recorded in
  gate.log; Rule 27 requires a base-case proof for any deny mechanism

## Test freeze (evidence integrity)

- tests.lock records SHA-256 of each frozen test file; P2 denies edits to
  locked files (new test files allowed)
- CI re-verifies the freeze: required check "Verify test files are frozen"
  on ruleset protect-main — local freeze + remote verification (ADR-004)
- CODEOWNERS extends freeze protection to tests.lock, *.test.js, and
  .github/ so the agent cannot edit the check that checks it
