# MCP Tool Inventory — consolidated, verified (2026-11-10)

Scope: RESEARCH AND DOCUMENTATION ONLY. Consolidates `docs/MCP_INVENTORY.md`,
`knowledge/k-005-mcp-servers-research.md`, `knowledge/k-006-sonarqube-scanner-mcps.md`
plus a fresh primary-source pass over the 24-name verification list. Nothing installed, nothing wired.
Layers: L1 Enforcement · L2 Quality/CI · L3 Planning · L4 Verification · L5 Orchestration · L6 Deployment.
Status tags: **documented** = confirmed on a primary source (GitHub/PyPI/npm/crates.io/official registry/vendor site);
**asserted** = found only via secondary aggregator or vendor claim; **unverified** = could not confirm.

Verification method (2026-11-10 pass): each of the 24 prior-research names was looked up on
GitHub, PyPI, npm, crates.io, and registry.modelcontextprotocol.io / registry mirrors (Glama,
mcpobservatory, mcpcentral). Where a name resolved, the canonical repo/package is recorded in §2;
star counts and versions are as published at lookup time and will drift. Where a name resolved to
a *different-shaped* thing than the name implied (Snyk Evo ADS = SaaS platform, agent-orchestrator-kit
= installer kit, Obot = full control plane), the table says so rather than pretending it is an MCP server.
"Devin?" = judged compatible with this CLI/bash/rego environment (stdio or HTTP MCP, Windows-friendly,
no exotic runtime) — an architectural estimate, not a tested claim.

## 1. Consolidated table

