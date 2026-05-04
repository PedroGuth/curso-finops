#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 🔍 FinOps Audit - Auditoria Completa de Custos AWS
# ============================================================

REGION="us-east-1"
OUTPUT="terminal"
REPORT_FILE="finops-audit-report.md"
TOTAL_SAVINGS=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --region REGION    AWS region (default: us-east-1)
  --output FORMAT   Output format: terminal|markdown|json (default: terminal)
  -h, --help        Show this help

Examples:
  $(basename "$0") --region us-east-1 --output markdown
  $(basename "$0") --output json
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region) REGION="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# --- Helpers ---
SECTIONS=()
JSON_SECTIONS=()

add_savings() {
  local amount="${1:-0}"
  TOTAL_SAVINGS=$(echo "$TOTAL_SAVINGS + $amount" | bc 2>/dev/null || echo "$TOTAL_SAVINGS")
}

section() {
  local title="$1"
  if [[ "$OUTPUT" == "terminal" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $title"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  fi
  SECTIONS+=("## $title")
}

info() {
  local msg="$1"
  if [[ "$OUTPUT" == "terminal" ]]; then
    echo "  $msg"
  fi
  SECTIONS+=("$msg")
}

run_check() {
  local name="$1"
  shift
  if ! "$@" 2>/dev/null; then
    info "⚠️  Falha ao executar: $name (continuando...)"
  fi
}

# --- 1. Resumo da Conta ---
check_account() {
  section "📋 1. Resumo da Conta"
  local account_id
  account_id=$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null || echo "N/A")
  local today
  today=$(date +%Y-%m-%d)
  info "  🆔 Account ID: $account_id"
  info "  🌎 Região: $REGION"
  info "  📅 Data: $today"
  JSON_SECTIONS+=("\"account\":{\"id\":\"$account_id\",\"region\":\"$REGION\",\"date\":\"$today\"}")
}

# --- 2. Custo Estimado do Mês ---
check_costs() {
  section "💰 2. Custo Estimado do Mês (últimos 30 dias)"
  local start_date end_date
  end_date=$(date +%Y-%m-%d)
  start_date=$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d '30 days ago' +%Y-%m-%d)

  local cost_data
  cost_data=$(aws ce get-cost-and-usage \
    --time-period Start="$start_date",End="$end_date" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --query 'ResultsByTime[].Groups[].{Service:Keys[0],Amount:Metrics.BlendedCost.Amount}' \
    --output json 2>/dev/null)

  if [[ -n "$cost_data" ]]; then
    local total
    total=$(echo "$cost_data" | python3 -c "
import json,sys
data=json.load(sys.stdin)
total=sum(float(d['Amount']) for d in data)
print(f'{total:.2f}')
" 2>/dev/null || echo "0.00")
    info "  💵 Custo total (30 dias): \$$total"
    info ""
    info "  📊 Top 5 Serviços:"
    echo "$cost_data" | python3 -c "
import json,sys
data=json.load(sys.stdin)
data.sort(key=lambda x: float(x['Amount']), reverse=True)
for i,d in enumerate(data[:5],1):
    print(f'     {i}. {d[\"Service\"]}: \${float(d[\"Amount\"]):.2f}')
" 2>/dev/null | while read -r line; do info "$line"; done
  else
    info "  ⚠️  Não foi possível obter dados de custo"
  fi
}

# --- 3. EC2 ---
check_ec2() {
  section "🖥️  3. EC2 - Instâncias"
  local all_instances stopped old_gen
  all_instances=$(aws ec2 describe-instances --region "$REGION" \
    --query 'Reservations[].Instances[].InstanceId' --output json 2>/dev/null)
  local total
  total=$(echo "$all_instances" | python3 -c "import json,sys;print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)

  stopped=$(aws ec2 describe-instances --region "$REGION" \
    --filters Name=instance-state-name,Values=stopped \
    --query 'Reservations[].Instances[].InstanceId' --output json 2>/dev/null)
  local stopped_count
  stopped_count=$(echo "$stopped" | python3 -c "import json,sys;print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)

  old_gen=$(aws ec2 describe-instances --region "$REGION" \
    --query 'Reservations[].Instances[].InstanceType' --output json 2>/dev/null)
  local old_gen_count
  old_gen_count=$(echo "$old_gen" | python3 -c "
import json,sys,re
types=json.load(sys.stdin)
old=sum(1 for t in types if re.match(r'^(t2|m4|c4|r4)',t))
print(old)
" 2>/dev/null || echo 0)

  info "  📦 Total de instâncias: $total"
  info "  🛑 Instâncias paradas: $stopped_count"
  info "  🏚️  Gerações antigas (t2/m4/c4/r4): $old_gen_count"
  JSON_SECTIONS+=("\"ec2\":{\"total\":$total,\"stopped\":$stopped_count,\"old_gen\":$old_gen_count}")
}

# --- 4. EBS ---
check_ebs() {
  section "💾 4. EBS - Volumes"
  local gp2_volumes
  gp2_volumes=$(aws ec2 describe-volumes --region "$REGION" \
    --filters Name=volume-type,Values=gp2 \
    --query 'Volumes[].{Id:VolumeId,Size:Size}' --output json 2>/dev/null)
  local gp2_count gp2_total_gb savings
  gp2_count=$(echo "$gp2_volumes" | python3 -c "import json,sys;print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)
  gp2_total_gb=$(echo "$gp2_volumes" | python3 -c "
import json,sys
vols=json.load(sys.stdin)
print(sum(v['Size'] for v in vols))
" 2>/dev/null || echo 0)
  # gp2=$0.10/GB, gp3=$0.08/GB → economia de $0.02/GB/mês
  savings=$(echo "$gp2_total_gb * 0.02" | bc 2>/dev/null || echo 0)
  add_savings "$savings"

  local unattached
  unattached=$(aws ec2 describe-volumes --region "$REGION" \
    --filters Name=status,Values=available \
    --query 'Volumes[].VolumeId' --output json 2>/dev/null)
  local unattached_count
  unattached_count=$(echo "$unattached" | python3 -c "import json,sys;print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)

  info "  📀 Volumes gp2: $gp2_count ($gp2_total_gb GB)"
  info "  💡 Economia potencial (gp2→gp3): \$$savings/mês"
  info "  🔌 Volumes não anexados: $unattached_count"
  JSON_SECTIONS+=("\"ebs\":{\"gp2_count\":$gp2_count,\"gp2_gb\":$gp2_total_gb,\"savings\":$savings,\"unattached\":$unattached_count}")
}

# --- 5. EIPs ---
check_eips() {
  section "🌐 5. Elastic IPs"
  local eips
  eips=$(aws ec2 describe-addresses --region "$REGION" \
    --query 'Addresses[?AssociationId==null].PublicIp' --output json 2>/dev/null)
  local eip_count savings
  eip_count=$(echo "$eips" | python3 -c "import json,sys;print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)
  # $0.005/hora × 730h = $3.65/mês por EIP
  savings=$(echo "$eip_count * 3.65" | bc 2>/dev/null || echo 0)
  add_savings "$savings"

  info "  🏷️  EIPs não associados: $eip_count"
  info "  💡 Custo desperdiçado: \$$savings/mês"
  JSON_SECTIONS+=("\"eips\":{\"unassociated\":$eip_count,\"waste\":$savings}")
}

# --- 6. Snapshots Órfãos ---
check_snapshots() {
  section "📸 6. Snapshots Órfãos"
  local snapshots account_id
  account_id=$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null)
  snapshots=$(aws ec2 describe-snapshots --region "$REGION" \
    --owner-ids "$account_id" \
    --query 'Snapshots[].{Id:SnapshotId,VolumeId:VolumeId,Size:VolumeSize}' \
    --output json 2>/dev/null)

  local orphan_count orphan_gb savings
  orphan_count=0; orphan_gb=0
  if [[ -n "$snapshots" ]]; then
    local result
    result=$(echo "$snapshots" | python3 -c "
import json,sys,subprocess
snaps=json.load(sys.stdin)
volumes=set()
try:
    out=subprocess.check_output(['aws','ec2','describe-volumes','--region','$REGION','--query','Volumes[].VolumeId','--output','json'],stderr=subprocess.DEVNULL)
    volumes=set(json.loads(out))
except: pass
orphans=[s for s in snaps if s['VolumeId'] not in volumes]
total_gb=sum(s['Size'] for s in orphans)
print(f'{len(orphans)} {total_gb}')
" 2>/dev/null || echo "0 0")
    orphan_count=$(echo "$result" | awk '{print $1}')
    orphan_gb=$(echo "$result" | awk '{print $2}')
  fi
  # $0.05/GB/mês
  savings=$(echo "$orphan_gb * 0.05" | bc 2>/dev/null || echo 0)
  add_savings "$savings"

  info "  🗑️  Snapshots órfãos: $orphan_count ($orphan_gb GB)"
  info "  💡 Economia potencial: \$$savings/mês"
  JSON_SECTIONS+=("\"snapshots\":{\"orphans\":$orphan_count,\"gb\":$orphan_gb,\"savings\":$savings}")
}

# --- 7. RDS Ociosas ---
check_rds() {
  section "🗄️  7. RDS - Instâncias Ociosas"
  local instances
  instances=$(aws rds describe-db-instances --region "$REGION" \
    --query 'DBInstances[].DBInstanceIdentifier' --output json 2>/dev/null)
  local idle_count=0 total_count
  total_count=$(echo "$instances" | python3 -c "import json,sys;print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)

  if [[ "$total_count" -gt 0 ]]; then
    local end_time start_time
    end_time=$(date -u +%Y-%m-%dT%H:%M:%S)
    start_time=$(date -u -v-1H +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S)
    for db in $(echo "$instances" | python3 -c "import json,sys;[print(x) for x in json.load(sys.stdin)]" 2>/dev/null); do
      local conns
      conns=$(aws cloudwatch get-metric-statistics --region "$REGION" \
        --namespace AWS/RDS --metric-name DatabaseConnections \
        --dimensions Name=DBInstanceIdentifier,Value="$db" \
        --start-time "$start_time" --end-time "$end_time" \
        --period 3600 --statistics Average \
        --query 'Datapoints[0].Average' --output text 2>/dev/null || echo "N/A")
      if [[ "$conns" == "0" || "$conns" == "0.0" ]]; then
        ((idle_count++)) || true
      fi
    done
  fi

  info "  📦 Total RDS: $total_count"
  info "  😴 Instâncias ociosas (0 conexões): $idle_count"
  JSON_SECTIONS+=("\"rds\":{\"total\":$total_count,\"idle\":$idle_count}")
}

# --- 8. S3 sem Lifecycle ---
check_s3() {
  section "🪣 8. S3 - Buckets sem Lifecycle"
  local buckets
  buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output json 2>/dev/null)
  local total no_lifecycle=0
  total=$(echo "$buckets" | python3 -c "import json,sys;print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)

  for bucket in $(echo "$buckets" | python3 -c "import json,sys;[print(x) for x in json.load(sys.stdin)]" 2>/dev/null); do
    if ! aws s3api get-bucket-lifecycle-configuration --bucket "$bucket" &>/dev/null; then
      ((no_lifecycle++)) || true
    fi
  done

  info "  🪣 Total de buckets: $total"
  info "  ⚠️  Sem lifecycle policy: $no_lifecycle"
  JSON_SECTIONS+=("\"s3\":{\"total\":$total,\"no_lifecycle\":$no_lifecycle}")
}

# --- 9. Tags Compliance ---
check_tags() {
  section "🏷️  9. Tags - Compliance"
  local required_tags=("Environment" "Project" "Owner")
  local instances
  instances=$(aws ec2 describe-instances --region "$REGION" \
    --query 'Reservations[].Instances[].{Id:InstanceId,Tags:Tags}' --output json 2>/dev/null)

  local result
  result=$(echo "$instances" | python3 -c "
import json,sys
required=$( printf '%s\n' "${required_tags[@]}" | python3 -c "import sys;print([l.strip() for l in sys.stdin])")
instances=json.load(sys.stdin)
total=len(instances)
compliant=0
for i in instances:
    tags={t['Key']:t['Value'] for t in (i.get('Tags') or [])}
    if all(k in tags for k in $( printf '%s\n' "${required_tags[@]}" | python3 -c "import sys;print([l.strip() for l in sys.stdin])")):
        compliant+=1
rate=(compliant/total*100) if total>0 else 0
print(f'{total} {compliant} {rate:.1f}')
" 2>/dev/null || echo "0 0 0")

  local total compliant rate
  total=$(echo "$result" | awk '{print $1}')
  compliant=$(echo "$result" | awk '{print $2}')
  rate=$(echo "$result" | awk '{print $3}')

  info "  📦 Instâncias EC2: $total"
  info "  ✅ Com tags obrigatórias: $compliant"
  info "  📊 Taxa de compliance: ${rate}%"
  info "  🏷️  Tags verificadas: ${required_tags[*]}"
  JSON_SECTIONS+=("\"tags\":{\"total\":$total,\"compliant\":$compliant,\"rate\":$rate}")
}

# --- 10. Savings Plans ---
check_savings_plans() {
  section "📈 10. Savings Plans - Cobertura"
  local end_date start_date
  end_date=$(date +%Y-%m-%d)
  start_date=$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d '30 days ago' +%Y-%m-%d)

  local coverage
  coverage=$(aws ce get-savings-plans-coverage \
    --time-period Start="$start_date",End="$end_date" \
    --query 'SavingsPlansCoverages[0].Coverage.CoveragePercentage' \
    --output text 2>/dev/null || echo "N/A")

  local utilization
  utilization=$(aws ce get-savings-plans-utilization \
    --time-period Start="$start_date",End="$end_date" \
    --query 'Total.Utilization.UtilizationPercentage' \
    --output text 2>/dev/null || echo "N/A")

  info "  📊 Cobertura de Savings Plans: ${coverage}%"
  info "  🎯 Utilização: ${utilization}%"
  JSON_SECTIONS+=("\"savings_plans\":{\"coverage\":\"$coverage\",\"utilization\":\"$utilization\"}")
}

# --- Resumo Final ---
show_summary() {
  section "🏁 RESUMO - Economia Total Possível"
  info ""
  info "  💰💰💰 Economia mensal estimada: \$${TOTAL_SAVINGS}/mês 💰💰💰"
  info ""
  info "  🚀 Próximos passos:"
  info "     1. Migrar volumes gp2 → gp3"
  info "     2. Liberar EIPs não utilizados"
  info "     3. Remover snapshots órfãos"
  info "     4. Avaliar instâncias paradas e gerações antigas"
  info "     5. Configurar lifecycle em buckets S3"
  info ""
  info "  📅 Relatório gerado em: $(date '+%Y-%m-%d %H:%M:%S')"
}

# --- Main ---
main() {
  if [[ "$OUTPUT" == "terminal" ]]; then
    echo ""
    echo "🔍 ═══════════════════════════════════════════════════════"
    echo "   FinOps Audit - Auditoria Completa de Custos AWS"
    echo "═══════════════════════════════════════════════════════════"
  fi

  run_check "Resumo da Conta" check_account
  run_check "Custos" check_costs
  run_check "EC2" check_ec2
  run_check "EBS" check_ebs
  run_check "EIPs" check_eips
  run_check "Snapshots" check_snapshots
  run_check "RDS" check_rds
  run_check "S3" check_s3
  run_check "Tags" check_tags
  run_check "Savings Plans" check_savings_plans
  show_summary

  if [[ "$OUTPUT" == "markdown" ]]; then
    {
      echo "# 🔍 FinOps Audit Report"
      echo ""
      echo "> Gerado em: $(date '+%Y-%m-%d %H:%M:%S') | Região: $REGION"
      echo ""
      printf '%s\n' "${SECTIONS[@]}"
    } > "$REPORT_FILE"
    echo ""
    echo "✅ Relatório salvo em: $REPORT_FILE"
  elif [[ "$OUTPUT" == "json" ]]; then
    echo "{$(IFS=,; echo "${JSON_SECTIONS[*]}"),\"total_savings\":$TOTAL_SAVINGS}"
  fi
}

main
