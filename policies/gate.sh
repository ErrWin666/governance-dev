#!/usr/bin/env bash
# WHY: single fail-closed entrypoint for the PreToolUse gate (M5, R1).
# stdin  = Devin hook payload JSON (tool_name, tool_input, ...)
# stdout = unused; stderr = block reason on deny.
# exit 0 allow / exit 2 deny / exit 2 GOV_GATE_DOWN on any error (fail closed).
# Ungoverned workspaces (no ./policies/main.rego) pass through — this hook lives
# in the GLOBAL user config and must not gate unrelated projects.
# Plan B port: targets WSL (native fork). Also runs under Git Bash so the
# transition session keeps working; opa is at ~/.local/bin (no sudo available).
set -u

export PATH="$HOME/.local/bin:$PATH"

[ -f ./policies/main.rego ] || exit 0

mkdir -p logs
PAYLOAD="$(cat)"
printf '%s\n\n' "$PAYLOAD" >> logs/b1.0-pretool.log
GATE=logs/gate.log

# TEMP (Fix-2 cwd proof): remove after fresh session shows /mnt/c/governance-dev.
printf '%s PWD-PROOF cwd=%s\n' "$(date -Is)" "$(pwd)" >> "$GATE"

command -v opa >/dev/null 2>&1 || {
	printf '%s GOV_GATE_DOWN opa-not-found\n' "$(date -Is)" >> "$GATE"
	echo 'GOV_GATE_DOWN: opa not installed - fail closed (M5)' >&2
	exit 2
}

# Runtime-read env data: tool inventory + freeze state + evidence presence.
INV=$(grep -v '^[[:space:]]*#' policies/.governance/tool-inventory.txt | sed '/^[[:space:]]*$/d' | jq -R . | jq -sc .)
FT='[]'; TL=false
if [ -f tests.lock ]; then TL=true; FT=$(awk '{print $NF}' tests.lock | jq -R . | jq -sc .); fi
EVP=false; MAN=$(ls evidence/*/manifest.json 2>/dev/null | jq -R . | jq -sc .); MAN=${MAN:-'[]'}
[ "$MAN" != '[]' ] && EVP=true
CUR=$(head -1 policies/.governance/current_phase 2>/dev/null | tr -d ' \r\n')
CURJ=null; [ -n "$CUR" ] && CURJ="\"$CUR\""
ENVJSON=$(jq -n --argjson inv "$INV" --argjson ft "$FT" --argjson ev "$EVP" --argjson tl "$TL" \
	--argjson man "$MAN" --argjson cp "$CURJ" \
	'{env:{inventory:$inv,frozen_tests:$ft,evidence_present:$ev,tests_locked:$tl,evidence_manifests:$man,current_phase:$cp}}')

# TMP stays project-relative: resolves via cwd under BOTH runtimes (Git Bash
# + Windows opa during transition, WSL + /mnt/c + Linux opa after activation).
# /tmp was rejected: Windows opa cannot read MSYS paths mid-transition.
TMP="logs/.gate-env.$$.json"
printf '%s' "$ENVJSON" > "$TMP"

eval_opa() {
	printf '%s' "$PAYLOAD" | timeout 4 opa eval --data policies/ --data "$TMP" --stdin-input 'data.governance.decision' --format json 2>&1
}

# ERR-007 retry removed: WSL fork is native; a failed eval now logs straight
# to GOV_GATE_DOWN so remaining instability is visible, not masked.
OUT=$(eval_opa); RC=$?
rm -f "$TMP"

if [ "$RC" -ne 0 ] || ! printf '%s' "$OUT" | grep -q '"allow"'; then
	printf '%s GOV_GATE_DOWN rc=%s out=%s\n' "$(date -Is)" "$RC" "$OUT" >> "$GATE"
	echo 'GOV_GATE_DOWN: policy gate unavailable - fail closed' >&2
	exit 2
fi

if printf '%s' "$OUT" | grep -q '"allow"[[:space:]]*:[[:space:]]*false'; then
	REASONS=$(printf '%s' "$OUT" | grep -oE '"(P[0-9]+-|UNRECOGNIZED-TOOL)[^"]*"' | tr -d '"' | paste -sd' | ' -)
	printf '%s DENY %s input=%s\n' "$(date -Is)" "$REASONS" "$PAYLOAD" >> "$GATE"
	printf '%s\n' "$REASONS" >&2
	exit 2
fi
exit 0
