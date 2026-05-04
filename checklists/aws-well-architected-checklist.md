# AWS Well-Architected Framework – Checklist do Pilar de Otimização de Custos ✅

Checklist completo baseado no [AWS Well-Architected Framework - Cost Optimization Pillar](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html).

Use este checklist para avaliar suas cargas de trabalho e identificar oportunidades de melhoria.

---

## 1. Prática do Gerenciamento Financeiro da Nuvem

### 1.1 Governança

- [ ] Existe um responsável (ou equipe) por FinOps na organização?
- [ ] Há parceria formal entre equipes de TI e Financeiro?
- [ ] Existe um processo de revisão periódica de custos (semanal/mensal)?
- [ ] A liderança executiva patrocina iniciativas de otimização?
- [ ] Há metas de economia definidas e acompanhadas?
- [ ] Existe um processo de aprovação para novos gastos significativos?

### 1.2 Cultura

- [ ] As equipes de desenvolvimento têm visibilidade dos custos que geram?
- [ ] Há incentivos para equipes que reduzem custos?
- [ ] Conquistas de economia são celebradas e comunicadas?
- [ ] Existe treinamento de FinOps para novos membros?

### 1.3 Orçamento e Previsão

- [ ] Há orçamentos definidos por conta/equipe/projeto?
- [ ] Previsões de custo são atualizadas regularmente?
- [ ] Variações de orçamento são investigadas proativamente?
- [ ] O planejamento considera sazonalidade e crescimento?

---

## 2. Consciência sobre Gastos e Uso

### 2.1 Estrutura de Contas

- [ ] Usa AWS Organizations com contas separadas por ambiente/equipe?
- [ ] Há uma conta pagadora dedicada (sem workloads)?
- [ ] Contas de sandbox são isoladas com limites de gasto?
- [ ] SCPs estão configuradas para prevenir gastos não autorizados?

### 2.2 Marcação (Tags)

- [ ] Existe um dicionário de tags documentado e padronizado?
- [ ] Tags obrigatórias estão definidas (Department, Environment, Application, CostCenter)?
- [ ] Há enforcement automático de tags (AWS Config, IAM, SCPs)?
- [ ] Tags de alocação de custos estão ativadas no Billing?
- [ ] Taxa de conformidade de tags é monitorada (meta: >95%)?
- [ ] Recursos sem tags são identificados e corrigidos regularmente?

### 2.3 Monitoramento e Alertas

- [ ] AWS Cost Explorer está habilitado e é usado regularmente?
- [ ] AWS Budgets estão configurados com alertas (80%, 100%, forecast)?
- [ ] Cost Anomaly Detection está ativo com notificações?
- [ ] Há dashboards de custo visíveis para as equipes?
- [ ] Relatórios de custo são enviados periodicamente à gestão?
- [ ] CUR (Cost and Usage Report) está configurado para análise detalhada?

### 2.4 Descomissionamento

- [ ] Há processo para identificar recursos não utilizados?
- [ ] Recursos de ambientes temporários são removidos automaticamente?
- [ ] Contas de sandbox são limpas periodicamente?
- [ ] Snapshots e backups antigos são expirados automaticamente?

---

## 3. Uso de Recursos de Baixo Custo

### 3.1 Seleção de Serviço

- [ ] Serviços gerenciados são preferidos quando possível (RDS vs EC2+DB)?
- [ ] Serverless é considerado para cargas variáveis (Lambda, Fargate, Aurora Serverless)?
- [ ] A região mais econômica é escolhida (considerando latência)?
- [ ] Serviços gratuitos são aproveitados (VPC, CloudFormation, Auto Scaling)?

### 3.2 Tipo e Tamanho de Recurso

- [ ] Instâncias EC2 usam a última geração disponível?
- [ ] Graviton (arm64) é usado onde possível (~20% mais barato)?
- [ ] Right-sizing é feito regularmente com Compute Optimizer?
- [ ] Instâncias burstable (t3/t3a) são usadas para cargas variáveis?
- [ ] Volumes EBS são gp3 (não gp2)?
- [ ] Classes de armazenamento S3 são adequadas ao padrão de acesso?

### 3.3 Modelos de Preço

