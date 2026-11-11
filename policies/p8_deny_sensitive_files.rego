# WHY: credentials and key material written through agent tools leave the
# audit boundary and are unrecoverable once leaked (M5).
# Matchers verified against 15-name inventory (STATE.md, ERR-006)
package governance

import rego.v1

deny contains msg if {
	input.tool_name in {"write", "edit", "notebook_edit"}
	p := norm(target_path)
	some pat in sensitive_patterns
	sensitive_match(p, pat)
	msg := sprintf("P8-SENSITIVE-FILE: %s", [pat])
}

sensitive_patterns := {
	".env", ".env.local", ".env.production", ".env.development", ".env.staging",
	".pem", ".key",
	"id_rsa", "id_ed25519", "id_dsa",
	"credentials.json", "credentials.yaml", "credentials.yml",
	"/secrets/", "secrets.",
}

sensitive_match(p, pat) if {
	endswith(p, pat)
	not endswith(p, ".env.example")
	not endswith(p, ".env.template")
}

sensitive_match(p, pat) if {
	contains(p, pat)
	startswith(pat, "/")
}

# prefix-family patterns like "secrets." only fire on basename
# (verifier: endswith(".../secrets.txt","secrets.") never matched)
sensitive_match(p, pat) if {
	endswith(pat, ".")
		parts := split(p, "/")
	base := parts[count(parts) - 1]
	startswith(base, pat)
}
