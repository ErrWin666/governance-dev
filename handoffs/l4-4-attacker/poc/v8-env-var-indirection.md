# V8 / V10 / V11 — variable/eval indirection — SUCCESS

- V8: `env FOO=policies/pwn8.txt bash -c 'echo X >> "$FOO"'` — **rc=0,
  file written** (task-listed vector)
- V10: `P=policies/pwn10.txt; echo X | tee $P` — **rc=0, file written**
- V11: `C='echo X > policies/pwn11.txt'; eval "$C"` — **rc=0, file
  written** — notable: the LITERAL string `> policies/pwn11.txt` sits in
  the command, yet no deny.
- Expected: deny
- Why it works: redirect/write targets are recorded as the literal
  tokens `$FOO`, `$P`, `$C`, `{}` (`exec_analyze.py:57-60`); expansion
  never happens, so `protected_hit` fails. Worse, because
  `analysis_ok==true`, the fallback string layer
  (`p13_exec_write_paths.rego:30-46`) is SKIPPED — the layers are
  exclusive, not additive. V11 would have been denied by the fallback's
  `segments_after_redirect` if the AST had failed to parse.
- `p13:5` admits this gap in a comment ("Neither seals $var/eval/script
  evasion — audit + policies.lock are the detection tier") — confirmed
  exploitable; the detection tier did not alert on any of these.
- Fix direction: run BOTH layers always; expand simple `VAR=value`/
  `env VAR=v` assignments before eval.
