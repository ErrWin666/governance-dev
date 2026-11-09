#!/usr/bin/env bash
# WHY: single fail-closed entrypoint for the PreToolUse gate (M5, R1).
set -u

export PATH="$HOME/.local/bin:$PATH"

[ -f ./policies/main.rego ] || exit 0

mkdir -p logs
PAYLOAD="$(cat)"
printf '%s\n\n' "$PAYLOAD" >> logs/b1.0-pretool.log
GATE=logs/gate.log

printf '%s PWD-PROOF cwd=%s\n' "$(date -Is)" "$(pwd)" >> "$GATE"

command -v opa >/dev/null 2>&1 || {
	printf '%s GOV_GATE_DOWN opa-not-found\n' "$(date -Is)" >> "$GATE"
	echo 'GOV_GATE_DOWN: opa not installed - fail closed (M5)' >&2
	exit 2
}

# (b) integrity seal: tampered policies = fail closed (GAP-L1-10, owner-sealed)
if [ -f policies/.governance/policies.lock ]; then
	EXP=$(tr -d ' 
' < policies/.governance/policies.lock | tr 'A-F' 'a-f')
	ACT=$(find policies -maxdepth 1 -type f \( -name '*.rego' -o -name 'gate.sh' \) -print0 | sort -z | xargs -0 cat | sha256sum | awk '{print $1}')
	if [ -n "$EXP" ] && [ "$EXP" != "$ACT" ]; then
		printf '%s DENY POLICIES-INTEGRITY lock mismatch
' "$(date -Is)" >> "$GATE"
		echo 'POLICIES-INTEGRITY: policies hash mismatch — tampered or re-seal needed' >&2
		exit 2
	fi
fi

INV=$(grep -v '^[[:space:]]*#' policies/.governance/tool-inventory.txt | sed '/^[[:space:]]*$/d' | jq -R . | jq -sc .)
FT='[]'; TL=false
if [ -f tests.lock ]; then TL=true; FT=$(awk '{print $NF}' tests.lock | jq -R . | jq -sc .); fi
EVP=false; MAN=$(ls evidence/*/manifest.json 2>/dev/null | jq -R . | jq -sc .); MAN=${MAN:-'[]'}
[ "$MAN" != '[]' ] && EVP=true
CUR=$(head -1 policies/.governance/current_phase 2>/dev/null | tr -d ' \r\n')
CURJ=null; [ -n "$CUR" ] && CURJ="\"$CUR\""

# L3: verify approved plan files with hash match
PLAN_SPEC_APPROVED=false
if [ -f plan/spec.approved ] && [ -f plan/spec.md ]; then
    EXPECTED=$(tr -d ' \r\n' < plan/spec.approved | tr 'A-F' 'a-f')
    ACTUAL=$(sha256sum plan/spec.md 2>/dev/null | awk '{print $1}')
    if [ -n "$EXPECTED" ] && [ "$EXPECTED" = "$ACTUAL" ]; then
        PLAN_SPEC_APPROVED=true
    fi
fi

PLAN_TASKS_APPROVED=false
if [ -f plan/tasks.approved ] && [ -f plan/tasks.md ]; then
    EXPECTED=$(tr -d ' \r\n' < plan/tasks.approved | tr 'A-F' 'a-f')
    ACTUAL=$(sha256sum plan/tasks.md 2>/dev/null | awk '{print $1}')
    if [ -n "$EXPECTED" ] && [ "$EXPECTED" = "$ACTUAL" ]; then
        PLAN_TASKS_APPROVED=true
    fi
fi

ENVJSON=$(jq -n --argjson inv "$INV" --argjson ft "$FT" --argjson ev "$EVP" --argjson tl "$TL" \
	--argjson man "$MAN" --argjson cp "$CURJ" \
	--argjson psa "$PLAN_SPEC_APPROVED" --argjson pta "$PLAN_TASKS_APPROVED" \
	'{env:{inventory:$inv,frozen_tests:$ft,evidence_present:$ev,tests_locked:$tl,evidence_manifests:$man,current_phase:$cp,plan_spec_approved:$psa,plan_tasks_approved:$pta}}')

TMP="logs/.gate-env.$$.json"
printf '%s' "$ENVJSON" > "$TMP"

eval_opa() {
	printf '%s' "$PAYLOAD" | timeout 4 opa eval --data policies/ --data "$TMP" --stdin-input 'data.governance.decision' --format json 2>&1
}

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