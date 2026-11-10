# L4.4 Final Report — exec-write protection review

Scope under review: p13 AST layer (`policies/exec_analyze.py`) + string fallback
(`policies/p13_exec_write_paths.rego`) + `policies.lock` integrity seal
(`policies/gate.sh`) + P14 seal-forgery rule (`policies/p14_deny_seal_forgery.rego`).
This report is written solely from the three role verdicts and the attacker PoC
files; every claim carries an evidence pointer.

## 1. Verdict summary per role

- **Verifier — DISPUTED**: core mechanisms exist and tests pass, but a live
  fallback bypass plus a silently dead AST layer make "complete and correct"
  an overclaim. (`handoffs/l4-4-verifier/verdict.json`, findings[0–3])
- **Skeptic — DISPUTED**: design-level contradictions — cwd-relative blind spot
  enabling a re-seal kill chain, PATH poisoning of the gate and the seal itself,
  and broad analyzer coverage gaps. (`handoffs/l4-4-skeptic/verdict.json`,
  subclaims 1–4, findings)
- **Attacker — DISPUTED**: 11/16 exec vectors wrote to protected `policies/`
  through the live gate; the protection "is a linter for obvious writes, not a
  sandbox." (`handoffs/l4-4-attacker/verdict.json` summary; `poc/*.md`)

All three roles independently DISPUTED the completeness claim; none verified it.

## 2. Confirmed holes — merged/deduped, severity-ordered

### Critical

1. **Exclusive layers + indirection evasion family — 11/16 live-gate bypasses.**
   The string fallback runs only when AST analysis fails (`not analysis_ok`),
   so any parseable command hiding writes behind indirection evades BOTH layers:
   `python3 -c open()`, `base64 -d | bash`, `xargs`/`xargs -I{} sh -c`,
   `find -exec`, symlink write-through, `$var`/`env VAR=`/`eval` indirection,
   `git -C`/`checkout-index`/`reset --hard`. Confirmed end-to-end with gate rc=0
   and files created in `policies/`. p13's own comment concedes the
   `$var`/`eval` evasion class. Even a literal `> policies/…` inside a quoted
   `eval` string passed. Evidence: `handoffs/l4-4-attacker/verdict.json`
   findings[0–1] + `poc/v1-python3-interpreter.md`, `poc/v3-base64-pipe.md`,
   `poc/v5-xargs-find.md`, `poc/v6b-git-flag-prefix.md`, `poc/v7-symlink.md`,
   `poc/v8-env-var-indirection.md`; `handoffs/l4-4-skeptic/verdict.json`
   finding (analyzer coverage gaps); → `policies/p13_exec_write_paths.rego:5,29-50`,
   `policies/exec_analyze.py:8-11,42-61`.

2. **cwd-relative write blind spot → re-seal kill chain.** The analyzer never
   tracks cwd, so `cd policies && rm p1.rego` yields `writes=["p1.rego"]` which
   contains no `policies/` substring — no deny, and `ok:true` suppresses the
   fallback. Full chain verified: tamper `exec_analyze.py` via cd-relative
   write → recompute sha256 (read-only, allowed) → `cd policies/.governance &&
   printf HASH > policies.lock` (also missed) = attacker-controlled analyzer
   under a valid seal. Evidence: `handoffs/l4-4-skeptic/verdict.json`
   finding[0]; → `policies/exec_analyze.py:35-61`,
   `policies/p13_exec_write_paths.rego:54-58,75`.

3. **PATH poisoning defeats the policy engine AND the seal.**
   `gate.sh:5` prepends user-writable `$HOME/.local/bin`; no policy covers it.
   A planted `opa` neuters every policy; planted `sha256sum`/`find`/`cat` make
   the lock check lie; planted `python3` controls the analyzer, whose `ok:true`
   is trusted unconditionally. Every gate dependency resolves through the
   poisoned PATH. Evidence: `handoffs/l4-4-skeptic/verdict.json` findings[1]
   and "integrity check is circular"; → `policies/gate.sh:5,16,24-27,67,79`,
   `policies/exec_analyze.py:6`.

