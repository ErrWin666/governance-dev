# WHY: semantic regression for p13 (GAP-L1-10 mitigation, ERR-018).
# opa check can't catch logic FPs — only should-allow vectors can.
# Run: opa test policies/ tests/policy/ -v
package governance_test

import rego.v1

import data.governance

# mirror of the env gate.sh injects (inventory incl. exec; no plan seals)
mock_env := {
	"inventory": ["exec", "read", "write", "edit", "notebook_edit", "mcp__x"],
	"frozen_tests": [],
	"evidence_present": false,
	"tests_locked": false,
	"evidence_manifests": [],
	"current_phase": null,
	"plan_spec_approved": false,
	"plan_tasks_approved": false,
}

p13_msgs(cmd) := {m |
	m := governance.deny[_] with input as {"tool_name": "exec", "tool_input": {"command": cmd}}
		with data.env as mock_env
	contains(m, "P13-EXEC-WRITE")
}

# --- should DENY ---

test_deny_sed_in_place if {
	p13_msgs("sed -i s/x/y/ policies/foo.rego") != set()
}

test_deny_redirect if {
	p13_msgs("echo hi > policies/foo.rego") != set()
}

test_deny_rm if {
	p13_msgs("rm -rf policies/") != set()
}

test_deny_git_checkout_src if {
	p13_msgs("git checkout -- src/x.py") != set()
}

test_deny_cp_to_approvals if {
	p13_msgs("cp a.txt approvals/") != set()
}

# --- should ALLOW ---

test_allow_read_logs if {
	p13_msgs("tail -4 logs/gate.log") == set()
}

test_allow_find_policies if {
	p13_msgs("find policies -name '*.rego' -type f") == set()
}

test_allow_git_add if {
	p13_msgs("git add policies/ docs/GAPS.md") == set()
}

test_allow_stderr_redirect if {
	p13_msgs("pytest tests/ 2>/dev/null") == set()
}

test_allow_mention_path if {
	p13_msgs("cat docs/errors/README.md && ls policies/.governance/") == set()
}

test_allow_git_switch if {
	p13_msgs("git switch -c fix/x && git commit -F m.txt") == set()
}

# --- edge: substring ops must not match inside words (ERR-018 class) ---

test_allow_add_not_dd if {
	p13_msgs("git add policies/x.rego") == set()
}

# --- verifier over-deny regression: substring lookalikes must pass ---

test_allow_mystate if {
	p13_ast_msgs("anything", {"ok": true, "commands": ["touch"], "writes": ["mystate.md"]}) == set()
}

test_allow_approved_bak if {
	p13_ast_msgs("anything", {"ok": true, "commands": ["cp"], "writes": ["x.approved.bak"]}) == set()
}

test_deny_nested_policies if {
	p13_ast_msgs("anything", {"ok": true, "commands": ["rm"], "writes": ["/mnt/c/x/policies/y"]}) != set()
}

# --- AST layer vectors (verifier gap: tests covered fallback only) ---
# Feed data.env.exec_analysis directly — the same shape exec_analyze.py emits.

ast_env(ana) := object.union(mock_env, {"exec_analysis": ana})

p13_ast_msgs(cmd, ana) := {m |
	m := governance.deny[_] with input as {"tool_name": "exec", "tool_input": {"command": cmd}}
		with data.env as ast_env(ana)
	contains(m, "P13-EXEC-WRITE")
}

test_ast_deny_write_target if {
	p13_ast_msgs("anything", {"ok": true, "commands": ["sed"], "writes": ["policies/x.rego"]}) != set()
}

test_ast_deny_blocked_cmd if {
	p13_ast_msgs("anything", {"ok": true, "commands": ["dd"], "writes": []}) != set()
}

test_ast_allow_readonly if {
	p13_ast_msgs("anything", {"ok": true, "commands": ["tail"], "writes": []}) == set()
}

test_ast_fallback_on_parse_fail if {
	p13_ast_msgs("rm -rf policies/", {"ok": false}) != set()
}
