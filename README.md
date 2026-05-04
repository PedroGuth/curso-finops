# FinOps na AWS – Economizando e Gerenciando Custos na Nuvem ☁️💰

[![Udemy](https://img.shields.io/badge/Udemy-Acessar%20Curso-purple?style=for-the-badge&logo=udemy)](https://www.udemy.com/course/finops-na-aws-economizando-e-gerenciando-custos-na-nuvem/)

Repositório de apoio ao curso **FinOps na AWS** disponível na Udemy.

Você quer ser o mestre do orçamento e FinOps na AWS? Então vamos juntos.

Vamos descomplicar todo o papo de FinOps, mostrando como gerenciar, otimizar e prever seus custos enquanto roda suas workloads na nuvem. Você vai aprender, de maneira prática, a implementar as melhores estratégias de arquitetura e descobrir hacks para economizar dinheiro de verdade.

Não tem enrolação: o objetivo é transformar números e faturas em oportunidades de economia. Vamos usar o console da AWS, código, linha de comando e fazer tudo que seja necessário para parar de gastar dinheiro!

## O que Você Vai Aprender

- 🧠 FinOps pode transformar sua relação com a AWS — pare de gastar à toa e comece a investir com inteligência
- 📄 Navegue pela fatura e descubra o que cada linha realmente significa — sem susto no fim do mês
- 🤖 Automações simples que resolvem problemas comuns, como substituir discos gp2 por gp3, sem ficar de babá das contas
- 🤝 Entenda como unir DevOps, Financeiro e Gestão para deixar todos no mesmo barco
- 🎓 Prepare-se para suas certificações AWS (Solutions Architect Associate e Cloud Practitioner)

## Conteúdo do Curso

10 seções • 57 aulas • ~6 horas de vídeo

| Seção | Tema | Destaques |
|-------|------|-----------|
| 1 | Introdução | Visão geral, teoria essencial, Well-Architected Framework e Tool |
| 2 | Tags e Marcação | Dicionário de tags, práticas recomendadas, governança com Config e IAM |
| 3 | Preços e Custos | Modelos de custo, Free Tier, Spot, Savings Plans, Calculadora AWS |
| 4 | Faturamento e Monitoramento | Billing, Cost Explorer, Budgets, Anomaly Detection, Data Export, QuickSight |
| 5 | Computação (parte 1) | EC2, Spot, Auto Scaling, redimensionamento, Compute Optimizer |
| 6 | Computação (parte 2) | Serverless (Lambda), licenciamento, containers |
| 7 | Redes | Transferência de dados, VPC, VPN, Transit Gateway, CloudFront, Route 53 |
| 8 | Armazenamento | EBS (gp2 vs gp3), snapshots, S3 (classes e lifecycle), EFS |
| 9 | Bancos de Dados | RDS, Aurora, DynamoDB, ElastiCache, Redshift |
| 10 | Governança | AWS Organizations, SCPs, Control Tower, Landing Zone, multi-account |

## Laboratórios Práticos

| # | Laboratório | Serviços |
|---|-------------|----------|
| 1 | Controlar recursos com marcação e AWS Config | AWS Config, IAM |
| 2 | Ambientes temporários com EC2 Auto Scaling | Auto Scaling, AWS Backup, Lambda, EventBridge |
| 3 | Redimensionamento EC2 com métricas do CloudWatch | CloudWatch, Resource Groups |
| 4 | Reduzir custos de rede com CloudFront e endpoints | CloudFront, VPC Endpoints, Auto Scaling |
| 5 | Ciclo de vida do Amazon S3 | S3, Lambda, Aurora Serverless |
| 6 | AWS Instance Scheduler | Instance Scheduler, CloudFormation, DynamoDB |

## Ferramentas AWS Cobertas

- **Custos**: Cost Explorer, Budgets, Cost Anomaly Detection, Data Export (CUR), Billing Conductor
- **Otimização**: Compute Optimizer, Trusted Advisor, Instance Scheduler
- **Governança**: Organizations, Control Tower, Config, IAM
- **Monitoramento**: CloudWatch, EventBridge
- **Visualização**: QuickSight, Athena, Redshift

## Recursos do Repositório

### 🔧 [Scripts de Automação](scripts/)

| Script | O que faz | Economia |
|--------|-----------|----------|
| `migrate-gp2-to-gp3.sh` | Migra volumes EBS de gp2 para gp3 | ~20% no EBS |
| `cleanup-unused-eips.sh` | Libera Elastic IPs não associados | ~$3.65/mês por EIP |
| `cleanup-orphan-snapshots.sh` | Remove snapshots de volumes deletados | $0.05/GB/mês |

### 🔒 [IAM Policies e SCPs](policies/)

| Arquivo | Descrição |
|---------|-----------|
| `require-tags-ec2.json` | Exige tags ao criar instâncias EC2 |
| `restrict-instance-types.json` | Permite apenas tipos de instância aprovados |
| `abac-department-access.json` | Controle de acesso baseado em tags (ABAC) |
| `scp-deny-regions.json` | Bloqueia regiões não autorizadas |
| `scp-deny-expensive-resources.json` | Impede criação de recursos caros |

### 📊 [Queries Athena para CUR](queries/)

| Query | Descrição |
|-------|-----------|
| `custo-por-servico.sql` | Top serviços por custo no mês |
| `custo-diario.sql` | Custo diário dos últimos 30 dias |
| `custo-por-tag.sql` | Custo agrupado por tag Environment |
| `custo-transferencia-dados.sql` | Custos de transferência de dados |
| `recursos-sem-tags.sql` | Recursos sem tags (desperdício) |
| `cobertura-savings-plans.sql` | Cobertura de SPs e RIs |

## Pré-requisitos

Saber o que é um EC2, S3 e RDS já serve :) Bastam conhecimentos práticos na nuvem que a gente chega no fim juntos.

## Estrutura do Repositório

```
.
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── labs/
│   ├── lab-01-config-tags/          # Tags e AWS Config
│   ├── lab-02-auto-scaling/         # Ambientes temporários
│   ├── lab-03-cloudwatch-rightsizing/ # Redimensionamento EC2
│   ├── lab-04-cloudfront-endpoints/ # CloudFront e VPC Endpoints
│   ├── lab-05-s3-lifecycle/         # Ciclo de vida S3
│   └── lab-06-instance-scheduler/   # Instance Scheduler
├── scripts/                         # Automações FinOps (bash)
├── policies/                        # IAM Policies e SCPs (JSON)
└── queries/                         # Queries Athena para CUR (SQL)
```

## Referências

- [AWS Well-Architected Framework – Pilar de Otimização de Custos](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)
- [Well-Architected Tool](https://aws.amazon.com/well-architected-tool/)
- [Calculadora de Preços da AWS](https://calculator.aws/)
- [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/)