| Tool | Layer | One-line function | MCP? | Devin? | Integration | Maturity | License | Key limits | Source |
|---|---|---|---|---|---|---|---|---|---|
| github-mcp-server | L4/L5/L6 | PRs, actions, GHSA, code-security toolsets | Yes | Yes | stdio/HTTP MCP | 34.4k★ | MIT | needs GH token; wide surface | github.com/github/github-mcp-server |
| semgrep mcp | L2 | canonical SAST via MCP (`semgrep mcp`, ≥1.137) | Yes | Yes | CLI→stdio MCP | semgrep mature | LGPL-2.1 | standalone repo archived; heavy scans | semgrep.dev/docs/mcp |
| playwright-mcp | L2/L4 | deterministic browser a11y snapshots | Yes | Yes | stdio MCP | 39.5k★ | Apache-2.0 | browser deps; noisy on CI | github.com/microsoft/playwright-mcp |
| server-memory | L3/L5 | KG entities/relations for state+handoffs | Yes | Yes | stdio MCP | 315k dl/wk | MIT | ref-server, "not production-ready" | github.com/modelcontextprotocol/servers |
| server-sequential-thinking | L3 | externalized reasoning ledger | Yes | Yes | stdio MCP | 282k dl/wk | MIT | ref-server; no persistence guarantee | github.com/modelcontextprotocol/servers |
| supply-chain-mcp-server | L2/L4 | OSV/GHSA/NVD/EPSS/KEV/deps.dev, keyless | Yes | Yes | stdio MCP | small | Apache-2.0 | community, unvetted; rate limits | github.com/badchars/supply-chain-mcp-server |
| trivy-mcp | L2 | FS/image/IaC/secrets scan via trivy plugin | Yes | Yes | CLI plugin→stdio | 56★ official | MIT | needs trivy install; scan time | github.com/aquasecurity/trivy-mcp |
| mcp-zap-server | L2 | OWASP ZAP DAST wrapper | Yes | Yes | stdio MCP | 68★ | Apache-2.0 | only if DAST targets exist | github.com/dtkmn/mcp-zap-server |
| exa / exa-code | L3 | neural web+code search for research | Yes | present | HTTP MCP | mature svc | proprietary | account/quota | exa.ai |
| firecrawl | L3 | keyless web scrape/crawl | Yes | Yes | HTTP MCP | mature svc | proprietary/API | free tier limits | firecrawl.dev |
| fetch | L3 | reference URL fetch | Yes | Yes | stdio MCP | reference | MIT | ref-server | github.com/modelcontextprotocol/servers |
| snyk (session) | L2 | vuln scanning, SAST | Yes | present | MCP (live) | mature svc | proprietary | account-gated | snyk.io |
| deepwiki (session) | L3 | GitHub repo docs + Q&A | Yes | present | MCP (live) | svc | proprietary | repo coverage gaps | deepwiki.com |
| context7 (session) | L3/L4 | up-to-date library docs | Yes | present | MCP (live) | svc | proprietary | docs-only facts | context7.com |
| notion (session) | L3 | owner-facing reports/KB | Yes | present | MCP (live) | mature | proprietary | write-capable; scope tightly | notion.so |
| TestSprite (session) | L4 | test generation/run evidence | Yes | present | MCP (live) | svc | BUSL-1.1 | cloud + wide surface; needs sec review | testsprite.com |
| aegis-guardrails | L1/L2 | rules→agent at edit time; AST checks in pre-commit+CI | Yes | Yes | stdio MCP + CLI + hook + CI | v4.5.0, ~4★ | Apache-2.0 | single maintainer; new (Oct 2026) | github.com/nseney1/Aegis-Guardrails |
| constraints-registry | L1/L3 | queryable eng-constraint bundle + OPA/Checkov/Semgrep validate | Yes | Yes | stdio/HTTP MCP | v0.1.1 | Apache-2.0 | `get_constraints` fails OPEN; advisory only | github.com/SureshKhemka/constraints-registry |
| toolleash | L1 | synthesize least-privilege tool policies from OTel traces | Yes | Yes | CLI + MCP allow-list emit | v0.1.1 pre-1.0 | Apache-2.0 | no PyPI-1.0; repo named AgentProbe | github.com/Avanishk05/AgentProbe |
| obsigno | L1/L4 | stdio policy proxy + Ed25519 hash-chained audit ledger | Yes | Yes | stdio proxy | v0.3.0, small | Apache-2.0 | in-line = latency/SPOF; young | github.com/amudhan22/obsigno |
| mcp-governance-proxy | L1 | hold risky tool calls for human review | Yes | Yes | HTTP MCP proxy | v0.x, 0★ | Apache-2.0 | generic name, 0★, overlaps obsigno | github.com/andreas-altamirano/mcp-governance-proxy |
| Snyk Evo ADS | L1/L4 | platform: PreToolUse/PostToolUse hooks + MCP governance | No (platform) | Partial | hook + SaaS | GA 2026 | proprietary | paid; not a self-host MCP | snyk.io/evo |
| Rigour | L2 | agent self-review gates, fix packets, learned rules | Yes | Yes | stdio MCP + hooks | v7.0.14, ~29★ | MIT | JS/TS-centric; churn (498 rels) | github.com/rigour-labs/rigour |
| PMAT | L2 | TDG score, mutation testing, 157-check compliance, gates | Yes | Yes | `pmat agent mcp-server` stdio/HTTP | v3.43.0, ~170★ | MIT OR Apache-2.0 | Rust install; heavy for small repos | github.com/paiml/paiml-mcp-agent-toolkit |
| emetgate | L1/L4 | fail-closed write gate: reparse+rules+tests before disk | Yes | Partial | stdio MCP (Zig bin) + lockdown | v0.8.0, ~4★ | MIT | Windows-only; TS/JS/Zig only; not signed | github.com/emetgate/emetgate |
| stepcheck-dev | L3/L4 | anti-context-rot kernel: gated commits, DSSE attestations | Yes | Yes | Streamable HTTP MCP + Studio | v0.3.4, small | Apache-2.0 | brand-new (Nov 2026); heavy stack | github.com/lalithasutam/stepcheck-dev |
| Hound (hound-mcp) | L2 | dependency bloodhound: vulns/license/typosquat, 7 ecosystems | Yes | Yes | stdio MCP | 17★, npm | MIT | deps.dev+OSV only; no private registries | github.com/tiluckdave/hound-mcp |
| agentic-sdlc-mcp | L1/L5 | SDLC control plane: HITL gates, quality thresholds over GitHub | Yes | Yes | stdio MCP (npm) | v1.11.0, 1★ | MIT | 1★; needs GITHUB_TOKEN | github.com/SakuraCianna/agentic-sdlc-mcp |
| hallucc-mcp | L4 | claim-by-claim hallucination check + CUA risk gating | Yes | Yes | HTTP MCP (hosted) + npm | v0.1.11 | MIT | paid quota via aihcc.cloud; CN docs | github.com/fredyee/hallucc-mcp |
| verification-mcp | L4 | fact/citation/freshness check vs Wikipedia/Crossref/Wayback | Yes | Yes | hosted HTTP MCP | v0.1.1, 1★ | MIT (repo header) | 4.6% uptime on Glama; hosted-only | github.com/guptaprakhariitr/verification-mcp |
| colab-ai-mcp | L4 | academic citation verification (Crossref/S2/DBLP/arXiv) | Yes | Yes | stdio MCP (npm) | v1.2.0 | unverified | niche (papers); license not declared | github.com/AhmedCoolProjects/colab-ai-mcp |
| verify-api-mcp | L4 | 8 evidence-backed verify_* tools (citation/URL/pkg/repo…) | Yes | Yes | stdio MCP (PyPI) | v0.6.0 | MIT | x402 pay-per-call or API key | github.com/mgdsn/verify-api-mcp |
| session-mesh-mcp | L5 | multi-agent coordination kernel, cross-session mesh | Yes | Yes | stdio MCP + dashboard | v0.2.1, 1★ | MIT | 1★; ex-name agent-mesh-mcp | github.com/ShashankIIITN/session-mesh-mcp |
| rutherford-mcp-server | L5 | orchestrate existing agent CLIs (Claude/Codex/Goose) via ACP | Yes | Yes | stdio MCP (PyPI) | v3.3.0, 4★ | MIT | needs agents' CLIs+logins present | github.com/chapmanjw/rutherford-mcp-server |
| Hecatoncheire | L5 | writer/validator/observer multi-agent loop, local LLM | Yes | Partial | docker stdio MCP | WIP, 1★ | none declared | needs NVIDIA GPU; self-marked WIP | github.com/srose69/hecatoncheire |
| agent-orchestrator-kit | L3/L5 | OpenSpec role-pipeline kit + subagents + CI gate-check | No (kit) | Yes | npx installer + CI yml + MCP tpl | v0.18.1, 1★ | MIT | Cursor/Claude/Amp only; not a server | github.com/makshc2/agent-orchestrator-kit |
| ForkFlux | L5 | self-hosted job/handoff bus + audit for agent teams | Yes | Yes | stdio/Streamable HTTP MCP | v0.6.0, 6★ | Apache-2.0 | needs FastAPI service + tokens | github.com/forkflux/forkflux |
| MCP as a Judge | L3/L4 | LLM-judge gates on plan, diff, tests via MCP sampling | Yes | Yes | stdio MCP (PyPI) | v0.5.0, 17★ | MIT | judge needs an LLM call (cost, non-det) | github.com/OtherVibes/mcp-as-a-judge |
| Obot Platform | L1/L5 | enterprise MCP gateway/control plane: SSO, audit, catalog | Gateway | Partial | self-host server + filters | 1.1k★ | MIT | heavy infra; org-scale not repo-scale | github.com/obot-platform/obot |
| sonarqube-mcp (owner) | L2/L4 | official SonarQube toolsets (gates/issues/hotspots/snippets) | Yes | Yes | stdio/HTTP, Docker or JAR | 584★ official | SSAL | needs Server ≥2025.1; USER token; 1 write tool | github.com/SonarSource/sonarqube-mcp-server |
| Termonster (owner) | — | human GUI smart terminal w/ AI hub | No | No | desktop app | v0.5.1 beta | proprietary | no MCP/API surface; human-facing only | termonster.monstersgate.com |
| copier (owner) | — | project template engine | No | Yes | CLI | mature | MIT | not governance; not MCP | github.com/copier-org/copier |

