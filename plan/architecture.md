# Architecture decisions — CLI Password Generator
- Single module `src/pgen.py`; no classes (functions suffice, <40 lines each per spec v2.1)
- `secrets` not `random` (crypto-strength); `argparse` not click (stdlib only)
