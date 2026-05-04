# Plano de Otimização de Custos AWS 🎯

**Data**: [DD/MM/AAAA]
**Responsável**: [NOME]
**Período de execução**: [DATA INÍCIO] a [DATA FIM]

---

## Situação Atual

| Métrica | Valor |
|---------|:-----:|
| Gasto mensal atual | $X,XXX |
| Gasto anual projetado | $XX,XXX |
| % do orçamento utilizado | XX% |
| Desperdício estimado | $X,XXX/mês (XX%) |

---

## Oportunidades Identificadas

### 🔴 Prioridade Alta (Quick Wins)

| # | Oportunidade | Economia/mês | Esforço | Responsável | Prazo |
|---|-------------|:------------:|:-------:|:-----------:|:-----:|
| 1 | Migrar X volumes gp2 → gp3 | $XXX | 1h | [Nome] | [Data] |
| 2 | Liberar X EIPs não associados | $XX | 15min | [Nome] | [Data] |
| 3 | Deletar X snapshots órfãos (XX GB) | $XX | 30min | [Nome] | [Data] |
| 4 | Instance Scheduler em dev/test | $X,XXX | 2h | [Nome] | [Data] |
| | **Subtotal** | **$X,XXX** | | | |

### 🟡 Prioridade Média (Semanas)

| # | Oportunidade | Economia/mês | Esforço | Responsável | Prazo |
|---|-------------|:------------:|:-------:|:-----------:|:-----:|
| 5 | Right-sizing de X instâncias EC2 | $XXX | 4h | [Nome] | [Data] |
| 6 | Comprar Savings Plans ($XX/hr) | $X,XXX | 2h | [Nome] | [Data] |
| 7 | S3 Lifecycle em X buckets | $XXX | 2h | [Nome] | [Data] |
| 8 | VPC Endpoints para S3/DynamoDB | $XXX | 1h | [Nome] | [Data] |
| | **Subtotal** | **$X,XXX** | | | |

### 🟢 Prioridade Baixa (Meses)

| # | Oportunidade | Economia/mês | Esforço | Responsável | Prazo |
|---|-------------|:------------:|:-------:|:-----------:|:-----:|
| 9 | Migrar para Graviton (arm64) | $XXX | 1 sprint | [Nome] | [Data] |
| 10 | Refatorar para serverless | $X,XXX | 2 sprints | [Nome] | [Data] |
| 11 | Implementar caching (ElastiCache) | $XXX | 1 sprint | [Nome] | [Data] |
| | **Subtotal** | **$X,XXX** | | | |

---

## Resumo Financeiro

| | Mensal | Anual |
|-|:------:|:-----:|
| Economia Quick Wins | $X,XXX | $XX,XXX |
| Economia Prioridade Média | $X,XXX | $XX,XXX |
| Economia Prioridade Baixa | $X,XXX | $XX,XXX |
| **Economia Total Projetada** | **$X,XXX** | **$XX,XXX** |
| **% de Redução** | **XX%** | **XX%** |

---

## Cronograma

```
Semana 1-2:  [████████░░░░░░░░] Quick Wins (gp2→gp3, EIPs, snapshots, scheduler)
Semana 3-4:  [░░░░████████░░░░] Right-sizing + Savings Plans
Mês 2:       [░░░░░░░░████████] S3 Lifecycle + VPC Endpoints
Mês 3+:      [░░░░░░░░░░░░████] Graviton + Serverless + Cache
```

---

## Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|:------------:|:-------:|-----------|
| Downtime durante right-sizing | Média | Médio | Fazer em janela de manutenção |
| SP/RI subutilizado | Baixa | Alto | Comprar em incrementos pequenos |
| Impacto em performance | Baixa | Alto | Testar em staging primeiro |

---

## Métricas de Acompanhamento

| Métrica | Baseline | Meta (30 dias) | Meta (90 dias) |
|---------|:--------:|:--------------:|:--------------:|
| Custo mensal | $X,XXX | $X,XXX | $X,XXX |
| Volumes gp2 | X | 0 | 0 |
| EIPs ociosos | X | 0 | 0 |
| Cobertura SP/RI | XX% | XX% | XX% |
| Taxa de tags | XX% | XX% | >95% |
| CPU média EC2 | XX% | >30% | >40% |

---

## Aprovações

| Nome | Cargo | Assinatura | Data |
|------|-------|:----------:|:----:|
| [Nome] | FinOps Lead | _________ | ___/___/___ |
| [Nome] | Engineering Manager | _________ | ___/___/___ |
| [Nome] | Finance | _________ | ___/___/___ |

---

*Revisão: Este plano será revisado [semanalmente/quinzenalmente] até a conclusão.*
