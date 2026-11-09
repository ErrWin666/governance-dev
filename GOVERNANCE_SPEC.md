# GOVERNANCE_SPEC.md
# Governance Specification — Version 2.0
# Created: [date] — bumped to v2.0 on 2026-11-09 (moved to repo root + documented corrections below)
# Owner: [your name]
# Status: Owner-approved — the fixed reference for every session
#
# Correction log v1.0 → v2.0:
# 1) Moved from docs/specs/ to the repo root (the constitution lives at the
#    top of the tree, not buried).
# 2) Rule 21 (mandatory Git-Bash runtime) — RETIRED: the runtime of record
#    is WSL (ADR-001, ERR-007). Kept struck-through below for the record.
# 3) Language: this document is now English-only (owner directive
#    2026-11-09). The v1.x Arabic original is preserved in git history and
#    at C:/governance-dev-archive/GOVERNANCE_SPEC-v1-arabic.md.

---

## 0. Purpose of this document

This document is the **formal contract** between the Owner (me) and any AI
agent (Devin or other) working on my projects. Any work that does not comply
with this specification is **unapproved**, regardless of code quality or
delivery speed.

**Governing principles:**
1. **Action over intent**: no success claim is accepted without tangible evidence.
2. **Separation of roles**: no role plans, executes, reviews, and approves at once.
3. **Rules from outside**: policies are imposed on the agent externally, not requested of it.
4. **No silent work**: every step leaves a trace; every failure is visible.
5. **Simplicity first**: the least complexity that serves the purpose; the fewest roles that cover the functions.
6. **Proportional simplicity**: governance scales to the project's size and risk. A mechanism runs only when its benefit outweighs its cost.

---

## 1. Lifecycle — 6 phases

Every project passes through these phases in order. No transition to a phase
before passing the previous phase's gate.

### P0 — Exploration

| Item | Details |
|---|---|
| **Inputs** | Owner's idea in their own words |
| **Output** | `docs/spec.md` (complete spec) |
| **Required evidence** | Signed spec + open-questions list + studied-alternatives list |
| **Executed by** | Coordinator + Researcher |
| **Verified by** | Owner (explicit approval) |
| **Acceptance criteria** | • Problem is clear • User identified • Acceptance criteria testable • Out of scope defined • Alternatives documented • Open questions answered or deferred by decision |

**Rule**: no code in this phase. No project files. Only the spec document.

### P1 — Architecture Documentation

| Item | Details |
|---|---|
| **Inputs** | Approved `docs/spec.md` |
| **Output** | `docs/architecture/` (ADRs + C4 diagrams + folder structure) |
| **Required evidence** | • `adr/001-*.md`, `adr/002-*.md`, ... • `c4-context.mmd`, `c4-container.mmd` • `folder-structure.md` • `tech-stack.md` |
| **Executed by** | Coordinator + Writer |
| **Verified by** | Verifier (completeness) + Skeptic (contradictions) |
| **Acceptance criteria** | • Every architectural decision has an ADR • Diagrams are Mermaid in Git • Folder structure defined • Chosen technologies justified • No decision without a "why" |

**Rule**: diagrams are written as text (Mermaid) and stored in Git. No external images.

### P2 — Blueprint

| Item | Details |
|---|---|
| **Inputs** | Approved `docs/architecture/` |
| **Output** | `docs/blueprint/` (function map, flow, test plan) |
| **Required evidence** | • `function-map.mmd` • `data-flow.mmd` • `test-plan.md` • `test-cases.md` |
| **Executed by** | Coordinator + Writer |
| **Verified by** | Verifier + Skeptic |
| **Acceptance criteria** | • Every major function specified with inputs/outputs • Logical flow drawn • Test plan covers: unit, integration, e2e, security • Every test has an acceptance criterion |

**Rule**: no code before the blueprint is approved. The blueprint is the "roadmap" the implementer follows.

### P3 — Implementation

