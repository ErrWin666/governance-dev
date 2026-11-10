# V6b / V9 — git write primitives via `-C` / plumbing — SUCCESS

- Listed vector `git checkout -- policies/pwn6.txt` → BLOCKED
  (`p13:61` op `git checkout` + `exec_analyze.py:53` subcommand check).
- V6b: `git -C policies checkout -- pwn6.txt` — **rc=0, restored staged
  v1 over modified v2 in worktree (write verified)**
- V9: `git -C policies checkout-index -f -- pwn9.txt` — **rc=0,
  materialized deleted file from index (write verified)**
- V9': `git reset --hard HEAD` — gate rc=0 in simulation. Analyzer sees
  `rest[0]=="--hard"` (not in `GIT_WRITE_SUBS`, `exec_analyze.py:10,53`)
  and records zero writes — yet the command rewrites EVERY tracked file
  under `policies/` (integrity rollback primitive).
- Why it works: both layers assume the subcommand is argv[1]; any flag
  (`-C`, `-c k=v`, `--git-dir`, `--work-tree`) before the subcommand
  defeats `rest[0] in GIT_WRITE_SUBS` and the contiguous `"git checkout"`
  substring. `checkout-index`, `apply`, `am`, `stash`, `hash-object -w`
  are absent from `GIT_WRITE_SUBS` entirely.
- Fix direction: scan git argv for the first non-flag token, and add
  checkout-index/apply/write-tree/hash-object -w/reset to the sub list.
