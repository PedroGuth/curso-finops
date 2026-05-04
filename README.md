# FinOps na AWS – Economizando e Gerenciando Custos na Nuvem ☁️💰

[![Udemy](https://img.shields.io/badge/Udemy-Acessar%20Curso-purple?style=for-the-badge&logo=udemy)](https://www.udemy.com/course/finops-na-aws-economizando-e-gerenciando-custos-na-nuvem/)
[![AWS](https://img.shields.io/badge/AWS-FinOps-FF9900?style=for-the-badge&logo=amazonwebservices)](https://aws.amazon.com/aws-cost-management/)
[![License: MIT](https://img.shields.io/badge/Licença-MIT-green?style=for-the-badge)](LICENSE)
[![Labs](https://img.shields.io/badge/Labs-6%20práticos-blue?style=for-the-badge)](#laboratórios-práticos)
[![Cheat Sheet](https://img.shields.io/badge/📋-Cheat%20Sheet-red?style=for-the-badge)](CHEATSHEET.md)
[![FAQ](https://img.shields.io/badge/❓-FAQ-orange?style=for-the-badge)](FAQ.md)
[![Certificações](https://img.shields.io/badge/🎓-Certificações-teal?style=for-the-badge)](CERTIFICACOES.md)

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

### 🛠️ [Ferramentas FinOps](tools/)

| Ferramenta | Tipo | Descrição |
|------------|------|-----------|
| `aws-cost-optimizer.py` | Python | Analisa EC2, EBS, EIP, RDS, S3 e identifica economia |
| `tag-compliance-checker.sh` | Bash | Verifica compliance de tags em todos os recursos |
| `finops-dashboard.json` | CloudWatch | Dashboard com 9 widgets de monitoramento de custos |
| `cost-anomaly-alerts.yaml` | CloudFormation | Cost Anomaly Detection + Budget + alertas |
| `reserved-instances-calculator.py` | Python | Calculadora de economia com RIs e Savings Plans |

### ✅ [Checklists](checklists/)

| Arquivo | Descrição |
|---------|-----------|
| `aws-well-architected-checklist.md` | 84 itens do pilar de custos do Well-Architected Framework |

### 📝 [Templates de Relatórios](templates/)

| Template | Para quem | Frequência |
|----------|-----------|------------|
| `relatorio-mensal-custos.md` | Equipe técnica + gestão | Mensal |
| `relatorio-executivo-finops.md` | C-Level / Diretoria | Trimestral |
| `plano-otimizacao-custos.md` | Equipe FinOps + Engineering | Por projeto |

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
| `top-accounts-custo.sql` | Top contas por custo (Organizations) |
| `ec2-custo-por-tipo.sql` | EC2 por tipo de instância e modelo de preço |
| `custo-por-regiao.sql` | Custo total por região AWS |

### 🏗️ [Terraform](terraform/)

| Módulo | Descrição |
|--------|-----------|
| `budget-alerts/` | Budget com alertas + Cost Anomaly Detection |
| `s3-lifecycle/` | S3 com lifecycle, versionamento e encryption |
| `instance-scheduler/` | Lambda + EventBridge para ligar/desligar EC2 |
| `vpc-endpoints/` | VPC Endpoints Gateway para S3 e DynamoDB |

## Pré-requisitos

Saber o que é um EC2, S3 e RDS já serve :) Bastam conhecimentos práticos na nuvem que a gente chega no fim juntos.

## Estrutura do Repositório

```
.
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CHEATSHEET.md                    # 📋 Referência rápida de FinOps
├── FAQ.md                           # ❓ Dúvidas frequentes dos alunos
├── GLOSSARIO.md                     # 📖 Glossário de termos FinOps/AWS
├── DECISOES.md                      # 🔀 Diagramas de decisão de custos
├── CERTIFICACOES.md                 # 🎓 Guia de estudo para certificações
├── labs/
│   ├── lab-01-config-tags/          # Tags e AWS Config
│   ├── lab-02-auto-scaling/         # Ambientes temporários
│   ├── lab-03-cloudwatch-rightsizing/ # Redimensionamento EC2
│   ├── lab-04-cloudfront-endpoints/ # CloudFront e VPC Endpoints
│   ├── lab-05-s3-lifecycle/         # Ciclo de vida S3
│   └── lab-06-instance-scheduler/   # Instance Scheduler
├── tools/                           # 🛠️ Ferramentas FinOps (Python, Bash, JSON, YAML)
├── scripts/                         # 🔧 Automações FinOps (Bash)
├── lambda/                          # ⚡ Funções Lambda para automação
├── policies/                        # 🔒 IAM Policies e SCPs (JSON)
├── queries/                         # 📊 Queries Athena para CUR (SQL)
├── terraform/                       # 🏗️ Módulos Terraform reutilizáveis
├── checklists/                      # ✅ Well-Architected Checklist
└── templates/                       # 📝 Templates de relatórios FinOps
```

## Referências

- [AWS Well-Architected Framework – Pilar de Otimização de Custos](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)
- [Well-Architected Tool](https://aws.amazon.com/well-architected-tool/)
- [Calculadora de Preços da AWS](https://calculator.aws/)
- [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/)