| Item | Details |
|---|---|
| **Inputs** | Approved `docs/blueprint/` + `spec.hash` + `tests.hash` |
| **Output** | Code + tests + `evidence/P3/` |
| **Required evidence** | • `git diff` of the code • `test-report.log` (full, not summarized) • `coverage-report.html` • `lint-report.log` • `sonarqube-report.json` • `evidence-manifest.json` |
| **Executed by** | Implementer (in isolated VM) |
| **Verified by** | Verifier (automated) + Skeptic (sample) |
| **Acceptance criteria** | • Every test in `test-plan.md` exists • Coverage ≥ 80% • No lint errors • SonarQube: no Bug or Vulnerability issues • File size ≤ 400 lines • Function size ≤ 50 lines • No hardcoded secrets • `git diff` matches the blueprint |

**Strict implementation rules:**
- **Forbidden** to modify test files after `tests.hash` (detected via hash mismatch).
- **Forbidden** to write everything at once — work is split into small tasks (each ≤ 200 lines changed).
- **Forbidden** hardcoded secrets (detected by gitleaks).
- **Forbidden** variable duplication (detected by SonarQube duplication).
- **Forbidden** exceeding 400 lines/file or 50 lines/function (detected by CI script).
- **Forbidden** "working" code without a test (0% coverage = failure).
- **Forbidden** fixing broken code by editing the test (detected by hash).

### P4 — Security Audit

| Item | Details |
|---|---|
| **Inputs** | P3 code + `evidence/P3/` |
| **Output** | `evidence/P4/` (vulnerability report + remediations) |
| **Required evidence** | • `sast-report.json` (SonarQube) • `dast-report.json` (ZAP baseline) • `secrets-scan.json` (gitleaks) • `dependency-check.json` • `threat-model.md` • `remediation.diff` |
| **Executed by** | Attacker (in isolated VM) |
| **Verified by** | Verifier + Owner |
| **Acceptance criteria** | • No unremediated Critical/High vulnerabilities • Every fix documented in `remediation.diff` • Threat model covers OWASP Top 10 • No exposed secrets • Dependencies updated |

**Rule**: the Attacker **does not fix** vulnerabilities itself. It documents them only; the Implementer (in a new round) fixes them. This prevents conflicts of interest.

### P5 — Approval

| Item | Details |
|---|---|
| **Inputs** | All of `evidence/P0..P4/` + `evidence-manifest.json` |
| **Output** | `evidence/P5/approval.md` + `release/` |
| **Required evidence** | • `approval.md` signed by the Owner • `release-manifest.json` • `changelog.md` |
| **Executed by** | Writer + Verifier |
| **Verified by** | Owner (mandatory final approval) |
| **Acceptance criteria** | • All previous phases approved • Evidence bundle complete • Owner explicitly approved • No critical open questions |

**Rule**: no release without the Owner's explicit approval. Approval is recorded in `approval.md` with date and signature.

### Proportional governance

| Project size | Phases | Mechanisms | Roles |
|---|---|---|---|
| Small (≤ 500 lines) | P0, P3, P5 | M1, M2, M4, M8 | R1, R3, R4, R6 |
| Medium | P0–P5 | M1–M8 (M6 only for web apps) | All except R5 (unless needed) |
| Large | P0–P5 + M6 | All mechanisms | All roles |

---

## 2. Roles — 5 core roles

Each role works in an **isolated VM** (Managed Devin) or a **coordination
session** (the Coordinator). No role sees what it does not need.

### R1 — Coordinator/Auditor

- **Responsibility**: understand intent, plan, dispatch tasks, monitor progress, document decisions, request owner approval.
- **Does NOT**: implement code, review code, approve results.
- **Inputs**: owner's words, other roles' reports.
- **Outputs**: `docs/spec.md`, `phase-contracts/`, `coordination-log.md`, approval requests.
- **Isolation**: the parent session (coordination only, no direct access to project files).
- **Quality bar**: every decision documented in `coordination-log.md` with its reason.

