# WHY: cold-verifier findings — logs/gate.log and b1.0-pretool.log are
# write-editable (exec is gated but write/edit are not) -> audit forgery;
# policies/exec_analyze.py is write-editable (p4 covers only
# .rego/.json/.yaml) -> analyzer tamper. Deny non-exec writes to all.
package governance

import rego.v1

deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	p := audit_path
	audit_hit(p)
	msg := sprintf("P15-AUDIT-FORGERY: %s writes protected audit/analyzer file %s", [input.tool_name, p])
}

# ERR-022: filename allowlist missed b1.0-discovery.log and future logs —
# protect logs/*.log by suffix (patch scripts stay writable as .py/.json).
audit_hit(p) if {
	endswith(p, "policies/exec_analyze.py")
}

audit_hit(p) if {
	contains(p, "logs/")
	endswith(p, ".log")
}

audit_path := p if {
	p := lower(replace(input.tool_input.file_path, "\\", "/"))
}

audit_path := p if {
	p := lower(replace(input.tool_input.notebook_path, "\\", "/"))
}
