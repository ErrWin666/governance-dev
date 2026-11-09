# START_HERE — The Governance System in Plain Terms

> The one document the owner reads. Everything else is detail for engineers.
> Last updated: 2026-11-09.

## What this is

A supervision system for AI agents (like Devin). Agents cheat: they say
"done" without proof, fix the tests instead of the code, and edit the rules
that constrain them. This system is the rulebook + receipts + manager:

- **A doorman** — checks every action before it happens, can say no.
- **Receipts** — every claim must produce a proof file.
- **You, the manager** — the only one who approves anything.

## Your job — 3 signatures only (nothing more)

| When | What you do |
|---|---|
| Start of a piece of work | Read the plan, say "approved" — once |
| End of the work | Review the proof bundle, press merge — once |
| Anytime | Decide only when there's a conflict or exception |

If the system asks you for more than that, the design is wrong — report it.

## The building — 6 floors, honest status

| Floor | Name | Does | Status |
|---|---|---|---|
| 1 | The doorman | Blocks dangerous actions before they happen | ✅ Built & proven |
| 2 | Quality inspector | Automatic code checks before merging | 🟡 ~65% (2 of 3 checkers proven) |
| 3 | Written plan | No code without your signed plan | 🟡 ~50% (works, never finished a full cycle) |
| 4 | The detective | Checks whether claims are actually true | ❌ Not built — the most important one |
| 5 | Separate workers | Builder ≠ inspector, so no self-grading | ❌ Not built |
| 6 | Copy machine | Installs this whole system into real projects | ❌ Not built |

## How one piece of work flows

```
your idea → plan written down → YOU sign → agent builds →
receipts filed → independent check → PR → automatic gates → YOU merge
```

Every arrow produces a file you can check. No step is ceremonial.

## Problems → solutions

| Problem | The mechanism |
|---|---|
| Agent claims success with no proof | "Done" requires a proof file, checked |
| Agent edits the rules | Rule files are locked to it; only you edit |
| Agent sneaks past the doorman | Outer wall on GitHub — outside the agent's machine |
| Silent failure | Any gate failure = everything stops, loudly |
| Agent grades itself | Floor 4: a separate checker sees only the artifacts, never the agent's story |

## When things break

Every error becomes a numbered lesson (`docs/errors/ERR-001…016`) and, when
needed, a new rule. Nothing fails silently twice.

## What reduces YOUR burden (designed, not built yet)

- **Self-review (L0)**: a checker reads *my* responses on every reply and
  flags overclaims — so you don't have to watch me line by line.
- Approvals batched at the 3 signature points instead of scattered questions.
- `STATE.md` is the only page you ever need to read.

## Right now — the only open items needing you

1. `policies/.governance/current_phase` says `P4` but no code exists —
   change its contents to `P0` or delete it (it's locked to me).
2. When you want the password-generator pilot built: review `plan/spec.md`
   and say "approve" — it becomes approval A-003.

## Where things live

- Where we are: `STATE.md` · What works/missing: `docs/GAPS.md` ·
  Full design: `docs/DESIGN.md` · Errors learned: `docs/errors/`
