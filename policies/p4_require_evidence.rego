# WHY: a phase transition or implementation write without evidence/P<n>/manifest.json
# breaks the evidence chain (M2/M5).
# Matchers verified against 15-name inventory (STATE.md, ERR-006)
# Surface: (a) approvals/ + STATE.md need any manifest; (b) src/ writes need the
# manifest for current_phase - 1 (env.current_phase, runtime-read by gate.sh).
package governance

import rego.v1

# (a) transition records require some evidence to exist
deny contains msg if {
	input.tool_name in {"write", "edit"}
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
	input.tool_name in {"write", "edit"}
	contains(norm(target_path), "/src/")
	not valid_current_phase
	msg := "P4-NO-EVIDENCE: src/ write denied - current phase unset (fail closed)"
}

deny contains msg if {
	input.tool_name in {"write", "edit"}
	contains(norm(target_path), "/src/")
	valid_current_phase
	not required_evidence in evidence_manifests
	msg := sprintf("P4-NO-EVIDENCE: src/ write requires %s", [required_evidence])
}

valid_current_phase if {
	regex.match(`^P\d+$`, object.get(data.env, "current_phase", ""))
}

required_evidence := sprintf("evidence/%s/manifest.json", [prev_phase])

prev_phase := sprintf("P%d", [to_number(trim_prefix(data.env.current_phase, "P")) - 1])

evidence_manifests contains norm(m) if {
	some m in object.get(data.env, "evidence_manifests", [])
}

# (c) governance self-protection — the gate, its policies, the runtime
# inventory, and Devin's governance config are read-only through agent tools.
# Layer 1 (this policy) denies write/edit/notebook_edit; layer 2 is the
# Windows ACL (AA read-only, Administrators full). Recovery: docs/.
# *.rego/*.json/*.yaml are matched at ANY depth under policies/ because
# `opa eval --data policies/` loads them recursively — a nested file is a
# policy/data injection vector, not a harmless new file.
#
# EXCEPTION (dev-only): .rego files directly under
# C:/governance-dev/policies/ are writable — this is the governance
# development environment where Devin authors new policies. Production
# projects (any other path) remain fully protected.
# The .governance/ subdirectory (runtime inventory + phase state) stays
# protected even in dev — those are runtime data, not policy authoring.
#
# NOTE: the path "c:/governance-dev/policies/" is hardcoded. If the
# governance folder is relocated, update is_development_policy_file below.
deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	p := norm(target_path)
	is_governance_file(p)
	not is_development_policy_file(p)
	msg := sprintf("P4-GOVERNANCE-FILE: %s is a protected governance file", [target_path])
}

is_development_policy_file(p) if {
	startswith(p, "c:/governance-dev/policies/")
	endswith(p, ".rego")
	not contains(p, "/.governance/")
}

is_governance_file(p) if {
	regex.match(`(^|.*/)policies/gate\.sh$`, p)
}

is_governance_file(p) if {
	regex.match(`(^|.*/)policies/.+\.(rego|json|ya?ml)$`, p)
}

is_governance_file(p) if {
	regex.match(`(^|.*/)policies/\.governance/`, p)
}

is_governance_file(p) if {
	p == "c:/users/aa/appdata/roaming/devin/config.json"
}

is_governance_file(p) if {
	p == "c:/users/aa/appdata/roaming/devin/mcp_config.json"
}