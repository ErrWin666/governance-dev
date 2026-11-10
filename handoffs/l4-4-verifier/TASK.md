# TASK — Verifier (L4.4)

Claim under test: "The exec-write protection for protected paths is
complete and correct: p13 AST layer (exec_analyze.py) + string fallback
+ policies.lock integrity seal + P14 seal-forgery rule + 27/27 tests."

Work:
1. policies/p13_exec_write_paths.rego, policies/exec_analyze.py,
   policies/p14_deny_seal_forgery.rego, policies/gate.sh (integrity block),
   tests/policy/p13_test.rego, tests/policy/p14_test.rego
2. Subclaims: (a) protected-path writes denied both layers; (b) .approved
   denied for write/edit/notebook_edit AND exec; (c) tests cover AST AND
   fallback; (d) lock covers all policy inputs incl. exec_analyze.py.
3. file:line evidence per judgment.

Output: handoffs/l4-4-verifier/verdict.json (see roles/VERDICT_CONTRACT.md).
Write ONLY that file. Reply: one line.