4. **Fallback redirect match is startswith-only — live seal-forgery hole in
   fallback-only mode.** `seg_starts_protected` uses `startswith()` where the
   ops/AST paths use `contains()`; nested or `./`-prefixed protected targets
   pass: empirical `opa eval` returned `deny=[]` for
   `echo forged > plan/tasks.approved` and `echo forged > ./policies/x.rego`.
   bashlex is not reliably installed in this environment (`ModuleNotFoundError`
   observed by all three roles; it "flipped" across runs), and `gate.sh:67`
   silently substitutes `{}` on analyzer failure — so fallback-only mode is a
   live deployed state, and P14 does not cover exec (`p14:10`). Evidence:
   `handoffs/l4-4-verifier/verdict.json` finding[0], subclaim b;
   `handoffs/l4-4-skeptic/verdict.json` minor (undeclared bashlex);
   `handoffs/l4-4-attacker/poc/BLOCKED-vectors.md` notes, `poc/FINDINGS-meta.md`
   F5; → `policies/p13_exec_write_paths.rego:68-73,82-85`, `policies/gate.sh:66-68`,
   `policies/exec_analyze.py:6`, `policies/p14_deny_seal_forgery.rego:10`.

### Major

5. **Analyzer structural blind spots (all verified `ok:true, writes:[]`).**
   - Wrapper/interpreter verbs absent: `env`, `find -exec`, `python3 -c`,
     `git rm`, `zsh -c`/`dash -c`, `wsl` (non-`-c` form), `sh <script`,
     `bash script.sh`, `tar xf`, `unzip -o`, `curl -o`, `eval`, `awk system()`.
     → `handoffs/l4-4-skeptic/verdict.json` finding[2];
     `policies/exec_analyze.py:8-11,42,55-56`.
   - Windows `.exe` suffix defeats all verb matching (`rm.exe`, `bash.exe -c`,
     `powershell.exe -c`); deployment OS is Windows. → skeptic finding;
     `policies/exec_analyze.py:39-42`.
   - Command substitution and assignments invisible: `x=$(rm -rf policies/)`
     yields `commands:[], writes:[]`. → skeptic finding;
     `policies/exec_analyze.py:11,15-21`.
   - `MAX_DEPTH=3` prunes nested `bash -c` at depth 4; only the `-c` flag form
     recurses. → skeptic finding; `policies/exec_analyze.py:11,42-47`.
   - Redirect ops limited to `{">",">>","&>"}`: `<>`, `<`, `>|`, `>&N` missed.
     → skeptic finding; `policies/exec_analyze.py:57-60`.
   - git check is `argv[1]`-fragile: `rest[0] in GIT_WRITE_SUBS` misses
     `-C`/`-c`/`--git-dir` prefixes; `checkout-index`/`apply`/`am`/`reset`
     absent — `git reset --hard` = gate-allowed mass rewrite.
     → `handoffs/l4-4-attacker/verdict.json` finding[2],
     `poc/v6b-git-flag-prefix.md`; `policies/exec_analyze.py:10,53-54`.

