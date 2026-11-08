# policies/ — B1.1 Policy Gate (M5)

OPA is the PDP; every governed tool call passes `gate.sh` → `opa eval data.governance.decision`.
No `allow` = no call. Any error = deny (fail closed, `GOV_GATE_DOWN` in logs/gate.log).

| File | Policy | One-line purpose |
|------|--------|------------------|
| `main.rego` | entrypoint | aggregates all denies → `{allow, reasons}`; shared helpers (`norm`, `target_path`) |
| `p1_deny_wsl_root.rego` | `deny_wsl_root` | deny `wsl` with root flags (`-u root`, `-uroot`, `--user[= ]root`); malformed exec = deny |
| `p2_deny_test_edit.rego` | `deny_test_edit` | `tests.lock` present → frozen: deny edits to locked test paths; lock file untouchable; new tests allowed |
| `p3_deny_secrets.rego` | `deny_secrets` | deny secret patterns in write/edit/exec/webfetch/subagent/MCP payloads |
| `p4_require_evidence.rego` | `require_evidence` | deny transition writes (`approvals/`, `STATE.md`) with no `evidence/*/manifest.json` |
| `p5_deny_unrecognized_tool.rego` | catch-all | deny `tool_name` outside `.governance/tool-inventory.txt` (`mcp__*` prefix allowed) |
| `gate.sh` | wiring | fail-closed wrapper: logs payload → builds env data → `opa eval` → exit 0/2 |
| `.governance/tool-inventory.txt` | inventory | runtime-read verified `tool_name` list (ERR-006); `*` suffix = prefix match |

Notes:
- All matchers key on the **logged `tool_name`**, never function names (ERR-006).
- `opa` must be on PATH (`winget install openpolicyagent.opa`); absent = gate down = deny all.
- P4 surface is v1-conservative (`approvals/` + `STATE.md`); broaden in B1.2 if needed.
- Verification of deny enforcement (wsl variants, curl|bash, secret URLs, etc.) is B1.2 scope.
