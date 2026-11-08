# ADR-001: WSL as runtime for governance hooks (not Git Bash)

## Status
Accepted

## Context
Governance hooks (gate.sh, OPA evaluation) need a reliable shell runtime.
Git Bash (MSYS2) intermittently failed to fork child processes —
ERR-007 documented `cygheap read copy failed` / 0xC0000142 at a ~7.5%
failure rate, caused by Desktop Heap exhaustion. A fork failure inside the
hook leaves its behavior undefined: a call may be blocked or may silently
pass — a silent policy-bypass risk.

## Decision
Hooks execute via `wsl.exe -d Ubuntu-24.04 -e bash -c "bash /mnt/c/..."`
(WSL native fork). The `bash -c` wrapper is required because MSYS path
conversion does not handle /mnt/c paths directly. Desktop Heap was raised
768→4096 as a complementary fix; WSL remains the runtime of record.

## Consequences
**Positive:**
- 0/20 fork errors after Desktop Heap 4096 (was ~7.5%) — stable runtime
- Native Linux fork semantics; OPA and jq behave as documented
- gh CLI available in WSL (v2.45.0, authed) for CI ruleset management

**Negative:**
- WSL cold start adds latency to the first hook call of a session
- MSYS path conversion requires the `bash -c` wrapper (fragile quoting)
- If WSL crashes or is corrupt, hooks fail → fail_closed locks everything;
  recovery requires manual file restore (`wsl --shutdown`, STATE.md §7)
- Related finding ERR-011: sha256sum in Git Bash produces binary-mode
  output (`*` prefix) incompatible with tests.lock parsing; WSL-native
  coreutils must be used for manifest generation

## Alternatives considered
- **Git Bash (MSYS2)**: rejected — ERR-007 fork failures made hook behavior
  undefined; a governance layer cannot run on a flaky runtime
- **Docker container**: rejected — adds a daemon dependency and startup
  latency worse than WSL cold start
- **Pure Windows binary (PowerShell/native)**: rejected — no fork
  equivalent; OPA/Rego tooling and gate.sh assume POSIX semantics

## References
- docs/errors/ERR-007.md
- docs/errors/ERR-010.md
- STATE.md §3 (Rule 21 obsolete — WSL is runtime)
