# MCP Inventory — current session servers mapped to L4 roles

Date: 2026-11-10 · Status: D-item · Source: live session tool registry

## What this session actually has (12 servers)

| Server | Type | Useful for | Role fit |
|---|---|---|---|
| **exa / exa-code** | web search + fetch (neural) | primary-source research, code search | **researcher**, skeptic |
| **deepwiki / devin/deepwiki** | GitHub repo docs + Q&A | library/repo intelligence, wiki Q&A | **researcher**, verifier |
| **context7** | up-to-date library docs | API/doc facts for implementation claims | **verifier**, implementer |
| **snyk** | vulnerability scanning | dependency CVE checks, SAST | **attacker**, skeptic |
| **TestSprite** | test generation/run | automated test evidence | **verifier** (testing role) |
| **corridor** | **dead** — list_tools fails | remove or report | none |
| **notion** | docs/wiki workspace | owner-facing reports, knowledge base | **writer**, editor |
| **mui-mcp / nuxt / ui-thing** | UI framework helpers | not relevant to governance core | none (project is CLI/bash/rego) |

## Role → tool mapping (today)

| Role | Has | Missing (candidate) |
|---|---|---|
| researcher | exa, deepwiki, context7 | — (covered) |
| verifier | context7, TestSprite | github-mcp (PR evidence), sequential-thinking |
| skeptic | exa, snyk | sequential-thinking, vuln-DB MCP |
| attacker | snyk, semgrep (CLI not MCP) | semgrep-mcp, osv-mcp, codeql-mcp |
| editor/writer | notion | markdownlint/lsp |
| implementer | all file/exec tools | github-mcp |
| supervisor | run_subagent | orchestration MCP (L5 scope) |

## Gaps — resolved by K-005 research

| Gap | Winner (free) | Roles |
|---|---|---|
| Vuln-DB unified | `badchars/supply-chain-mcp-server` (OSV/GHSA/NVD/EPSS/KEV, no key) | attacker, skeptic |
| SAST via MCP | `semgrep mcp` (built into semgrep ≥1.137) | verifier, attacker |
| GitHub/CI state | `github/github-mcp-server` (PRs, actions, advisories) | supervisor, verifier, editor |
| Knowledge graph | `@modelcontextprotocol/server-memory` | supervisor, skeptic, writer |
| Reasoning ledger | `server-sequential-thinking` | skeptic, supervisor |
| Research | exa ✅ already present + firecrawl (keyless) | researcher |

Adoption rule (governance): pin version, read-only where possible, add tool
names to `tool-inventory.txt` (P5 blocks unlisted tools), owner approves
each server before wiring into `.devin/agents/*/AGENT.md` allowed-tools.

## Notes

- `corridor` purpose unknown — probe `mcp_list_tools` before documenting further.
- UI servers (mui/nuxt/ui-thing) are irrelevant noise for this repo.
- Inventory rule: a server is "role-mapped" only after a live tool call proves it works.