6. **Fallback op list is narrower than the AST's** — `vi`, `git am/reset/
   commit-tree` covered by `exec_analyze.py` but missing from fallback ops, so
   fallback-only mode is strictly weaker; and op-free writers are admitted
   unsealed by design. Evidence: `handoffs/l4-4-verifier/verdict.json`
   finding[1]; → `policies/exec_analyze.py:8-10`,
   `policies/p13_exec_write_paths.rego:4-5,61`.

7. **Seal scope gaps.** `find -maxdepth 1` seals only top-level `*.rego`,
   `gate.sh`, `exec_analyze.py` — excluding `policies/.governance/`
   (`tool-inventory.txt` feeds `data.env.inventory`, `current_phase` feeds
   phase math, and `policies.lock` itself). Deleting or emptying
   `policies.lock` skips the integrity check entirely (`[ -f ]`/`[ -n "$EXP" ]`
   guards). A `.rego` injected into a `policies/` subdirectory is unsealed but
   loaded recursively by `opa --data policies/` (fail-closed on hash mismatch —
   DoS, not silent bypass). Evidence: `handoffs/l4-4-skeptic/verdict.json`
   subclaim 2 + major finding; `handoffs/l4-4-verifier/verdict.json` note[0];
   `handoffs/l4-4-attacker/poc/FINDINGS-meta.md` F6; → `policies/gate.sh:23-26,35,37,40`,
   `policies/p5_deny_unrecognized_tool.rego:14-22`,
   `policies/p4_require_evidence.rego:44-53`,
   `policies/p4_governance_self_protection.rego:32-36,46-48`.

8. **Claimed compensating control is false.** p13's header calls "audit +
   policies.lock the detection tier" for `$var`/`eval`/script evasion, but the
   lock only seals policy files — evaded writes to `approvals/`, `evidence/`,
   `state.md`, `tests.lock`, `*.approved`, `logs/`, `src/` have NO detection
   tier; the detection tier did not alert on any attacker run. Evidence:
   `handoffs/l4-4-skeptic/verdict.json` major finding;
   `handoffs/l4-4-attacker/poc/v8-env-var-indirection.md`; →
   `policies/p13_exec_write_paths.rego:5,75`, `policies/gate.sh:26`.

9. **Nondeterministic fail-closed denies (availability).**
   `POLICIES-INTEGRITY` mismatch observed twice with the seal verified intact,
   plus one `UNRECOGNIZED-TOOL` — Cygwin fork failures corrupt the
   `find|xargs|sha256sum` seal and inventory pipelines. Not a bypass, but
   spurious denies erode trust and can mask real denies. Evidence:
   `handoffs/l4-4-attacker/verdict.json` finding[3],
   `poc/FINDINGS-meta.md` F4; → `policies/gate.sh:23-35`.

10. **No timeout / unbounded stdin on the analyzer.** `opa` gets `timeout 4`
    but `python3 exec_analyze.py` gets none and does unbounded
    `sys.stdin.read()` — a pathological command hangs the pre-tool gate.
    Evidence: `handoffs/l4-4-skeptic/verdict.json` major finding; →
    `policies/gate.sh:67,79`, `policies/exec_analyze.py:64`.

### Minor / notes

11. **Over-deny false positive:** all non-flag args counted as writes, so
    `cp policies/p1.rego /tmp/copy` (read-only copy) is denied — sources can't
    be distinguished from destinations. → skeptic minor;
    `policies/exec_analyze.py:2-3,55-56`.
12. **Undeclared bashlex dependency:** top-level import, no requirements/pin;
    absence → silent permanent fallback-only mode. → skeptic minor, attacker
    minor, verifier critical root cause; `policies/exec_analyze.py:6`,
    `policies/gate.sh:67`.
13. **Non-string `tool_input.command` divergence:** `jq -r` stringifies for the
    analyzer while Rego `replace()` goes undefined — the two layers can see
    different inputs. → skeptic minor; `policies/gate.sh:67`,
    `policies/p13_exec_write_paths.rego:33,42`.
14. **Deny messages don't identify which layer fired; analyzer degradation
    writes no gate.log entry** — a silently dead AST layer is undetectable from
    logs. → verifier note; `policies/p13_exec_write_paths.rego:17,26,36,45`,
    `policies/gate.sh:66-68`.
15. **Policy-file injection surface (note):** new `.rego` files under
    `policies/` are writable via the write tool dev exception and are loaded
    recursively by opa — added denies can only tighten and env overlap fails
    closed (not a silent bypass), but injection breaks the seal → fail-closed
    DoS / re-seal social-engineering surface. → attacker note + skeptic
    non-finding; `policies/p4_governance_self_protection.rego:11-13,32-36`,
    `policies/gate.sh:26,79`.

## 3. What IS proven to work (evidence only)

- **Seal is correct and currently valid**: recomputed sha256 matches
  `policies/.governance/policies.lock`; covers all top-level `*.rego` +
  `gate.sh` + `exec_analyze.py`; compare-and-fail-closed on mismatch.
  (verifier subclaim d VERIFIED → `policies/gate.sh:23-33`)
- **AST layer denies direct writes when it runs**: `bash -c 'echo x >
  policies/x'` DENIED (incl. adjacent-quote normalization), `sed -i`/
  `--in-place` in any flag order DENIED, `git checkout -- policies/x` DENIED.
  (attacker `poc/BLOCKED-vectors.md` V2/V2b/V4a/V4b/V6a →
  `policies/exec_analyze.py:42-54`, `policies/p13_exec_write_paths.rego:54-61`)
