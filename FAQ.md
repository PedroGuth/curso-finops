# FAQ – FinOps na AWS ❓

Perguntas frequentes dos alunos do curso **FinOps na AWS – Economizando e Gerenciando Custos na Nuvem**.

---

## 📌 Geral

### 1. O que é FinOps?
FinOps (Financial Operations) é uma prática que une tecnologia, finanças e negócios para gerenciar custos na nuvem de forma colaborativa. O objetivo é maximizar o valor de cada real investido na AWS.

### 2. Preciso de alguma certificação AWS antes de começar o curso?
Não. Basta saber o que é EC2, S3 e RDS. O curso explica tudo do zero no contexto de custos.

### 3. Quanto tempo leva para implementar FinOps na minha empresa?
Você pode ver resultados em 2-4 semanas com quick wins como right-sizing e limpeza de recursos ociosos. A cultura FinOps completa leva de 3 a 6 meses para se consolidar.

### 4. FinOps é só para empresas grandes?
Não. Startups com contas de $500/mês podem economizar 20-30% aplicando as mesmas práticas que empresas com milhões em gastos.

### 5. Qual a diferença entre FinOps e simplesmente "cortar custos"?
Cortar custos é reduzir gastos sem critério. FinOps é otimizar — gastar o necessário para gerar valor, eliminando desperdício sem comprometer performance.

---

## 💰 Billing e Custos

### 6. Como entendo minha fatura da AWS?
Use o Cost Explorer para visualizar graficamente e o CUR para análise detalhada. Comece filtrando pelos 3-5 serviços mais caros.

### 7. Por que estou sendo cobrado se não estou usando nada?
Recursos provisionados geram custo mesmo parados — EBS volumes, Elastic IPs não associados, NAT Gateways e RDS instances ociosas são os vilões mais comuns.

### 8. O Free Tier realmente é grátis?
Sim, dentro dos limites. Existem 3 tipos: Always Free, 12 Months Free e Trials. Passe dos limites e a cobrança começa — configure alertas no Budgets.

### 9. Como configuro alertas para não levar susto na fatura?
Use AWS Budgets para alertas de custo e Cost Anomaly Detection para detectar gastos fora do padrão automaticamente.

### 10. Qual a diferença entre custo blended e unblended?
Unblended é o custo real de cada recurso. Blended é a média ponderada com descontos distribuídos entre contas. Para otimização, use unblended.

### 11. Posso pedir reembolso de cobranças acidentais?
A AWS tem uma política informal de cortesia para novos usuários. Abra um caso no Support, mas não conte com isso como prática recorrente.

---

## 🏷️ Tags

### 12. Por que tags são tão importantes para FinOps?
Sem tags, você não sabe quem gastou o quê nem qual projeto consome mais. São a base da alocação de custos e do chargeback/showback.

### 13. Quantas tags devo usar?
Comece com 4-6 essenciais: Environment, Project, Owner, CostCenter, Team e Application. Mais que 10 vira burocracia.

### 14. Como forço o uso de tags nos recursos?
Use IAM Policies com `aws:RequestTag` para exigir tags na criação, AWS Config Rules para detectar recursos sem tags, e SCPs para bloquear em toda a Organization.

### 15. Tags afetam o custo dos recursos?
Não. Tags são metadados gratuitos. Mas sem ativar Cost Allocation Tags no Billing, você não consegue filtrar custos por tag no Cost Explorer.

---

## 🖥️ EC2 e Computação

### 16. Quando usar Spot vs On-Demand vs Reserved?
On-Demand para workloads imprevisíveis. Spot para cargas tolerantes a interrupção (até 90% desconto). Reserved/Savings Plans para workloads estáveis 24/7.

### 17. O que é right-sizing e como faço?
É ajustar o tipo de instância ao uso real. Use Compute Optimizer ou CloudWatch para identificar instâncias com CPU < 20% e reduza o tipo.

### 18. Savings Plans ou Reserved Instances — qual escolher?
Savings Plans são mais flexíveis e cobrem EC2, Fargate e Lambda. RIs dão desconto ligeiramente maior mas prendem a um tipo específico. Para a maioria, Savings Plans vencem.

### 19. Instâncias Graviton realmente economizam?
Sim. Oferecem até 40% melhor relação custo-performance vs x86. A maioria das aplicações Linux roda sem modificação.

### 20. Como o Auto Scaling ajuda a economizar?
Ajusta a quantidade de instâncias conforme a demanda. Você paga apenas pelo que usa, em vez de provisionar para o pico 24/7.

---

## 💾 Armazenamento

### 21. Devo migrar meus volumes de gp2 para gp3?
Sim. gp3 é 20% mais barato com 3.000 IOPS de baseline. A migração é online, sem downtime.

### 22. Quais são as classes do S3 e quando usar cada uma?
Standard (acesso frequente), Intelligent-Tiering (padrão desconhecido), Standard-IA (acesso raro), Glacier Instant (acesso eventual), Glacier Flexible (backups), Deep Archive (retenção regulatória).

