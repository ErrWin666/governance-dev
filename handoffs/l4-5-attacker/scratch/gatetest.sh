#!/bin/bash
# Replicate gate.sh env construction + opa eval for a given command
# NOTE: uses PATH-resolved jq/python3/opa because gate.sh's hardcoded
# /usr/bin/{jq,python3,opa} do not exist on this Windows host (itself a finding).
cd /c/governance-dev || exit 1
CMD="$1"
ANA=$(printf '%s' "$CMD" | python3 policies/exec_analyze.py "$(pwd)" 2>/dev/null || echo '{"ok":false,"crashed":true}')
INV=$(grep -v '^[[:space:]]*#' policies/.governance/tool-inventory.txt | sed '/^[[:space:]]*$/d' | jq -R . | jq -sc .)
FT='[]'; [ -f tests.lock ] && FT=$(awk '{print $NF}' tests.lock | jq -R . | jq -sc .)
ENVJSON=$(jq -n --argjson inv "$INV" --argjson ft "$FT" --argjson ea "$ANA" \
  '{env:{inventory:$inv,frozen_tests:$ft,evidence_present:false,tests_locked:false,evidence_manifests:[],current_phase:null,exec_analysis:$ea,plan_spec_approved:false,plan_tasks_approved:false}}')
printf '%s' "$ENVJSON" > /tmp/env.json
INPUT=$(jq -n --arg c "$CMD" '{tool_name:"exec",tool_input:{command:$c}}')
printf '%s' "$INPUT" | opa eval --data policies/ --data /tmp/env.json --stdin-input 'data.governance.decision' --format pretty 2>&1 | head -25
echo "ANALYZER: $ANA"
