# WHY: a tool_name outside the verified inventory is unproven territory — deny by default (M7/ERR-006)
# Matchers verified against 15-name inventory (STATE.md, ERR-006)
# Inventory is runtime-read from policies/.governance/tool-inventory.txt (injected
# as data.env.inventory by gate.sh). Approval records: approvals/approval.md (ERR-001 interim).
package governance

import rego.v1

deny contains msg if {
	not inventory_match(object.get(input, "tool_name", ""))
	msg := sprintf("UNRECOGNIZED-TOOL:%s — not in verified inventory", [object.get(input, "tool_name", "<absent>")])
}

inventory_match(name) if {
	some e in object.get(data.env, "inventory", [])
	name == e
}

inventory_match(name) if {
	some e in object.get(data.env, "inventory", [])
	endswith(e, "*")
	startswith(name, trim_suffix(e, "*"))
}