### R2 — Researcher

- **Responsibility**: search for tools, libraries, similar projects, best practices. Provide a **Knowledge Base** for the others.
- **Does NOT**: implement, approve, decide.
- **Inputs**: questions from the Coordinator.
- **Outputs**: `knowledge/` (Markdown files with sources), `docs/research/` (research reports).
- **Isolation**: isolated VM (read-only + internet access).
- **Quality bar**: every piece of information has a source (link + date).

### R3 — Implementer

- **Responsibility**: write code and tests per the blueprint, in small tasks.
- **Does NOT**: review itself, edit tests, approve its own work.
- **Inputs**: `docs/blueprint/`, `docs/spec.md`, `knowledge/`.
- **Outputs**: code + tests + `evidence/P3/`.
- **Isolation**: isolated VM (write access to the project folder only).
- **Quality bar**: every task ≤ 200 lines changed, coverage ≥ 80%, no lint errors.

### R4 — Verifier/Skeptic

- **Responsibility**: verify evidence (Verifier) + hunt contradictions (Skeptic). A dual role, but the two work sequentially.
- **Does NOT**: write code, approve its own work, trust any claim without evidence.
- **Inputs**: `evidence/P<n>/`, the code, the tests.
- **Outputs**: `evidence/P<n>/verdict.md` (PASS/PARTIAL/FAIL + reasons).
- **Isolation**: isolated VM (read-only).
- **Quality bar**: every judgment backed by a reference to a concrete trace (file, line, hash).

### R5 — Attacker

- **Responsibility**: security testing (SAST/DAST/manual), produce a vulnerability report.
- **Does NOT**: fix vulnerabilities, approve, decide.
- **Inputs**: P3 code.
- **Outputs**: `evidence/P4/` (reports + threat model).
- **Isolation**: isolated VM (read-only + attack tools).
- **Quality bar**: every vulnerability classified (CVSS), with an exploit scenario and a proposed fix.

### R6 — Writer/Consultant

- **Responsibility**: draft the final summary from evidence, give expert opinion (consultant) when needed.
- **Does NOT**: add claims not present in the evidence, decide, implement.
- **Inputs**: all of `evidence/`.
- **Outputs**: `evidence/P5/summary.md`, `release/changelog.md`.
- **Isolation**: isolated VM (read-only).
- **Quality bar**: every sentence in the summary has a reference in the evidence.

---

## 3. Mechanisms — 9 mandatory mechanisms

### M1 — Phase Contract
- **Description**: a written document before each phase defining: inputs, outputs, evidence, acceptance criteria.
- **Location**: `phase-contracts/P<n>-contract.md`.
- **Mandatory**: no phase starts without an owner-approved contract.
- **Verification**: the Verifier checks that every contract item is satisfied.

### M2 — Evidence Bundle
- **Description**: folder `evidence/P<n>/` holding all evidence + `manifest.json` (file list + hashes).
- **Mandatory**: no phase counts as complete without a complete evidence bundle.
- **Verification**: the Verifier checks the manifest (every file present, hash matching).

### M3 — Frozen Spec
- **Description**: `spec.hash` (SHA-256 of the spec) recorded in `spec.lock` outside the work folder (e.g. `~/.governance/spec.lock`).
- **Mandatory**: any spec edit requires updating the hash + owner approval.
- **Verification**: before each phase, the hash is recomputed and compared. Any difference = stop.

### M4 — Test Freeze
- **Description**: `tests.hash` (SHA-256 of every test file) recorded in `tests.lock`.
- **Mandatory**: no test-file edits after freezing without owner approval.
- **Verification**: CI checks the hash before every run. Any difference = build failure.
- **Exception**: adding new tests is allowed (existing ones may not be edited).

