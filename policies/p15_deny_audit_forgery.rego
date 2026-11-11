# WHY: cold-verifier findings — logs/gate.log and b1.0-pretool.log are
# write-editable (exec is gated but write/edit are not) -> audit forgery;
# policies/exec_analyze.py is write-editable (p4 covers only
# .rego/.json/.yaml) -> analyzer tamper. Deny non-exec writes to all.
package governance

import rego.v1

audit_targets := {"logs/gate.log", "logs/b1.0-pretool.log", "policies/exec_analyze.py"}

deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	p := audit_path
	some t in audit_targets
	endswith(p, t)
	msg := sprintf("P15-AUDIT-FORGERY: %s writes protected audit/analyzer file %s", [input.tool_name, t])
}

audit_path := p if {
	p := lower(replace(input.tool_input.file_path, "\\", "/"))
}

audit_path := p if {
	p := lower(replace(input.tool_input.notebook_path, "\\", "/"))
}
