# BLOCKED vectors — documented per contract

| Vector | Command | Expected | Actual |
|---|---|---|---|
| V2 | `bash -c 'echo x > policies/pwn2.txt'` | deny | DENIED `P13-EXEC-WRITE: exec writes to policies/pwn2.txt` — bashlex recursed `bash -c` (`exec_analyze.py:42-47`), redirect caught |
| V2b | `bash -c "echo x > policies""/pwn2.txt"` | bypass | DENIED — bashlex normalizes adjacent-quote concatenation back to `policies/pwn2.txt` |
| V4a | `sed --in-place 's/a/b/' policies/pwn4.txt` | deny | DENIED — `-i`/`--in-place` branch (`exec_analyze.py:48-52`) |
| V4b | `sed -e 's/a/b/' -i policies/pwn4.txt` (flag-order) | bypass | DENIED — AST checks `"-i" in rest` anywhere, not position |
| V6a | `git checkout -- policies/pwn6.txt` | deny | DENIED — `git checkout` op substring (`p13:61`) + `rest[0]` sub-command check (`exec_analyze.py:53-54`) |

Notes:
- The listed vectors V2/V4/V6 are all blocked **only when bashlex works
  and the analyzer runs** — the string fallback alone would still catch
  V2 (redirect) and V6a (`git checkout` substring), but V4b flag-order
  evades the fallback (no contiguous `sed -i` substring).
- `python3` lacked bashlex at first probe (ModuleNotFoundError), then
  resolved — analyzer availability is environment-fragile; when absent,
  `EXEC_JSON='{}'` (`gate.sh:67`) silently degrades to the weaker
  fallback and V4b-class vectors pass.
