# FinOps na AWS – Cheat Sheet 📋

Referência rápida com os principais conceitos, preços e decisões de otimização de custos na AWS.

---

## 🧠 Os 4 Pilares do Cloud Financial Management

| Pilar | Foco | Ações-chave |
|-------|------|-------------|
| **Ver** | Medição e prestação de contas | Tags, Cost Explorer, CUR, categorias de custo |
| **Economizar** | Otimização de custos | Right-sizing, Spot, Savings Plans, lifecycle |
| **Planejar** | Planejamento e previsão | Budgets, previsão, caso de negócio |
| **Executar** | Operações financeiras | Automação, governança, cultura de custos |

---

## 💰 Modelos de Preço

### Comparação Rápida

| Modelo | Desconto | Compromisso | Melhor para |
|--------|----------|-------------|-------------|
| On-Demand | 0% | Nenhum | Cargas imprevisíveis, testes |
| Spot | Até 90% | Nenhum (pode perder) | Stateless, tolerante a falhas |
| RI Standard | Até 72% | 1 ou 3 anos | Carga constante, previsível |
| RI Convertible | Até 66% | 1 ou 3 anos | Carga constante com flexibilidade |
| Compute SP | Até 66% | 1 ou 3 anos ($/hora) | EC2 + Fargate + Lambda |
| EC2 Instance SP | Até 72% | 1 ou 3 anos ($/hora) | Família específica em uma região |

### Savings Plans vs Reserved Instances

| Característica | Compute SP | EC2 Instance SP | RI Convertible | RI Standard |
|----------------|:----------:|:---------------:|:--------------:|:-----------:|
| Flexível em família | ✅ | ❌ | ✅* | ❌ |
| Flexível em região | ✅ | ❌ | ❌ | ❌ |
| Flexível em tamanho | ✅ | ✅ | ✅* | ✅** |
| Flexível em OS | ✅ | ✅ | ✅* | ❌ |
| Aplica em Fargate/Lambda | ✅ | ❌ | ❌ | ❌ |

\* Requer troca manual | \*\* Apenas RIs regionais

### Opções de Pagamento (quanto mais antecipado, maior o desconto)

```
Sem pagamento antecipado  →  Pagamento parcial  →  Pagamento total antecipado
      (menor desconto)                                  (maior desconto)
```

---

## 🖥️ Computação (EC2)

### Nomenclatura de Instâncias

```
c5n.xlarge
│ │ │
│ │ └─ Tamanho (nano, micro, small, medium, large, xlarge, 2xlarge...)
│ └─── Atributo (n=rede, d=disco local, a=AMD, g=Graviton)
└───── Família + Geração (c=compute, m=general, r=memory, t=burstable)
```

### Famílias Principais

| Família | Uso | Proporção Memória:vCPU |
|---------|-----|------------------------|
| **t3/t3a** | Burstable, dev/test | Variável |
| **m5/m6i** | Uso geral | 4:1 |
| **c5/c6i** | Compute-intensive | 2:1 |
| **r5/r6i** | Memory-intensive | 8:1 |
| **i3/i4i** | Storage-intensive | Alto IOPS local |

### Dicas de Economia em EC2

- ✅ Sempre use a **última geração** (melhor preço/performance)
- ✅ Use **Graviton** (arm64) para ~20% mais barato
- ✅ **Spot** para workloads stateless e tolerantes a falhas
- ✅ **Auto Scaling** para não pagar por capacidade ociosa
- ✅ **Instance Scheduler** para desligar dev/test fora do horário
- ✅ **Compute Optimizer** para recomendações de right-sizing

---

## 💾 Armazenamento

### EBS – Tipos de Volume

