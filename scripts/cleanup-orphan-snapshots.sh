#!/usr/bin/env bash
# Identifica snapshots EBS órfãos (cujo volume de origem não existe mais).
# Snapshots custam $0.05/GB/mês e se acumulam rápido.
#
# Uso: ./cleanup-orphan-snapshots.sh [--region us-east-1] [--dry-run]

set -euo pipefail

REGION="${AWS_DEFAULT_REGION:-us-east-1}"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region)  REGION="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *)         echo "Uso: $0 [--region REGION] [--dry-run]"; exit 1 ;;
  esac
done

echo "🔍 Buscando snapshots na região ${REGION}..."

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

SNAPSHOTS=$(aws ec2 describe-snapshots \
  --region "$REGION" \
  --owner-ids "$ACCOUNT_ID" \
  --query 'Snapshots[].{ID:SnapshotId,VolumeId:VolumeId,Size:VolumeSize,Date:StartTime}' \
  --output json)

TOTAL=$(echo "$SNAPSHOTS" | jq length)
echo "📦 Total de snapshots: ${TOTAL}"

echo "🔍 Verificando volumes existentes..."
VOLUMES=$(aws ec2 describe-volumes \
  --region "$REGION" \
  --query 'Volumes[].VolumeId' \
  --output json)

ORPHANS=$(echo "$SNAPSHOTS" | jq --argjson vols "$VOLUMES" \
  '[.[] | select(.VolumeId as $vid | $vols | index($vid) | not)]')

ORPHAN_COUNT=$(echo "$ORPHANS" | jq length)
ORPHAN_SIZE=$(echo "$ORPHANS" | jq '[.[].Size] | add // 0')

echo "🗑️  Snapshots órfãos: ${ORPHAN_COUNT}"
echo "💾 Tamanho total: ${ORPHAN_SIZE} GB"
echo "💸 Custo estimado: ~USD $(echo "$ORPHAN_SIZE * 0.05" | bc)/mês"
echo ""

if [[ "$ORPHAN_COUNT" -eq 0 ]]; then
  echo "✅ Nenhum snapshot órfão."
  exit 0
fi

echo "$ORPHANS" | jq -r '.[] | "  \(.ID) - vol: \(.VolumeId) - \(.Size) GB (\(.Date))"'

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "🏁 Modo dry-run. Nenhuma alteração feita."
  exit 0
fi

echo ""
read -rp "Deseja deletar todos os snapshots órfãos? (s/N) " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
  echo "Cancelado."
  exit 0
fi

echo "$ORPHANS" | jq -r '.[].ID' | while read -r SNAP_ID; do
  echo "🗑️  Deletando ${SNAP_ID}..."
  aws ec2 delete-snapshot --region "$REGION" --snapshot-id "$SNAP_ID"
  echo "   ✅ Deletado"
done

echo "🎉 Limpeza concluída!"
