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

# GAP-L1-12: exec can exfiltrate via shell tools — heuristic raise-of-bar
# (documented evasion: base64, pipes, interpreters). Read-ish requests pass —
# P3 covers literal secrets in payload text; data-carrying forms deny.

deny contains msg if {
	input.tool_name == "exec"
	c := concat("", [" ", lower(replace(input.tool_input.command, "\\", "/"))])
	some t in p10_blocked_tools
	contains(c, t)
	msg := sprintf("P10-DATA-EXFIL: exec outbound tool%s", [t])
}

deny contains msg if {
	input.tool_name == "exec"
	c := concat("", [" ", lower(replace(input.tool_input.command, "\\", "/"))])
	some u in p10_outbound
	contains(c, u)
	some f in p10_exfil_flags
	contains(c, f)
	msg := sprintf("P10-DATA-EXFIL: exec%s with data flag%s", [u, f])
}

p10_blocked_tools := {" scp ", " sftp ", " nc ", " ncat ", " netcat ", " socat ", " telnet ", " ftp ", " rsync ", " ssh "}

p10_outbound := {" curl ", " wget ", " gh api"}

p10_exfil_flags := {" -d ", " --data", " --form", " -f ", " -t ", " --upload-file", " --post", " --json", " -x post", " -x put", " -x patch", " -x delete", " --method", " --input", " --field"}

p10_secret_patterns := {
	"api-key-like": `(?i)(api[_-]?key|password|secret|token)\s*[:=]\s*\S{8,}`,
	"openai": `sk-[a-zA-Z0-9]{20,}`,
	"github": `ghp_[a-zA-Z0-9]{20,}`,
	"aws": `AKIA[0-9A-Z]{16}`,
	"slack": `xox[baprs]-[a-zA-Z0-9-]{10,}`,
}
