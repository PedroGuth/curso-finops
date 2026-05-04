# 🆕 Runbook: Configurando FinOps em uma Nova Conta AWS

**Situação**: Acabei de criar (ou recebi acesso a) uma nova conta AWS e preciso configurar FinOps do zero.

**Tempo estimado**: 45–60 minutos

---

## Passo 1 — Ativar Cost Explorer

O Cost Explorer precisa ser ativado manualmente (leva até 24h para popular dados):

```bash
aws ce get-cost-and-usage \
  --time-period Start=$(date -v-7d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity DAILY \
  --metrics "UnblendedCost"
```

> Se retornar erro, ative pelo console: **Billing → Cost Explorer → Enable**.

Ative também o acesso de IAM ao billing:

```bash
# Isso precisa ser feito pelo root account no console:
# Account Settings → IAM User and Role Access to Billing Information → Activate
```

---

## Passo 2 — Configurar Budget + Alertas

```bash
# Criar budget mensal com alerta em 50%, 80% e 100%
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws budgets create-budget \
  --account-id $ACCOUNT_ID \
  --budget '{
    "BudgetName": "Budget-Mensal-Total",
    "BudgetLimit": {"Amount": "100", "Unit": "USD"},
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }' \
  --notifications-with-subscribers '[
    {"Notification": {"NotificationType": "ACTUAL", "ComparisonOperator": "GREATER_THAN", "Threshold": 50, "ThresholdType": "PERCENTAGE"}, "Subscribers": [{"SubscriptionType": "EMAIL", "Address": "seu-email@exemplo.com"}]},
    {"Notification": {"NotificationType": "ACTUAL", "ComparisonOperator": "GREATER_THAN", "Threshold": 80, "ThresholdType": "PERCENTAGE"}, "Subscribers": [{"SubscriptionType": "EMAIL", "Address": "seu-email@exemplo.com"}]},
    {"Notification": {"NotificationType": "ACTUAL", "ComparisonOperator": "GREATER_THAN", "Threshold": 100, "ThresholdType": "PERCENTAGE"}, "Subscribers": [{"SubscriptionType": "EMAIL", "Address": "seu-email@exemplo.com"}]}
  ]'
```

Ou via Terraform (recomendado):

```bash
cd terraform/budget-alerts
terraform init
terraform apply -var="monthly_budget=100" -var="alert_email=seu-email@exemplo.com"
```

> 📁 Referência: `terraform/budget-alerts/` e `tools/cost-anomaly-alerts.yaml`

---

## Passo 3 — Ativar Tags de Alocação de Custos

```bash
# Ativar tags como "cost allocation tags" (precisa de acesso billing)
aws ce update-cost-allocation-tags-status \
  --cost-allocation-tags-status '[
    {"TagKey": "Environment", "Status": "Active"},
    {"TagKey": "Project", "Status": "Active"},
    {"TagKey": "Owner", "Status": "Active"},
    {"TagKey": "CostCenter", "Status": "Active"},
    {"TagKey": "Department", "Status": "Active"}
  ]'
```

> 💡 Tags de alocação levam até 24h para aparecer no Cost Explorer.

Defina a política de tags obrigatórias:

```bash
# Aplicar policy que exige tags ao criar EC2
aws iam create-policy \
  --policy-name RequireTagsEC2 \
  --policy-document file://policies/require-tags-ec2.json
```

> 📁 Referência: `policies/require-tags-ec2.json` e `labs/lab-01-config-tags/`

---

## Passo 4 — Deploy do Dashboard de Custos

```bash
# Criar dashboard CloudWatch com widgets de custo
aws cloudwatch put-dashboard \
  --dashboard-name "FinOps-Dashboard" \
  --dashboard-body file://tools/finops-dashboard.json
```

Verifique o dashboard:

```bash
aws cloudwatch get-dashboard --dashboard-name "FinOps-Dashboard" \
  --query 'DashboardName' --output text
```

