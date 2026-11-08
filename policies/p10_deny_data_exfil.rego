# WHY: outbound tools (webfetch/MCP) can carry secrets in URL/payload (M5)
# Heuristic, not exhaustive: base64/obfuscated secrets NOT caught.
# Matchers verified against 15-name inventory (STATE.md, ERR-006)
# NOTE: pattern map is named p10_secret_patterns — p3 owns secret_patterns.
package governance

import rego.v1

deny contains msg if {
	outbound_tool
	walk(input.tool_input, [_, v])
	is_string(v)
	some name, pat in p10_secret_patterns
	regex.match(pat, v)
	msg := sprintf("P10-DATA-EXFIL: %s in outbound payload", [name])
}

outbound_tool if {
	input.tool_name in {"webfetch", "mcp_list_tools"}
}

outbound_tool if {
	startswith(input.tool_name, "mcp__")
}

p10_secret_patterns := {
	"api-key-like": `(?i)(api[_-]?key|password|secret|token)\s*[:=]\s*\S{8,}`,
	"openai": `sk-[a-zA-Z0-9]{20,}`,
	"github": `ghp_[a-zA-Z0-9]{20,}`,
	"aws": `AKIA[0-9A-Z]{16}`,
	"slack": `xox[baprs]-[a-zA-Z0-9-]{10,}`,
}