| Tipo | Uso | IOPS | Throughput | Preço/GB/mês* |
|------|-----|------|------------|---------------|
| **gp3** | Uso geral (RECOMENDADO) | 3.000 base (até 16k) | 125 MB/s (até 1k) | $0.08 |
| **gp2** | Uso geral (legado) | 3 por GB (até 16k) | Até 250 MB/s | $0.10 |
| **io2** | Alta performance | Até 256k | Até 4k MB/s | $0.125 + IOPS |
| **st1** | Throughput (big data) | N/A | Até 500 MB/s | $0.045 |
| **sc1** | Cold (arquivo) | N/A | Até 250 MB/s | $0.015 |

\* us-east-1

> 🎯 **Regra de ouro**: migre TUDO de gp2 para gp3. Mesmo desempenho, 20% mais barato.

### S3 – Classes de Armazenamento

| Classe | Acesso | Preço/GB/mês* | Recuperação | Duração mín. |
|--------|--------|---------------|-------------|--------------|
| **Standard** | Frequente | $0.023 | Instantâneo | – |
| **Intelligent-Tiering** | Variável | $0.004–$0.023 | Instantâneo | – |
| **Standard-IA** | Infrequente | $0.0125 | Instantâneo | 30 dias |
| **One Zone-IA** | Infrequente, recriável | $0.010 | Instantâneo | 30 dias |
| **Glacier Instant** | Arquivo, acesso trimestral | $0.004 | Instantâneo | 90 dias |
| **Glacier Flexible** | Arquivo, acesso anual | $0.0036 | Minutos a horas | 90 dias |
| **Glacier Deep Archive** | Arquivo raro | $0.00099 | 12–48 horas | 180 dias |

\* us-east-1

### Fluxo de Lifecycle Recomendado

```
Standard → (30 dias) → Standard-IA → (90 dias) → Glacier → (365 dias) → Expirar
```

---

## 🌐 Redes – Transferência de Dados

### Regras de Cobrança

| De → Para | Custo |
|-----------|-------|
| Internet → AWS | **Grátis** |
| Mesma AZ (IP privado) | **Grátis** |
| EC2 → S3/DynamoDB (mesma região) | **Grátis** |
| EC2 → CloudFront | **Grátis** |
| Entre AZs (mesma região) | $0.01/GB cada direção |
| Entre regiões | $0.02/GB (varia) |
| AWS → Internet | $0.09/GB (primeiros 10 TB) |

### Dicas de Economia em Rede

- ✅ Use **VPC Endpoints Gateway** (S3, DynamoDB) — grátis, evita NAT
- ✅ Use **CloudFront** na frente de S3 e ALB — transferência EC2→CF é grátis
- ✅ Mantenha recursos na **mesma AZ** quando possível
- ✅ Libere **Elastic IPs** não associados ($3.65/mês cada)
- ✅ Avalie **VPC Endpoint Interface** vs **NAT Gateway** para tráfego alto

---

## 🗄️ Bancos de Dados

### Quando Usar Cada Serviço

| Serviço | Tipo | Melhor para | Modelo serverless? |
|---------|------|-------------|:------------------:|
| **RDS** | Relacional | OLTP, apps tradicionais | ❌ |
| **Aurora** | Relacional | Alta performance, compatível MySQL/PG | ✅ |
| **DynamoDB** | NoSQL (key-value) | Microsserviços, alta escala | ✅ |
| **ElastiCache** | Cache (Redis/Memcached) | Reduzir leituras no DB | ❌ |
| **Redshift** | Data Warehouse | Analytics, OLAP | ✅ |

### Dicas de Economia em Bancos

- ✅ **Aurora Serverless** para cargas intermitentes
- ✅ **RIs de 1 ou 3 anos** para bancos de produção estáveis
- ✅ **ElastiCache** na frente do RDS reduz instância necessária
- ✅ **DynamoDB On-Demand** para tráfego imprevisível
- ✅ **Redshift Serverless** para queries esporádicas

---

## 🏷️ Tags – Dicionário Mínimo

