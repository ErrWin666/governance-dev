# Landscape Research — Agent Governance Tools & Architectures

> Date: 2026-11-09. Question: do engineering tools/architectures exist that
> match the governance-dev idea (L1 gate → L2 CI → L3 plan → L4 verify →
> L5 orchestrate → L6 deploy)? Sources: primary docs/repos where possible.

## Headline

The idea is not novel as a whole — an industry category formed in 2025–2026
usually called **agent governance** or **policy-as-code for agents**. Every
layer has a working analogue. The two most valuable findings:

1. **L4 (independent verification) has academic + tool proof it works** —
   a fresh-context verifier caught more seeded faults than the builder's own
   tests (arxiv 2610.28667, p=0.006, 46 seeded faults).
2. **The owner's hard-gated plan layer (P12 hash-locked approval) is a real
   differentiator** — spec-kit/Kiro/BMAD are advisory conventions; nothing
   found gates `src/` writes on an approved-hash match like P12 does.

## L1 — enforcement gate (hook → policy → fail-closed)

The PDP/PEP pattern (policy decision point outside the model; enforcement
point in front of each tool) is now standard vocabulary for agents:

- **Vercel AI SDK `@ai-sdk/policy-opa`** — OPA tool-approvals built into the
  SDK; policy input includes full message history; CI-testable with `opa test`.
- **Microsoft agent-governance-toolkit (AGT)** — closest industrial analogue.
  Agent Control Specification (Rust core): stateless, deterministic,
  **fail-closed** policy runtime evaluated at 8 intervention points incl.
  `pre_tool_call`; OPA dispatcher; SDKs for Py/Node/.NET/Rust. Adds Agent
  Runtime "four privilege rings" (≈ our role→tool envelopes), Agent SRE kill
  switch, Agent Compliance. Claims 10/10 OWASP Agentic Top 10 coverage.
  github.com/microsoft/agent-governance-toolkit
- **MCP gateways** (all enforce per-tool-call policy + audit):
  EnforceAuth Portcullis (Gate/Keep/Guard, OPA delegate, escalate→signed JWT),
  Permit MCP Gateway (per-call authz, consent screens, deny-by-default),
  Docker MCP Enterprise Gateway, yogesh895/gate-mcp (YAML rules:
  deny/allow/warn/redact/require_approval, approval workflows, audit).
- **Claude Code PreToolUse hooks** — same interception mechanism as our L1
  (JSON payload on stdin, allow/deny/ask + input rewrite). Confirms the hook
  contract is a cross-vendor standard, not a Devin oddity.
- Articles formalizing the pattern: Gökhan Gökalp "Runtime Governance for AI
  Agents: Policy-as-Code with OPA" (identical flow: agent decides tool call →
  OPA eval → allow/deny → fail closed if OPA unreachable); Cyber Strategy
  Institute "Policy as Code for AI Agents" (PDP three-way verdict
  allow/deny/escalate + policy version recorded per decision — matches our
  decision{allow,reasons} + gate.log); IBM Community "Three-Tier Tool
  Classification" (auto-allow / guarded / blocked-or-approve).

**Our differentiators vs the field:** local file-system governance of a
coding agent (most products gate MCP/network tools, not writes to src/),
fail-closed proven on our own machine (ERR-010), and P4 self-protection of
the policies themselves.

## L2 — CI quality gates

Standard industry practice (required checks, rulesets, gitleaks, CODEOWNERS).
Adjacent LLM-output guardrails exist (NeMo Guardrails, Guardrails AI,
Protect AI LLM Guard — **archived 2026-07**, cautionary lesson on tool
lifespan). arcasilesgroup/ai-engineering — repo-installed governance via git
hooks, 12 procedures + 6 guards; notable for honest verification language
(receipt-derived status, calls surfaces "unproven" without a denial receipt).

## L3 — plan-first convention

Spec-driven development is a named, tool-backed category:

- **GitHub spec-kit** — constitution → specify → plan → tasks → implement →
  converge; 41+ agent integrations; Markdown artifacts per phase.
- **AWS Kiro** — requirements → design → tasks; "steering" docs as memory.
- **BMAD-METHOD** — persona roster (Analyst/PM/Architect/SM/Dev/QA +
  Orchestrator); **artifacts hand off as files, not chat** — same principle
  as our "evidence flows as files"; explicit HITL gates.
- **OpenSpec** — per-change spec deltas merged into a spec library.
- **KbWen/agentic-os** — plan→build→review→test→ship; evidence validator +
  git hook + CI job; honest limit: "catches a phase missing from the record,
  not a faked record" (≈ our workflow-guard honest limitation).
- **DimitriGeelen/agentic-engineering-framework** — tiered authority model:
  Human=SOVEREIGNTY / Framework=AUTHORITY / Agent=INITIATIVE; "agent may
  propose, never approve its own work". Maps 1:1 to our three boundaries.

**Our differentiator:** all of the above are conventions/skills — none
*enforces* the spec→approval→tasks→approval chain at the tool-call layer.
P12 (hash-locked approval files + OPA deny on src/ writes) is hard
enforcement of what others leave advisory.

## L4 — independent verification (the unbuilt core)

The exact pattern exists and is validated:

- **arXiv 2610.28667 — "Who Verifies the Builder? Toward Independent
  Assurance for Agent-Produced Software"**: argues for an *assurance plane
  structurally independent of the build plane*; Verification Contract;
  spec-first verification phase *designed without access to the
  implementation*; then mutation analysis + PBT + fuzzing; human keeps the
  release decision. Pre-registered study: fresh-context verifier detected
  more of 46 seeded faults than builder's own tests (p=0.006); a different
  model provider added nothing. **Empirical basis for: artifact-only
  verifier inputs, mutation gates, owner-keeps-merge.**
