#!/usr/bin/env python3
# Diagnostic probe for exec_analyze.py — runs test commands through the real
# analyzer and prints what it extracts. Read-only; creates no files.
import sys, subprocess
sys.path.insert(0, "/mnt/c/governance-dev/policies")
import exec_analyze

exec_analyze.ROOT = "/mnt/c/governance-dev"
exec_analyze.WORK = "/mnt/c/governance-dev"

CASES = [
    'echo probe &>> src/.gate-probe.tmp; echo "exit=$?"',
    "echo probe &>> src/x.tmp; echo done",
    "echo probe &>> src/x.tmp",
    "echo probe &>> src/.hidden.tmp",
    "echo probe &> src/x.tmp",
    "echo probe >> src/x.tmp",
    "echo probe >&2",
    "mv src/x dst",
    "cp src/x dst",
    "cp a src/b",
    "mv a src/b",
    "echo x | tee src/y",
    "install -m 755 a src/b",
    "dd if=a of=src/b",
    "printf x > src/y 2>&1",
    "bash -c 'echo x > src/y'",
    "ln -s /tmp/x src/l",
    "echo x | xargs -I{} cp {} src/",
    "find . -name f -exec cp {} src/ \\;",
    "touch src/z",
    "git checkout -- src/f",
    "echo $(cat s) > out",
]

for c in CASES:
    res = exec_analyze.analyze(c)
    if res is None:
        print(f"PARSE-FAIL  {c}")
    else:
        cmds, writes = res
        hits = [w for w in writes if "/src/" in w or w.endswith("/src")]
        flag = "HITS-SRC" if hits else ("no-src" if writes else "EMPTY")
        print(f"{flag:9}  {c!r:60} -> cmds={cmds} writes={sorted(writes)}")
