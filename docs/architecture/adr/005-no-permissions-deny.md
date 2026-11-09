# ADR-005: Do not rely on Devin's permissions.deny (dead code)

## Status
Accepted

## Context
ERR-008 documented that `permissions.deny` rules in config.json do not
block tool execution. Even the un-evaded base case — plain `rm probe.txt`
under an `Exec(rm)` deny rule — executed. All 4 payloads tested (plain rm,
`;`-chained, `bash -c`, `$var` expansion) ran despite the deny. A deny
mechanism that never fires is worse than none: it manufactures false
confidence.

## Decision
Never use `permissions.deny` in config.json as an enforcement mechanism.
All command-level denies go through gate.sh + OPA policies, which are
proven to fire (P1 blocked `wsl -u root`, recorded in gate.log).

## Consequences
**Positive:**
- No false sense of security — every relied-upon deny is one we have
  empirically watched block
- Single enforcement point: Rego policies, auditable in gate.log
- Rule 27 encoded: deny features must be proven with a base-case test
  before reliance

**Negative:**
- All enforcement must be authored and maintained in Rego — no config
  shorthand for quick denies
- OPA/Rego knowledge becomes a required skill for governance changes

## Alternatives considered
- **Combined config deny + OPA**: rejected — the config deny contributes
  nothing enforceable while implying coverage that does not exist;
  false confidence is the specific failure mode being eliminated

## References
- docs/errors/ERR-008.md
- STATE.md §2 (honest gaps), §3 (verified facts)
