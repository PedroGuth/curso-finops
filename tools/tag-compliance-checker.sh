#!/usr/bin/env bash
# ============================================================================
# Tag Compliance Checker - Verificador de Compliance de Tags
# ============================================================================
# Verifica se os recursos AWS possuem as tags obrigatórias definidas pela
# organização e gera relatório de conformidade.
#
# Tags verificadas: Department, Environment, Application, CostCenter
#
# Uso:
#   ./tag-compliance-checker.sh [--region us-east-1] [--format table|csv|json]
#
# Requisitos: AWS CLI, jq
# ============================================================================

set -euo pipefail

REGION="${AWS_DEFAULT_REGION:-us-east-1}"
FORMAT="table"
REQUIRED_TAGS=("Department" "Environment" "Application" "CostCenter")

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region)  REGION="$2"; shift 2 ;;
    --format)  FORMAT="$2"; shift 2 ;;
    --tags)    IFS=',' read -ra REQUIRED_TAGS <<< "$2"; shift 2 ;;
    -h|--help)
      echo "Uso: $0 [--region REGION] [--format table|csv|json] [--tags tag1,tag2,tag3]"
      echo ""
      echo "Opções:"
      echo "  --region   Região AWS (default: us-east-1)"
      echo "  --format   Formato de saída: table, csv, json (default: table)"
      echo "  --tags     Tags obrigatórias separadas por vírgula"
      exit 0
      ;;
    *)         echo "Opção desconhecida: $1"; exit 1 ;;
  esac
done

echo "============================================================================"
echo "🏷️  Tag Compliance Checker"
echo "============================================================================"
echo "Região: ${REGION}"
echo "Tags obrigatórias: ${REQUIRED_TAGS[*]}"
echo "Data: $(date '+%Y-%m-%d %H:%M')"
echo "============================================================================"
echo ""

TOTAL=0
COMPLIANT=0
NON_COMPLIANT=0
RESULTS="[]"

# --- EC2 Instances ---
echo "🔍 Verificando instâncias EC2..."
INSTANCES=$(aws ec2 describe-instances \
  --region "$REGION" \
  --query 'Reservations[].Instances[].{Id:InstanceId,Tags:Tags,Type:InstanceType,State:State.Name}' \
  --output json)

