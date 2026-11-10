# WHY: semantic tests for P14 seal-forgery rule (GAP-L3-08).
package governance_test

import rego.v1

import data.governance

p14_env := {
	"inventory": ["exec", "read", "write", "edit", "notebook_edit", "mcp__x"],
	"frozen_tests": [],
	"evidence_present": false,
	"tests_locked": false,
	"evidence_manifests": [],
	"current_phase": null,
	"plan_spec_approved": false,
	"plan_tasks_approved": false,
}

test_deny_write_seal if {
	governance.deny[m] with input as {"tool_name": "write", "tool_input": {"file_path": "plan/spec.approved"}}
		with data.env as p14_env
	contains(m, "P14-SEAL-FORGERY")
}

test_deny_edit_seal if {
	governance.deny[m] with input as {"tool_name": "edit", "tool_input": {"file_path": "plan/tasks.approved"}}
		with data.env as p14_env
	contains(m, "P14-SEAL-FORGERY")
}

test_deny_notebook_seal if {
	governance.deny[m] with input as {"tool_name": "notebook_edit", "tool_input": {"notebook_path": "plan/x.approved"}}
		with data.env as p14_env
	contains(m, "P14-SEAL-FORGERY")
}

test_allow_normal_plan if {
	count(governance.deny) == 0 with input as {"tool_name": "write", "tool_input": {"file_path": "plan/phase-2-x.md"}}
		with data.env as p14_env
}
