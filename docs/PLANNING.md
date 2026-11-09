# L3 — Planning layer (plan/ convention)

No `src/` writes without owner-approved spec + tasks. Enforced by **P12**
(`policies/p12_require_plan.rego`), advisory skills in `.devin/skills/`.

## Flow

1. Idea → `spec-driven-development` skill → ≥5 clarifying questions → draft `plan/spec.md`
2. Owner reviews → approve: `sha256sum plan/spec.md > plan/spec.approved` + entry in `approvals/approval.md` (A-XXX format)
3. `planning-and-task-breakdown` skill → `plan/tasks.md` → approve: `sha256sum plan/tasks.md > plan/tasks.approved`
4. `src/` writes allowed while both hashes match. Edit spec/tasks → hash stale → P12 blocks until re-approval.
5. Cold session → `plan-resume` skill reads plan/+STATE.md+evidence/ → status + proposed next task → waits for owner.

## gate.sh patch (OWNER — apply manually, P4-blocked for agents)

Add before the `ENVJSON=$(jq -n ...)` line:

```bash
PLAN_SPEC=false; PLAN_TASKS=false; SPEC_OK=false; TASKS_OK=false
[ -f plan/spec.md ] && PLAN_SPEC=true
[ -f plan/tasks.md ] && PLAN_TASKS=true
if [ -f plan/spec.approved ] && [ -f plan/spec.md ]; then
	[ "$(sha256sum plan/spec.md | awk '{print $1}')" = "$(tr -d ' \r\n' < plan/spec.approved)" ] && SPEC_OK=true
fi
if [ -f plan/tasks.approved ] && [ -f plan/tasks.md ]; then
	[ "$(sha256sum plan/tasks.md | awk '{print $1}')" = "$(tr -d ' \r\n' < plan/tasks.approved)" ] && TASKS_OK=true
fi
```

Add to the jq call: `--argjson psp "$PLAN_SPEC" --argjson ptp "$PLAN_TASKS" --argjson psa "$SPEC_OK" --argjson pta "$TASKS_OK"`
and env fields: `plan_spec_present:$psp,plan_tasks_present:$ptp,plan_spec_approved:$psa,plan_tasks_approved:$pta`

Until applied, P12 stays fail-closed: every src/ write is denied (verified live 2026-11-09).
Approve-path logic verified via direct `opa eval` (approved env → zero P12 denials).

## Skills

| Role | Skill | Source |
|---|---|---|
| S1 spec-writer | spec-driven-development | addyosmani/agent-skills (74.2K) |
| S2 task-decomposer | planning-and-task-breakdown | addyosmani/agent-skills (72.9K) |
| S3 resume | plan-resume (custom; session-handoff adopted for generic handoffs) | custom + softaworks/agent-toolkit |
