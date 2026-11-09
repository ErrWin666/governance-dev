# WHY: a phase transition or implementation write without evidence/P<n>/manifest.json
# breaks the evidence chain (M2/M5).
# Matchers verified against 15-name inventory (STATE.md, ERR-006)
# Surface: (a) approvals/ + STATE.md need any manifest; (b) src/ writes need the
# manifest for current_phase - 1 (env.current_phase, runtime-read by gate.sh).
# Governance self-protection moved to p4_governance_self_protection.rego.
package governance

import rego.v1

# (a) transition records require some evidence to exist
deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	p := norm(target_path)
	is_transition_path(p)
	not object.get(data.env, "evidence_present", false)
	msg := sprintf("P4-NO-EVIDENCE: transition write to %s with no evidence/*/manifest.json", [input.tool_input.file_path])
}

is_transition_path(p) if {
	contains(p, "/approvals/")
}

is_transition_path(p) if {
	endswith(p, "/state.md")
}

# (b) src/ writes require evidence/P<current_phase-1>/manifest.json
deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	contains(norm(target_path), "/src/")
	not valid_current_phase
	msg := "P4-NO-EVIDENCE: src/ write denied - current phase unset (fail closed)"
}

deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	contains(norm(target_path), "/src/")
	valid_current_phase
	not required_evidence in evidence_manifests
	msg := sprintf("P4-NO-EVIDENCE: src/ write requires %s", [required_evidence])
}

valid_current_phase if {
	regex.match(`^P\d+$`, object.get(data.env, "current_phase", ""))
}

required_evidence := lower(sprintf("evidence/%s/manifest.json", [prev_phase]))

prev_phase := sprintf("P%d", [to_number(trim_prefix(data.env.current_phase, "P")) - 1])

evidence_manifests contains norm(m) if {
	some m in object.get(data.env, "evidence_manifests", [])
}
