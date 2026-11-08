# ADR-003: P4 protects governance files from agent edits

## Status
Accepted

## Context
The agent's own edit/write tools could disable governance from the inside:
edit config.json to remove hooks, neuter gate.sh, or rewrite policies/*.rego
to allow everything. An earlier version of P4 protected only /src/,
/approvals/, and state.md — leaving the entire enforcement layer writable
by the thing it enforces upon. A governance system the agent can edit is
a suggestion, not a boundary.

## Decision
Extend P4 to deny any write/edit to:
- policies/gate.sh
- policies/*.rego
- policies/.governance/*
- %APPDATA%/devin/config.json
- %APPDATA%/devin/mcp_config.json

## Consequences
**Positive:**
- Agent cannot disable or weaken its own governance via Devin's tools
- The enforcement layer is now inside the enforced boundary (self-protection)
- Changes to governance files require human action outside the agent

**Negative:**
- Owner must edit these files from outside Devin (Notepad, PowerShell,
  WSL shell) — slower iteration on policy files
- Legitimate policy updates need an out-of-band workflow, adding friction
  to the Phase 3 centralization work

## Alternatives considered
- **Windows ACL only**: rejected — ACLs gate OS-level access but do not
  stop the agent's own edit/write tool calls; the deny must live in the
  hook/policy layer the tool call passes through
- **No protection**: rejected — unacceptable risk; a single prompt
  injection or agent error could silently dismantle enforcement

## References
- STATE.md §1 (P4 protects governance files), §6 (key files)
- docs/errors/ERR-009.md (adjacent: governance bypass vectors)
