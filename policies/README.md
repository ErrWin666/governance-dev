# policies/ — Policy Gate (M5)

OPA is the PDP; every governed tool call passes `gate.sh` → `opa eval
data.governance.decision`. No `allow` = no call. Any error = deny (fail
closed, `GOV_GATE_DOWN` in `logs/gate.log`).

Integrity: `gate.sh` seals all policy files (`*.rego`, `gate.sh`,
`exec_analyze.py`) against `.governance/policies.lock` — mismatch **or a
missing lock** = deny everything (fail closed).

| File | One-line purpose |
|------|------------------|
| `main.rego` | entrypoint: `allow` iff `count(deny)==0`; shared helpers (`norm`, `target_path`) |
| `p1_deny_wsl_root.rego` | deny `wsl` as root; quotes normalized (`-u "root"` caught); malformed exec = deny |
| `p2_deny_test_edit.rego` | `tests.lock` frozen: deny edits to locked test paths + the lock itself |
| `p3_deny_secrets.rego` | deny secret patterns in write/edit/exec/webfetch/subagent/MCP payloads |
| `p4_require_evidence.rego` | transition writes (`approvals/`, `STATE.md`) need a manifest; `src/` needs evidence for phase N−1 |
| `p4_governance_self_protection.rego` | `policies/` read-only to write/edit/notebook_edit except `.rego` authoring |
| `p5_deny_unrecognized_tool.rego` | catch-all: `tool_name` outside `tool-inventory.txt` = deny (`*` = prefix) |
| `p8_deny_sensitive_files.rego` | deny writes to creds/keys/secrets (basename + path matchers) |
| `p10_deny_exfil.rego` | deny exfil channels in payloads |
| `p12_require_plan.rego` | `src/` writes need hash-matched `plan/spec.approved`+`tasks.approved` |
| `p13_exec_write_paths.rego` | exec writes to protected paths denied — bashlex AST + string fallback, segment-boundary matching |
| `p14_deny_seal_forgery.rego` | write/edit/notebook_edit of `*.approved` seals denied (GAP-L3-08) |
| `p15_deny_audit_forgery.rego` | write/edit of `logs/gate.log`, `logs/b1.0-pretool.log`, `exec_analyze.py` denied |
| `gate.sh` | fail-closed wrapper: log → env build → seal check → opa eval → exit 0/2 |
| `exec_analyze.py` | bashlex AST: verbs, redirects (`>`,`>>`,`&>`,`&>>`,`>&`,`<>`), `find -exec`, `xargs`, `bash -c` depth 6, workdir-aware |
| `.governance/tool-inventory.txt` | verified `tool_name` list, runtime-read |
| `.governance/policies.lock` | SHA-256 seal over all policy files (owner-sealed) |

## Design notes

- Matchers key on the **logged `tool_name`**, never function names (ERR-006).
- `opa` must exist and run `version` cleanly — absent/broken = `GOV_GATE_DOWN` = deny all.
- **R1 decision (2026-11-10, owner): exec writes to `src/` are a HARD
  barrier** — denied regardless of plan approvals. `src/` writes go through
  write/edit tools where p4/p12 evidence checks apply. Intentional.
- Residuals by design (clause-18 detection tier): `$var` indirection,
  base64/concat payloads, `git -C` subcommands, interpreter-script writes
  — audited, not prevented. Hardening = L5 scope.
- Broken `.rego` = total lockdown (`opa eval` fails → fail closed).
  Recovery: `docs/RUNBOOK.md` §lockdown (owner-side fix + reseal).
- Semantic tests: `tests/policy/p*_test.rego` — 34/34; run
  `opa test policies/ tests/policy/`.
