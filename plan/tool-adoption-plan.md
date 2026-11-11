# Tool Adoption Plan — staged, no skipping

Date: 2026-11-10 · Phase: B6 · Status: AWAITING OWNER APPROVAL (S1)
Sources: K-005, K-006, docs/MCP_TOOL_INVENTORY.md (42 tools verified)

## Stage gates — mandatory order

| Stage | What | Gate |
|---|---|---|
| **S0 Document** | this plan + inventories | done |
| **S1 Approve** | owner signs off per tool | approvals/approval.md line |
| **S2 Register** | add tool names to `tool-inventory.txt` | P5 passes else tools denied |
| **S3 Wire** | `allowed-tools` in `.devin/agents/*/AGENT.md` | profile loaded |
| **S4 Verify** | live call proves tool works for that role | evidence in handoffs/ |

No tool is "adopted" until S4 evidence exists. Frontmatter ≠ enforcement.

---

## 1. Global vulnerability databases (قواعد الثغرات العالمية)

| DB | Content | Access channel (free) | Role consumer |
|---|---|---|---|
| **NVD** | CVE + CVSS + CWE, US gov | `supply-chain-mcp`, `cve-mcp`, Web API | attacker, skeptic |
| **OSV** | package-version ↔ vuln, OSS | `supply-chain-mcp`, **osv-scanner CI (already live)** | attacker, verifier |
| **GHSA** | GitHub advisories | `github-mcp` (advisories toolset), `supply-chain-mcp` | attacker, verifier |
| **CISA KEV** | actively-exploited list | `supply-chain-mcp` | attacker (prioritization) |
| **EPSS** | exploit-probability scores | `supply-chain-mcp` | skeptic (severity challenge) |
| **ExploitDB** | public PoCs | `cve-mcp` | attacker |
| **Snyk DB** | enriched CVE+fix advice | snyk MCP (present; account-gated) | skeptic |
| **VulnerableCode** | multi-source OSS vulns | REST via webfetch (no MCP) | attacker (fallback) |
| **VulDB** | threat-intel + API | `vulners-mcp` — MONITOR (7★) | — |
| **OpenSSF Scorecard** | project hygiene | `supply-chain-mcp`, `deps.dev` | skeptic |

Rule: verdict.json cites **CVE/GHSA IDs** — a DB claim, not an opinion.

## 2. Scanner / analysis tools (الفحص)

| Tool | Type | Integration | Role |
|---|---|---|---|
| `sonarsource/sonarqube-mcp` ✅ OWNED | SAST+quality gate | Docker MCP (image pulled; needs USER token + Server 2025.1 — have 26.9) | verifier, attacker, implementer, supervisor |
| `semgrep mcp` | SAST rules | `semgrep mcp` stdio (semgrep 1.185 installed) | attacker, verifier |
| `aquasecurity/trivy-mcp` | CVE/IaC/secrets/fs | `trivy plugin install mcp` | attacker, skeptic |
| `mcp-zap-server` | DAST web | Docker, API-key auth | **attacker** (owner has web targets) |
| `osv-scanner` | deps CVE | CI (already in supply-chain.yml) | L2 |
| `gitleaks` | secrets | CLI only (no MCP needed) | attacker CLI |
| `sonar-scanner-cli` | scan push | CI / exec | L2 |

## 3. Orchestration / state / reasoning (اللوجستية)

| Tool | Purpose | Role |
|---|---|---|
| `@modelcontextprotocol/server-memory` | KG: project state, inter-role handoffs | supervisor, skeptic, writer |
| `server-sequential-thinking` | reasoning ledger skeptic can challenge | supervisor, skeptic |
| `github/github-mcp-server` | PRs, reviews, actions, GHSA, dependabot | supervisor, editor, verifier |
| `obsigno` | signed audit ledger (who did what) | L1 evidence — **first test** |

## 4. Research (البحث)

| Tool | Role |
|---|---|
| exa ✅ present | researcher |
| firecrawl (keyless) | researcher |
| fetch (reference) | writer |
| deepwiki ✅ present | researcher, verifier |
| context7 ✅ present | verifier, implementer |
| notion ✅ present | writer (owner-facing reports) |

## 5. CLI-only (no MCP — deliberate)

`gitleaks`, `osv-scanner`, `sonar-scanner`, `semgrep --sarif`, `mutmut`,
`dependency-cruiser` — run inside role `allowed-tools`/CI, no MCP wrapper
(adds attack surface for zero gain).

## 6. Rejected / deferred

constraints-registry (fails OPEN — anti-pattern), Snyk Evo ADS (paid),
Hecatoncheire (GPU WIP), Termonster (human GUI), Checkmarx/Veracode
(paywalled), Obot (org-scale overhead), auto-cmux (doesn't exist).

## 7. Adoption order (one tool at a time, S2→S4 each)

1. **obsigno** — cheapest L1 proof (signed audit, no keys, stdio wrap)
2. **sonarqube-mcp** — owned infra, biggest verifier value
3. **supply-chain-mcp** — arms attacker+skeptic with global DBs
4. **github-mcp** — PR/CI visibility for supervisor+editor
5. **trivy-mcp** / **mcp-zap-server** — attacker depth
6. **memory + sequential-thinking** — L3→L5 state plumbing

Each: owner approval → inventory entry → profile wire → live evidence.
