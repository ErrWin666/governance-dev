# ADR-002: fail_closed: true is mandatory in PreToolUse hook

## Status
Accepted

## Context
Devin's hook contract: exit 0 = allow, exit 2 = block, any other exit =
logged-but-not-blocking. The default is therefore fail-open — a hook that
crashes, times out, or is missing lets the tool call execute silently.
WSL cold start, fork failure (ERR-007), or a missing gate.sh would each
produce exactly that silent bypass. Governance that fails open is not
governance.

## Decision
Set `"fail_closed": true` on every PreToolUse hook. Under fail_closed,
any non-2 exit — including hook failure and timeout — blocks the call.

## Consequences
**Positive:**
- ERR-010 proven: gate.sh missing → exit 127 → BLOCKED, not fail-open
- No silent bypass path remains in the hook contract itself
- Timeout counts as failure → blocked (fail-closed by construction)

**Negative:**
- If the hook breaks, ALL tools are blocked — including read/edit —
  locking the owner out of the session
- Recovery is manual and must happen outside Devin: edit
  %APPDATA%/devin/config.json in Notepad → remove fail_closed (or restore
  config.json.bak-failclosed) → new session (STATE.md §7)

## Alternatives considered
- **Rely on exit-2 only (default contract)**: rejected — fail-open by
  design; every hook malfunction becomes a silent bypass
- **External watchdog process**: rejected — adds a second moving part
  that itself can fail; fail_closed achieves the same guarantee in-config

## References
- docs/errors/ERR-010.md
- docs/errors/ERR-007.md
- STATE.md §3 (hook contract), §7 (recovery)
