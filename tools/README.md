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

## Exemplo de Output

### aws-cost-optimizer.py

```text
🔍 Analisando recursos na região us-east-1...

╔══════════════════════════════════════════════════════════════════════════════════════════════╗
║                           AWS Cost Optimizer - Findings                                     ║
╠════╦══════════════════╦═══════════════════════════════╦════════════╦═════════════════════════╣
║ #  ║ Tipo             ║ Recurso                       ║ Economia   ║ Recomendação            ║
╠════╬══════════════════╬═══════════════════════════════╬════════════╬═════════════════════════╣
║ 1  ║ EC2 Ociosa       ║ i-0a1b2c3d (app-staging)      ║ $52.56/mês ║ CPU média < 2% (30d)   ║
║ 2  ║ EBS gp2          ║ vol-0f9e8d7c (data-vol)       ║ $10.00/mês ║ Migrar para gp3        ║
║ 3  ║ EIP não usado    ║ 54.233.100.42                 ║ $3.65/mês  ║ Liberar ou associar    ║
║ 4  ║ Snapshot órfão   ║ snap-0ab12cd (150 GB)         ║ $7.50/mês  ║ Volume não existe mais ║
║ 5  ║ S3 sem lifecycle ║ logs-prod-2024 (2.3 TB)       ║ $38.00/mês ║ Adicionar lifecycle    ║
╚════╩══════════════════╩═══════════════════════════════╩════════════╩═════════════════════════╝

📊 Resumo:
   Findings: 5
   Economia mensal estimada: $111.71/mês
   Economia anual projetada: $1,340.52/ano

💡 Execute com --fix para aplicar correções automáticas (onde suportado).
```

### reserved-instances-calculator.py --simulate

```text
🧮 Simulação de economia: t3.large × 3 instâncias (us-east-1)

╔═══════════════════════════════════════════════════════════════════════════════╗
║              Comparação de Modelos de Preço - t3.large (Linux)               ║
╠═══════════════════╦════════════╦════════════╦════════════╦════════════════════╣
║ Modelo            ║ $/hora     ║ Mensal (3) ║ Anual (3)  ║ Economia vs OD     ║
╠═══════════════════╬════════════╬════════════╬════════════╬════════════════════╣
║ On-Demand         ║ $0.0832    ║ $179.71    ║ $2,186.50  ║ —                  ║
║ Savings Plan 1yr  ║ $0.0540    ║ $116.64    ║ $1,419.12  ║ 35% ($767.38)      ║
║ Savings Plan 3yr  ║ $0.0350    ║ $75.60     ║ $919.80    ║ 58% ($1,266.70)    ║
║ RI Standard 1yr   ║ $0.0510    ║ $110.16    ║ $1,340.28  ║ 39% ($846.22)      ║
║ RI Standard 3yr   ║ $0.0320    ║ $69.12     ║ $840.96    ║ 62% ($1,345.54)    ║
╚═══════════════════╩════════════╩════════════╩════════════╩════════════════════╝

💡 Recomendação: Para uso contínuo (>70% utilização), Savings Plan 3yr oferece
   o melhor equilíbrio entre economia e flexibilidade.
```

### tag-compliance-checker.sh

```text
🏷️  Verificando compliance de tags na região us-east-1...
    Tags obrigatórias: Environment, Team, CostCenter

Verificando EC2... ✓ (6 instâncias)
Verificando EBS... ✓ (8 volumes)
Verificando RDS... ✓ (1 instância)

╔══════════════════════════════════════════════════════════════════════════╗
║                    Relatório de Compliance de Tags                      ║
╠══════════════════════════════════════════════════════════════════════════╣
║ Total de recursos verificados:  15                                     ║
║ Recursos conformes:             12  ✅                                  ║
║ Recursos NÃO conformes:         3  ❌                                  ║
║ Taxa de compliance:             80%                                     ║
╠══════════════════════════════════════════════════════════════════════════╣
║                        Recursos Não Conformes                          ║
╠════════════════════════════╦══════════╦═════════════════════════════════╣
║ Recurso                    ║ Tipo     ║ Tags faltando                  ║
╠════════════════════════════╬══════════╬═════════════════════════════════╣
║ i-0a1b2c3d (dev-test)      ║ EC2      ║ CostCenter                     ║
║ vol-0f9e8d7c               ║ EBS      ║ Environment, Team              ║
║ vol-0ab12cd3               ║ EBS      ║ Team                           ║
╚════════════════════════════╩══════════╩═════════════════════════════════╝

💡 Use AWS Config com a regra 'required-tags' para enforcement automático.
```
