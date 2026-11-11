# Hostile Audit — 2026-11-11

**Auditor**: independent read-only subagent (hostile disposition — mandate:
disprove "all documented errors are fixed; governance works").
**Verdict**: standing claim **NOT supported**. Defensible claim:
"Specific runtime controls are proven; complete governance is partial."

Legend: ✅ fixed in ERR-028 batch | 🔴 open | 🟡 partial / owner-decision

---

## A. Fail-open holes in gate.sh (the gate itself)

| # | Finding | Evidence | Status |
|---|---|---|---|
| F1 | Missing `main.rego` → `exit 0` — silent allow-all before any check | `gate.sh` `[ -f main.rego ] \|\| exit 0` | 🔴 **STILL OPEN** — survived ERR-028 batch |
| F2 | Empty/whitespace `policies.lock` skipped integrity check | former `gate.sh:35` `[ -n "$EXP" ]` | ✅ fixed — `-s` + hex-format validation |
| F4 | `ROOT_DIR` vs cwd-relative paths mixed (logs/, policies/, tests.lock, evidence/, plan/) | `gate.sh` throughout | 🟡 unconfirmed — verify post-batch |
| F5 | `exec_analyze.py` invoked without timeout (OPA has `timeout 4`) | `gate.sh` analyzer call | 🟡 unconfirmed |

## B. Trust-base / supply chain

