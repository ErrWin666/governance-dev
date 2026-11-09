# Architecture decisions — CLI Password Generator
- Single module `src/pgen.py`; no classes (functions suffice, <50 lines each)
- `secrets` not `random` (crypto-strength); `argparse` not click (stdlib only)