### M5 — Policy Gate
- **Description**: OPA (installed) used as a PDP (decision engine). Every tool call goes through `opa eval`.
- **Mandatory**: no tool call without an `allow` decision from OPA.
- **Initial policies**:
  - `deny_wsl_root`: block `wsl -u root` (detected via `tool_input` analysis).
  - `deny_test_edit`: block test-file edits after freezing.
  - `deny_secrets`: block writing keys/passwords into code.
  - `require_evidence`: block phase transitions without an evidence bundle.
- **Verification**: a `PreToolUse` hook calls OPA before every tool.

### M6 — Security Scan
- **Description**: mandatory automated scan in P4.
- **Tools**:
  - SonarQube (you have a container): SAST + code smells + duplication + hardcoded secrets.
  - OWASP ZAP baseline: DAST for web applications.
  - gitleaks: secrets detection in git history.
  - `npm audit` / `pip-audit`: dependencies.
- **Mandatory**: no P5 approval without a clean security report (no Critical/High).
- **Verification**: the Verifier reviews reports + the Owner approves.

### M7 — Error Registry
- **Description**: `docs/errors/ERR-<id>.md` per error (description, root cause, fix, regression test).
- **Mandatory**: every new error is documented + a regression test added.
- **Verification**: CI checks every registry error has a matching test.

### M8 — Owner Approval
- **Description**: mandatory checkpoint at P0 (spec approval) and P5 (release approval).
- **Mandatory**: no transition without recorded explicit approval.
- **Verification**: `air-gate` or a workflow checkpoint requesting approval.
- **Recording**: `approval.md` with date + signature (text or hash).

### M9 — Knowledge Base
- **Description**: `knowledge/` (Markdown files from the Researcher) + `knowledge/index.json` (index).
- **Mandatory**: every new task consults `knowledge/` before searching.
- **Verification**: the Coordinator checks that every decision consults the Knowledge Base.

---

## 4. Non-negotiable rules

These rules are **non-negotiable**. Any violation = phase failure.

| # | Rule | How enforced |
|---|---|---|
| 1 | No self-review | Verifier is a separate role; writes no code |
| 2 | No success claim without evidence | Mandatory evidence bundle per phase |
| 3 | No editing tests to satisfy broken code | `tests.hash` + CI check |
| 4 | No hardcoded secrets | gitleaks + SonarQube + OPA |
| 5 | No file > 400 lines | CI script |
| 6 | No function > 50 lines | CI script |
| 7 | No variable duplication | SonarQube duplication |
| 8 | No code without a test | coverage gate (≥80%) |
| 9 | No silently changing spec | `spec.hash` + check before each phase |
| 10 | No silent work | every step in `coordination-log.md` |
| 11 | No silent failure | every error in `error-registry` |
| 12 | No transition without a phase contract | approved `phase-contract` |
| 13 | No approval without owner sign-off | `air-gate` + `approval.md` |
| 14 | No building from scratch what exists | Researcher consults Knowledge Base + ready tools |
| 15 | No rewriting an existing project | additive work starts from current `docs/` + `git log` |
| 16 | No over-engineering | small projects start minimal (M1, M2, M4, M8); the rest added only when needed |
| 17 | CI is the only source of pass/fail evidence | any success/failure claim is accepted only from a signed artefact produced in external CI; agent-written files are not evidence |
| 18 | Local interception = detection, not prevention | local interception (hooks/OPA) detects and logs; real prevention lives only in Managed Devins + CI |
| 19 | `size:` is mandatory in the phase contract | every phase-contract declares project size (small/medium/large) — activates the proportional table; not accepted without it |
| 20 | Build phases follow M8 | GOVERNANCE_BUILD_PLAN itself is subject to approval — no transition between build phases (B<n>) without a recorded owner approval in `approvals/` |
| ~~21~~ | ~~Mandatory single runtime (Single-Environment Mandate)~~ — **RETIRED** | Required Git Bash only; retired because Git Bash proved unreliable (cygheap fork failures, ERR-007) and the runtime of record became WSL (ADR-001). Its spirit survives: policies like `wsl -u root` (P1) remain in force |

