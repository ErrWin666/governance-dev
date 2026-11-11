# K-005 — MCP server research for the 8 roles (2026-11)

Source: background research agent, primary sources only (official repos,
registry.modelcontextprotocol.io, PulseMCP). Full report in session history.

## Registry landscape

- Canonical list: `registry.modelcontextprotocol.io` (launched 2025-09,
  API frozen at v0.1). `modelcontextprotocol/servers` (91.9k★) now holds
  only 7 *reference* servers, marked "not production-ready".
- PulseMCP indexes 21,500+ servers — popularity signal only; community
  servers are unvetted code.

## Adopt (free tier, mature)

| Server | Why | Roles |
|---|---|---|
| `github/github-mcp-server` (34.4k★, MIT) | PRs, reviews, actions logs, GHSA advisories, dependabot, code_security toolsets | supervisor, implementer, editor, verifier, attacker |
| `semgrep mcp` (subcommand of semgrep ≥1.137 — standalone repo ARCHIVED) | canonical SAST-via-MCP, 5k+ community rules free | verifier, attacker, implementer |
| `microsoft/playwright-mcp` (39.5k★, Apache-2.0) | #1-2 on PulseMCP, deterministic a11y snapshots | verifier, attacker |
| `@modelcontextprotocol/server-memory` (315k dl/wk) | KG entities/relations for project state + inter-role handoffs | supervisor, skeptic, writer |
| `@modelcontextprotocol/server-sequential-thinking` (282k dl/wk) | externalized reasoning ledger the skeptic can challenge | supervisor, skeptic |
| `badchars/supply-chain-mcp-server` | 18/21 free sources: OSV, GHSA, NVD, EPSS, CISA KEV, deps.dev, Scorecard | attacker, skeptic, verifier |
| `exa` + `firecrawl` (keyless) + `fetch` | research triad, all free without keys | researcher, writer |

## Monitor

- `getzep/graphiti` MCP (20k★) — temporal KG, best audit-trail architecture;
  ships with NO auth — harden first.
- `vulnersCom/vulners-mcp` (7★) — too young.
- `snyk mcp` — account-gated.
- TestSprite (present here) — BUSL-1.1 + cloud + wide tool surface: needs
  security review before role assignment.
- CodeQL MCPs — no mature turnkey option.

## Skip

- `semgrep/mcp` standalone repo — archived.
- Perplexity MCP — no free tier.
- Small community vuln/CodeQL wrappers — redundant or unvetted.

## Governance caveat (ours, not theirs)

Community MCP servers = unvetted code inside the agent loop. Before any
adoption: pin version, read-only/stdio only, add tool names to
`tool-inventory.txt`, and require the P5 inventory check to pass.
