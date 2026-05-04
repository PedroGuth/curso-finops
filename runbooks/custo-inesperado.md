# 🚨 Runbook: Custo Inesperado / Fatura Alta

**Situação**: Recebi uma fatura inesperada ou o custo subiu muito em relação ao mês anterior.

**Tempo estimado**: 15–30 minutos

---

## Passo 1 — Verificar Cost Explorer (últimos 7 dias, por serviço)

Identifique qual serviço está gerando o custo anormal:

```bash
aws ce get-cost-and-usage \
  --time-period Start=$(date -v-7d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE \
  --output table
```

Compare com o período anterior:

```bash
aws ce get-cost-and-usage \
  --time-period Start=$(date -v-14d +%Y-%m-%d),End=$(date -v-7d +%Y-%m-%d) \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE \
  --output table
```

**O que procurar**: Serviço com custo significativamente maior que o período anterior.

---

## Passo 2 — Verificar Anomaly Detection

```bash
aws ce get-anomalies \
  --date-interval Start=$(date -v-30d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --query 'Anomalies[].{Service: RootCauses[0].Service, Region: RootCauses[0].Region, Impact: Impact.TotalImpact}' \
  --output table
```

```bash
aws ce get-anomaly-monitors \
  --query 'AnomalyMonitors[].{Name: MonitorName, Type: MonitorType}' \
  --output table
```

**O que procurar**: Anomalias com alto impacto financeiro (`TotalImpact`).

---

## Passo 3 — Identificar o recurso específico (CUR + Athena)

Se você tem o CUR configurado, use as queries do repositório (`queries/custo-por-servico.sql`).

Via AWS CLI, identifique recursos específicos:

```bash
# EC2 — instâncias rodando
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{ID: InstanceId, Type: InstanceType, Launch: LaunchTime, Name: Tags[?Key==`Name`].Value | [0]}' \
  --output table

# NAT Gateway — pode gerar custos altos de transferência
aws ec2 describe-nat-gateways \
  --filter "Name=state,Values=available" \
  --query 'NatGateways[].{ID: NatGatewayId, Subnet: SubnetId, Created: CreateTime}' \
  --output table

# RDS — instâncias ativas
aws rds describe-db-instances \
  --query 'DBInstances[].{ID: DBInstanceIdentifier, Class: DBInstanceClass, Engine: Engine}' \
  --output table
```

---

## Passo 4 — Ação Imediata

```bash
# Parar instância EC2
aws ec2 stop-instances --instance-ids <instance-id>

# Deletar NAT Gateway não necessário
aws ec2 delete-nat-gateway --nat-gateway-id <nat-gw-id>

# Parar instância RDS
aws rds stop-db-instance --db-instance-identifier <db-name>

# Liberar Elastic IP não associado
aws ec2 describe-addresses \
  --query 'Addresses[?AssociationId==null].{IP: PublicIp, AllocID: AllocationId}' \
  --output table
aws ec2 release-address --allocation-id <alloc-id>
```

> ⚠️ **Cuidado**: Antes de deletar qualquer recurso, confirme que não está em uso por outro time.

---

## Passo 5 — Prevenção (Budget + SCP)

### Criar Budget com alerta:

```bash
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget '{
    "BudgetName": "Alerta-Custo-Mensal",
    "BudgetLimit": {"Amount": "100", "Unit": "USD"},
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }' \
  --notifications-with-subscribers '[{
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [{"SubscriptionType": "EMAIL", "Address": "seu-email@exemplo.com"}]
  }]'
```

### Aplicar SCP para bloquear recursos caros:

```bash
# Use: policies/scp-deny-expensive-resources.json
aws organizations create-policy \
  --name "DenyExpensiveResources" \
  --type SERVICE_CONTROL_POLICY \
  --content file://policies/scp-deny-expensive-resources.json \
  --description "Impede criação de recursos caros sem aprovação"
```

---

## Checklist Final

- [ ] Identifiquei o serviço causador do custo
- [ ] Identifiquei o recurso específico
- [ ] Tomei ação imediata (parar/deletar/redimensionar)
- [ ] Configurei alerta de budget
- [ ] Documentei o incidente no [relatório mensal](../templates/relatorio-mensal-custos.md)