| Tag | Valores exemplo | Obrigatória? |
|-----|-----------------|:------------:|
| `Environment` | Production, Development, Test | ✅ |
| `Department` | Finance, Engineering, Marketing | ✅ |
| `Application` | payments-api, website, data-pipeline | ✅ |
| `CostCenter` | CC-1234, CC-5678 | ✅ |
| `Owner` | email do responsável | Recomendada |
| `Schedule` | office-hours, 24x7, weekdays | Recomendada |

> 🎯 Comece com **4 tags obrigatórias**. Menos é mais no início.

---

## 📊 Ferramentas de Monitoramento

| Ferramenta | O que faz | Quando usar |
|------------|-----------|-------------|
| **Cost Explorer** | Visualiza custos por serviço/tag/conta | Análise diária/mensal |
| **Budgets** | Alertas quando custo ultrapassa limite | Controle proativo |
| **Anomaly Detection** | ML detecta gastos anormais | Alertas automáticos |
| **CUR + Athena** | Dados granulares de custo (SQL) | Análise profunda |
| **QuickSight** | Dashboards visuais | Relatórios para gestão |
| **Compute Optimizer** | Recomendações de right-sizing | Otimização de EC2 |
| **Trusted Advisor** | Verificações de boas práticas | Auditoria geral |

---

## 🏛️ Governança Multi-Account

### Estrutura Recomendada (Landing Zone)

```
Organização
├── Management Account (pagadora)
├── OU: Security
│   ├── Conta de Auditoria
│   └── Conta de Logs
├── OU: Workloads
│   ├── Conta de Produção
│   ├── Conta de Staging
│   └── Conta de Desenvolvimento
└── OU: Sandbox
    └── Contas de experimentação
```

### SCPs Essenciais

| SCP | Efeito |
|-----|--------|
| Deny regiões não autorizadas | Bloqueia uso fora de us-east-1 e sa-east-1 |
| Deny instâncias caras | Impede p4d, x2idn, u-* |
| Require tags | Nega criação sem tags obrigatórias |

---

## ⚡ Quick Wins (faça hoje!)

| Ação | Economia | Esforço |
|------|----------|---------|
| Migrar gp2 → gp3 | 20% no EBS | 5 min (script) |
| Liberar EIPs não usados | $3.65/mês cada | 2 min |
| Deletar snapshots órfãos | $0.05/GB/mês | 5 min (script) |
| Instance Scheduler (dev/test) | ~70% em EC2 | 30 min |
| S3 Lifecycle rules | 50-90% em storage | 10 min |
| VPC Endpoint para S3 | Elimina custo NAT→S3 | 5 min |
| CloudFront na frente do ALB | Reduz data transfer | 15 min |
| Right-sizing com Compute Optimizer | 20-40% em EC2 | 15 min |

---

## 🎓 Certificações Relacionadas

- **AWS Certified Cloud Practitioner** — cobre conceitos de billing e pricing
- **AWS Certified Solutions Architect – Associate** — cobre arquitetura cost-effective
- **FinOps Certified Practitioner (FOCP)** — certificação específica de FinOps

---

## 📐 Fórmulas Úteis

```
Economia com Instance Scheduler:
  Horas ligado por semana = 10h/dia × 5 dias = 50h
  Horas na semana = 168h
  Economia = (168 - 50) / 168 = ~70%

Custo mensal de EIP não associado:
  $0.005/hora × 730 horas = $3.65/mês

Economia gp2 → gp3 (100 GB):
  gp2: 100 GB × $0.10 = $10/mês
  gp3: 100 GB × $0.08 = $8/mês
  Economia: $2/mês por volume (20%)

Break-even de Savings Plan (1 ano, sem antecipado):
  Se uso > 70% do tempo → SP vale a pena
```

---

> 💡 **Dica final**: FinOps não é um projeto com fim. É um ciclo contínuo de medir, otimizar e planejar. Comece pelos quick wins e evolua.