- **Fallback catches literal prefixed writes** when the AST is absent
  (redirect + op-substring rules exist and deny literal targets —
  `p13_exec_write_paths.rego:30-46`; `BLOCKED-vectors.md` notes V2/V6a would
  still be caught).
- **`write`/`edit`/`notebook_edit` forgery of `.approved` is denied** by P14
  seal-target rule with passing tests. (verifier subclaim b →
  `policies/p14_deny_seal_forgery.rego:9-22`, `tests/policy/p14_test.rego:19-35`)
- **27/27 opa tests pass** across p10/p13/p14 — but no test exercises the
  fallback startswith hole or the indirection vectors. (verifier subclaim c →
  `tests/policy/p13_test.rego:30-107`)
- **`.governance` is protected from `write`/`edit` tools** by p4 governance
  self-protection (exec path is the gap). →
  `policies/p4_governance_self_protection.rego:46-48`.
- **Failure mode is fail-closed**, not fail-open: seal mismatch and analyzer
  absence deny or degrade rather than silently allow on the integrity check
  itself (though fallback-only degrade is silent). → `policies/gate.sh:27-32,66-68`.

## 4. Recommended fix order (critical first — drawn from the findings)

1. **Run BOTH layers always** — remove the `analysis_ok` exclusivity so the
   string fallback also scans parseable commands. (attacker F1 +
   `poc/v8-env-var-indirection.md` fix direction)
2. **Replace `startswith()` with `contains()` in the fallback redirect check**
   (`p13:82-85`) — closes the `./`-prefixed and nested-path seal-forgery hole.
   (verifier critical root cause)
3. **Make the AST layer non-optional and observable**: declare/pin bashlex,
   treat `exec_analysis={}` as a logged alert (or deny), add `timeout` and
   bounded stdin to `gate.sh:67`. (verifier, skeptic, attacker — all three)
4. **Close the analyzer's blind spots**: add interpreter/launcher verbs
   (`python*`, `env`, `xargs`, `find -exec`, decode-then-execute pipes),
   expand simple `VAR=`/`env VAR=` assignments, track `cd`/cwd state, strip
   `.exe` suffixes, walk command substitutions, raise/remove `MAX_DEPTH`,
   recurse non-`-c` script forms, cover `<`/`<>`, `>|` redirect ops, resolve
   realpaths of write targets (symlinks), and scan git argv for the first
   non-flag token + add `reset`/`checkout-index`/`apply`/`hash-object -w`.
   (fix directions in all `poc/v*.md` + skeptic findings)
5. **Harden the gate's own trust base**: pin absolute paths for
   `opa`/`python3`/`sha256sum`/`find`/`jq` or sanitize PATH; stop trusting the
   analyzer's `ok:true` unconditionally. (skeptic criticals 2/3)
6. **Extend the seal**: include `policies/.governance/*` (or hash them
   separately), treat missing/empty `policies.lock` as failure not skip, and
   cover subdirectory `*.rego` in the hashed set. (skeptic/verifier seal findings)
7. **Add regression tests** for the fallback startswith hole, cd-relative
   writes, and each attacker PoC vector. (verifier subclaim c gap)
8. **Improve audit attribution**: tag which layer fired in deny messages; log
   analyzer degradation to gate.log. (verifier note)
9. **Fix the source/destination over-deny** so read-only copies aren't
   blocked. (skeptic minor)

## Evidence-base caveats

- Every claim above traces to a `file:line` cited inside the role verdicts or
  PoC files; no claim was added from outside the evidence bundle.
- Runtime results (gate rc=0, `deny=[]`, hash match) are attested by the roles
  in their verdicts/PoCs; this report does not re-execute them.
- bashlex availability is environment-fragile: verifier observed it absent,
  attacker/skeptic observed it absent-then-present across runs — both states
  are documented and both are exploitable (fallback-only → hole #4; AST live →
  holes #1–3).
