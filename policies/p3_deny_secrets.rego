# WHY: secrets written into files, commands, URLs or MCP payloads leave the audit boundary (M5)
# Matchers verified against 15-name inventory (STATE.md, ERR-006)
# Limit: only the first 64KB of each field is scanned — beyond that, no detection (documented).
package governance

import rego.v1

scan_cap := 65536

secret_patterns := [
	`AKIA[0-9A-Z]{16}`,
	`-----BEGIN [A-Z ]*PRIVATE KEY-----`,
	`(?i)(password|passwd|api[_-]?key|secret|token)["'\s]*[:=]["'\s]*[A-Za-z0-9/+=\-_]{8,}`,
	`ghp_[A-Za-z0-9]{36}`,
	`sk-[A-Za-z0-9]{20,}`,
	`xox[baprs]-[A-Za-z0-9-]{10,}`,
	`(?i)bearer\s+[A-Za-z0-9._\-]{20,}`,
]

scannable(name) if {
	name in {"write", "edit", "notebook_edit", "exec", "webfetch", "run_subagent"}
}

scannable(name) if {
	startswith(name, "mcp__")
}

# String fields worth scanning, per tool family.
candidate_strings contains s if {
	some k in ["content", "new_string", "new_source", "command", "task", "url", "prompt"]
	s := input.tool_input[k]
	is_string(s)
}

# MCP payloads are objects — scan the serialized form.
candidate_strings contains s if {
	startswith(input.tool_name, "mcp__")
	s := json.marshal(object.get(input, "tool_input", {}))
}

deny contains msg if {
	scannable(input.tool_name)
	some s in candidate_strings
	some pat in secret_patterns
	regex.match(pat, substring(s, 0, scan_cap))
	msg := sprintf("P3-SECRET: %s payload matches secret pattern %s", [input.tool_name, pat])
}
