# WHY: no src/ writes without owner-approved plan/spec.md + plan/tasks.md (L3).
# Approval = plan/spec.approved + plan/tasks.approved files containing the
# sha256 of the approved document; any post-approval edit invalidates the hash.
package governance

import rego.v1

deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	p := norm(target_path)
	contains(p, "/src/")
	not plan_spec_approved
	msg := "P12-NO-PLAN: src/ write denied — owner-approved plan/spec.md required (L3)"
}

deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	p := norm(target_path)
	contains(p, "/src/")
	plan_spec_approved
	not plan_tasks_approved
	msg := "P12-NO-TASKS: src/ write denied — owner-approved plan/tasks.md required (L3)"
}

plan_spec_approved if {
	object.get(data.env, "plan_spec_approved", false)
}

plan_tasks_approved if {
	object.get(data.env, "plan_tasks_approved", false)
}
