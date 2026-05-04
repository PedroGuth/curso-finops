# Glossário – FinOps na AWS 📖

Termos e conceitos usados no curso **FinOps na AWS**, organizados em ordem alfabética.

---

### ABAC (Attribute-Based Access Control)
Controle de acesso baseado em atributos (tags). Permite criar políticas IAM que autorizam ações com base nas tags do recurso e do usuário, sem precisar listar ARNs específicos.

### AMI (Amazon Machine Image)
Imagem pré-configurada usada para lançar instâncias EC2. Inclui sistema operacional, aplicações e configurações. AMIs próprias evitam custos de licenciamento de marketplace.

### Athena
Serviço serverless de consultas SQL sobre dados no S3. Usado para analisar o CUR (Cost and Usage Report) sem precisar de infraestrutura de banco de dados.

### Auto Scaling
Serviço que ajusta automaticamente a quantidade de instâncias EC2 conforme a demanda. Escala para cima em picos e para baixo em períodos ociosos, otimizando custos.

### AZ (Availability Zone)
Data center isolado dentro de uma região AWS. Tráfego entre AZs é cobrado ($0.01/GB por direção), então a localidade dos recursos impacta custos.

### Billing Conductor
Serviço que permite personalizar a fatura para grupos de contas, aplicando taxas customizadas, créditos e markups. Útil para revendedores e chargeback interno.

### Budgets
Serviço que permite definir orçamentos de custo, uso ou reservas e receber alertas quando limites são atingidos. Suporta ações automáticas como parar instâncias.

### BYOL (Bring Your Own License)
Modelo que permite usar licenças de software existentes (Windows, SQL Server, Oracle) na AWS, evitando pagar novamente pelo licenciamento incluído nas AMIs.

### Chargeback
Prática de cobrar os custos de nuvem diretamente dos times/projetos que os geraram. Requer tags consistentes e relatórios de alocação de custos.

### CloudFront
CDN (Content Delivery Network) da AWS. Reduz custos de transferência de dados ao servir conteúdo de edge locations, com preço de egress menor que direto do EC2/S3.

### CloudWatch
Serviço de monitoramento que coleta métricas, logs e eventos. Essencial para right-sizing — métricas de CPU, memória e rede indicam se recursos estão superdimensionados.

### Compute Optimizer
Serviço gratuito que analisa métricas de utilização e recomenda tipos de instância ideais para EC2, Auto Scaling Groups, EBS e Lambda.

### Consolidated Billing
Recurso do AWS Organizations que unifica a fatura de todas as contas-membro. Permite aproveitar descontos por volume e compartilhar RIs/Savings Plans entre contas.

### Control Tower
Serviço que automatiza a configuração de ambientes multi-account com guardrails de segurança e compliance pré-definidos. Implementa uma Landing Zone com boas práticas.

### Cost Allocation Tags
Tags ativadas no Billing Console que aparecem no Cost Explorer e CUR para filtrar e agrupar custos. Podem ser tags definidas pelo usuário ou geradas pela AWS.

### Cost Anomaly Detection
Serviço gratuito que usa machine learning para identificar gastos fora do padrão e enviar alertas automáticos via SNS ou email.

### Cost Explorer
Ferramenta visual para analisar custos e uso da AWS. Permite filtrar por serviço, conta, tag, região e período, com gráficos e previsões de gastos futuros.

### CUR (Cost and Usage Report)
Relatório detalhado com cada linha de cobrança da AWS. Exportado para S3, pode ser consultado via Athena ou Redshift para análises granulares.

### Data Export
Funcionalidade que permite exportar dados de custo e uso da AWS para S3 em formatos como Parquet ou CSV, substituindo a configuração legada do CUR.

### Data Transfer
Cobrança por tráfego de rede. Ingress é gratuito, mas egress (saída para internet ou entre regiões/AZs) é cobrado. Um dos custos mais subestimados na AWS.

### DynamoDB
Banco de dados NoSQL serverless. No modo On-Demand, cobra por requisição; no modo Provisioned, cobra por capacidade reservada. Reserved Capacity oferece desconto.

