#!/usr/bin/env bash
# find-idle-rds.sh - Identifica instâncias RDS com 0 conexões nos últimos 7 dias
# Usa métricas do CloudWatch (DatabaseConnections) para detectar RDS ociosos
set -euo pipefail

REGION=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region) REGION="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Uso: $0 [--region us-east-1] [--dry-run]"; exit 1 ;;
  esac
done

AWS_OPTS=()
[[ -n "$REGION" ]] && AWS_OPTS+=(--region "$REGION")

END_TIME=$(date -u +%Y-%m-%dT%H:%M:%S)
START_TIME=$(date -u -v-7d +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S)

echo "=== Instâncias RDS ociosas (0 conexões nos últimos 7 dias) ==="
echo ""
printf "%-30s %-20s %-15s %-15s\n" "DB Identifier" "Classe" "Engine" "Custo Est./mês"
printf "%-30s %-20s %-15s %-15s\n" "-------------" "------" "------" "--------------"

# Custos estimados por classe (USD/mês, on-demand us-east-1)
estimate_cost() {
  case "$1" in
    db.t3.micro)   echo "~\$12" ;;
    db.t3.small)   echo "~\$24" ;;
    db.t3.medium)  echo "~\$49" ;;
    db.t3.large)   echo "~\$98" ;;
    db.r5.large)   echo "~\$172" ;;
    db.r5.xlarge)  echo "~\$344" ;;
    db.r6g.large)  echo "~\$155" ;;
    db.m5.large)   echo "~\$125" ;;
    db.m5.xlarge)  echo "~\$250" ;;
    *)             echo "N/A" ;;
  esac
}

# shellcheck disable=SC2016
INSTANCES=$(aws rds describe-db-instances "${AWS_OPTS[@]}" --query 'DBInstances[?DBInstanceStatus==`available`].[DBInstanceIdentifier,DBInstanceClass,Engine]' --output text)

IDLE_COUNT=0

while IFS=$'\t' read -r db_id db_class engine; do
  [[ -z "$db_id" ]] && continue

  max_connections=$(aws cloudwatch get-metric-statistics "${AWS_OPTS[@]}" \
    --namespace AWS/RDS \
    --metric-name DatabaseConnections \
    --dimensions Name=DBInstanceIdentifier,Value="$db_id" \
    --start-time "$START_TIME" \
    --end-time "$END_TIME" \
    --period 86400 \
    --statistics Maximum \
    --query 'Datapoints[].Maximum' --output text)

  # Verifica se todas as métricas são 0 (ou sem dados)
  is_idle=true
  for val in $max_connections; do
    if [[ "$val" != "0.0" && "$val" != "0" && "$val" != "None" ]]; then
      is_idle=false
      break
    fi
  done

  if $is_idle; then
    cost=$(estimate_cost "$db_class")
    printf "%-30s %-20s %-15s %-15s\n" "$db_id" "$db_class" "$engine" "$cost"
    ((IDLE_COUNT++))
  fi
done <<< "$INSTANCES"

echo ""
echo "Total de instâncias ociosas: $IDLE_COUNT"

if $DRY_RUN; then
  echo ""
  echo "[DRY-RUN] Nenhuma ação executada. Revise as instâncias acima antes de parar/deletar."
fi
