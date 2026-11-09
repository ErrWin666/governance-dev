# GOVERNANCE VISION — the owner's unified engineering statement

> Source: owner's own words (2026-11-09), translated verbatim to English.
> This document states **intent** — GOVERNANCE_SPEC.md is the contract that
> enforces it. If the two ever disagree, the spec governs and this file is
> the place to check what was meant.

## 1. Project lifecycle

### Phase Zero — Exploration and Planning (before any code)

When starting a new project, begin with a discussion session. In it:

- **Deep research** on the idea — sources, similar projects, existing tools, technologies, alternatives
- **Architecture and engineering environment** chosen and justified (why this one, not another)
- **Programming language** chosen with engineering justification (why Python, not Go; why Node, not Rust)
- **Tools and libraries** chosen with a reason for each (why this tool? what was the alternative? why was it rejected?)
- **Full documentation**: problem, scope, user, acceptance criteria, what is out of scope
- **Blueprint**: function map, classes, responsibilities of each
- **Flow diagrams**: logic flow and data/control flow
- **Test plan**: unit, integration, e2e, success criteria, thresholds
- **Clear MVP**: what ships in v1, what is deferred

**Governing rule**: no code before the owner approves this plan. The plan is
a fixed spec document that any later party returns to.

## 2. Coding rules

### Hard rules

**Security first:**
- No hardcoded secrets, passwords, or keys in code
- No committing any file containing sensitive data
- API endpoints handled per security and precision principles

**Variables and naming:**
- No scattered variables — a **central class/module** holds constants and settings, with comments stating where each is used; a large project gets one easy-to-edit configuration file instead of edits spreading through the code
- Consistent casing in names (no mixing `userName`/`Username`/`username`)
- No magic numbers — every constant has a name and a meaning

**Structure and behavior:**
- Follow **OOP, DRY, SOLID** and known design principles
- **No God Class**
- Class limit: **300 lines**; function limit: **40 lines**
- No duplicated code (DRY), no dead code
- No over-engineering — simplicity first; the complex solution only on proven need

**Logic:**
- Code may run while its logic is wrong — that is rejected
- No Clever Hans — no code that looks right but has broken logic
- On test failure: **fix the code or the logic, never edit the test** (editing a test to satisfy broken code = cheating)

**Logging and monitoring:**
- A defined **logging system**, not scattered `console.log`/`print`
- Every significant event logged; every error leaves a trace

### Advisory rules (do not block merges, only advise)

- Advanced Clean Code patterns
- Detailed SOLID (SRP, OCP, LSP, ISP, DIP)
- Readability metrics
- Refactoring suggestions

## 3. The multi-agent team

The project is not built by one agent. It is built by a team — each role with a defined responsibility:

- **Researcher**: deep-dives official docs and sources; finds tools, libraries, patterns — instead of reinventing the wheel; documents findings with sources.
- **Supervisor (Coordinator)**: coordinates roles, decomposes and dispatches tasks, collects results, decides phase transitions.
- **Implementer**: writes code in an isolated environment, follows only the approved plan, produces evidence (diff, tests, manifests).
- **Verifier**: checks that claims are evidence-backed, inspects citations (real `file:line`), compares output to the plan.
- **Skeptic**: hunts logical contradictions; asks "does the code do what was claimed?"; finds gaps between plan and implementation.
- **Attacker (Red/Blue)**: tests security vulnerabilities, tries to break the system, documents without fixing (fixing is the Implementer's).
- **Editor**: edits final documentation, drafts the summary from evidence only, adds no claims absent from evidence.
- **Independent Writer**: writes the final output isolated from the Implementer; reviews coherence and wording.

**Team rules:**
- Every role in an **isolated session** — cannot see the others' context
- Handoff via **files and evidence**, never conversation
- The Implementer **never approves its own work** — the Verifier is independent
- The Skeptic **writes no code** — documents only
- The Attacker **does not fix** — documents only
- The result: a project as if a **complete engineering team** built it

## 4. Skills and mandatory rules

- Skills load from known sources like **skills.sh** — no writing from scratch if one exists; mandatory on the main agent and subagents; every skill has: name, source, what it does, what it verifies
- Rules bind every agent regardless of role, in three categories:
  - **Hard Rules**: block the work on violation
  - **Role Rules**: bind one role (e.g., the Verifier never writes)
  - **Output Rules**: output format (e.g., ADHD style, concise reports)
- **Enforcement principle**: the agent does not "choose" compliance — rules are imposed from outside the agent (policies, CI, hooks). **What is not machine-enforced is not a rule — it is a suggestion.**

## 5. Governance mechanics

- **Centralized change**: a new policy = **one new file** (`p13_*.rego`), no edits to existing files; auto-discovery loads it
- **Easy deploy/update**: one command deploys governance onto a real project; one command updates it in existing projects without breaking local customizations — no manual copying
- **Tools**: use ready-made quality tools (SonarQube or any free tool); inventory existing MCP tools and wire them; suggest new tools when needed — do not invent; every tool connects via CI or hooks
- **Philosophy**: no claim without evidence; fail-closed; work outside the agent's reach (the agent never edits what governs it); the owner is the final authority

## 6. Elements carried from earlier context

- **Evidence bundles**: every phase produces `evidence/P<n>/`
- **Test freeze**: approved tests cannot be edited without approval
- **Spec freeze**: any spec edit requires re-approval
- **CI as the final wall**: unreachable by the agent
- **Role separation**: no role plans + executes + reviews + approves
- **Proportional governance**: small project = fewer policies; large = all
- **Error registry**: every error documented as ERR with root cause and lesson
- **Knowledge base**: research findings are never lost
- **Resume**: a new session resumes from files, not conversation
- **ADHD output style**: concise output, numbered steps, no preamble
- **Action over intent**: every claim needs evidence

## 7. The one-line summary

**Complete engineering governance that transforms the AI agent from a lone
implementer into a full engineering team working to clear standards,
producing verifiable evidence, and unable to cheat itself.**
