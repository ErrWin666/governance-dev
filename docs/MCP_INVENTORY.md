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

## Gaps a new MCP would fill (research targets)

1. **Vuln-DB MCP** (OSV/NVD/GHSA unified) — attacker+skeptic cite real CVEs in verdict.json
2. **Semgrep MCP** — attacker runs SAST inside role context (now: CLI only)
3. **GitHub MCP** — verifier reads PR/CI state without exec
4. **Knowledge-graph MCP** — L3 knowledge/index.md upgraded to queryable graph
5. **Sequential-thinking** — skeptic structured reasoning traces

## Notes

- `corridor` purpose unknown — probe `mcp_list_tools` before documenting further.
- UI servers (mui/nuxt/ui-thing) are irrelevant noise for this repo.
- Inventory rule: a server is "role-mapped" only after a live tool call proves it works.
