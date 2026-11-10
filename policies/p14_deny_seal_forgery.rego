# WHY: GAP-L3-08 — write/edit/notebook_edit could forge *.approved seals
# (owner-approval artifacts). p13 covers exec only; this closes the tool
# seam. Seals may be created ONLY via the owner's ungated terminal —
# same model as policies.lock resealing (proved workable in-session).
package governance

import rego.v1

deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	p := seal_target
	endswith(p, ".approved")
	msg := sprintf("P14-SEAL-FORGERY: %s writes to an approval seal — owner terminal only", [input.tool_name])
}

seal_target := p if {
	p := lower(input.tool_input.file_path)
}

seal_target := p if {
	p := lower(input.tool_input.notebook_path)
}
