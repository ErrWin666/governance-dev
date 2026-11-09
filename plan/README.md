# plan/ — L3 planning layer

No `src/` writes without owner-approved spec + tasks (enforced by P12).

Flow:
1. Idea → `spec-driven-development` skill → draft `spec.md` (>=5 clarifying questions first)
2. Owner reviews, approves: `sha256sum plan/spec.md > plan/spec.approved` + entry in approvals/approval.md
3. `planning-and-task-breakdown` skill → `tasks.md` → owner approves: `sha256sum plan/tasks.md > plan/tasks.approved`
4. P12 allows src/ writes while both hashes match. Edit spec → hash stale → re-approve.

Files: spec.md (intent), tasks.md (verifiable units), research/ (prior art),
architecture.md (decisions), test-plan.md (strategy), TEMPLATE-spec.md.

Cold resume: `plan-resume` skill reads these files, reports status, waits for owner.
