#!/usr/bin/env bash
# find-old-gen-instances.sh - Lista instâncias EC2 de gerações antigas e sugere upgrade
# Famílias antigas detectadas: t2, m3, m4, c3, c4, r4
set -euo pipefail

REGION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region) REGION="$2"; shift 2 ;;
    *) echo "Uso: $0 [--region us-east-1]"; exit 1 ;;
  esac
done

AWS_OPTS=()
[[ -n "$REGION" ]] && AWS_OPTS+=(--region "$REGION")

# Mapeia família antiga -> família nova sugerida
suggest_type() {
  local instance_type="$1"
  local family size
  family=$(echo "$instance_type" | cut -d. -f1)
  size=$(echo "$instance_type" | cut -d. -f2)

  case "$family" in
    t2) echo "t3.$size" ;;
    m3) echo "m6i.$size" ;;
    m4) echo "m6i.$size" ;;
    c3) echo "c6i.$size" ;;
    c4) echo "c6i.$size" ;;
    r4) echo "r6i.$size" ;;
    *)  echo "N/A" ;;
  esac
}

echo "=== Instâncias EC2 de geração antiga ==="
echo ""
printf "%-22s %-15s %-15s %-20s\n" "Instance ID" "Tipo Atual" "Sugerido" "Nome"
printf "%-22s %-15s %-15s %-20s\n" "-----------" "----------" "--------" "----"

OLD_FAMILIES="t2.*|m3.*|m4.*|c3.*|c4.*|r4.*"
COUNT=0

# shellcheck disable=SC2016
INSTANCES=$(aws ec2 describe-instances "${AWS_OPTS[@]}" \
  --filters "Name=instance-state-name,Values=running,stopped" \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,Tags[?Key==`Name`].Value|[0]]' \
  --output text)

while IFS=$'\t' read -r instance_id instance_type name; do
  [[ -z "$instance_id" ]] && continue

  if echo "$instance_type" | grep -qE "^($OLD_FAMILIES)"; then
    suggested=$(suggest_type "$instance_type")
    name="${name:-sem-nome}"
    printf "%-22s %-15s %-15s %-20s\n" "$instance_id" "$instance_type" "$suggested" "$name"
    ((COUNT++))
  fi
done <<< "$INSTANCES"

echo ""
echo "Total de instâncias de geração antiga: $COUNT"