for row in $(echo "$INSTANCES" | jq -c '.[]'); do
  TOTAL=$((TOTAL + 1))
  INSTANCE_ID=$(echo "$row" | jq -r '.Id')
  STATE=$(echo "$row" | jq -r '.State')
  TAGS=$(echo "$row" | jq -r '.Tags // []')
  MISSING=()

  for tag in "${REQUIRED_TAGS[@]}"; do
    HAS_TAG=$(echo "$TAGS" | jq -r --arg t "$tag" '[.[] | select(.Key == $t)] | length')
    if [[ "$HAS_TAG" == "0" ]]; then
      MISSING+=("$tag")
    fi
  done

  if [[ ${#MISSING[@]} -eq 0 ]]; then
    COMPLIANT=$((COMPLIANT + 1))
    STATUS="✅ Compliant"
  else
    NON_COMPLIANT=$((NON_COMPLIANT + 1))
    STATUS="❌ Non-compliant"
  fi

  RESULTS=$(echo "$RESULTS" | jq --arg id "$INSTANCE_ID" --arg type "EC2" \
    --arg status "$STATUS" --arg missing "${MISSING[*]:-}" --arg state "$STATE" \
    '. += [{"resource_type": $type, "resource_id": $id, "state": $state, "status": $status, "missing_tags": $missing}]')
done

# --- EBS Volumes ---
echo "🔍 Verificando volumes EBS..."
VOLUMES=$(aws ec2 describe-volumes \
  --region "$REGION" \
  --query 'Volumes[].{Id:VolumeId,Tags:Tags,Size:Size,Type:VolumeType}' \
  --output json)

for row in $(echo "$VOLUMES" | jq -c '.[]'); do
  TOTAL=$((TOTAL + 1))
  VOL_ID=$(echo "$row" | jq -r '.Id')
  TAGS=$(echo "$row" | jq -r '.Tags // []')
  MISSING=()

  for tag in "${REQUIRED_TAGS[@]}"; do
    HAS_TAG=$(echo "$TAGS" | jq -r --arg t "$tag" '[.[] | select(.Key == $t)] | length')
    if [[ "$HAS_TAG" == "0" ]]; then
      MISSING+=("$tag")
    fi
  done

  if [[ ${#MISSING[@]} -eq 0 ]]; then
    COMPLIANT=$((COMPLIANT + 1))
    STATUS="✅ Compliant"
  else
    NON_COMPLIANT=$((NON_COMPLIANT + 1))
    STATUS="❌ Non-compliant"
  fi

  RESULTS=$(echo "$RESULTS" | jq --arg id "$VOL_ID" --arg type "EBS" \
    --arg status "$STATUS" --arg missing "${MISSING[*]:-}" --arg state "n/a" \
    '. += [{"resource_type": $type, "resource_id": $id, "state": $state, "status": $status, "missing_tags": $missing}]')
done

# --- RDS Instances ---
echo "🔍 Verificando instâncias RDS..."
RDS_INSTANCES=$(aws rds describe-db-instances \
  --region "$REGION" \
  --query 'DBInstances[].{Id:DBInstanceIdentifier,Arn:DBInstanceArn,Class:DBInstanceClass}' \
  --output json)

for row in $(echo "$RDS_INSTANCES" | jq -c '.[]'); do
  TOTAL=$((TOTAL + 1))
  DB_ID=$(echo "$row" | jq -r '.Id')
  DB_ARN=$(echo "$row" | jq -r '.Arn')
  TAGS=$(aws rds list-tags-for-resource --resource-name "$DB_ARN" --query 'TagList' --output json 2>/dev/null || echo "[]")
  MISSING=()

  for tag in "${REQUIRED_TAGS[@]}"; do
    HAS_TAG=$(echo "$TAGS" | jq -r --arg t "$tag" '[.[] | select(.Key == $t)] | length')
    if [[ "$HAS_TAG" == "0" ]]; then
      MISSING+=("$tag")
    fi
  done

  if [[ ${#MISSING[@]} -eq 0 ]]; then
    COMPLIANT=$((COMPLIANT + 1))
    STATUS="✅ Compliant"
  else
    NON_COMPLIANT=$((NON_COMPLIANT + 1))
    STATUS="❌ Non-compliant"
  fi

  RESULTS=$(echo "$RESULTS" | jq --arg id "$DB_ID" --arg type "RDS" \
    --arg status "$STATUS" --arg missing "${MISSING[*]:-}" --arg state "n/a" \
    '. += [{"resource_type": $type, "resource_id": $id, "state": $state, "status": $status, "missing_tags": $missing}]')
done

# --- S3 Buckets ---
echo "🔍 Verificando buckets S3..."
BUCKETS=$(aws s3api list-buckets --query 'Buckets[].Name' --output json)

for BUCKET in $(echo "$BUCKETS" | jq -r '.[]'); do
  TOTAL=$((TOTAL + 1))
  TAGS=$(aws s3api get-bucket-tagging --bucket "$BUCKET" --query 'TagSet' --output json 2>/dev/null || echo "[]")
  MISSING=()

  for tag in "${REQUIRED_TAGS[@]}"; do
    HAS_TAG=$(echo "$TAGS" | jq -r --arg t "$tag" '[.[] | select(.Key == $t)] | length')
    if [[ "$HAS_TAG" == "0" ]]; then
      MISSING+=("$tag")
    fi
  done

  if [[ ${#MISSING[@]} -eq 0 ]]; then
    COMPLIANT=$((COMPLIANT + 1))
    STATUS="✅ Compliant"
  else
    NON_COMPLIANT=$((NON_COMPLIANT + 1))
    STATUS="❌ Non-compliant"
  fi

  RESULTS=$(echo "$RESULTS" | jq --arg id "$BUCKET" --arg type "S3" \
    --arg status "$STATUS" --arg missing "${MISSING[*]:-}" --arg state "n/a" \
    '. += [{"resource_type": $type, "resource_id": $id, "state": $state, "status": $status, "missing_tags": $missing}]')
done

# --- Relatório ---
echo ""
echo "============================================================================"
echo "📊 RESULTADO"
echo "============================================================================"

COMPLIANCE_RATE=0
if [[ $TOTAL -gt 0 ]]; then
  COMPLIANCE_RATE=$(echo "scale=1; $COMPLIANT * 100 / $TOTAL" | bc)
fi

echo "Total de recursos: ${TOTAL}"
echo "✅ Conformes: ${COMPLIANT}"
echo "❌ Não conformes: ${NON_COMPLIANT}"
echo "📈 Taxa de conformidade: ${COMPLIANCE_RATE}%"
echo ""

case "$FORMAT" in
  json)
    echo "$RESULTS" | jq '.'
    echo "$RESULTS" > tag-compliance-report.json
    echo "📁 Relatório salvo: tag-compliance-report.json"
    ;;
  csv)
    echo "resource_type,resource_id,status,missing_tags" > tag-compliance-report.csv
    echo "$RESULTS" | jq -r '.[] | [.resource_type, .resource_id, .status, .missing_tags] | @csv' >> tag-compliance-report.csv
    echo "📁 Relatório salvo: tag-compliance-report.csv"
    ;;
  table|*)
    echo "Recursos NÃO conformes:"
    echo ""
    echo "$RESULTS" | jq -r '.[] | select(.status | contains("Non-compliant")) | "  \(.resource_type)\t\(.resource_id)\tFaltando: \(.missing_tags)"'
    ;;
esac

echo ""
echo "============================================================================"
if (( $(echo "$COMPLIANCE_RATE < 80" | bc -l) )); then
  echo "⚠️  Taxa de conformidade abaixo de 80%. Ação necessária!"
elif (( $(echo "$COMPLIANCE_RATE < 95" | bc -l) )); then
  echo "🟡 Bom progresso! Faltam poucos recursos para 100%."
else
  echo "🎉 Excelente! Quase todos os recursos estão conformes!"
fi
echo "============================================================================"
