# WHY: governance self-protection — the gate, its policies, the runtime
# inventory, and Devin's governance config must be read-only through agent
# tools, or an agent can simply disable its own enforcement (M2).
# Split from p4_require_evidence.rego section (c) — 100-line cap.
package governance

import rego.v1

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
