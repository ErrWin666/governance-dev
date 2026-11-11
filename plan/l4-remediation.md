# L4 Remediation Plan — closing the residual list

Date: 2026-11-10 · Phase: B6 · Status: AWAITING OWNER sequencing

## Remaining items (ranked by risk, not effort)

| # | Item | Risk | Fix | Effort |
|---|---|---|---|---|
| R1 | p13 hard-denies all exec writes to `src/` even with p12/p4 approvals | design decision | Decide: (a) hard barrier — document in README/POLICY_COVERAGE; (b) gate on `plan_spec_approved`+evidence like p4 does | decision only |
| R2 | README documents p1–p5 only; p5:4 comment references nonexistent file | doc debt | Rewrite policies table to p1–p15 + analyzer + seal mechanics | small |
| R3 | L4.3 custom profiles unproven (exec ran in fresh session) | unverified claim | Fresh session test: launch named `verifier`, attempt exec, record deny/allow in `handoffs/l4-7-profile/` | needs new session |
| R4 | Agent self-reseal channel (`python3 logs/fix_*.py` → writes policies/ + reseals) | structural — seal is only as strong as who can reseal | L5: owner-side seal tool / external approval token; until then ERR-019 rule (atomic script + owner witnesses) | L5 scope |
| R5 | `$var` indirection, base64/concat, `git -C` subcommands | clause-18 detection-tier | Documented residual — L5 isolation, not more regex | documented |
| R6 | MCP role mapping unverified | inventory half-done | Probe each server via `mcp_list_tools`, delete noise rows, wire winners into `.devin/agents/*/AGENT.md` allowed-tools | medium |

## Order of execution (proposed)

1. **R1 decision** — owner picks (a) or (b); either path is one file edit
2. **R2** — README rewrite (bundled with R1 commit)
3. **R6** — finish MCP inventory once research lands; map to role profiles
4. **R3** — profile behavior test in a fresh session (blocks nothing else)
5. **R4/R5** — explicitly moved to L5 scope in `docs/GAPS.md`

## Done when

- Every row above is either fixed-with-evidence or moved to GAPS.md with
  an owner-acknowledged deferral note. No "complete" claims on residuals.
