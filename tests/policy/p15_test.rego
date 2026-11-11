# WHY: semantic tests for P15 audit-forgery rule.
package governance_test

import rego.v1

import data.governance

p15_env := {
	"inventory": ["exec", "read", "write", "edit", "notebook_edit"],
	"frozen_tests": [],
	"evidence_present": false,
	"tests_locked": false,
	"evidence_manifests": [],
	"current_phase": null,
	"plan_spec_approved": false,
	"plan_tasks_approved": false,
}

test_deny_gate_log_write if {
	governance.deny[m] with input as {"tool_name": "write", "tool_input": {"file_path": "logs/gate.log"}}
		with data.env as p15_env
	contains(m, "P15-AUDIT-FORGERY")
}

test_deny_pretool_edit if {
	governance.deny[m] with input as {"tool_name": "edit", "tool_input": {"file_path": "logs/b1.0-pretool.log"}}
		with data.env as p15_env
	contains(m, "P15-AUDIT-FORGERY")
}

test_deny_analyzer_write if {
	governance.deny[m] with input as {"tool_name": "write", "tool_input": {"file_path": "policies/exec_analyze.py"}}
		with data.env as p15_env
	contains(m, "P15-AUDIT-FORGERY")
}

test_allow_other_log if {
	count(governance.deny) == 0 with input as {"tool_name": "write", "tool_input": {"file_path": "logs/p_test.json"}}
		with data.env as p15_env
}
