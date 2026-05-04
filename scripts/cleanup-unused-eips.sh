#!/usr/bin/env bash
# Identifica e libera Elastic IPs não associados a nenhuma instância.
# EIPs não associados custam ~$3.65/mês cada.
#
# Uso: ./cleanup-unused-eips.sh [--region us-east-1] [--dry-run]

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

echo "🔍 Buscando Elastic IPs não associados na região ${REGION}..."

EIPS=$(aws ec2 describe-addresses \
  --region "$REGION" \
  --query 'Addresses[?AssociationId==`null`].{AllocationId:AllocationId,PublicIp:PublicIp}' \
  --output json)

COUNT=$(echo "$EIPS" | jq length)
echo "📦 Encontrados: ${COUNT} EIPs não associados"

if [[ "$COUNT" -eq 0 ]]; then
  echo "✅ Nenhum EIP ocioso."
  exit 0
fi

echo "$EIPS" | jq -r '.[] | "  \(.PublicIp) (\(.AllocationId))"'
CUSTO_MENSAL=$(echo "$COUNT * 3.65" | bc)
echo ""
echo "💸 Custo estimado desses EIPs: ~USD ${CUSTO_MENSAL}/mês"

if [[ "$DRY_RUN" == true ]]; then
  echo "🏁 Modo dry-run. Nenhuma alteração feita."
  exit 0
fi

read -rp "Deseja liberar todos? (s/N) " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
  echo "Cancelado."
  exit 0
fi

echo "$EIPS" | jq -r '.[].AllocationId' | while read -r ALLOC_ID; do
  echo "🗑️  Liberando ${ALLOC_ID}..."
  aws ec2 release-address --region "$REGION" --allocation-id "$ALLOC_ID"
  echo "   ✅ Liberado"
done

echo "🎉 Limpeza concluída!"
