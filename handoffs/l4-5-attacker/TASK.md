# TASK — Attacker with real tooling (L4.5)

You now have semgrep 1.185.0. Target: the governance repo itself —
policies/ (.rego + .py + gate.sh), tests/policy/, and the handoffs/
protocol design.

Work:
1. Run: `export PATH=$HOME/.local/bin:$PATH` first.
2. `semgrep scan --config p/security-audit --config p/owasp-top-ten --json -o /tmp/sarif.json policies/ src/` (or --sarif).
3. Also run a focused bash/injection ruleset if present (p/bash, p/command-injection).
4. Triage every finding: real vs noise; cite file:line.
5. Combine with your earlier knowledge — 8 residual holes remain documented
   in handoffs/l4-4-editor/OUTPUT.md; which did semgrep independently rediscover?

Output: handoffs/l4-5-attacker/verdict.json + handoffs/l4-5-attacker/semgrep.sarif.
Write ONLY under handoffs/l4-5-attacker/. Reply: one line.