### 23. Quando usar Glacier vs S3 Standard-IA?
Standard-IA se precisa de acesso imediato mas raro. Glacier se pode esperar minutos/horas. Glacier custa ~$0.0036/GB vs ~$0.0125/GB do IA.

### 24. Como Lifecycle Policies economizam dinheiro?
Movem objetos automaticamente entre classes S3 conforme a idade, eliminando trabalho manual e garantindo que dados antigos não fiquem na classe mais cara.

### 25. Snapshots EBS custam caro?
Custam $0.05/GB/mês e acumulam rápido. Snapshots órfãos são desperdício puro — use o script `cleanup-orphan-snapshots.sh` para limpar.

---

## 🌐 Redes

### 26. Por que transferência de dados é tão cara na AWS?
A AWS cobra por dados que saem da nuvem ou cruzam AZs/regiões. Tráfego entre AZs custa $0.01/GB em cada direção — acumula rápido em arquiteturas distribuídas.

### 27. Como VPC Endpoints reduzem custos?
Permitem acessar serviços AWS sem passar pelo NAT Gateway. O Gateway Endpoint para S3/DynamoDB é gratuito e elimina custos de NAT.

### 28. NAT Gateway é caro — tem alternativa?
Custa ~$32/mês + $0.045/GB. Use VPC Endpoints para tráfego AWS, ou NAT Instance para cenários menores.

### 29. CloudFront ajuda a economizar em transferência?
Sim. Dados via CloudFront são mais baratos que egress direto, além de melhorar performance com cache. Inclui 1TB/mês no Free Tier.

---

## 🏛️ Governança

### 30. Por que usar múltiplas contas AWS?
Isola ambientes, facilita alocação de custos, limita blast radius e permite SCPs diferentes por OU. É a prática recomendada pela AWS.

### 31. O que são SCPs e como ajudam em FinOps?
Service Control Policies bloqueiam ações preventivamente — como criar instâncias caras ou usar regiões não autorizadas — em toda a Organization.

### 32. Control Tower vs Organizations — qual usar?
Organizations é a base. Control Tower automatiza criação de contas com guardrails pré-configurados. Use Control Tower se está começando do zero.

### 33. Como faço chargeback entre times?
Ative Cost Allocation Tags, marque recursos com tags de time/projeto, e use Cost Explorer ou CUR + Athena para gerar relatórios por tag.

---

## 🔧 Ferramentas

### 34. Qual a diferença entre Cost Explorer e CUR?
Cost Explorer é visual e rápido para o dia a dia. CUR é detalhado linha a linha — ideal para análises profundas com Athena/QuickSight.

### 35. O Trusted Advisor é gratuito?
Parcialmente. Checks completos de custo exigem plano Business ou Enterprise Support. O plano Basic oferece apenas checks limitados.

### 36. O que o Compute Optimizer faz?
Analisa métricas de utilização e recomenda tipos de instância mais adequados para EC2, EBS e Lambda. É gratuito.

### 37. Cost Anomaly Detection vale a pena?
Sim, e é gratuito. Usa ML para detectar gastos fora do padrão e alerta antes que a fatura exploda.

### 38. Quando usar QuickSight vs Cost Explorer?
Cost Explorer para análises padrão. QuickSight para dashboards customizados e relatórios visuais para stakeholders não-técnicos.

---

## 🎓 Certificações

### 39. Este curso prepara para alguma certificação?
Cobre tópicos do pilar de Custos cobrados no Cloud Practitioner (CLF-C02) e Solutions Architect Associate (SAA-C03). Complementa sua preparação.

### 40. O que é a certificação FinOps Certified Practitioner?
Certificação da FinOps Foundation que valida conhecimento em práticas FinOps (vendor-neutral). Cobre princípios, fases (Inform, Optimize, Operate) e capabilities.

### 41. Qual certificação fazer primeiro para trabalhar com FinOps?
Cloud Practitioner → Solutions Architect Associate → FinOps Certified Practitioner. As três juntas formam um perfil completo.

---

## 💡 Dicas Extras

### 42. Qual o quick win mais rápido para economizar?
Migrar volumes gp2 para gp3 (20% economia, sem risco). Depois: liberar EIPs não associados e limpar snapshots órfãos.

### 43. Com que frequência devo revisar custos?
Diariamente: 2 min no Cost Explorer. Semanalmente: anomalias e Compute Optimizer. Mensalmente: análise completa com relatório.

### 44. Posso automatizar tudo isso?
Boa parte sim. Instance Scheduler para ligar/desligar recursos, Lambda + EventBridge para limpezas, e AWS Config para compliance contínua.

---

> 💬 **Tem uma dúvida que não está aqui?** Abra uma
> [dúvida sobre o curso](https://github.com/PedroGuth/curso-finops/issues/new?template=duvida.yml)
> aqui no repositório — não precisa estar matriculado. Quem faz o
> [curso completo](https://turing.education/finops) também pode perguntar direto na área de alunos.