### EBS (Elastic Block Store)
Armazenamento em bloco para EC2. Tipos incluem gp2, gp3, io1, io2, st1 e sc1. Volumes geram custo mesmo quando a instância está parada.

### EC2 (Elastic Compute Cloud)
Serviço de máquinas virtuais da AWS. Principal gerador de custos na maioria das contas. Oferece modelos On-Demand, Spot, Reserved e Savings Plans.

### EFS (Elastic File System)
Sistema de arquivos compartilhado e elástico. Mais caro que EBS por GB, mas escala automaticamente. Possui classes Infrequent Access para economia.

### EIP (Elastic IP)
Endereço IPv4 estático. Gratuito quando associado a uma instância em execução; cobra $0.005/hora (~$3.65/mês) quando não associado ou quando a instância está parada.

### ElastiCache
Serviço gerenciado de cache in-memory (Redis/Memcached). Reserved Nodes oferecem até 55% de desconto para uso contínuo.

### EventBridge
Barramento de eventos serverless. Usado em automações FinOps para disparar Lambda em horários específicos (ex: desligar instâncias à noite).

### Fargate
Motor de computação serverless para containers (ECS/EKS). Cobra por vCPU e memória por segundo. Savings Plans de Compute cobrem Fargate.

### FinOps
Prática operacional e cultural que maximiza o valor de negócio da nuvem através da colaboração entre tecnologia, finanças e negócios.

### Free Tier
Camada gratuita da AWS com três tipos: Always Free (ex: Lambda 1M requests/mês), 12 Months Free (ex: 750h EC2 t2.micro) e Trials de curta duração.

### Glacier
Classe de armazenamento S3 para arquivamento de longo prazo. Glacier Instant Retrieval, Flexible Retrieval e Deep Archive oferecem custos progressivamente menores com tempos de acesso maiores.

### gp2
Tipo de volume EBS SSD de propósito geral (geração anterior). Performance escala com tamanho do volume (3 IOPS/GB). Sendo substituído pelo gp3.

### gp3
Tipo de volume EBS SSD de propósito geral (geração atual). 20% mais barato que gp2, com 3.000 IOPS e 125 MB/s de baseline independente do tamanho.

### Graviton
Processadores ARM desenvolvidos pela AWS. Instâncias Graviton (t4g, m7g, c7g) oferecem até 40% melhor relação custo-performance vs equivalentes x86.

### IAM (Identity and Access Management)
Serviço de controle de acesso. Em FinOps, usado para exigir tags na criação de recursos e restringir tipos de instância permitidos.

### Instance Scheduler
Solução AWS que liga e desliga instâncias EC2 e RDS em horários programados. Pode economizar até 70% em ambientes de desenvolvimento que rodam só em horário comercial.

### Intelligent-Tiering
Classe S3 que move objetos automaticamente entre tiers de acesso frequente e infrequente com base no padrão de uso. Sem custo de retrieval, apenas taxa de monitoramento.

### Lambda
Serviço de computação serverless. Cobra por número de requisições e duração (GB-segundo). Inclui 1M requests e 400.000 GB-s/mês no Free Tier.

### Landing Zone
Ambiente multi-account pré-configurado com boas práticas de segurança, logging e governança. Implementado via Control Tower ou manualmente.

### Lifecycle Policy
Regra que automatiza transições de objetos S3 entre classes de armazenamento ou expiração após determinado período. Essencial para otimização de custos de storage.

### NAT Gateway
Serviço gerenciado que permite instâncias em subnets privadas acessarem a internet. Custa ~$32/mês fixo + $0.045/GB processado.

### On-Demand
Modelo de precificação padrão da AWS — pague por hora/segundo sem compromisso. Mais flexível, porém mais caro que Reserved ou Spot.

### Organizations
Serviço para gerenciar múltiplas contas AWS centralmente. Habilita Consolidated Billing, SCPs e compartilhamento de descontos entre contas.