---

## 5. Project structure

```
project-root/
├── GOVERNANCE_SPEC.md          ← this document (repo root)
├── docs/
│   ├── spec.md                 ← P0 spec
│   ├── architecture/
│   │   ├── adr/                ← ADRs
│   │   ├── c4-context.mmd
│   │   ├── c4-container.mmd
│   │   ├── folder-structure.md
│   │   └── tech-stack.md
│   ├── blueprint/
│   │   ├── function-map.mmd
│   │   ├── data-flow.mmd
│   │   ├── test-plan.md
│   │   └── test-cases.md
│   ├── errors/                 ← error registry
│   │   ├── ERR-001.md
│   │   └── ...
│   └── research/               ← researcher reports
├── knowledge/                  ← Knowledge Base
│   ├── index.json
│   └── *.md
├── phase-contracts/
│   ├── P0-contract.md
│   ├── P1-contract.md
│   └── ...
├── evidence/
│   ├── P0/
│   ├── P1/
│   ├── P2/
│   ├── P3/
│   ├── P4/
│   ├── P5/
│   └── manifest.json
├── locks/
│   ├── spec.lock               ← spec hash
│   └── tests.lock              ← tests hash
├── coordination-log.md         ← log of every decision
├── approvals/
│   └── approval.md             ← owner approval
└── src/                        ← the code
    └── tests/
```

---

## 6. Workflow — worked example

**The owner wants a new project:**

1. **Owner** writes the idea in the parent session.
2. **Coordinator** calls the **Researcher** to understand the domain + find ready tools.
3. **Coordinator** writes `docs/spec.md` + `phase-contracts/P0-contract.md`.
4. **Owner** reviews the spec and approves (M8).
5. **Coordinator** creates `locks/spec.lock` (M3).
6. **Coordinator** dispatches the **Writer** to write `docs/architecture/`.
7. **Verifier** checks P1 completeness, **Skeptic** hunts contradictions.
8. **Coordinator** logs in `coordination-log.md` and moves to P2.
9. **Writer** writes `docs/blueprint/` + `docs/blueprint/test-plan.md`.
10. **Coordinator** creates `locks/tests.lock` (M4) — after the test plan is approved.
11. **Implementer** executes in an isolated VM, task by task, producing `evidence/P3/`.
12. **Verifier** checks the evidence automatically (OPA + CI + manifests).
13. **Attacker** runs security tests, produces `evidence/P4/`.
14. **Implementer** fixes vulnerabilities in a new round, **Attacker** verifies.
15. **Writer** drafts `evidence/P5/summary.md`.
16. **Owner** reviews all evidence and approves (M8).
17. **Writer** produces `release/`.

---

## 7. Learning from errors (Learning Loop)

**Every error passes through this cycle:**

1. **Detection**: an error is found (failing test, security scan, review).
2. **Registration**: documented in `docs/errors/ERR-<id>.md`:
   - Description
   - Root cause
   - Applied fix
   - Regression test
3. **Testing**: a regression test is added in `tests/regression/ERR-<id>.test.*`.
4. **Verification**: CI confirms the test fails before the fix and passes after (where possible).
5. **Rule**: if the error recurs, a new rule is added to `GOVERNANCE_SPEC.md` (section 4).
6. **Periodic review**: every 10 errors, a review of recurring patterns.

**Strict rule**: no error is closed without a regression test. No exceptions.

---

## 8. Incremental development (working on an existing project)

When adding a feature to an existing project:

1. **Coordinator** reads the current `docs/` + `coordination-log.md` + `git log`.
2. **Researcher** identifies what exists vs what is needed.
3. **Coordinator** writes an **addendum spec** (`docs/spec-addendum-<feature>.md`) — does not rewrite the original spec.
4. **Coordinator** creates a new phase-contract for the feature.
5. The rest of the phases are unchanged, except:
   - New evidence goes to `evidence/<feature>/P<n>/`.
   - The original `spec.lock` stays; a new `spec-addendum-<feature>.lock` is created.
   - The original `tests.lock` stays; a new `tests-addendum-<feature>.lock` is created.
