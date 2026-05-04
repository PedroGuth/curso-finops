# Ferramentas FinOps 🛠️

Ferramentas prontas para análise, monitoramento e otimização de custos AWS.

## Ferramentas Disponíveis

| Ferramenta | Tipo | Descrição |
|------------|------|-----------|
| `aws-cost-optimizer.py` | Python | Analisa EC2, EBS, EIP, RDS e S3 e identifica oportunidades de economia |
| `tag-compliance-checker.sh` | Bash | Verifica compliance de tags em EC2, EBS, RDS e S3 |
| `finops-dashboard.json` | CloudWatch | Template de dashboard com 9 widgets de monitoramento de custos |
| `cost-anomaly-alerts.yaml` | CloudFormation | Configura Cost Anomaly Detection + Budget + alertas SNS/email |
| `reserved-instances-calculator.py` | Python | Calcula economia com RIs e Savings Plans (modo real e simulação) |

## Uso Rápido

```bash
# Analisar custos (requer AWS CLI + boto3 + tabulate)
pip install boto3 tabulate
python tools/aws-cost-optimizer.py --region us-east-1

# Verificar compliance de tags
chmod +x tools/tag-compliance-checker.sh
./tools/tag-compliance-checker.sh --region us-east-1 --format table

# Simular economia com RIs (sem precisar de conta AWS)
python tools/reserved-instances-calculator.py --simulate t3.large:5 m5.xlarge:2

# Deploy do dashboard CloudWatch
aws cloudwatch put-dashboard \
  --dashboard-name FinOps \
  --dashboard-body file://tools/finops-dashboard.json

# Deploy dos alertas de anomalia
aws cloudformation deploy \
  --template-file tools/cost-anomaly-alerts.yaml \
  --stack-name finops-cost-alerts \
  --parameter-overrides EmailNotification=seu@email.com ThresholdAmount=10
```
