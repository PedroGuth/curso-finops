#!/usr/bin/env bash
# Migra todos os volumes EBS gp2 para gp3 em uma região.
# gp3 é ~20% mais barato que gp2 e oferece 3000 IOPS + 125 MB/s de base.
#
# Uso: ./migrate-gp2-to-gp3.sh [--region us-east-1] [--dry-run]

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

echo "🔍 Buscando volumes gp2 na região ${REGION}..."

VOLUMES=$(aws ec2 describe-volumes \
  --region "$REGION" \
  --filters Name=volume-type,Values=gp2 \
  --query 'Volumes[].{ID:VolumeId,Size:Size,State:State}' \
  --output json)

COUNT=$(echo "$VOLUMES" | jq length)
echo "📦 Encontrados: ${COUNT} volumes gp2"

if [[ "$COUNT" -eq 0 ]]; then
  echo "✅ Nenhum volume gp2 para migrar."
  exit 0
fi

echo "$VOLUMES" | jq -r '.[] | "  \(.ID) - \(.Size) GB (\(.State))"'
echo ""

if [[ "$DRY_RUN" == true ]]; then
  echo "🏁 Modo dry-run. Nenhuma alteração feita."
  exit 0
fi

read -rp "Deseja migrar todos para gp3? (s/N) " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
  echo "Cancelado."
  exit 0
fi

echo "$VOLUMES" | jq -r '.[].ID' | while read -r VOL_ID; do
  echo "🔄 Migrando ${VOL_ID} para gp3..."
  aws ec2 modify-volume \
    --region "$REGION" \
    --volume-id "$VOL_ID" \
    --volume-type gp3 \
    --output text
  echo "   ✅ ${VOL_ID} migrado"
done

echo ""
echo "🎉 Migração concluída! Economia estimada: ~20% no custo de EBS."
