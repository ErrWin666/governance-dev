# WHY: single PDP entrypoint — aggregate every policy deny into one decision.
# Matchers verified against 15-name inventory (STATE.md, ERR-006)
package governance

import rego.v1

decision := {
	"allow": count(deny) == 0,
	"reasons": sort([r | some r in deny]),
}

# --- shared helpers (single home; reused by p1-p5) ---

norm(p) := lower(replace(p, "\\", "/"))

target_path := p if {
	p := input.tool_input.file_path
	is_string(p)
}

target_path := p if {
	p := input.tool_input.notebook_path
	is_string(p)
}
