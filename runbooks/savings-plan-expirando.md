# 💰 Runbook: Savings Plan ou RI Expirando

**Situação**: Um Savings Plan ou Reserved Instance está próximo do vencimento e preciso decidir se renovo, altero ou deixo expirar.

**Tempo estimado**: 30–60 minutos (análise + decisão)

---

## Passo 1 — Verificar Expiração

```bash
# Listar Savings Plans e suas datas de expiração
aws savingsplans describe-savings-plans \
  --query 'SavingsPlans[].{ID: SavingsPlanId, Type: SavingsPlanType, Commitment: Commitment, End: End, State: State}' \
  --output table

# Listar Reserved Instances e expiração
aws ec2 describe-reserved-instances \
  --filters "Name=state,Values=active" \
  --query 'ReservedInstances[].{ID: ReservedInstancesId, Type: InstanceType, Count: InstanceCount, End: End}' \
  --output table

# RDS Reserved Instances
aws rds describe-reserved-db-instances \
  --query 'ReservedDBInstances[?State==`active`].{ID: ReservedDBInstanceId, Class: DBInstanceClass, End: StartTime, Duration: Duration}' \
  --output table
```

---

## Passo 2 — Analisar Uso Atual

```bash
# Utilização do Savings Plan (últimos 30 dias)
aws ce get-savings-plans-utilization \
  --time-period Start=$(date -v-30d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --query 'Total.{Utilization: UtilizationPercentage, Used: UsedCommitment, Total: TotalCommitment}' \
  --output table

# Cobertura do Savings Plan
aws ce get-savings-plans-coverage \
  --time-period Start=$(date -v-30d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --output table

# Utilização de Reserved Instances
aws ce get-reservation-utilization \
  --time-period Start=$(date -v-30d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --query 'Total.{Utilization: UtilizationPercentage, PurchasedHours: PurchasedHours, UsedHours: TotalActualHours}' \
  --output table
```

**Análise**:
- Utilização > 80%: Vale renovar
- Utilização 50–80%: Considere reduzir o commitment
- Utilização < 50%: Provavelmente não vale renovar

---

## Passo 3 — Decidir: Renovar / Alterar / Não Renovar

### Obter recomendações da AWS:

```bash
# Recomendações de Savings Plans
aws ce get-savings-plans-purchase-recommendation \
  --savings-plans-type COMPUTE_SP \
  --term-in-years ONE_YEAR \
  --payment-option NO_UPFRONT \
  --lookback-period-in-days SIXTY_DAYS \
  --query 'SavingsPlansPurchaseRecommendation.SavingsPlansPurchaseRecommendationDetails[].{Commitment: HourlyCommitmentToPurchase, Savings: EstimatedMonthlySavingsAmount, ROI: EstimatedROI}' \
  --output table
```

```bash
# Recomendações de RIs
aws ce get-reservation-purchase-recommendation \
  --service "Amazon Elastic Compute Cloud - Compute" \
  --term-in-years ONE_YEAR \
  --payment-option NO_UPFRONT \
  --output table
```

### Critérios de decisão:

| Cenário | Ação |
|---------|------|
| Workload estável, utilização alta | Renovar (mesmo tipo/tamanho) |
| Workload crescendo | Renovar com commitment maior |
| Workload diminuindo | Reduzir commitment ou não renovar |
| Migrando para serverless | Não renovar |
| Mudando tipo de instância | Compute SP (flexível) |

---

## Passo 4 — Comprar Novo Savings Plan

```bash
# Simular compra (use o calculador do repo primeiro)
python3 tools/reserved-instances-calculator.py

# Comprar Savings Plan via CLI
aws savingsplans create-savings-plan \
  --savings-plan-offering-id <offering-id> \
  --commitment "0.50" \
  --purchase-time $(date -u +%Y-%m-%dT%H:%M:%SZ)
```

> ⚠️ **Importante**: A compra de Savings Plans é irreversível. Confirme os valores antes de executar.

Para obter os offering IDs disponíveis:

```bash
aws savingsplans describe-savings-plans-offering-rates \
  --savings-plan-offering-ids <offering-id> \
  --output table
```

---

## Passo 5 — Monitorar Cobertura Pós-Renovação

```bash
# Verificar cobertura após a compra (espere 24-48h)
aws ce get-savings-plans-coverage \
  --time-period Start=$(date -v-7d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity DAILY \
  --output table

# Query Athena para monitoramento contínuo
# Arquivo: queries/cobertura-savings-plans.sql
```

### Configurar alerta de cobertura baixa:

```bash
# Use o módulo Terraform do repo
cd terraform/budget-alerts
terraform apply -var="sp_coverage_threshold=80"
```

---

## Checklist Final

- [ ] Verifiquei data de expiração dos SPs/RIs
- [ ] Analisei utilização dos últimos 30 dias
- [ ] Consultei recomendações da AWS
- [ ] Tomei decisão (renovar/alterar/não renovar)
- [ ] Executei a compra (se aplicável)
- [ ] Configurei monitoramento de cobertura
- [ ] Documentei a decisão no [relatório executivo](../templates/relatorio-executivo-finops.md)
