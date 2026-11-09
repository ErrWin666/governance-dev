# L2a Implementation — Quality Gate Layer A

> Built 2026-11-09. Scope: Layer A only — every PR, stack-agnostic, fast, deterministic.
> Layer B (risky PRs), Layer C (advisory skills), Layer D (per-language adapters) are later phases.

## What was built

`.github/workflows/quality-gate.yml` — single job `quality-gate` on `pull_request` to `main`,
all checks run unconditionally (`if: always()`) and a **Gate summary** step aggregates
per-check outcomes so one run reports every failure at once. Job timeout: 5 min.
Required status check `quality-gate` added to ruleset `protect-main` (admin bypass preserved).

## Checks

| ID | Gate | Tool / method | Version | Install in CI | Fail condition |
|----|------|---------------|---------|---------------|----------------|
| A1 | File + function size | embedded python: `wc`-style line count, `ast` for .py, brace-span heuristic for brace langs | — | none | src >400 lines (tests exempt), .rego >100 lines, function >40 lines (spec v2.1; class ≤300 not yet checked — GAP-L2-12) |
| A2 | Secrets | gitleaks | 8.24.3 | separate `secret-scan.yml` (pre-existing P7) | any finding |
| A3 | Hardcoded values + magic numbers | **Lyncus rule engine** (`Lyncus.rules.hardcode_rules.scan_file_for_hardcode` imported directly) | 1.0.5 | `pip install lyncus==1.0.5` | any CREDENTIAL / DATABASE / HARDPATH / HARDURL / MAGICNUM match in changed files |
| A4 | API contract | **api-contract-guard** `--mode openapi --fail-on-breaking` | 0.2.0 | `pip install api-contract-guard==0.2.0 pyyaml` | breaking change vs base spec (removed op/status, removed/changed schema props); YAML converted to JSON first |
| A5 | Mutation testing | **mutmut** diff-scoped via `setup.cfg [mutmut] source_paths` + `only_mutate` = changed .py files; score from `mutmut export-cicd-stats` JSON + generated-total from run log | 3.8.1 | `pip install mutmut==3.8.1 pytest` | `(killed+timeout) / total < 60%`; `no_tests` mutants count against score |
| A6 | Diff coverage | **pytest-cov → coverage.xml → diff-cover** `--compare-branch $BASE_SHA --fail-under 80`; plus strict check that every changed .py source file appears in coverage.xml | diff-cover 11.x | `pip install pytest pytest-cov diff-cover` | <80% coverage on changed lines, or changed source file with zero instrumentation |
| A7 | Duplication | **jscpd** | 5.4.3 | `npm i -g jscpd@5.4.3` | >5% duplicated tokens (`--min-tokens 50 --threshold 5`) |
| A8 | Debug leftovers + silenced errors | `git diff -U0` added-lines grep per extension | — | none | `print(`/`pdb.set_trace`/`breakpoint()`/bare `except:` (.py); `console.log`/`debugger`/empty `catch {}` (.js/.ts) in added lines |

## Tool verification results

| Tool requested | Real? | Used? | Notes |
|---|---|---|---|
| `lyncus` (pip) | yes — PyPI `Lyncus` 1.0.5 | yes, as rule library | CLI works but **auto-installs entire language toolchains** (ruff/mypy/bandit/eslint/stryker…) on every scan — too heavy for a <5 min gate, so A3 imports `scan_file_for_hardcode` directly. Same rules the CLI's `--only hardcode` runs. |
| `foxguard` | yes — PyPI 0.14.1 | no | not needed; Lyncus covers A3 |
| `api-contract-guard` | yes — PyPI 0.2.0 | yes | JSON input only; YAML specs converted via pyyaml. Compares response schemas/operations. |
| `muti` | **no** — PyPI 404, npm `muti@1.0.0` is a junk package ("ay 7aga") | no | fell back per plan: mutmut (Py), Stryker (JS — needs per-project config, see limits) |
| `jscpd` | yes — npm 5.4.3 | yes | v5 Rust rewrite keeps `--min-tokens`/`--threshold` CLI |
| `coverage`/`diff-cover` | yes | yes | diff-cover verified locally: 25%→fail, 100%→pass |

## SonarQube

Two containers exist on the Docker Desktop host (`mail-assistant-sonarqube-sonarqube-1`, `sonarqube`)
but both are **stopped** — `localhost:9000` unreachable from Windows and WSL2. Not required for L2a;
all checks are CLI-based. If SonarQube is wanted later it belongs to L2d (per-language scanners feeding
a shared dashboard).

## Verified behavior (2026-11-09)

- **Seeded bad PR #1** (417-line js, 58-line py func, `DB_PASS="admin123"`, `0.0034`, uncovered func,
  weak test, `console.log`, `print(`, bare `except:`, empty `catch {}`):
  - A1 fail (3 annotations), A3 fail (HC005 credential + HC031 magic), A5 fail (mutation 0.6%: 1/178),
    A6 fail (13% diff coverage), A8 fail (4 patterns). A4/A7 pass. Gate FAILED → `mergeStateStatus: BLOCKED`.
- **Clean PR #2** (`mathutil` + full tests): all checks pass/skip, A5 score 94% (16/17, one equivalent
  `range` mutant survives), gate PASSED → merge ALLOWED. **Runtime: 27s.**

