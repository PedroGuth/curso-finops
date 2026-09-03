# 🎓 Guia de Certificações AWS para FinOps

[![Cloud Practitioner](https://img.shields.io/badge/CLF--C02-Cloud%20Practitioner-232F3E?style=for-the-badge&logo=amazonwebservices)](https://aws.amazon.com/certification/certified-cloud-practitioner/)
[![Solutions Architect](https://img.shields.io/badge/SAA--C03-Solutions%20Architect-FF9900?style=for-the-badge&logo=amazonwebservices)](https://aws.amazon.com/certification/certified-solutions-architect-associate/)
[![FinOps](https://img.shields.io/badge/FOCP-FinOps%20Practitioner-00B388?style=for-the-badge)](https://www.finops.org/certification/)

Guia completo de preparação para certificações AWS e FinOps, mapeado diretamente com o conteúdo do curso **FinOps na AWS**.

> 💡 **Dica**: Este curso cobre conteúdo relevante para **três certificações**. Use-o como base e complemente com os recursos indicados abaixo.

---

## 📋 Índice

- [AWS Certified Cloud Practitioner (CLF-C02)](#aws-certified-cloud-practitioner-clf-c02)
- [AWS Certified Solutions Architect – Associate (SAA-C03)](#aws-certified-solutions-architect--associate-saa-c03)
- [FinOps Certified Practitioner (FOCP)](#finops-certified-practitioner-focp)
- [Plano de Estudo Sugerido](#plano-de-estudo-sugerido)
- [Mapeamento: Módulos do Curso → Domínios dos Exames](#mapeamento-módulos-do-curso--domínios-dos-exames)

---

## AWS Certified Cloud Practitioner (CLF-C02)

### Visão Geral do Exame

| Item | Detalhe |
|------|---------|
| **Código** | CLF-C02 |
| **Formato** | 65 perguntas (múltipla escolha e múltipla resposta) |
| **Duração** | 90 minutos |
| **Nota mínima** | 700 / 1000 |
| **Custo** | USD 100 |
| **Idioma** | Disponível em português (Brasil) |
| **Validade** | 3 anos |
| **Pré-requisito** | Nenhum — é a porta de entrada! |

> 🚀 **Essa é a certificação ideal para começar.** Se você está fazendo o curso FinOps na AWS, já tem uma base sólida para o domínio de Billing & Pricing.

### Domínios e Pesos

| Domínio | Peso | O que cobra |
|---------|------|-------------|
| 1 – Cloud Concepts | 24% | Proposta de valor da nuvem, Well-Architected Framework, estratégias de migração |
| 2 – Security and Compliance | 30% | Modelo de responsabilidade compartilhada, IAM, compliance, criptografia |
| 3 – Cloud Technology and Services | 34% | Serviços de computação, rede, armazenamento, banco de dados |
| 4 – Billing, Pricing and Support | 12% | Modelos de preço, ferramentas de billing, planos de suporte |

### Tópicos do Curso que Caem no Exame

| Seção do Curso | Domínio CLF-C02 | Tópicos Relevantes |
|----------------|-----------------|---------------------|
| 1 – Introdução | Domínio 1 (Cloud Concepts) | Well-Architected Framework, pilar de custos, proposta de valor da nuvem |
| 2 – Tags e Marcação | Domínio 2 (Security) | IAM policies, governança, AWS Config |
| 3 – Preços e Custos | Domínio 4 (Billing) | Free Tier, On-Demand vs Spot vs Reserved, Savings Plans, Calculadora AWS |
| 4 – Faturamento e Monitoramento | Domínio 4 (Billing) | Cost Explorer, Budgets, Billing Console, alertas de custo |
| 5 – Computação (parte 1) | Domínio 3 (Technology) | EC2, Auto Scaling, Compute Optimizer |
| 6 – Computação (parte 2) | Domínio 3 (Technology) | Lambda, containers (ECS/EKS) |
| 7 – Redes | Domínio 3 (Technology) | VPC, CloudFront, Route 53, transferência de dados |
| 8 – Armazenamento | Domínio 3 (Technology) | S3 (classes de armazenamento), EBS, EFS |
| 9 – Bancos de Dados | Domínio 3 (Technology) | RDS, Aurora, DynamoDB, ElastiCache |
| 10 – Governança | Domínio 2 (Security) | Organizations, SCPs, Control Tower, multi-account |

### 10 Dicas de Estudo para o CLF-C02

1. **Domine o modelo de responsabilidade compartilhada** — cai em quase toda prova. Saiba o que é responsabilidade da AWS vs. do cliente.
2. **Decore os modelos de preço do EC2** — On-Demand, Reserved, Spot, Savings Plans e Dedicated Hosts. O curso cobre isso na Seção 3.
3. **Entenda o Free Tier** — saiba quais serviços têm 12 meses grátis, quais são always free e quais são trial.
4. **Conheça as ferramentas de billing** — Cost Explorer, Budgets, Billing Console, Cost Anomaly Detection. Tudo isso está na Seção 4.
5. **Saiba diferenciar os planos de suporte** — Basic, Developer, Business, Enterprise On-Ramp e Enterprise. Foque nos SLAs de resposta.
6. **Estude o Well-Architected Framework** — conheça os 6 pilares, especialmente o de otimização de custos (Seção 1 do curso).
7. **Não decore, entenda** — a prova testa conceitos, não comandos CLI. Foque no "por que" e não no "como".
8. **Faça simulados** — pratique com pelo menos 3 simulados completos antes da prova. Mire em 80%+ nos simulados.
9. **Revise os serviços core** — EC2, S3, RDS, VPC, IAM, Lambda, CloudFront. Saiba o que cada um faz em uma frase.
10. **Use o Cheat Sheet do repositório** — o arquivo [CHEATSHEET.md](CHEATSHEET.md) é uma revisão rápida perfeita para a véspera da prova.

### Recursos Gratuitos para Estudo

| Recurso | Link |
|---------|------|
| AWS Cloud Practitioner Essentials (curso oficial gratuito) | [AWS Skill Builder](https://explore.skillbuilder.aws/learn/course/external/view/elearning/134/aws-cloud-practitioner-essentials) |
| AWS Cloud Quest: Cloud Practitioner (gamificado) | [AWS Skill Builder](https://explore.skillbuilder.aws/learn/course/external/view/elearning/11458/aws-cloud-quest-cloud-practitioner) |
| Exam Prep Official Question Set (20 perguntas oficiais) | [AWS Skill Builder](https://explore.skillbuilder.aws/learn/course/external/view/elearning/14050/aws-certified-cloud-practitioner-official-practice-question-set) |
| AWS Whitepapers – Overview of Amazon Web Services | [AWS Docs](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/introduction.html) |
| AWS Well-Architected Framework | [AWS Docs](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html) |
| Guia do Exame CLF-C02 (PDF oficial) | [AWS Certification](https://d1.awsstatic.com/training-and-certification/docs-cloud-practitioner/AWS-Certified-Cloud-Practitioner_Exam-Guide.pdf) |

---

## AWS Certified Solutions Architect – Associate (SAA-C03)

### Visão Geral do Exame

| Item | Detalhe |
|------|---------|
| **Código** | SAA-C03 |
| **Formato** | 65 perguntas (múltipla escolha e múltipla resposta) |
| **Duração** | 130 minutos |
| **Nota mínima** | 720 / 1000 |
| **Custo** | USD 150 |
| **Idioma** | Disponível em português (Brasil) |
| **Validade** | 3 anos |
| **Pré-requisito** | Nenhum oficial, mas recomenda-se 1 ano de experiência prática |

> 🎯 **Essa é a certificação mais popular da AWS.** O Domínio 4 (Cost-Optimized Architectures) vale 20% da prova — e o nosso curso cobre esse domínio inteiro.

### Domínios e Pesos

| Domínio | Peso | O que cobra |
|---------|------|-------------|
| 1 – Design Secure Architectures | 30% | IAM, criptografia, segurança de rede, compliance |
| 2 – Design Resilient Architectures | 26% | Alta disponibilidade, disaster recovery, desacoplamento |
| 3 – Design High-Performing Architectures | 24% | Seleção de serviços, escalabilidade, caching, otimização |
| 4 – Design Cost-Optimized Architectures | 20% | Estratégias de custo, storage tiers, compute pricing, rightsizing |

### Tópicos do Curso que Caem no Exame

#### Domínio 4 – Cost-Optimized Architectures (20%) — Cobertura Completa 🎯

| Tópico do Exame | Seção do Curso | Conteúdo Específico |
|------------------|----------------|---------------------|
| Modelos de preço de computação | Seção 3, 5 | On-Demand, Spot, Reserved, Savings Plans, rightsizing |
| Classes de armazenamento S3 | Seção 8 | S3 Standard, IA, One Zone-IA, Glacier, Intelligent-Tiering, lifecycle policies |
| Tipos de volume EBS | Seção 8 | gp2 vs gp3, io1/io2, st1, sc1 — quando usar cada um |
| Opções de banco de dados | Seção 9 | RDS vs Aurora vs DynamoDB, Aurora Serverless, Reserved Instances para RDS |
| Transferência de dados | Seção 7 | Custos de data transfer, VPC Endpoints, CloudFront, NAT Gateway |
| Ferramentas de otimização | Seção 4, 5 | Compute Optimizer, Trusted Advisor, Cost Explorer |
| Auto Scaling | Seção 5 | Scaling policies, scheduled scaling, target tracking |
| Serverless | Seção 6 | Lambda pricing (requests + duration), Step Functions, API Gateway |
| Governança de custos | Seção 10 | Organizations, Consolidated Billing, SCPs |

#### Outros Domínios — Cobertura Parcial

| Seção do Curso | Domínio SAA-C03 | Tópicos Relevantes |
|----------------|-----------------|---------------------|
| 2 – Tags e Marcação | Domínio 1 (Secure) | IAM policies, ABAC, AWS Config rules |
| 5 – Computação (parte 1) | Domínio 2 (Resilient) e 3 (High-Performing) | Auto Scaling, placement groups, EC2 instance types |
| 7 – Redes | Domínio 1 (Secure) e 3 (High-Performing) | VPC, subnets, security groups, CloudFront, Route 53 |
| 8 – Armazenamento | Domínio 2 (Resilient) e 3 (High-Performing) | S3 replication, EBS snapshots, EFS |
| 9 – Bancos de Dados | Domínio 2 (Resilient) | Multi-AZ, Read Replicas, backups automáticos |
| 10 – Governança | Domínio 1 (Secure) | Organizations, SCPs, Control Tower |

### 10 Dicas de Estudo para o SAA-C03

1. **Foque no Domínio 4 primeiro** — com o curso FinOps, você já tem 20% da prova coberta. Comece pelo que você já sabe e ganhe confiança.
2. **Domine S3 de ponta a ponta** — classes de armazenamento, lifecycle policies, replicação, versionamento, encryption. S3 cai em TODOS os domínios.
3. **Entenda os cenários de custo** — a prova adora perguntas do tipo "qual a opção MAIS econômica?". Pense sempre em custo-benefício.
4. **Saiba quando usar Spot vs Reserved vs Savings Plans** — workloads tolerantes a falha = Spot; previsíveis = Reserved/SP; variáveis = On-Demand.
5. **Estude VPC profundamente** — subnets públicas/privadas, NAT Gateway, VPC Endpoints, Security Groups vs NACLs. Redes são ~15% da prova.
6. **Pratique com os labs do curso** — os Labs 2 (Auto Scaling), 4 (CloudFront + Endpoints) e 5 (S3 Lifecycle) são diretamente relevantes.
7. **Conheça os padrões de disaster recovery** — Backup & Restore, Pilot Light, Warm Standby, Multi-Site. Saiba o custo e o RTO/RPO de cada um.
8. **Estude serverless além de Lambda** — API Gateway, DynamoDB, S3, SQS, SNS, Step Functions, EventBridge. Arquiteturas serverless são tendência na prova.
9. **Faça pelo menos 5 simulados completos** — a prova é mais difícil que o CLF-C02. Mire em 75%+ nos simulados antes de agendar.
10. **Leia os FAQs dos serviços principais** — EC2, S3, RDS, VPC, Lambda, ELB. Os FAQs da AWS são ouro para a prova.

### Recursos Gratuitos para Estudo

| Recurso | Link |
|---------|------|
| AWS Skill Builder – Exam Prep SAA-C03 | [AWS Skill Builder](https://explore.skillbuilder.aws/learn/course/external/view/elearning/14760/exam-prep-aws-certified-solutions-architect-associate-saa-c03) |
| Official Practice Question Set SAA-C03 (20 perguntas) | [AWS Skill Builder](https://explore.skillbuilder.aws/learn/course/external/view/elearning/13266/aws-certified-solutions-architect-associate-official-practice-question-set) |
| AWS Well-Architected Labs | [wellarchitectedlabs.com](https://www.wellarchitectedlabs.com/) |
| Guia do Exame SAA-C03 (PDF oficial) | [AWS Certification](https://d1.awsstatic.com/training-and-certification/docs-sa-assoc/AWS-Certified-Solutions-Architect-Associate_Exam-Guide.pdf) |
| AWS Architecture Center | [AWS Architecture](https://aws.amazon.com/architecture/) |
| AWS Whitepapers recomendados | [AWS Docs](https://aws.amazon.com/whitepapers/) |

> 📖 **Whitepapers essenciais para o SAA-C03:**
> - AWS Well-Architected Framework
> - Architecting for the Cloud: Best Practices
> - Overview of Amazon Web Services
> - AWS Security Best Practices

---

## FinOps Certified Practitioner (FOCP)

### Visão Geral do Exame

| Item | Detalhe |
|------|---------|
| **Código** | FOCP |
| **Organização** | FinOps Foundation (parte da Linux Foundation) |
| **Formato** | 50 perguntas (múltipla escolha) |
| **Duração** | 60 minutos |
| **Nota mínima** | Não divulgada publicamente (estimativa: ~75%) |
| **Custo** | USD 300 (inclui 1 retake) |
| **Idioma** | Inglês |
| **Validade** | 2 anos |
| **Pré-requisito** | Nenhum, mas experiência com cloud billing ajuda muito |

> 🌍 **Essa é a certificação vendor-neutral de FinOps.** Enquanto as certificações AWS focam em tecnologia, a FOCP foca em processos, cultura e framework. Juntas, elas te tornam um profissional completo.

### Domínios e Pesos

| Domínio | O que cobra |
|---------|-------------|
| FinOps Framework & Principles | Princípios do FinOps, fases (Inform, Optimize, Operate), personas, cultura de colaboração |
| Inform (Visibilidade) | Alocação de custos, tagging, showback/chargeback, relatórios, dashboards |
| Optimize (Otimização) | Rightsizing, reservas, Spot, commitment-based discounts, arquitetura eficiente |
| Operate (Operação) | Governança, políticas, automação, ciclo contínuo de otimização, KPIs |

### Como o Curso Prepara para a FOCP

O curso **FinOps na AWS** é focado em implementação prática na AWS, mas cobre os conceitos fundamentais do framework FinOps. Veja o mapeamento:

| Domínio FOCP | Seções do Curso | Cobertura |
|--------------|-----------------|-----------|
| Framework & Principles | Seção 1 (Introdução) | ✅ Well-Architected, princípios de otimização, cultura FinOps |
| Inform (Visibilidade) | Seção 2 (Tags), Seção 4 (Faturamento) | ✅ Tagging, Cost Explorer, Budgets, CUR, dashboards, relatórios |
| Optimize (Otimização) | Seções 3, 5, 6, 7, 8, 9 | ✅ Rightsizing, Spot, Savings Plans, lifecycle policies, gp2→gp3 |
| Operate (Operação) | Seção 10 (Governança), Labs | ✅ Organizations, SCPs, automações, Instance Scheduler |

#### O que o curso cobre bem para a FOCP:
- ✅ Alocação de custos e tagging (Seção 2)
- ✅ Ferramentas de visibilidade e relatórios (Seção 4)
- ✅ Estratégias de otimização de computação, rede e armazenamento (Seções 5-9)
- ✅ Automação de governança (Seção 10 + Labs)
- ✅ Colaboração entre equipes (conceito transversal no curso)

#### O que você precisa complementar:
- ⚠️ Framework FinOps em profundidade (fases, maturity model, personas detalhadas)
- ⚠️ Conceitos multi-cloud (a FOCP é vendor-neutral)
- ⚠️ Showback vs Chargeback em detalhe
- ⚠️ Unit economics e métricas de negócio (cost per customer, cost per transaction)
- ⚠️ FinOps team structure e organizational adoption

### Recursos para Estudo

| Recurso | Link |
|---------|------|
| FinOps Framework (leitura obrigatória) | [finops.org/framework](https://www.finops.org/framework/) |
| FinOps Principles | [finops.org/framework/principles](https://www.finops.org/framework/principles/) |
| FinOps Personas | [finops.org/framework/personas](https://www.finops.org/framework/personas/) |
| FinOps Certified Practitioner – Detalhes | [finops.org/certification](https://www.finops.org/certification/) |
| Livro: Cloud FinOps (O'Reilly) | [O'Reilly](https://www.oreilly.com/library/view/cloud-finops-2nd/9781492098348/) |
| FinOps Foundation YouTube | [YouTube](https://www.youtube.com/@FinOpsFoundation) |

---

## Plano de Estudo Sugerido

### 📅 Cloud Practitioner (CLF-C02) — 4 Semanas

Ideal para quem já está fazendo o curso FinOps na AWS e quer a primeira certificação.

| Semana | Foco | Ações |
|--------|------|-------|
| **1** | Cloud Concepts + Billing | Assistir Seções 1, 3 e 4 do curso. Fazer o módulo AWS Cloud Practitioner Essentials no Skill Builder. Revisar Well-Architected Framework. |
| **2** | Technology & Services | Assistir Seções 5, 6, 7, 8 e 9 do curso. Estudar os serviços core: EC2, S3, RDS, VPC, Lambda, CloudFront. Fazer Labs 2 e 5. |
| **3** | Security & Governance | Assistir Seções 2 e 10 do curso. Estudar IAM, modelo de responsabilidade compartilhada, Organizations, SCPs. Fazer Lab 1. |
| **4** | Revisão + Simulados | Revisar o [CHEATSHEET.md](CHEATSHEET.md). Fazer 3 simulados completos. Revisar erros. Focar nos pontos fracos. Agendar a prova! |

> 💪 **Meta**: Dedique 1-2 horas por dia. Total estimado: ~30-40 horas de estudo.

### 📅 Solutions Architect Associate (SAA-C03) — 8 Semanas

Para quem já tem o Cloud Practitioner ou experiência equivalente.

| Semana | Foco | Ações |
|--------|------|-------|
| **1** | Fundamentos + IAM | Revisar Seção 1 e 2 do curso. Estudar IAM em profundidade (policies, roles, federation). Estudar AWS Organizations e SCPs (Seção 10). |
| **2** | Computação | Revisar Seções 5 e 6 do curso. Estudar EC2 (instance types, placement groups, ENI, AMI). Auto Scaling policies. Lambda, ECS, EKS. Fazer Lab 2. |
| **3** | Armazenamento | Revisar Seção 8 do curso. Estudar S3 (todas as classes, lifecycle, replication, encryption). EBS (tipos, snapshots, encryption). EFS, FSx. Fazer Lab 5. |
| **4** | Banco de Dados | Revisar Seção 9 do curso. Estudar RDS (Multi-AZ, Read Replicas, Aurora). DynamoDB (partitions, GSI, DAX). ElastiCache, Redshift. |
| **5** | Redes | Revisar Seção 7 do curso. Estudar VPC (subnets, route tables, NAT, VPC Peering, Transit Gateway). CloudFront, Route 53, Global Accelerator. Fazer Lab 4. |
| **6** | Cost Optimization + Serverless | Revisar Seções 3 e 4 do curso. Estudar Savings Plans, Reserved Instances, Spot. Arquiteturas serverless. Cost Explorer, Compute Optimizer. Fazer Lab 6. |
| **7** | Segurança + Alta Disponibilidade | Estudar KMS, CloudTrail, GuardDuty, WAF. Padrões de DR (Backup & Restore → Multi-Site). ELB, Route 53 failover. |
| **8** | Revisão + Simulados | Revisar o [CHEATSHEET.md](CHEATSHEET.md) e a [checklist Well-Architected](checklists/aws-well-architected-checklist.md). Fazer 5 simulados completos. Revisar todos os erros. Agendar a prova! |

> 💪 **Meta**: Dedique 1.5-2 horas por dia. Total estimado: ~80-100 horas de estudo.

---

## Mapeamento: Módulos do Curso → Domínios dos Exames

Tabela completa mostrando como cada seção do curso contribui para cada certificação.

| Seção do Curso | CLF-C02 | SAA-C03 | FOCP |
|----------------|---------|---------|------|
| **1 – Introdução** | ✅ Domínio 1 (Cloud Concepts) | ✅ Domínio 4 (Cost-Optimized) | ✅ Framework & Principles |
| **2 – Tags e Marcação** | ✅ Domínio 2 (Security) | ✅ Domínio 1 (Secure) e 4 (Cost) | ✅ Inform (alocação de custos) |
| **3 – Preços e Custos** | ✅ Domínio 4 (Billing) | ✅ Domínio 4 (Cost-Optimized) | ✅ Optimize (commitment discounts) |
| **4 – Faturamento e Monitoramento** | ✅ Domínio 4 (Billing) | ✅ Domínio 4 (Cost-Optimized) | ✅ Inform (visibilidade, relatórios) |
| **5 – Computação (parte 1)** | ✅ Domínio 3 (Technology) | ✅ Domínio 2, 3 e 4 | ✅ Optimize (rightsizing) |
| **6 – Computação (parte 2)** | ✅ Domínio 3 (Technology) | ✅ Domínio 3 e 4 | ✅ Optimize (serverless) |
| **7 – Redes** | ✅ Domínio 3 (Technology) | ✅ Domínio 1, 3 e 4 | ✅ Optimize (data transfer) |
| **8 – Armazenamento** | ✅ Domínio 3 (Technology) | ✅ Domínio 2, 3 e 4 | ✅ Optimize (storage tiers) |
| **9 – Bancos de Dados** | ✅ Domínio 3 (Technology) | ✅ Domínio 2, 3 e 4 | ✅ Optimize (database pricing) |
| **10 – Governança** | ✅ Domínio 2 (Security) | ✅ Domínio 1 (Secure) | ✅ Operate (governança, políticas) |

### Cobertura Estimada por Certificação

| Certificação | Cobertura do Curso | Complemento Necessário |
|--------------|--------------------|-----------------------|
| **CLF-C02** | ~60% | Serviços adicionais (SQS, SNS, Kinesis), planos de suporte, migração |
| **SAA-C03** | ~40% (90%+ no Domínio 4) | Segurança avançada, HA/DR, serviços de integração, analytics |
| **FOCP** | ~50% | Framework FinOps detalhado, multi-cloud, unit economics, organizational adoption |

---

## 🏆 Ordem Recomendada de Certificação

```
1️⃣  Cloud Practitioner (CLF-C02)     → Base sólida, confiança, vocabulário AWS
         ⬇️ (1-2 meses depois)
2️⃣  Solutions Architect Associate     → Arquitetura, profundidade técnica
         ⬇️ (quando quiser)
3️⃣  FinOps Certified Practitioner     → Framework, processos, visão de negócio
```

> 🎯 **Com o curso FinOps na AWS + os recursos deste guia, você tem tudo para conquistar essas três certificações. O segredo é consistência: estude um pouco todo dia, faça simulados e não desista. Bora lá!** 🚀

---

## 📚 Recursos Adicionais do Repositório

Aproveite os materiais deste repositório para reforçar seus estudos:

| Recurso | Como usar para certificação |
|---------|----------------------------|
| [CHEATSHEET.md](CHEATSHEET.md) | Revisão rápida na véspera da prova |
| [Checklist Well-Architected](checklists/aws-well-architected-checklist.md) | Revisar os 84 itens do pilar de custos |
| [Queries Athena](queries/) | Entender CUR e análise de custos (SAA-C03 Domínio 4) |
| [IAM Policies e SCPs](policies/) | Praticar leitura de policies JSON (CLF-C02 e SAA-C03) |
| [Scripts de automação](scripts/) | Entender otimizações práticas (gp2→gp3, cleanup) |
| [Ferramentas FinOps](tools/) | Visão prática de análise de custos |
| [Templates de relatórios](templates/) | Entender reporting FinOps (FOCP) |

---

*Última atualização: Maio 2026*
*Guia criado como material de apoio ao curso [FinOps na AWS](https://turing.education/finops)*