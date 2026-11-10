# Meta findings — gate architecture

## F1 (critical) — AST/fallback layers are exclusive, not additive
`p13_exec_write_paths.rego:30-46`: the string fallback only runs when
`not analysis_ok`. Any command bashlex can parse with writes hidden
behind indirection bypasses BOTH checks — including commands containing
literal `> policies/…` inside quoted strings (V11 proof). Run both.

## F2 (critical) — indirection family is wide open
`$var`, `env VAR=…`, `eval`, `xargs {}`, `find -exec … {}`, base64,
interpreters, symlinks: 11/16 attempted vectors wrote to `policies/`.
p13's own comment (line 5) concedes this; `policies.lock` does not
compensate (it only seals policy files, not runtime behavior).

## F3 (major) — git threat model is argv[1]-fragile
`exec_analyze.py:53`: `rest[0] in GIT_WRITE_SUBS` only. `git -C …`,
`git --git-dir=…`, `git -c …`, plus unlisted subs (`checkout-index`,
`apply`, `reset --hard` mass rewrite) all pass undetected.

## F4 (major) — nondeterministic fail-closed denies (availability)
Observed `POLICIES-INTEGRITY` mismatch twice with the seal verified
intact (`gate.sh:23-33`) and `UNRECOGNIZED-TOOL` once — cygwin fork
failures (`child_copy: cygheap read copy failed`) corrupt the
`find|xargs cat|sha256sum` and inventory pipelines. Fail-closed, so no
bypass — but spurious denies erode trust and could mask real denies.

## F5 (minor) — analyzer dependency is silent/fragile
`gate.sh:67`: `… 2>/dev/null || echo '{}'` — if bashlex import fails,
the structural layer dies silently and only the weaker fallback guards.
Observed `python3` ModuleNotFoundError→working flip across runs
(rye-shim environment), i.e. protection strength varies per machine.

## F6 (note) — seal scope gap
`gate.sh:26` hashes `*.rego`, `gate.sh`, `exec_analyze.py` at
`maxdepth 1`. New unprotected file types placed in `policies/` (e.g. a
`.rego` IS covered — but `p4` allows authoring `.rego` there in dev, and
`opa eval --data policies/` loads them recursively) — dev exception in
`p4_governance_self_protection.rego:32-36` means a *new* `.rego` under
`C:/governance-dev/policies/` can be written via the write tool AND
loaded by opa → attacker-authored policy injection changes the seal,
which then fails closed — DoS, or re-seal social-engineering path.