## Known limits (documented, deterministic)

- **A5 JS/TS**: skipped when no `stryker.conf.*` exists — Stryker needs per-project setup (L2d).
- **A6 JS/TS**: only runs if `package.json` declares jest (cobertura → diff-cover); Go/other langs skip (L2d).
- **A5/A6** need an existing test suite (`test_*.py` in repo); without tests both skip with `::notice`.
- **A1 function size** for brace languages is a heuristic (signature + brace counting); exact
  per-language parsing belongs to L2d adapters. `.py` is exact via `ast`.
- **A3** scans all changed files, not only diff hunks — a pre-existing violation in a touched file
  fails the gate (fail-closed by design).
- **A4** only fires when a `*openapi*`/`*swagger*` spec file changes in the PR.
- jscpd `mutants/` dir left by mutmut is excluded via `--ignore` (would otherwise read as duplication).
- mutmut is Unix-only (fork isolation) — fine on `ubuntu-latest`; do not run locally on Windows.

## Layers B + C + D (added 2026-11-09)

### Layer B — `quality-gate-deep.yml` (job `quality-gate-deep`, required check)

Triggers only on risky PRs (diff >200 lines OR touches `policies/`, `.github/`, `auth/`, `payments/`); always reports a check result — safe PRs pass with a skip notice.

| ID | Check | Tool | Fail condition |
|----|-------|------|----------------|
| B1 | Dependency architecture | `import-linter` 2.16 (Py, `importlinter.ini` contracts) + `dependency-cruiser` 16 (JS, `.dependency-cruiser.js`) | contract violation / circular / unresolvable import |
| B2 | Cognitive complexity ≤15 | radon cc (Py) — `arborist-metrics` does not exist | complexity >15 |
| B3 | Coupling/cohesion | `polyscan` 0.6.1 npm (JS/Go/Rust/C++ only) | threshold breach; Py deferred to L2d |
| B4 | CFG dead code | `pyscn` 1.33.2 (pip, not Go binary) | unreachable code / dead branch |
| B5 | Mutation testing, module scope | mutmut 3.8.1 (`source_paths`=changed dirs, no `only_mutate`) | score <60% incl. `no_tests` mutants |
| B6 | API contract, strict | api-contract-guard `--strict-additions` | ANY schema change (not just breaking) |

### Layer C — advisory skills (skills.sh-first, never block)

Installed via `npx skills add <repo> --skill <name> -a devin` into `.devin/skills/` (+ `skills-lock.json`):

| Slot | Adopted skill | Source repo | Installs |
|---|---|---|---|
| C1 clean code/SOLID | `clean-code` | sickn33/agentic-awesome-skills | 12.8K |
| C2 adversarial review | `adversarial-reviewer` | alirezarezvani/claude-skills | 853 |
| C3 quality gate design | `quality-gate` | simota/quality-skills | — |
| C4 code review | `code-review` | mattpocock/skills | 868K |
| C5 logic flow | `logic-flow-review` | **custom — no skills.sh match** | — |
| B5 guidance | `mutation-testing` | secondsky/claude-skills | 453 |

Rejected: `trailofbits/skills@mutation-testing` (mewt/muton smart-contract only).
Sample advisory outputs: `evidence/P3/code-check.md`, `evidence/P3/logic-flow.md`.

### Layer D — `quality-gate-perlang.yml` (job `quality-gate-perlang`, required check)

| Adapter | Trigger | Tools |
|---|---|---|
| D2 Python | any changed .py | ruff, radon cc≤10, import-linter, pytest --cov-fail-under=80 (if tests exist) |
| D1 JS/TS | changed js/ts + package.json | eslint, eslint-plugin-sonarjs (cognitive ≤15), knip, dependency-cruiser, nyc --lines 80 |
| D3 Go | changed .go + go.mod | go vet, gocyclo ≤10, gocognit ≤15, go test -coverprofile |
| D4 | none recognized | `::warning` skip, never fails |

### SonarQube — LOCAL-ONLY

`sonarqube:community` recreated with `-p 9000:9000` (original had no port mapping
and a broken /etc/hosts → ES hostname crash). UP at http://localhost:9000 (v26.9.0).
Volumes `sonarqube_data/_extensions/_logs` preserved. **`admin` login returns 401 —
owner-set password in the preserved volume.** S1 gate conditions, S2 custom secret
rules, S3 S2068 all require owner credentials; S4 GitHub link is impossible anyway
(localhost unreachable from Actions) → documented as manual/local tool.

### Test evidence

- Risky PR #3 (>200 lines, import cycle, cc 15+, dead code, weak tests):
  B1 fail (cycle), B4 fail (unreachable), B5 fail, Gate FAILED → merge BLOCKED.
  D2 also failed (ruff/radon/import-linter on seed). D4 fix verified.
- Tools failing/limited → `docs/errors/ERR-015.md`.

## Notes for owner

- `STATE.md` not touched (P4) — manual update needed: mark L2a built, note `quality-gate`
  required check in ruleset `protect-main`.
- `docs/ROADMAP.md` §5 marked implemented **in working tree only** (file is uncommitted draft).
- Test branches `test/qg-bad`, `test/qg-good` + PRs #1/#2 were verification-only; deleted after run.
- Two transient GitHub 504s seen downloading OPA/gitleaks binaries — infra flake, retried green.