6. **Forbidden**: rewriting `src/` from scratch. Changes are surgical.

---

## 9. Trust boundaries

| Who | Trusts | Does not trust |
|---|---|---|
| Owner | Signed evidence + verifier reports | any agent's claims |
| Coordinator | Role reports + evidence | the implementer's word about itself |
| Researcher | its documented sources | undocumented knowledge |
| Implementer | the blueprint + the spec | its own self-review |
| Verifier | tangible evidence | the implementer's claims |
| Attacker | the code + scan tools | the implementer's security claims |

**Rule**: every handoff between two roles passes through a **tangible trace** (file, hash, report), never through conversation.

---

## 10. Anti-patterns (what must not be done)

| # | Forbidden | Reason |
|---|---|---|
| 1 | Text walls (regex guards) as a substitute for real isolation | proven historical failure (WAFs) |
| 2 | Relying on "the agent will comply" | intent is not proof |
| 3 | Accepting "the Verifier said PASS" as evidence | needs a tangible trace |
| 4 | Building a separate identity inside the same account | security theatre |
| 5 | Stacking layers (hook → gate → check → audit) | complexity beyond the owner's grasp |
| 6 | Writing everything at once | prevents incremental verification |
| 7 | Editing tests to satisfy broken code | hides the problem |
| 8 | Rewriting an existing project from scratch | wastes prior work |
| 9 | Working without a phase contract | opens the door to fake completion |
| 10 | Approving without owner sign-off | violates the core principle |

---

## 11. Success metrics

| Metric | Target | How measured |
|---|---|---|
| Phases approved without rework | ≥ 80% | `evidence/P<n>/verdict.md` |
| Errors with a regression test | 100% | `docs/errors/` vs `tests/regression/` |
| Test coverage | ≥ 80% | `coverage-report.html` |
| Critical vulnerabilities remediated | 100% | `evidence/P4/` |
| Approvals without owner sign-off | 0% | `approvals/approval.md` |
| Test edits after freezing | 0% | `locks/tests.lock` mismatch |
| Time to resume a project (after a break) | ≤ 10 minutes | `coordination-log.md` |

---

## 12. Signature

**Owner**: ________________
**Date**: ________________
**Version**: 2.0

I acknowledge that I have read and understood this specification, and that it
is the fixed reference for all work on my projects.

---

## Appendix A: Quick checklist

Before any work, confirm:
- [ ] `GOVERNANCE_SPEC.md` exists in the project
- [ ] `docs/spec.md` approved by the owner
- [ ] `locks/spec.lock` exists
- [ ] `phase-contracts/P<n>-contract.md` approved
- [ ] Roles defined (who executes, who verifies)
- [ ] Evidence bundle (`evidence/P<n>/`) exists

After any work, confirm:
- [ ] `evidence/P<n>/manifest.json` updated
- [ ] `coordination-log.md` updated
- [ ] `docs/errors/` updated (if an error occurred)
- [ ] `locks/tests.lock` unchanged (unless authorized)
- [ ] Owner approved (if the phase requires it)

---

## Appendix B: Supporting tools

| Tool | Use | Status |
|---|---|---|
| OPA | policy gate (PDP) | installed |
| SonarQube | SAST + code quality | container available |
| gitleaks | secrets detection | needs install |
| OWASP ZAP | DAST | needs install |
| cosign | artefact signing | installed |
| GitHub Attestations | provenance | ready via gh |
| AEGIS | tamper-proof log | needs install |
| MJC | external adjudicator | needs install |

*MJC: a deterministic structural adjudicator — not another LLM model; not
currently installed and needs setup and activation before real use.*

---

**End of specification.**
