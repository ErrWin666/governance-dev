# k-004 — Isolation substrates & handoff protocols (L4/L5)

Date: 2026-11-10 | Source: background research agent (web + GitHub)

## Tool-scoped role enforcement (mechanical, not verbal)
- Claude Code agents: `.claude/agents/*.md` — `tools:` allowlist / `disallowedTools:`, `isolation: worktree`, `maxTurns`; read-only Verifier physically cannot write
- Copilot `.agent.md` — `tools:`, `user-invocable: false`, **`handoffs:` frontmatter = declared role state machine**; GitHub enforces requester≠approver (cannot approve own PR)
- Roo Code modes: `groups:["read"]` + `fileRegex` — per-file-glob write permission, enforced in code
- Devin sessions: separate VM/session per API spawn; org RBAC; intra-session tool scoping NOT publicly documented

## File-based handoff protocols
- **ai-agent-handoff** (krivonosoff161): `TASK.md` + `SESSION.md` + `handoff-metadata` JSON sidecar (digest, sequence, parent — fail-closed on mismatch). Closest complete protocol.
- codex-delegate: `.ai/handoff/NNN_slug.*.md` monotonic round-trips, repo-relative pointers
- AAHP RFC proposal: `.ai/handoff/` STATUS/NEXT_ACTIONS/LOG/TRUST.md
- Delimit: content-addressed JSON record, writer=MCP server, CLI-agnostic

## Substrate
- git worktree: edit isolation only — NOT a security boundary (same user/creds/network)
- Cursor: Firecracker microVM per agent
- tmux orchestrators (orch, cc-colony): per-agent env + file-mail queues

## Architecture for governance-dev
Coordinator → devin_session_create per role → TASK.md brief → role reads files only → verdict.json out → CI recomputes claims → no self-approval (identity separation)
