# WHY: exec is a write primitive — path policies matching only {write,edit}
# are suggestions against it (GAP-L1-10). Two layers: (a) bashlex AST via
# data.env.exec_analysis (gate.sh computes it) — structural, no substring
# FPs; (b) string heuristic as fallback when parsing fails. Neither seals
# $var/eval/script evasion — audit + policies.lock are the detection tier.
package governance

import rego.v1

# (a) structural layer: analyzer emits real write targets
deny contains msg if {
	input.tool_name == "exec"
	ana := data.env.exec_analysis
	ana.ok == true
	some t in ana.writes
	protected_hit(t)
	msg := sprintf("P13-EXEC-WRITE: exec writes to %s", [t])
}

deny contains msg if {
	input.tool_name == "exec"
	ana := data.env.exec_analysis
	ana.ok == true
	some c in ana.commands
	c in blocked_commands
	msg := sprintf("P13-EXEC-WRITE: exec runs %s", [c])
}

# (b) fallback layer: unparseable/absent analysis → string heuristic
deny contains msg if {
	input.tool_name == "exec"
	not analysis_ok
	c := concat("", [" ", lower(replace(input.tool_input.command, "\\", "/"))])
	some seg in segments_after_op(c)
	seg_contains_protected(seg)
	msg := sprintf("P13-EXEC-WRITE: exec write aimed at protected path: %s", [input.tool_input.command])
}

deny contains msg if {
	input.tool_name == "exec"
	not analysis_ok
	c := concat("", [" ", lower(replace(input.tool_input.command, "\\", "/"))])
	some seg in segments_after_redirect(c)
	seg_contains_protected(seg)
	msg := sprintf("P13-EXEC-WRITE: exec redirect to protected path: %s", [input.tool_input.command])
}



deny contains msg if {
	input.tool_name == "exec"
	data.env.exec_analysis.crashed == true
	msg := "P13-ANALYZER-DOWN: exec analysis crashed — fail closed"
}

# (c) indirection: interpreters/subshells/git-flags + protected-path mention.
# Proven bypasses (l4-4 attacker poc/): python -c, $(), xargs, find -exec,
# base64|sh, ln -s, git checkout-index/reset --hard. Residual documented.
deny contains msg if {
	input.tool_name == "exec"
	c := concat("", [" ", lower(replace(input.tool_input.command, "\\", "/"))])
	some t in indirection_forms
	contains(c, t)
	some p in protected_paths
	contains(c, p)
	msg := sprintf("P13-EXEC-INDIRECTION: exec writes protected path via%s", [t])
}

indirection_forms := {"python3 -c", "python -c", "node -e", "perl -e", "ruby -e", "php -r", "eval ", " base64 ", " xargs ", " -exec ", " ln -s", "| sh", "| bash", "checkout-index", "reset --hard", "$(", " | python", " | node ", " env "}

analysis_ok if {
	data.env.exec_analysis.ok == true
}

blocked_commands := {"dd", "socat", "nc", "ncat", "netcat", "scp", "sftp", "rsync"}

protected_hit(t) if {
	p := lower(replace(t, "\\", "/"))
	some pat in protected_paths
	contains(p, pat)
}

segments_after_op(c) := [trim_space(p) |
	some op in {" cp ", " mv ", " tee ", "sed -i", "sed --in-place", " install ", " dd ", " truncate ", " touch ", " rm ", " patch ", " nano ", " vim ", " code ", "git checkout", "git restore", "git apply", "git clean"}
	parts := split(c, op)
	some i in numbers.range(0, count(parts) - 1)
	i > 0
	p := parts[i]
]

segments_after_redirect(c) := [trim_space(p) |
	parts := split(c, ">")
	some i in numbers.range(0, count(parts) - 1)
	i > 0
	p := parts[i]
]

protected_paths := {"policies/", "approvals/", "evidence/", "state.md", "tests.lock", ".approved", "logs/", "appdata/roaming/devin/", "src/"}

seg_contains_protected(seg) if {
	some p in protected_paths
	contains(seg, p)
}

seg_starts_protected(seg) if {
	some p in protected_paths
	startswith(seg, p)
}
