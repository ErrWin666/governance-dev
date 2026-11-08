# WHY: post-freeze edits to locked tests invalidate the evidence chain (M4)
# Matchers verified against 15-name inventory (STATE.md, ERR-006)
# Semantics: frozen iff tests.lock exists. New test files allowed (not in lock);
# modifying a locked path or the lock itself is denied.
package governance

import rego.v1

deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	not target_path
	msg := sprintf("P2-MALFORMED: %s call missing file_path/notebook_path", [input.tool_name])
}

# Lock integrity — tests.lock itself is never written through tools.
deny contains msg if {
	input.tool_name in {"write", "edit"}
	path_matches(norm(target_path), "tests.lock")
	msg := sprintf("P2-LOCK-MOD: tests.lock may not be modified via %s", [input.tool_name])
}

deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	object.get(data.env, "tests_locked", false) == true
	p := norm(target_path)
	some f in object.get(data.env, "frozen_tests", [])
	path_matches(p, norm(f))
	msg := sprintf("P2-TEST-FROZEN: %s is in tests.lock (frozen, M4)", [target_path])
}

path_matches(p, f) if {
	p == f
}

path_matches(p, f) if {
	endswith(p, sprintf("/%s", [f]))
}
