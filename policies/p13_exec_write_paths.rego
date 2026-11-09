# WHY: exec is a write primitive — path policies matching only {write,edit}
# are suggestions against it (GAP-L1-10). Deny exec commands that aim a write
# operator at a protected path; authoring goes through the write/edit tools.
# Heuristic, not a seal: subshells, base64, variables, and script interpreters
# evade it; audit log + policies.lock are the detection tier (clause 18).
package governance

import rego.v1

# word operators: target path appears anywhere in the following segment
deny contains msg if {
	input.tool_name == "exec"
	c := lower(replace(input.tool_input.command, "\\", "/"))
	some seg in segments_after_op(c)
	seg_contains_protected(seg)
	msg := sprintf("P13-EXEC-WRITE: exec write aimed at protected path: %s", [input.tool_input.command])
}

# redirection: the post-">" segment must START with a protected path —
# avoids false hits on `2>/dev/null` and reads piped to safe targets
deny contains msg if {
	input.tool_name == "exec"
	c := lower(replace(input.tool_input.command, "\\", "/"))
	some seg in segments_after_redirect(c)
	seg_starts_protected(seg)
	msg := sprintf("P13-EXEC-WRITE: exec redirect to protected path: %s", [input.tool_input.command])
}

segments_after_op(c) := [trim_space(p) |
	some op in {" cp ", " mv ", " tee ", "sed -i", "sed --in-place", " install ", " dd ", " truncate ", " touch ", " rm ", " patch ", " nano ", " vim ", " code ", "git checkout", "git restore", "git apply", "git clean"}
	parts := split(c, op)
	some i in numbers.range(1, count(parts) - 1)
	p := parts[i]
]

segments_after_redirect(c) := [trim_space(p) |
	parts := split(c, ">")
	some i in numbers.range(1, count(parts) - 1)
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
