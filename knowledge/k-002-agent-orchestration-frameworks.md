# k-002 — Multi-agent orchestration frameworks (L4)

Date: 2026-11-10 | Source: background research agent (web + GitHub)

## Key finding
Structural isolation (role cannot see implementer's context) exists only in:
- **Claude Agent SDK subagents** — separate context window, `tools:`/`disallowedTools:` per-agent, `isolation: worktree`, `maxTurns` (docs: code.claude.com/docs/en/sub-agents)
- **Devin API child sessions** — separate VM+session per spawn (docs.devin.ai) — **we have `devin_session_create` via MCP**
- **LangGraph subagents** — isolated invocation, only final result returns; state schema = the contract (langchain-ai/langgraph, MIT, ~44k stars)

## Disqualified for blind verification (shared history)
- AutoGen GroupChat (maintenance mode → MS Agent Framework)
- OpenAI Agents SDK/Swarm handoffs (shared history; input_filter ≠ isolation)
- CrewAI sequential (pastes prior outputs unless context=[])

## Worth copying
- MetaGPT (~71k★): typed artifact messages — handoffs as schemas not chat
- ChatDev (~35k★): phase-level role-pair isolation
- GPT-Engineer FilesDict: files as sole interchange medium — simplest governance
- Magentic-One Task/Progress Ledgers: best published supervisor pattern

## Lesson
Isolation is architectural (which primitive), never prompt-level. Shared-thread frameworks disqualify themselves by default.
