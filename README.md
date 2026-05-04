# FinOps na AWS – Curso Prático

Repositório de apoio ao curso **FinOps na AWS** disponível na Udemy. O curso ensina a gerenciar, otimizar e prever custos de cargas de trabalho na AWS, cobrindo desde fundamentos de Cloud Financial Management até governança de custos em ambientes multi-conta.

## Objetivos do Curso

- Explicar os custos dos principais serviços da AWS
- Aplicar estratégias e práticas recomendadas para reduzir custos
- Monitorar custos e uso de serviços com ferramentas nativas
- Estimar custos de cargas de trabalho atuais e futuras
- Implementar governança com marcação de recursos, estrutura de contas e controle de acesso

## Conteúdo Programático

| Módulo | Tema | Laboratório |
|--------|------|-------------|
| 0 | Visão geral do curso | – |
| 1 | Introdução ao Gerenciamento Financeiro da Nuvem | – |
| 2 | Marcação de recursos (Tags) | Lab 1: AWS Config e IAM |
| 3 | Preços e custos | – |
| 4 | Faturamento, relatórios e monitoramento | Lab 2: Ambientes temporários com EC2 Auto Scaling |
| 5 (parte 1) | Arquitetura voltada ao custo: Computação – Redimensionamento, CloudWatch, Spot | – |
| 5 (parte 2) | Arquitetura voltada ao custo: Computação – Auto Scaling, Automação, Serverless | Lab 3: Redimensionamento EC2 com métricas do CloudWatch |
| 6 | Arquitetura voltada ao custo: Redes | Lab 4: CloudFront e endpoints de VPC |
| 7 | Arquitetura voltada ao custo: Armazenamento | Lab 5: Ciclo de vida do Amazon S3 |
| 8 | Arquitetura voltada ao custo: Bancos de dados | – |
| 9 | Governança de custos | Lab 6: AWS Instance Scheduler |
| 10 | Resumo do curso | – |

## Principais Tópicos Abordados

### Gerenciamento Financeiro da Nuvem (CFM)
- **Ver** – Medição e prestação de contas
- **Economizar** – Otimização de custos
- **Planejar** – Planejamento e previsão
- **Executar** – Operações financeiras da nuvem

### Ferramentas AWS Cobertas
- AWS Cost Explorer, AWS Budgets, AWS CUR
- AWS Trusted Advisor, AWS Compute Optimizer
- AWS Config, AWS Organizations, AWS Control Tower
- Amazon CloudWatch, AWS Instance Scheduler
- Calculadora de Preços da AWS

### Modelos de Preço
- Sob demanda, Instâncias Spot (até 90% de desconto), Instâncias Reservadas
- Compute Savings Plans (até 66%) e EC2 Instance Savings Plans (até 72%)
- Nível gratuito da AWS (sempre gratuito, 12 meses, versões de teste)

### Arquitetura Voltada ao Custo
- **Computação**: redimensionamento EC2, Auto Scaling, instâncias spot, serverless (Lambda, Fargate)
- **Redes**: transferência de dados entre AZs/Regiões, VPC endpoints, CloudFront, Direct Connect
- **Armazenamento**: classes do S3, tipos de volume EBS, EFS, ciclo de vida
- **Bancos de dados**: RDS, Aurora Serverless, DynamoDB, ElastiCache, Redshift

## Laboratórios

| # | Laboratório | Serviços Principais |
|---|-------------|---------------------|
| 1 | Controlar consumo de recursos com marcação e AWS Config | AWS Config, IAM |
| 2 | Implantar ambientes temporários com EC2 Auto Scaling | Auto Scaling, AWS Backup, Lambda, EventBridge |
| 3 | Redimensionamento EC2 usando métricas do CloudWatch | CloudWatch, Resource Groups |
| 4 | Reduzir custos de transferência de dados com CloudFront e endpoints | CloudFront, VPC Endpoints, Auto Scaling |
| 5 | Reduzir custos de armazenamento com ciclo de vida do S3 | S3, Lambda, Aurora Serverless |
| 6 | Reduzir custos de computação com AWS Instance Scheduler | Instance Scheduler, CloudFormation, DynamoDB |

## Pré-requisitos

- AWS Solutions Architect – Associate (recomendado)
- Experiência prática com serviços AWS: Computação, Armazenamento, Rede e Bancos de dados

## Estrutura do Repositório

```
.
├── README.md
├── labs/           # Guias e recursos dos laboratórios
└── .gitignore
```

## Referências

- [AWS Well-Architected Framework – Pilar de Otimização de Custos](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)
- [Calculadora de Preços da AWS](https://calculator.aws/)
- [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/)
