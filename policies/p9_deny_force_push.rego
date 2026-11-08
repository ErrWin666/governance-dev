# WHY: force-push rewrites published history — recovery needs reflog access
# the pusher may not have (M5).
# Matchers verified against 15-name inventory (STATE.md, ERR-006)
# Heuristic: `git push ... --force*` (covers --force-with-lease) or a combined
# short flag containing f (-f, -fu, -nf). `git -C <dir> push`, aliases, and
# force flags passed via -o push options evade — documented limit.
package governance

import rego.v1

deny contains msg if {
	input.tool_name == "exec"
	c := input.tool_input.command
	is_string(c)
	is_force_push(c)
	msg := sprintf("P9-FORCE-PUSH: %s", [c])
}

is_force_push(c) if {
	regex.match(`git\s+push\b[^|&;]*\s--force`, c)
}

is_force_push(c) if {
	regex.match(`git\s+push\b[^|&;]*\s-[a-zA-Z]*f[a-zA-Z]*(\s|$)`, c)
}
