# 12 — Glossary (arc42 §12)

| Term | Definition | Why it matters here |
|---|---|---|
| ADR | Architecture Decision Record — immutable record of one decision, its context, and consequences (MADR format) | Decisions outlive memory; agents must never delete ADRs, only supersede them |
| DENY reason | Policy-coded string in a gate.log DENY row (e.g. `P1-GOVERNANCE-FILE`) | Makes every block attributable to a specific rule — auditable, not opaque |
| Desktop Heap | Windows kernel resource governing process/fork creation; raised 768→4096 | Its exhaustion caused MSYS2 fork failures (ERR-007); the raise took errors to 0/20 |
| Dormant bypass | An inactive attack path that arms itself when a precondition is met | `devin -p --config` is dormant until `devin auth login` runs (ERR-009) — invisible until triggered |
| Evidence bundle | Required artifact set per phase (`evidence/P<n>/manifest.json`) proving work happened | P4 blocks writes/transitions without it — claims require artifacts (spec M2) |
| fail_closed | Devin hook config flag: non-2 hook exit = block (incl. timeout) instead of logged-not-blocking | Converts every hook failure from silent bypass into a block (ADR-002, ERR-010) |
| Fork failure | OS failure to spawn a child process (`cygheap read copy failed`, 0xC0000142) | In the gate it makes allow/deny undefined — reason WSL replaced Git Bash (ADR-001) |
| Gate (gate.sh) | WSL-side bash entrypoint: logs payload, calls OPA, returns exit 0/2 | The single interception point all PreToolUse calls pass through |
| GOV_GATE_DOWN | Log marker emitted when the gate itself fails (opa-not-found, nonzero rc) | Keeps gate failures visible rather than masked as allows or denies |
| Governance | The system of hooks + policies + CI that bounds what the agent may do | Its files are themselves P4-protected — governance governs its own edit surface |
| Hook (PreToolUse/PostToolUse) | Devin extension points: Pre = runs before a tool call (can block), Post = runs after (audit) | PreToolUse is the enforcement seam; PostToolUse is the audit seam; both load at SessionStart only (ERR-004) |
| Managed Devin | Devin session running in an isolated VM under the spec's role model | Spec concept: true enforcement tiers live where the agent's OS user cannot reach |
| MSYS2 / Git Bash | Windows POSIX compatibility layer; former hook runtime | Retired after fork failures (ERR-007); `bash -c` wrapper still needed for /mnt/c path conversion |
| OPA / Rego | Open Policy Agent engine + its policy language | main.rego aggregates P1–P5 denies into one `decision` — the local verdict authority |
| Policy (P1–P5) | The five Rego deny modules: wsl-root, test-edit, secrets, evidence+self-protection, unrecognized-tool | Every relied-upon deny must be one of these proven policies (Rule 27) |
| PWD-PROOF | gate.log row: timestamp + cwd of each intercepted call | Proves where the payload ran — the audit row that exists per call |
| tests.lock | File recording SHA-256 hashes of frozen test files | Freeze anchor: P2 denies edits to locked files; CI re-verifies it (ADR-004) |
| Tool inventory | Verified list of logged tool_names (`policies/.governance/tool-inventory.txt`) | P5 denies anything not on it — matchers must use logged names, not API names (ERR-005/006) |