- [ ] Instâncias Spot são usadas para cargas tolerantes a falhas?
- [ ] Savings Plans cobrem a baseline de uso estável?
- [ ] Reserved Instances são usadas para RDS/ElastiCache/Redshift estáveis?
- [ ] Compras de compromisso são feitas em ciclos pequenos e regulares?
- [ ] Cobertura de SP/RI é monitorada (meta: >70% para produção)?
- [ ] RIs não utilizadas são vendidas no Marketplace?

### 3.4 Transferência de Dados

- [ ] VPC Endpoints Gateway são usados para S3 e DynamoDB?
- [ ] CloudFront está na frente de origens com alto tráfego?
- [ ] Transferência entre AZs é minimizada quando possível?
- [ ] NAT Gateway é evitado para tráfego que pode usar endpoints?
- [ ] Elastic IPs não associados são liberados?

---

## 4. Gerenciamento de Demanda e Fornecimento de Recursos

### 4.1 Auto Scaling

- [ ] Auto Scaling está configurado para todas as cargas variáveis?
- [ ] Políticas de scaling usam métricas adequadas (não apenas CPU)?
- [ ] Scaling preditivo está habilitado para cargas previsíveis?
- [ ] Capacidade mínima é revisada regularmente?

### 4.2 Agendamento

- [ ] Ambientes de dev/test são desligados fora do horário comercial?
- [ ] Instance Scheduler (ou similar) está implementado?
- [ ] Economia com agendamento é medida e reportada?
- [ ] Há exceções documentadas para recursos 24x7?

### 4.3 Buffer e Throttle

- [ ] Filas (SQS) são usadas para absorver picos de demanda?
- [ ] Rate limiting está configurado em APIs?
- [ ] Caching (ElastiCache, CloudFront) reduz carga nos backends?

---

## 5. Otimização ao Longo do Tempo

### 5.1 Revisão Contínua

- [ ] Há revisão mensal de custos com ações definidas?
- [ ] Novas gerações de instâncias são avaliadas quando lançadas?
- [ ] Novos serviços AWS são considerados para substituir soluções atuais?
- [ ] Trusted Advisor é revisado regularmente?
- [ ] Well-Architected Reviews são feitas periodicamente?

### 5.2 Automação

- [ ] Scripts de otimização rodam automaticamente (gp2→gp3, EIPs, snapshots)?
- [ ] Compliance de tags é verificado automaticamente?
- [ ] Alertas de anomalia disparam ações automáticas?
- [ ] Infrastructure as Code (CloudFormation/Terraform) é usado para consistência?

### 5.3 Métricas e KPIs

- [ ] Custo por unidade de negócio é rastreado (ex: custo por transação)?
- [ ] Tendência de custo mês a mês é monitorada?
- [ ] Economia realizada é quantificada e reportada?
- [ ] Há benchmark de custo vs. indústria/peers?

---

## 📊 Scorecard

| Área | Total de Itens | Conformes | % |
|------|:--------------:|:---------:|:-:|
| 1. Gerenciamento Financeiro | 16 | ___ | ___% |
| 2. Consciência sobre Gastos | 22 | ___ | ___% |
| 3. Recursos de Baixo Custo | 22 | ___ | ___% |
| 4. Demanda e Fornecimento | 11 | ___ | ___% |
| 5. Otimização Contínua | 13 | ___ | ___% |
| **TOTAL** | **84** | ___ | ___% |

### Classificação

| Score | Nível | Ação |
|-------|-------|------|
| 90-100% | 🟢 Excelente | Manter e refinar |
| 70-89% | 🟡 Bom | Priorizar gaps críticos |
| 50-69% | 🟠 Regular | Plano de ação urgente |
| < 50% | 🔴 Crítico | Revisão completa necessária |

---

## 🎯 Próximos Passos

1. Preencha o checklist para cada workload
2. Identifique os 3 itens com maior impacto financeiro
3. Crie um plano de ação com prazos e responsáveis
4. Revise mensalmente e atualize o scorecard
5. Use a [Well-Architected Tool](https://aws.amazon.com/well-architected-tool/) para avaliação formal

---

> 💡 Este checklist é um guia. Nem todos os itens se aplicam a todas as organizações. Adapte conforme seu contexto.
