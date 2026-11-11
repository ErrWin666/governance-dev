# WHY: a wsl root shell sidesteps every file/exec boundary this gate enforces (M5/R5)
# Matchers verified against 15-name inventory (STATE.md, ERR-006)
package governance

import rego.v1

# Malformed input denies by default — never gate on an absent field.
deny contains msg if {
	input.tool_name == "exec"
	not is_string(object.get(input, "tool_input", {}).command)
	msg := "P1-MALFORMED: exec call missing tool_input.command"
}

deny contains msg if {
	input.tool_name == "exec"
	cmd := norm_cmd(input.tool_input.command)
	regex.match(`\bwsl(\.exe)?\b`, cmd)
	regex.match(`(-u\s*=?|-u)\s*root\b|--user\s*=\s*root\b|--user\s+root\b`, cmd)
	msg := sprintf("P1-WSL-ROOT: wsl invoked as root: %s", [input.tool_input.command])
}

# strip quotes so -u "root" / --user 'root' cannot evade the root regex
norm_cmd(c) := lower(replace(replace(c, "\"", ""), "'", ""))
