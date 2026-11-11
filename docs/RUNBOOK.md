# RUNBOOK — operating the governance gate

Operational how-to for the most common incidents. Owner-side commands run
in an ungated PowerShell/WSL terminal.

## Reseal policies (after ANY intentional policy change)

```powershell
wsl -e bash -c "cd /mnt/c/governance-dev && find policies -maxdepth 1 -type f \( -name '*.rego' -o -name 'gate.sh' -o -name 'exec_analyze.py' \) -print0 | sort -z | xargs -0 cat | sha256sum | cut -d' ' -f1 > policies/.governance/policies.lock"
```

Rule (ERR-019): policy edits go through ONE script that runs `opa check`
BEFORE resealing — never edit `policies/` then seal later.

## Incident: every tool call denied with GOV_GATE_DOWN

Cause: a `.rego` file fails to compile → `opa eval` fails → fail closed.

```powershell
wsl -e bash -c "cd /mnt/c/governance-dev && ~/.local/bin/opa check policies/"
# fix the reported line in your editor, then reseal (command above)
```

## Incident: every tool call denied with POLICIES-INTEGRITY

Cause: a policy file changed after the last seal (hash mismatch) — or the
lock file was deleted. If the change was intentional: reseal. If NOT
intentional: `git diff policies/` — someone tampered; `git checkout` the
clean file, then reseal.

## Reading the gate log

```powershell
wsl -e bash -c "cd /mnt/c/governance-dev && tail -20 logs/gate.log"
```

- `PWD-PROOF cwd=…` — every gated call, with working dir
- `DENY P##-… input=…` — policy denies with rule IDs
- `GOV_GATE_DOWN rc=…` — infrastructure failures (opa broken, eval error)
- `DENY POLICIES-INTEGRITY` — seal mismatch or lock missing

## Verifying the gate is alive (provocation test)

```powershell
wsl -e bash -c 'cd /mnt/c/governance-dev && echo "{\"tool_name\":\"exec\",\"tool_input\":{\"command\":\"rm -rf policies/\"}}" | bash policies/gate.sh; echo EXIT=$?'
```

Expected: `P13-EXEC-WRITE` + `EXIT=2`. `EXIT=0` = gate not enforcing.

## Agent-side policy patching (the residual channel)

`write`/`edit` on `policies/gate.sh` + `exec_analyze.py` are denied (P15).
`.rego` files are editable but resealing is required after ANY change.
The only agent path is `python3 logs/fix_*.py` via exec (script-file
indirection — documented clause-18 residual, audit-logged). Owner-side
seal = L5 hardening target (GAP: agent can self-reseal).

## New agent profiles / fresh session

Custom subagent profiles under `.devin/agents/` are discovered at session
start. After adding/changing a profile: open a new Devin session, then ask
for the named profile (e.g. "use the verifier subagent").
