# V1 — interpreter bypass — SUCCESS

- Vector: `python3 -c "open('policies/pwn1.txt','w').write('PWNED-V1\n')"`
- Expected: deny (writes into protected `policies/`)
- Actual: **gate rc=0, file created, content verified**
- Why it works: `exec_analyze.py:8-9` `WRITE_VERBS` only lists shell write
  verbs; `python3` is not one. `p13_exec_write_paths.rego:11-18` sees no
  `writes` target. Fallback never runs because `analysis_ok==true`.
- Variant proven in same session: `python3 -c "import os; os.remove(...)"`
  — deletes protected files (used to clean `policies/pwn9.txt`).
- Fix direction: treat known interpreters (`python*`, `node`, `perl`,
  `ruby`, `powershell`, `pwsh`) as write-capable or require approval.