| # | Finding | Evidence | Status |
|---|---|---|---|
| F3 | OPA resolved via PATH incl. `$HOME/.local/bin/opa` (agent-writable) → fake `opa` prints `{"allow":true}` = total bypass; gate greps output string, no structural validation | `gate.sh` OPA resolution + eval-parse | 🔴 **OPEN** — fallback still present in resolution loop |
| F9 | `.rego` in nested subdir loads via `opa eval --data policies/` but is outside the seal → unsealed policy injection | former `opa eval --data policies/` | ✅ fixed — eval now loads top-level *.rego only (per gate.sh comment #3) |

## C. Governance records writable by agent (self-tampering)

| # | Finding | Status |
|---|---|---|
| F6 | `approvals/`, `STATE.md`, `evidence/` writable — p4 only denies when NO manifest exists; manifests exist → owner-approval forgery is one `write` away | 🔴 **OPEN — owner decision D2** |
| F7 | No rule protects `docs/errors/`, `.github/workflows/`, `tests/`, `.devin/`, `plan/` (except `.approved`), `CODEOWNERS`, `coordination-log.md`, `knowledge/`, `roles/`, `handoffs/`, `scripts/`, `logs/*.py|json|sh` | 🔴 **OPEN — owner decision D2** |
| F8 | `tests.lock` seals only phantom `test_sample.txt` — active tests (`tests/policy/*.rego`, `test_pgen.py`) unfrozen | 🔴 **OPEN — owner decision D3** |
| F14 | P13 protected-path set narrower than governance surface (omits `tests/`, `.github/`, `docs/`, `.devin/`, `plan/`, `scripts/`…) | 🔴 **OPEN — owner decision D2** |

## D. exec bypass — surviving vectors (~15, live in code)

| # | Finding | Status |
|---|---|---|
| F10 | Interpreter-script channel live (`python x.py`, `bash x.sh`, `node`, `powershell`, `cmd`, `perl`) — ACL covers only 4 items; `src/` barrier untrue vs scripts | 🔴 architectural residual (ERR-021) — owner decision D1 |
| F11 | Documented vectors still open: `$T` var, base64, `awk 'BEGIN{system()}'`, `git -C`, `curl -o`, `tar -C`, `find -delete` | 🔴 open — D1 scope |
| F12 | Additional: `rm -rf .|..|repo-root` (ancestors not matched), `git reset --hard`, `git rm`, `git mv`, `git apply`, `wsl -e` (no `-c`), `bash -lc`, `cmd/powershell/unlink/rmdir/icacls/takeown` verbs | 🔴 open — D1 scope |
| F13 | P13 fallback suppressed whenever AST `ok==true` — obfuscated-but-parseable survives | 🟡 recommend: run AST+fallback always (cheap deny-additive) |

## E. Audit trail & evidence

| # | Finding | Status |
|---|---|---|
| F15 | `logs/` gitignored → audit trail unversioned; `*.log` P15-protected but `*.py|json|sh` writable; script channel can forge `.log`; hook-spawn failures leave no gate entry | 🔴 open — owner decision (logs to git?) |
| F16 | Evidence manifests are agent-written narrative JSON — no file hashes, no external signatures | 🔴 open — owner decision D4 |

## F. Model/config inconsistencies

| # | Finding | Status |
|---|---|---|
| — | `current_phase=B6` but `p4_require_evidence` accepts only `P\d+` → ALL `src/` writes denied (fail-closed but model-broken) | 🔴 open — extend regex to `[BP]\d+` |
| — | `mcp__*` wildcard in tool-inventory auto-allows any future MCP tool | 🟡 keep or enumerate — owner call |

## G. What IS proven (with live evidence)

Hook fail-closed config ✓ · OPA errors/denies → exit 2 ✓ · missing lock → fail-closed ✓ · integrity mismatch detection ✓ · P13 direct + some indirection denies ✓ · P14 `.approved` ✓ · P15 `logs/*.log`+analyzer ✓ · P5 inventory catch-all ✓ · mv-source + backslash fixes ✓ · `rm -rf policies/` denied ✓

## H. Doc-drift (status unreliability)

`README.md` says "WSL gate" + "P1–P5" (now Git Bash, P1–P15) · `STATE.md` stale counts/WSL claims · `policies/README.md` stale P15 scope + unattached "34/34" · `docs/GAPS.md` stale `current_phase`/approvals · `docs/POLICY_COVERAGE.md` claims enforced owner-signoff (forgeable per F6) + missing-file claims now false · `errors/README.md` stale location + ERR-022 status · timestamps: several "FIXED 11-10" precede "Discovered 11-11".

## I. Repair-loop meta (why errors recurred)

3 of last ~6 incidents were repair-inflicted (fix_l4_h merged-line, fix_l4_i crash, fix_l4_j→ERR-027, 139991d wiped AGENT.md×5). Channel: blind `str.replace` scripts with no staging/verify/atomicity. **ERR-028 `policies/bin/repair.py` is the structural answer** — stage → battery (opa check/test + bash -n + provocation) → atomic swap → seal.

## J. Owner-decision register

| ID | Decision | Options |
|---|---|---|
| D1 | exec-vector closure scope | (a) close easy ~8 + document rest (b) allowlist model (c) accept residual |
| D2 | governance-record writability (F6/F7/F14) | (a) protect sensitive only: approvals/, STATE.md, evidence/, .github/, tests/, plan/ (b) protect all (c) git-as-audit only |
| D3 | freeze real tests in tests.lock | (a) freeze + repair.py owns updates (b) defer |
| D4 | externally-signed evidence | (a) invest now (b) defer to L5 |
| D5 | extend Windows ACLs (`apply-governance-acl.ps1`) | (a) prep script, owner runs elevated (b) defer |
| D6 | narrow the public claim to "partial" | recommended now |
| D7 | `mcp__*` wildcard; `logs/` gitignored; `current_phase` `[BP]\d+` | quick calls |

## K. Remaining actions after ERR-028 batch

1. 🔴 `main.rego || exit 0` → `exit 2` (F1) — one-line, still open
2. 🔴 Pin OPA (drop `$HOME/.local/bin` fallback) + structural output check (F3)
3. 🔴 Analyzer timeout (F5); ROOT_DIR anchoring (F4) — verify
4. D1–D7 owner decisions → implement
5. Fresh-session Git-Bash proof of final state
