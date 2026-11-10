# TASK — Skeptic (L4.4)

Target: the exec-write protection design (policies/p13_exec_write_paths.rego,
policies/exec_analyze.py, policies/gate.sh integrity block).

Hunt for ways this design could look right while being wrong:
1. Layering: when ana.ok==true, string rules are skipped — can analysis
   succeed while missing a write? (e.g. exec_analyze.py verbs list,
   `bash -c` depth cap, variable indirection, `python -c`, xargs, find -exec)
2. Lock: does `find policies -maxdepth 1` cover subdirectory files?
   Can exec_analyze.py itself be tampered without lock invalidation?
3. env trust: exec_analysis is computed by gate.sh — can an exec command
   influence what the analyzer sees (quoting, multibyte)?
4. Verifier/self-reference: who verifies the analyzer's own claims?

Every doubt → findings entry with file:line + why-it-matters.
Output: handoffs/l4-4-skeptic/verdict.json (roles/VERDICT_CONTRACT.md).
Write ONLY that file. Reply: one line.