### OU (Organizational Unit)
Agrupamento lógico de contas dentro do AWS Organizations. Permite aplicar SCPs e políticas de forma hierárquica (ex: OU-Produção, OU-Desenvolvimento).

### PrivateLink
Tecnologia que permite acessar serviços AWS ou de terceiros via rede privada, sem expor tráfego à internet. Interface VPC Endpoints usam PrivateLink.

### QuickSight
Serviço de BI serverless para criar dashboards interativos. Usado para visualizar dados do CUR com gráficos customizados e compartilhar com stakeholders.

### Redshift
Data warehouse gerenciado. Pode ser usado para analisar CUR em grande escala. Reserved Nodes oferecem até 75% de desconto.

### Region
Área geográfica com múltiplas AZs. Preços variam entre regiões — us-east-1 geralmente é a mais barata. Escolha a região mais próxima dos usuários com melhor custo.

### Reserved Instance (RI)
Compromisso de 1 ou 3 anos com um tipo específico de instância em troca de desconto de até 72%. Menos flexível que Savings Plans, mas com desconto ligeiramente maior.

### Right-sizing
Processo de ajustar recursos ao tamanho adequado para a carga real. Reduzir uma instância subutilizada de m5.xlarge para m5.large corta o custo pela metade.

### Route 53
Serviço de DNS da AWS. Cobra por hosted zone ($0.50/mês) e por consultas. Políticas de roteamento podem direcionar tráfego para regiões mais baratas.

### S3 (Simple Storage Service)
Armazenamento de objetos com múltiplas classes de custo. Cobra por GB armazenado, requisições e transferência de dados. Lifecycle Policies otimizam custos automaticamente.

### Savings Plan
Compromisso de gasto por hora ($/hora) por 1 ou 3 anos em troca de desconto. Mais flexível que RIs — Compute Savings Plans cobrem EC2, Fargate e Lambda em qualquer região.

### SCP (Service Control Policy)
Política aplicada no Organizations que define o máximo de permissões para contas-membro. Usada como guardrail para impedir ações que geram custos desnecessários.

### Serverless
Modelo onde a AWS gerencia toda a infraestrutura. Você paga apenas pelo uso real (requisições, duração). Inclui Lambda, Fargate, DynamoDB On-Demand, S3, etc.

### Showback
Similar ao chargeback, mas sem cobrança real — apenas mostra aos times quanto eles gastam para criar consciência de custos. Primeiro passo antes do chargeback.

### SNS (Simple Notification Service)
Serviço de mensageria pub/sub. Usado em FinOps para enviar alertas de Budget, Anomaly Detection e automações via email, SMS ou Lambda.

### Spot Instance
Instância EC2 com até 90% de desconto usando capacidade ociosa da AWS. Pode ser interrompida com 2 minutos de aviso. Ideal para workloads tolerantes a falhas.

### Tags
Pares chave-valor atribuídos a recursos AWS. Base fundamental do FinOps para alocação de custos, automação e governança.

### Transit Gateway
Hub central que conecta VPCs e redes on-premises. Cobra por hora + GB processado. Consolida conexões e pode reduzir custos vs múltiplos VPC Peerings.

### Trusted Advisor
Serviço que analisa sua conta e recomenda melhorias em custo, performance, segurança, tolerância a falhas e service limits. Checks completos requerem Business Support.

### VPC (Virtual Private Cloud)
Rede virtual isolada na AWS. A VPC em si é gratuita, mas componentes como NAT Gateway, VPN e tráfego entre AZs geram custos significativos.

### VPC Endpoint
Conexão privada entre VPC e serviços AWS sem usar internet. Gateway Endpoints (S3, DynamoDB) são gratuitos. Interface Endpoints cobram por hora + GB.

### Well-Architected Framework
Framework da AWS com 6 pilares de boas práticas, incluindo o pilar de Otimização de Custos. O Well-Architected Tool permite autoavaliação gratuita de workloads.

---

> 📚 **Referência**: [AWS Glossary](https://docs.aws.amazon.com/general/latest/gr/glos-chap.html) | [FinOps Terminology](https://www.finops.org/framework/terminology/)
