#!/bin/bash
# Replicates gate.sh env construction + opa eval, looping over vectors file.
# Uses PATH-resolved jq/python3/opa (gate.sh's /usr/bin paths absent on this host).
cd /c/governance-dev || exit 1
INV=$(grep -v '^[[:space:]]*#' policies/.governance/tool-inventory.txt | sed '/^[[:space:]]*$/d' | jq -R . | jq -sc .)
FT='[]'; [ -f tests.lock ] && FT=$(awk '{print $NF}' tests.lock | jq -R . | jq -sc .)
i=0
while IFS= read -r CMD; do
  [ -z "$CMD" ] && continue
  i=$((i+1))
  ANA=$(printf '%s' "$CMD" | python3 policies/exec_analyze.py "$(pwd)" 2>/dev/null || echo '{"ok":false,"crashed":true}')
  ENVJSON=$(jq -n --argjson inv "$INV" --argjson ft "$FT" --argjson ea "$ANA" \
    '{env:{inventory:$inv,frozen_tests:$ft,evidence_present:false,tests_locked:false,evidence_manifests:[],current_phase:null,exec_analysis:$ea,plan_spec_approved:false,plan_tasks_approved:false}}')
  printf '%s' "$ENVJSON" > /tmp/env.json
  INPUT=$(jq -n --arg c "$CMD" '{tool_name:"exec",tool_input:{command:$c}}')
  DEC=$(printf '%s' "$INPUT" | opa eval --data policies/ --data /tmp/env.json --stdin-input 'data.governance.decision' --format json 2>/dev/null)
  ALLOW=$(printf '%s' "$DEC" | jq -r '.result[0].expressions[0].value.allow')
  REASONS=$(printf '%s' "$DEC" | jq -rc '.result[0].expressions[0].value.reasons | join(" ; ")')
  echo "V$i [$ALLOW] $CMD"
  echo "    reasons: ${REASONS:-none}"
  echo "    analyzer: $ANA"
done < "$1"
