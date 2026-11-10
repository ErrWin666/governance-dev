# V5 / V5b / V12 — xargs / find -exec writes — SUCCESS

- V5: `echo policies/pwn5.txt | xargs touch` — **rc=0, file created**
- V5b: `find . -path './policies/pwn5b*' -exec sh -c 'echo X >> "$1"' _ {} \;`
  — **rc=0, appended to existing file**
- V12: `echo policies/pwn12.txt | xargs -I{} sh -c 'echo X > {}'`
  — **rc=0, file created**
- Expected: deny
- Why it works: `xargs`/`find` are not in `WRITE_VERBS`
  (`exec_analyze.py:8-9`); the real write verb/path arrives via argv
  substitution at runtime. In V12 the inner `sh -c` IS recursed but the
  redirect target is the literal `{}`, which is not a protected path.
- Fix direction: add `xargs`, `find -exec`, `parallel`, `watch`, `env`
  wrappers to a "launcher verbs" rule that requires -c/-exec argv
  inspection — though `{}`/`$1` substitution still needs data-flow.