## 2. The 24-name verification list (all resolved)

| # | Name | Verdict | Canonical identity |
|---|---|---|---|
| 1 | aegis-guardrails | documented | nseney1/Aegis-Guardrails (PyPI `aegis-guardrails` v4.5.0) |
| 2 | constraints-registry | documented | SureshKhemka/constraints-registry (on official registry) |
| 3 | toolleash | documented | Avanishk05/AgentProbe (PyPI `toolleash` v0.1.1) |
| 4 | obsigno | documented | amudhan22/obsigno (PyPI v0.3.0) |
| 5 | MCP Governance Proxy | documented* | andreas-altamirano/mcp-governance-proxy — generic name; 0★ repo confirmed, also cf. mcpambassador/server |
| 6 | Snyk Evo ADS | documented | snyk.io/evo — real product; it is a SaaS platform w/ hooks, NOT an MCP server |
| 7 | Rigour | documented | rigour-labs/rigour (@rigour-labs/mcp v7.0.14; on official registry) |
| 8 | PMAT | documented | paiml/paiml-mcp-agent-toolkit (crates `pmat` v3.43.0) |
| 9 | emetgate | documented | emetgate/emetgate (emetgate.dev; MIT; Windows+TS/JS/Zig only) |
| 10 | stepcheck-dev | documented | lalithasutam/stepcheck-dev (PyPI v0.3.4) |
| 11 | Hound | documented | tiluckdave/hound-mcp (npm `hound-mcp`) |
| 12 | agentic-sdlc-mcp | documented | SakuraCianna/agentic-sdlc-mcp (npm v1.11.0; on registry) |
| 13 | hallucc-mcp | documented | fredyee/hallucc-mcp (npm; hosted aihcc.cloud/mcp) |
| 14 | verification-mcp | documented | guptaprakhariitr/verification-mcp (hosted workers.dev; on registry) |
| 15 | colab-ai-mcp | documented | AhmedCoolProjects/colab-ai-mcp (npm) |
| 16 | verify-api-mcp | documented | mgdsn/verify-api-mcp (PyPI v0.6.0); NB second impl KyTheKitty/verifyapi-mcp — different project |
| 17 | session-mesh-mcp | documented | ShashankIIITN/session-mesh-mcp (PyPI v0.2.1) |
| 18 | rutherford-mcp-server | documented | chapmanjw/rutherford-mcp-server (PyPI v3.3.0) |
| 19 | auto-cmux | **unverified** | no project by this name; nearest = multiagentcognition/cmux-agent-mcp, puchkoff/cmux-mcp, EtanHey/cmuxlayer; `auto-cmux` is only a module name inside alvinunreal/oh-my-opencode-slim |
| 20 | Hecatoncheire | documented | srose69/hecatoncheire (WIP, no license, GPU req) |
| 21 | agent-orchestrator-kit | documented | makshc2/agent-orchestrator-kit (npm v0.18.1; an installer kit, not an MCP server) |
| 22 | ForkFlux | documented | forkflux/forkflux (PyPI `forkflux-mcp` v0.6.0, Apache-2.0) |
| 23 | MCP as a Judge | documented | OtherVibes/mcp-as-a-judge (PyPI v0.5.0; on registry) |
| 24 | Obot Platform | documented | obot-platform/obot (1.1k★, MIT; full control plane, not a single server) |