- **ontojoseki/agentic-verification-protocol** — Generator / Verifier /
  human Supervisor; "neither session can do the other's job"; 3 deployment
  modes (folder → git+signed commits → cross-account IAM).
- **visione4906/ctaio-claimcheck** — fresh `claude -p` per claim (no shared
  context), ripgrep deterministic retrieval, LLM only for judgment, verdict
  overruled to UNVERIFIABLE without file:line evidence (fail-closed on
  missing evidence — exactly our R5).
- **kaguc adversarial-review writeup** — N auditors, one dimension each;
  findings must land as file:line + failure scenario; independent verifier
  falsifies; only CONFIRMED enters repair queue. = our skeptic role.
- **hibou04-ops/antemortem-cli** (v0.11.1, already in ROADMAP) — forces
  file:line citation per claim, re-checks each citation against disk bytes
  offline, emits fabrication rate, CI gate on it. Confirmed real, active,
  PyPI-published.
- **DeepCitation** — same citation-verification idea for document domains.

## L5 — orchestration / role separation

- **MetaGPT** — `Code = SOP(Team)`: PM→Architect→PM→Engineer→QA pipeline;
  role profiles with scoped tools (PM gets web search, Engineer gets exec) —
  same idea as our role→tool envelopes.
- **Microsoft AGT Agent Runtime** — "execution sandboxing with four
  privilege rings" — industrial version of our envelope table.
- **agentic-verification-protocol Mode 3** — cross-account IAM separation as
  the enterprise version of isolation.

**Honest gap in the whole field (and ours):** most multi-agent frameworks
separate roles by *convention* — same process, same permissions. Hard
isolation (different OS users / VMs / accounts) is rare and mostly
enterprise-only.

## L6 — deployment / replication

- **Golden Path / Paved Road** — Spotify (Backstage scaffolder templates)
  and Netflix named this: opinionated, pre-wired project templates; "make
  the right way the easy way". Our small/medium/erp profiles = a
  governance-only golden path.
- **copier** — confirmed correct Q10 choice: `copier update` propagates
  template changes into generated projects via git-tag diffs + migrations;
  cookiecutter can't update (needs Cruft add-on). Stuart Ellis "Evolving
  Collections of Projects by Using Shared Copier Templates" describes the
  exact use case: one template, many projects, all evolve together.

## Threat-model basis

**OWASP Agentic/LLM Top 10 (2026)** — Excessive Agency (LLM03) is the core
risk this whole system controls (excessive functionality/permissions/
autonomy); Agent Goal Hijack, Tool Misuse, identity/privilege abuse cover
the rest of the threat model. Microsoft AGT maps its controls to 10/10 items
— usable as a completeness checklist for our threat model.

## Scientific-method connection

The arXiv verifier paper is literally the method asked for: pre-registered
hypothesis, seeded faults, statistical test. Our ERR registry + seeded-PR
negative tests are the same method, informal. Formalizing = per-decision
hypothesis + falsification test + recorded result (see rebuild plan).

## What to steal (candidate list for rebuild)

1. ACS 8-intervention-point model — our hook covers pre_tool_call only;
   `post_tool_call` and `output` are free extra gates.
2. Three-way verdict **escalate** (not just allow/deny) — matches owner
   approval; removes friction without weakening gates.
3. Policy version recorded per verdict — trivially cheap, improves audit.
4. Verification Contract + spec-first phase (verifier writes checks before
   seeing the diff) — strengthens L4 beyond our current design.
5. OWASP Agentic Top 10 as threat-model checklist.
6. agentic-os's honest-record framing — adopt its language for what a
   validator can and cannot prove.
7. Privilege rings as the formal name for role→tool envelopes.

## Sources (primary)

- github.com/microsoft/agent-governance-toolkit + microsoft.github.io/agent-governance-toolkit
- ai-sdk.dev/docs/agents/policy-tool-approvals
- code.claude.com/docs/en/hooks
- github.com/github/spec-kit + github.github.com/spec-kit
- github.com/bmad-code-org/BMAD-METHOD + bmadcode.com/method
- github.com/FoundationAgents/MetaGPT + arxiv.org/abs/2308.00352
- github.com/KbWen/agentic-os; github.com/arcasilesgroup/ai-engineering;
  github.com/DimitriGeelen/agentic-engineering-framework;
  github.com/jonathanmr22/pact; github.com/chasesaurabh/ai-governance
- arxiv.org/html/2610.28667 (Who Verifies the Builder?)
- github.com/ontojoseki/agentic-verification-protocol;
  github.com/visione4906/ctaio-claimcheck; kaguc.com/blog/adversarial-review
- github.com/hibou04-ops/antemortem-cli + pypi.org/project/antemortem;
  github.com/DeepCitation/deepcitation
- docs.enforceauth.com (Portcullis); permit.io/mcp-gateway;
  docker.com/products/mcp-enterprise-gateway; github.com/yogesh895/gate-mcp
- slsa.dev + in-toto.io + github.com/in-toto/attestation
- genai.owasp.org (Agentic Top 10 2026, LLM03 Excessive Agency)
- copier.readthedocs.io (updating/comparisons); stuartellis.name copier notes
- gokhan-gokalp.com OPA agents post; cyberstrategyinstitute.com PaC agents;
  IBM Community PaC MCP blog
