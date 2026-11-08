# Governance File Recovery (Session #19)

Two-layer protection on governance files:

| Layer | Mechanism | Blocks |
|-------|-----------|--------|
| 1 | `policies/p4_require_evidence.rego` (P4-GOVERNANCE-FILE) | `write`/`edit`/`notebook_edit` tool calls |
| 2 | Windows ACL: `AA:R`, `Administrators:F`, `SYSTEM:F` | any write as AA (incl. exec/echo/manual) |

Protected paths: `policies/gate.sh`, `policies/*.rego` (any depth, plus
`*.json`/`*.yaml`/`*.yml` — OPA data-injection guard), `policies/.governance/*`,
`%APPDATA%\devin\config.json`, `%APPDATA%\devin\mcp_config.json`.

## To modify a protected file (admin required)

1. Open PowerShell **as Administrator**.
2. Unlock:
   `powershell -ExecutionPolicy Bypass -File C:\governance-dev\scripts\apply-governance-acl.ps1 -Restore`
   (`icacls /reset` restores inherited ACLs; AA regains write.)
3. Edit the file(s).
4. Re-lock:
   `powershell -ExecutionPolicy Bypass -File C:\governance-dev\scripts\apply-governance-acl.ps1`

## Full rollback (pre-change state)

- File copies + ACL snapshots: `backups/pre-acl-2026-11-08/` (see its README.txt).
- Restore ACLs: `icacls C:\governance-dev /restore backups\pre-acl-2026-11-08\acl-repo-N.ntacl`
  (or just use `-Restore`; the .ntacl files capture exact pre-change SDDLs.)
- Revert P4 extension: copy `backups/pre-acl-2026-11-08/policies/p4_require_evidence.rego`
  over `policies/p4_require_evidence.rego` (requires admin while ACL is locked —
  unlock first via step 2 above).

## Known limits

- Layer 1 cannot see `exec` payloads — `echo > policies\x.rego` via exec is only
  stopped by layer 2 (AA write). Locking `policies/` itself is a possible future
  extension; not applied because the dir must stay writable for non-listed files.
- `config.json`/`mcp_config.json` read-only for AA means Devin's own settings
  writes may fail while locked — use the recovery flow above when Devin needs
  to persist config changes.