\* "documented" here means the repo exists; the name itself is generic — pin the exact repo if adopted.

## 3. Owner-asked tools (honest assessment)

- **Termonster** — real product (termonster.monstersgate.com; releases via MahmoudAdelMansour/Termonster-Releases). It is a *human-facing* GUI terminal with an AI hub; no MCP server, no API surface documented. Correct call: **not a governance layer** — a productivity shell. Reject for this system. Status: documented.
- **SonarQube** — official `sonarsource/sonarqube-mcp` exists (K-006 verified, 584★, SSAL). Owner's instance is **26.9.0 ≥ the 2025.1 floor** and `mcp:latest` image is already pulled (container stopped). Requirements: USER-type token, `SONARQUBE_URL`, `TELEMETRY_DISABLED=true`, drop `change_sonar_issue_status` from read-only roles. Cheapest zero-infra alternative remains the Web API (`api/qualitygates`, `api/issues/search`, `api/hotspots/search`). **Green light to test** — the only owner-asked tool that fits a layer (L2/L4). Status: documented.
- **copier** — copier-org/copier is a mature template/scaffolding engine (MIT). Useful for repo bootstrap, but **not MCP and not governance**. Reject for this system. Status: documented.

## 4. Verification status summary

- **documented (primary source confirmed): 41 of 42 rows** — all 24-list names except `auto-cmux` resolve to a real repo/package; all prior K-005/K-006 picks and session servers re-confirmed or carried forward from their verified research docs.
- **asserted:** none remaining — every carried claim is backed by a primary URL in §1/§2.
- **unverified: 1** — `auto-cmux` (§2 #19). License-unverified cells: `colab-ai-mcp` (license not declared); `Hecatoncheire` (NOASSERTION); `verification-mcp` (GitHub flags "Other", README header says MIT).

## 5. Per-layer recommendation (primary + fallback)

| Layer | Primary | Fallback |
|---|---|---|
| L1 Enforcement | **obsigno** — deny-by-default stdio proxy w/ signed audit ledger | aegis-guardrails `aegis check` (pre-commit/CI, fail-closed at commit) |
| L2 Quality CI | **semgrep mcp** + owner **sonarqube-mcp** (26.9.0 passes floor) | PMAT gates / hound-mcp / trivy-mcp |
| L3 Planning | **MCP as a Judge** (`judge_coding_plan`) + constraints-registry advisory | agent-orchestrator-kit OpenSpec pipeline |
| L4 Verification | **TestSprite** (already live) + hallucc-mcp for claim checks | MCP as a Judge `judge_*`; emetgate only if TS/JS/Zig scope appears |
| L5 Orchestration | **rutherford-mcp-server** (ACP, reuses existing CLI logins) | session-mesh-mcp; ForkFlux when cross-machine handoffs/audit needed |
| L6 Deployment | **github-mcp-server** actions/deployments toolsets | agentic-sdlc-mcp release signals + existing `scripts/` CI gates |

## 6. Integration risks

- **Fail-open vs fail-closed:** constraints-registry `get_constraints` *fails open by design* — advisory only, never a gate. emetgate and obsigno are fail-closed; aegis's CI gate is fail-closed. Rule: advisory tools may sit anywhere; enforcement tools must fail closed and log.
- **SPOF / latency:** in-line stdio proxies (obsigno, mcp-governance-proxy, mcp-leash-class tools) sit on every tool call — a proxy crash stalls the agent; budget for restart + timeout policy. Hosted services (hallucc, verification-mcp 4.6% uptime, verify-api) add a network dependency and an external trust boundary.
- **Cost:** hallucc (per-call quota), verify-api (x402 pay-per-call), snyk/Evo ADS and TestSprite (account/SaaS). MCP-as-a-Judge burns an LLM call per gate — non-deterministic verdicts; keep it advisory, not blocking.
- **Maintenance:** most L1/L5 candidates are 0–6★, single-maintainer, months old — pin versions, vendor configs, and keep a no-MCP fallback path per layer. Rigour churns releases weekly (498 shipped); obsigno, stepcheck-dev, aegis, session-mesh are all <3 months old — expect breaking changes.
- **Data egress:** hosted tools (hallucc, verification-mcp, verify-api, Snyk Evo, Obot cloud features) send code/claims/tool metadata off-box; a governance system that audits agents cannot itself leak prompts to an unvetted endpoint — self-host or drop.
- **Token/context tax:** broad toolsets (github-mcp-server, PMAT's 20 tools, TestSprite) inflate the system prompt; expose only the tool subset each role needs.
- **Trust:** community MCPs are unvetted code in the agent loop (K-005 caveat stands): stdio-only, read-only tool subsets, pin versions, add tool names to `tool-inventory.txt`, owner approval per server.

## 7. Rejected / parked

- `auto-cmux` — name unverifiable; cmux-class tools are macOS terminal multiplexers, wrong fit anyway.
- `Hecatoncheire` — self-declared WIP, no license, NVIDIA-GPU docker requirement.
- `corridor` (session server) — dead, `list_tools` fails; remove from session config.
- `Snyk Evo ADS` — real but a paid SaaS platform, not a composable layer; revisit only if owner buys Evo.
- `mcp-governance-proxy` / aca-govern / Ydris-class wrappers — 0–3★ and fully overlapped by obsigno.
- gitleaks/Nuclei/Bearer/Checkmarx/Veracode MCP wrappers — CLI-first tools (K-006); wrappers add risk, zero gain.
- `semgrep/mcp` standalone repo — archived; use `semgrep mcp` subcommand.
- `Termonster`, `copier` — real, wrong category (§3).
- Obot Platform — excellent but org-scale infrastructure; park until multi-user need exists.

## 8. Single best first tool to test

**obsigno** (`pip install obsigno`, github.com/amudhan22/obsigno, Apache-2.0, v0.3.0).

Why: L1 enforcement evidence is the system's deepest gap — every other layer consumes the answer
to "what was the agent allowed to do, and can we prove it?" obsigno is the only candidate that
produces that proof directly: a policy-enforcing stdio proxy whose every decision lands in an
Ed25519-signed, hash-chained ledger — exactly the evidence artifact the governance spec wants.

Why it is also the cheapest test: no accounts, no API keys, no network, no new infrastructure —
it wraps any existing stdio server, so it can be exercised inertly against `server-memory` or
`fetch` already in the tool set. One config block + one wrapped server + one denied call proves
the whole L1 audit primitive: deny → JSON-RPC error → signed ledger entry.

Runner-up: owner sonarqube-mcp (§3) — higher certainty (official, 584★) but only covers L2/L4
read signals and needs token setup; test it second.

MCP TOOL INVENTORY COMPLETE. No tools installed. No integrations tested. Awaiting owner decision on which tool to test first.
