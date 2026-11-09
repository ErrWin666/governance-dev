# STATE.md — Governance System Status

> Purpose: "Where are we now?" — for any new session to resume in 2 minutes.

**Last updated**: 2026-11-09
**Status**: Operational — CI enforcement proven on ci-test repo

## 1. What is built and working
- Local gate: PreToolUse hook → WSL gate.sh → OPA (P1-P5)
- fail_closed:true — proven (gate.sh missing → all blocked)
- P4 protects governance files (config.json, gate.sh, policies/)
- Desktop Heap 768→4096 — 0/20 fork errors (was 7.5%)
- Tool inventory: 22 tools (includes web_search, get_output, todo_write)
- CI enforcement on ci-test: Ruleset protect-main (#26814146) enforces
  3 required checks: test-lock ("Verify test files are frozen"),
  policy-lint ("Lint changed Rego policies"), secret-scan
  ("Scan PR diff for secrets") — merge BLOCKED proven on PR #6
- CODEOWNERS active; force pushes blocked; PR #1 blocked by CI
- P6 policy-lint + P7 secret-scan live on ci-test main
  (.github/workflows/policy-lint.yml, secret-scan.yml, .gitleaks.toml)
- Negative tests proven: PR #3 bad .rego → lint FAIL; PR #4 sk- secret →
  gitleaks FAIL (leaks found: 1)
- P3 fires in daily use: blocked literal sk- secret in exec push AND in
  ERR-013.md write payload — gate polices agent output, not just tests
- PostToolUse hook: audit layer (tool_response + tool_use_id)
- Subagent inner calls: visible in PARENT session log (same session_id)
- **L2 status (honest)**: Layer A proven (PRs #1/#2); Layer B proven
  (PR #3); Layer C = 6 advisory skills installed; Layer D PARTIAL —
  D2 Python proven, D1 JS/TS + D3 Go never run on real input
- **SonarQube**: localhost:9000 (v26.9.0) running but UNCONFIGURED —
  contributes zero gates today (owner password needed; unreachable
  from GitHub Actions)

## 2. What is NOT protected (honest gaps)
- governance-dev: admin bypass active on ruleset #26818941 (owner pushes
  directly, bypasses required checks). Production projects will use
  strict model — empty bypass + PR required (Phase 4, ERR-014, Rule 31)
- `devin -p --config` — dormant bypass (blocked only by CLI auth wall)
- `permissions.deny` — dead code (ERR-008) — do not rely on it
- Local exec of destructive commands — detectable, not preventable
  (fail-open seam in Devin hook contract)
- WSL cold start / crash — fail_closed blocks but locks owner out
  (recovery = manual)

## 3. Verified facts
- Hook contract: exit 0=allow, 2=block, others=logged-not-blocking
  (unless fail_closed:true — then non-2 = block; timeout = failure)
- Tool name aliasing: MCP logs as `mcp__<server>__<tool>`;
  `find_file_by_name` logs as `glob`. MCP rows carry `tool_provenance`
  {type:mcp, server, path:mcp_config.json}
- Match policies on logged `tool_name`, not function names
- Hooks load at SessionStart only (ERR-004)
- Rule 21 (Git-Bash only) — obsolete; WSL is runtime
- MSYS path conversion requires `bash -c` wrapper for /mnt/c paths
- 13 tool names proven under matcher:"" (B1.0); of record:
  policies/.governance/tool-inventory.txt
- gh CLI: WSL only (v2.45.0), authed as ErrWin666 — not in Git Bash
- sha256sum on Git Bash emits *filename (binary mode); tests.lock must be generated from WSL (wsl -e sha256sum ...) or with -t flag (ERR-011)
- gitleaks default rules miss alphabet-sequence tokens (sk-abcdef...);
  needs custom rule — .gitleaks.toml in ci-test (ERR-012)
- pull_request workflows run from PR HEAD file, but actions/checkout uses
  the merge ref (head + latest base) — config files land via base merge
- Policy centralization PROVEN (Phase 3): any new policies/*.rego in
  package governance auto-loads via `opa eval --data policies/` — no
  main.rego/gate.sh edit. Convention for new policies:
  `p<N>_<snake_case>.rego` (N = next free number), line 1 = `# WHY:`,
  `package governance` + `import rego.v1`, rules as `deny contains msg if`.
  Protected in governed projects by P4; editable in governance-dev by exception

## 4. Errors index
- ERR-004: mid-session hook change is silent
- ERR-005: tool name matrix from Claude Code ≠ Devin names
- ERR-006: logged tool_name ≠ function name (mcp__*, glob)
- ERR-007: MSYS2 cygheap fork failures
- ERR-008: permissions.deny non-functional
- ERR-009: devin -p dormant bypass
- ERR-010: fail_closed:true proven
- ERR-011: sha256sum binary mode breaks path parsing
- ERR-012: P6/P7 are CI-based, not runtime — OPA cannot self-inspect
- ERR-013: gitleaks defaults miss alphabet-sequence secrets (Rule 30)
- ERR-014: admin bypass deviation on governance-dev (dev only; prod strict)
- ERR-015: L2 tool install fallbacks (arborist-metrics 404, muti junk,
  pyscn pip-not-Go, polyscan no-Python)
- Full index: docs/errors/README.md (ERR-001..003 in the archived Arabic
  project — now at C:/governance-dev-archive/arabic-test-project/)

## 5. Next steps (in order — do not skip)
1. ~~Complete documentation~~ — Phase 1 DONE
2. ~~Complete policies P2 test + P6-P10~~ — Phase 2 DONE (2026-11-09)
   P1-P5 runtime .rego + P2 tested; P6 (policy-lint) & P7 (secret-scan)
   are CI workflows, verified in ci-test — replicate per-project (ERR-012)
3. ~~Build policy centralization (one file = one policy)~~ — Phase 3 DONE
   (2026-11-09): auto-load proven via p11 probe, see §3 convention +
   evidence/P3/manifest.json
4. L2 Quality Gate — PARTIAL (2026-11-09): A+B proven on PRs, C installed,
   D2 only of D1/D2/D3 proven; SonarQube dormant (docs/GAPS.md)
5. Finish L3 proof: cold-session resume test + pilot (docs/GAPS.md
   GAP-L3-04/09); then L4 verification — the missing core
6. Then L5 orchestration, L6 deployment (copier), spec v1.2 last
- **Next phase**: close L3 + L2 proof gaps per docs/RECOVERY_PLAN.md;
  no L4 work until earlier-layer gaps are closed
- Reference reads: GOVERNANCE_SPEC.md (v2.0, repo root since 2026-11-09),
  docs/plans/GOVERNANCE_BUILD_PLAN.md, approvals/approval.md (A-002)

## 6. Key files
- Governance: C:/governance-dev/policies/ (gate.sh, main.rego,
  p1-p5/p8-p10/p12_*.rego — P6/P7 are CI workflows, p11 was a deleted
  probe; .governance/tool-inventory.txt + current_phase;
  backups: gate.sh.gitbash.bak, gate.sh.timeout.bak)
- L2 workflows: C:/governance-dev/.github/workflows/ (quality-gate.yml,
  quality-gate-perlang.yml, policy-lint.yml, secret-scan.yml)
- L2 skills: C:/governance-dev/.devin/skills/ (clean-code, adversarial-
  reviewer, quality-gate, code-review, mutation-testing, logic-flow-review)
- Logs: C:/governance-dev/logs/gate.log (also b1.0-pretool.log,
  b1.0-discovery.log)
- Config: %APPDATA%/devin/config.json (PreToolUse, fail_closed:true;
  backup: config.json.bak-failclosed)
- CI testbed: github.com/ErrWin666/ci-test (tests.lock, CODEOWNERS,
  workflows: test-lock-verify + policy-lint + secret-scan, .gitleaks.toml,
  ruleset #26814146). Local clone moved out of the repo tree to
  C:/governance-dev-archive/ci-test (2026-11-09) — re-clone if needed
- Repo cleanup 2026-11-09: debris dirs out to C:/governance-dev-archive/;
  architecture/ → docs/architecture/; constitution → repo root v2.0
  (commits 7a479e0, 7488b65, 3055748, ad2d214)
- Governance repo: github.com/ErrWin666/governance-dev (ruleset #26818941,
  admin bypass per ERR-014)

## 7. Recovery procedures
- fail_closed locks everything: edit %APPDATA%/devin/config.json in Notepad
  → remove fail_closed (or restore config.json.bak-failclosed) → new session
- gate.sh missing: restore from gate.sh.gitbash.bak
- WSL corrupt: `wsl --shutdown` then restart
- SonarQube down: `docker start sonarqube` (port 9000); password reset via
  `docker exec sonarqube cat /opt/sonarqube/data/initial_admin_password`
- CI broken: check `wsl gh api repos/ErrWin666/ci-test/rulesets/26814146`
  or `wsl gh api repos/ErrWin666/governance-dev/rulesets/26818941`