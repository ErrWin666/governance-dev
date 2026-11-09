# Spec — CLI Password Generator (verification seed for L3)

## Problem
Owner needs a local CLI that generates strong passwords without network calls.

## Scope
- IN: `pgen --length N --no-symbols --count K` → prints K passwords
- OUT: storage, GUI, entropy reports, passphrases, network sync

## Tech stack
- Python 3.12 stdlib only (`secrets`, `argparse`) — zero deps, fits L2 gates

## Functions and classes
- `build_alphabet(no_symbols: bool) -> str` — char pool
- `generate(length: int, alphabet: str) -> str` — one password via secrets.choice
- `main(argv: list[str]) -> int` — arg parsing, loop, print

## Data flow
args -> alphabet -> secrets.choice loop -> stdout

## API surface
CLI only: `--length` (8-128, default 20), `--no-symbols`, `--count` (default 1)

## Test plan
- unit: length, charset membership, count, arg validation
- mutation >=60%, diff coverage >=80% (L2 gates apply)

## MVP
v1 = the three functions + tests. No flags beyond the three above.

## Open questions
None — owner answered: py3.12, no deps, secrets module, tests required.

## Approval
PENDING — sha256 goes to plan/spec.approved + entry in approvals/approval.md.
