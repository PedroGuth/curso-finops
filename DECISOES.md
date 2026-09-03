# Diagramas de Decisão para Otimização de Custos na AWS

Guia visual para tomar decisões rápidas de otimização de custos na AWS. Use estes fluxogramas como referência ao arquitetar ou revisar workloads.

---

## 1. Qual modelo de compra EC2 usar?

```mermaid
flowchart TD
    A{Carga previsível?} -->|Sim| B{Uso >70% do tempo?}
    A -->|Não| C{Tolerante a falhas?}
    B -->|Sim| D[EC2 Instance SP / RI Standard]
    B -->|Não| E[Compute Savings Plan]
    C -->|Sim| F[Spot Instances]
    C -->|Não| G[On-Demand]

    style D fill:#2e7d32,color:#fff
    style E fill:#1565c0,color:#fff
    style F fill:#f57f17,color:#000
    style G fill:#c62828,color:#fff
```

> **Recomendação:** Comece com Compute Savings Plan para ter flexibilidade. Use Spot para workloads batch/tolerantes e reserve Instance SP apenas quando tiver certeza da família e região.

---

## 2. Qual tipo de volume EBS escolher?

```mermaid
flowchart TD
    A{Precisa de latência <1ms?} -->|Sim| B{IOPS >80k?}
    A -->|Não| C{Custo é prioridade máxima?}
    B -->|Sim| D[io2 Block Express]
    B -->|Não| E[io1 / io2]
    C -->|Sim| F{Precisa de throughput alto?}
    C -->|Não| G[gp3]
    F -->|Sim, leitura sequencial| H[st1]
    F -->|Sim, cold storage| I[sc1]
    F -->|Não| G

    style G fill:#2e7d32,color:#fff
    style D fill:#6a1b9a,color:#fff
    style E fill:#1565c0,color:#fff
    style H fill:#f57f17,color:#000
    style I fill:#ff8f00,color:#000
```

> **Recomendação:** Use **gp3 SEMPRE** como padrão. Nunca crie gp2 — gp3 é mais barato e mais performático. Migre volumes gp2 existentes imediatamente.

---

## 3. Qual classe de armazenamento S3 usar?

```mermaid
flowchart TD
    A{Acesso frequente?} -->|Sim| B[S3 Standard]
    A -->|Não| C{Padrão de acesso imprevisível?}
    C -->|Sim| D[S3 Intelligent-Tiering]
    C -->|Não| E{Frequência de acesso?}
    E -->|Mensal| F[S3 Standard-IA]
    E -->|Trimestral| G[Glacier Instant Retrieval]
    E -->|Anual| H[Glacier Flexible Retrieval]
    E -->|Raramente / compliance| I[Glacier Deep Archive]
    J{Dados recriáveis?} -->|Sim| K[S3 One Zone-IA]
    A -.->|Dados recriáveis?| J

    style B fill:#1565c0,color:#fff
    style D fill:#2e7d32,color:#fff
    style F fill:#00838f,color:#fff
    style G fill:#4527a0,color:#fff
    style H fill:#6a1b9a,color:#fff
    style I fill:#1a237e,color:#fff
    style K fill:#f57f17,color:#000
```

> **Recomendação:** Na dúvida, use **Intelligent-Tiering** — ele move automaticamente entre tiers sem custo de retrieval. Para dados que você sabe que são frios, vá direto para Glacier.

---

## 4. Savings Plan vs Reserved Instance?

```mermaid
flowchart TD
    A{Precisa cobrir Lambda/Fargate?} -->|Sim| B[Compute Savings Plan]
    A -->|Não| C{Quer flexibilidade de família/região?}
    C -->|Sim| B
    C -->|Não| D{Quer máximo desconto em família fixa?}
    D -->|Sim| E[EC2 Instance Savings Plan]
    D -->|Não| F{Precisa cobrir RDS/ElastiCache/Redshift?}
    F -->|Sim| G[Reserved Instance do serviço]
    F -->|Não| B

    style B fill:#2e7d32,color:#fff
    style E fill:#1565c0,color:#fff
    style G fill:#6a1b9a,color:#fff
```

> **Recomendação:** Compute Savings Plan é o mais versátil (cobre EC2, Fargate e Lambda). Use EC2 Instance SP só quando tiver compromisso firme com família/região. RIs são obrigatórias para RDS e outros serviços que não suportam SP.

---

## 5. Como reduzir custos de transferência de dados?

```mermaid
flowchart LR
    A{Tipo de tráfego?} -->|Para S3/DynamoDB| B[VPC Endpoint Gateway]
    A -->|Para internet| C[CloudFront na frente]
    A -->|Entre AZs| D[Manter na mesma AZ]
    A -->|Entre regiões| E[Avaliar necessidade multi-região]
    A -->|NAT Gateway caro| F[VPC Endpoint Interface]

    style B fill:#2e7d32,color:#fff
    style C fill:#1565c0,color:#fff
    style D fill:#f57f17,color:#000
    style E fill:#c62828,color:#fff
    style F fill:#00838f,color:#fff
```

> **Recomendação:** VPC Gateway Endpoints para S3/DynamoDB são **gratuitos** — não há motivo para não usar. CloudFront elimina custo de transferência EC2→Internet (EC2→CloudFront é grátis).

---

## 6. Qual banco de dados usar?

```mermaid
flowchart TD
    A{Dados relacionais?} -->|Sim| B{Carga constante?}
    A -->|Não| C{Tipo de workload?}
    B -->|Sim| D[RDS com Reserved Instance]
    B -->|Não, variável| E[Aurora Serverless v2]
    C -->|Key-value / documentos| F[DynamoDB]
    C -->|Cache / sessões| G[ElastiCache]
    C -->|Analytics / OLAP| H[Redshift]

    style D fill:#1565c0,color:#fff
    style E fill:#2e7d32,color:#fff
    style F fill:#f57f17,color:#000
    style G fill:#6a1b9a,color:#fff
    style H fill:#c62828,color:#fff
```

> **Recomendação:** Aurora Serverless v2 é ideal para cargas variáveis — escala a zero e evita pagar por capacidade ociosa. Para DynamoDB, use modo on-demand se o padrão for imprevisível, e provisionado com auto-scaling se for estável.

---

## Resumo Rápido

| Decisão | Escolha Padrão (safe default) |
|---------|-------------------------------|
| Modelo EC2 | Compute Savings Plan |
| Volume EBS | gp3 |
| Classe S3 | Intelligent-Tiering |
| Compromisso | Compute SP (1 ano, sem pagamento adiantado) |
| Transferência | VPC Endpoints + CloudFront |
| Banco de dados | Aurora Serverless v2 / DynamoDB on-demand |

---

*Referência do curso [FinOps na AWS](https://turing.education/finops)*
