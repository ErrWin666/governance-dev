# Architecture — Agent Index

**Read this first.** This file routes you to the right document. Do not read
everything — read only what your task requires.

## Quick routing by question

| If you need to know... | Read |
|---|---|
| What is this system for? | 01-introduction.md |
| Who uses it, what external systems? | 02-context.md |
| What are the main components? | 03-building-blocks.md |
| How does security/logging work? | 08-crosscutting.md |
| What does term X mean? | 12-glossary.md |
| Why was decision Y made? | adr/ — see ADR index below |
| Where is the project spec / task list / resume state? | plan/ (L3 — spec.md, tasks.md, approved hashes; P12 gates src/) |
| How does self-review / L0 work? | ../docs/SELF_REVIEW_DESIGN.md (designed, not built) |

## ADR index (decisions, not documentation)

| ADR | Decision | Status |
|---|---|---|
| ADR-001 | WSL as runtime (not Git Bash) | Accepted |
| ADR-002 | fail_closed: true mandatory | Accepted |
| ADR-003 | P4 self-protection | Accepted |
| ADR-004 | CI as final enforcement wall | Accepted |
| ADR-005 | No permissions.deny reliance | Accepted |

## Rules for agents editing these docs
1. Never delete an ADR — supersede it with a new one (status: "Superseded by
   ADR-XXX")
2. Update AGENTS.md when adding new ADRs
3. Keep each file under 150 lines
4. Diagrams must be Mermaid (text), not images

## Last updated
2026-11-08