> 📁 Referência: `tools/finops-dashboard.json`

---

## Passo 5 — Configurar Cost Anomaly Detection

```bash
# Criar monitor de anomalias por serviço
aws ce create-anomaly-monitor \
  --anomaly-monitor '{
    "MonitorName": "Monitor-Todos-Servicos",
    "MonitorType": "DIMENSIONAL",
    "MonitorDimension": "SERVICE"
  }'
```

```bash
# Criar subscription para receber alertas
MONITOR_ARN=$(aws ce get-anomaly-monitors --query 'AnomalyMonitors[0].MonitorArn' --output text)

aws ce create-anomaly-subscription \
  --anomaly-subscription "{
    \"SubscriptionName\": \"Alerta-Anomalias\",
    \"MonitorArnList\": [\"$MONITOR_ARN\"],
    \"Subscribers\": [{\"Type\": \"EMAIL\", \"Address\": \"seu-email@exemplo.com\"}],
    \"Frequency\": \"DAILY\",
    \"ThresholdExpression\": {\"Dimensions\": {\"Key\": \"ANOMALY_TOTAL_IMPACT_ABSOLUTE\", \"Values\": [\"10\"], \"MatchOptions\": [\"GREATER_THAN_OR_EQUAL\"]}}
  }"
```

Ou via CloudFormation:

```bash
aws cloudformation deploy \
  --template-file tools/cost-anomaly-alerts.yaml \
  --stack-name cost-anomaly-alerts \
  --parameter-overrides AlertEmail=seu-email@exemplo.com
```

> 📁 Referência: `tools/cost-anomaly-alerts.yaml`

---

## Passo 6 — Aplicar SCPs (se usar Organizations)

```bash
# Bloquear regiões não autorizadas
aws organizations create-policy \
  --name "DenyUnauthorizedRegions" \
  --type SERVICE_CONTROL_POLICY \
  --content file://policies/scp-deny-regions.json \
  --description "Bloqueia uso de regiões não aprovadas"

# Bloquear recursos caros
aws organizations create-policy \
  --name "DenyExpensiveResources" \
  --type SERVICE_CONTROL_POLICY \
  --content file://policies/scp-deny-expensive-resources.json \
  --description "Impede criação de instâncias muito caras"
```

Anexar à OU desejada:

```bash
POLICY_ID=$(aws organizations list-policies --filter SERVICE_CONTROL_POLICY \
  --query 'Policies[?Name==`DenyExpensiveResources`].Id' --output text)

aws organizations attach-policy \
  --policy-id $POLICY_ID \
  --target-id <ou-id>
```

> 📁 Referência: `policies/scp-deny-regions.json` e `policies/scp-deny-expensive-resources.json`

---

## Passo 7 — Instance Scheduler (ambientes não-produção)

```bash
cd terraform/instance-scheduler
terraform init
terraform apply \
  -var="schedule_start=08:00" \
  -var="schedule_stop=20:00" \
  -var="timezone=America/Sao_Paulo" \
  -var="tag_key=Schedule" \
  -var="tag_value=office-hours"
```

Depois, adicione a tag `Schedule=office-hours` nas instâncias de dev/staging:

```bash
aws ec2 create-tags \
  --resources <instance-id> \
  --tags Key=Schedule,Value=office-hours
```

> 📁 Referência: `terraform/instance-scheduler/` e `labs/lab-06-instance-scheduler/`

---

## Checklist Final

- [ ] Cost Explorer ativado
- [ ] Budget configurado com alertas em 50%, 80% e 100%
- [ ] Tags de alocação ativadas (Environment, Project, Owner, CostCenter)
- [ ] Dashboard de custos implantado
- [ ] Anomaly Detection configurado com alertas por email
- [ ] SCPs aplicadas (regiões e recursos caros)
- [ ] Instance Scheduler ativo para ambientes não-produção
- [ ] Documentei a configuração no [plano de otimização](../templates/plano-otimizacao-custos.md)
