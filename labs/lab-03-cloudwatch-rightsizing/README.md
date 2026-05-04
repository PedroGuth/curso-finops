# Lab 03 – Redimensionamento EC2 com Métricas do CloudWatch

## Objetivo

Usar métricas do CloudWatch (CPU, memória e disco) para identificar instâncias EC2 superdimensionadas e redimensioná-las, reduzindo custos sem impactar performance. Configurar alarmes para detecção contínua de subutilização.

## Serviços Utilizados

| Serviço | Função no Lab |
|---------|---------------|
| CloudWatch | Coletar métricas e configurar alarmes |
| EC2 | Instâncias-alvo do redimensionamento |
| Resource Groups | Agrupar recursos por tag para visão consolidada |
| Systems Manager | Instalar e configurar o agente CloudWatch remotamente |

## Arquitetura

Instâncias EC2 de produção possuem o agente do CloudWatch instalado via Systems Manager, coletando métricas customizadas de memória e disco (que não são nativas do EC2). As métricas são enviadas ao CloudWatch, onde dashboards e alarmes permitem identificar instâncias com baixa utilização. Um alarme SNS notifica a equipe quando CPU fica abaixo de 10% por 24h consecutivas, sinalizando oportunidade de rightsizing.

```mermaid
graph TB
    subgraph Resource Group<br/>tag: Environment=Production
        EC2A[🖥️ EC2 Instância A]
        EC2B[🖥️ EC2 Instância B]
        EC2C[🖥️ EC2 Instância C]
    end

    EC2A -->|CloudWatch Agent| CW[📊 CloudWatch<br/>Métricas: CPU, Memória, Disco]
    EC2B -->|CloudWatch Agent| CW
    EC2C -->|CloudWatch Agent| CW

    CW -->|CPU < 10% por 24h| ALARM[🔔 CloudWatch Alarm]
    ALARM -->|Notificação| SNS[📧 SNS Topic<br/>rightsizing-alerts]
    SNS -->|E-mail| TEAM[👥 Equipe FinOps]
```

## Passo a Passo

### 1. Criar Resource Group

1. Acesse **Resource Groups & Tag Editor > Create Resource Group**.
2. Tipo: **Tag based**.
3. Tipo de recurso: `AWS::EC2::Instance`.
4. Filtro de tag: `Environment` = `Production`.
5. Nomeie como `production-instances`.
6. Crie o grupo.

> Isso permite visualizar e gerenciar todas as instâncias de produção em um só lugar.

### 2. Instalar Agente do CloudWatch via Systems Manager

1. Acesse **Systems Manager > Run Command**.
2. Clique em **Run command**.
3. Pesquise o documento `AWS-ConfigureAWSPackage`.
4. Configure:
   - Action: `Install`
   - Name: `AmazonCloudWatchAgent`
5. Em **Targets**, selecione **Specify resource group** e escolha `production-instances`.
6. Execute o comando.
7. Aguarde o status mudar para **Success** em todas as instâncias.

> Pré-requisito: as instâncias precisam ter o SSM Agent instalado e uma IAM Role com a policy `CloudWatchAgentServerPolicy`.

### 3. Configurar o Agente para Coletar Métricas

1. No **Systems Manager > Parameter Store**, crie um parâmetro:
   - Nome: `/cloudwatch-agent/config`
   - Tipo: String
   - Valor:

```json
{
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["disk_used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      }
    },
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}"
    }
  }
}
```

2. Execute outro **Run Command** com o documento `AmazonCloudWatch-ManageAgent`:
   - Action: `configure`
   - Optional Configuration Source: `ssm`
   - Optional Configuration Location: `/cloudwatch-agent/config`
   - Target: resource group `production-instances`

### 4. Analisar Métricas no Console CloudWatch

1. Acesse **CloudWatch > Metrics > All metrics**.
2. Navegue até o namespace **CWAgent**.
3. Visualize:
   - **mem_used_percent** por InstanceId
   - **disk_used_percent** por InstanceId
4. Navegue até **AWS/EC2** para ver **CPUUtilization**.
5. Crie um **Dashboard** com widgets para CPU, memória e disco lado a lado.
6. Defina o período para **2 semanas** para ter uma visão representativa.

### 5. Identificar Instâncias Superdimensionadas

Critérios de subutilização:

| Métrica | Limiar | Indica |
|---------|--------|--------|
| CPUUtilization | < 20% média em 14 dias | CPU superdimensionada |
| mem_used_percent | < 30% média em 14 dias | Memória superdimensionada |
| disk_used_percent | < 30% | Disco superdimensionado |

Anote as instâncias que atendem a esses critérios. Exemplo:
- `i-0abc123` – m5.xlarge com CPU média de 8% e memória de 22% → candidata a `m5.large` ou `t3.large`.

### 6. Criar Alarme CloudWatch

1. Vá em **CloudWatch > Alarms > Create alarm**.
2. Selecione a métrica `AWS/EC2 > Per-Instance Metrics > CPUUtilization`.
3. Escolha a instância-alvo.
4. Configure:
   - Estatística: **Average**
   - Período: **1 hora**
   - Condição: **Lower than 10**
   - Datapoints to alarm: **24 de 24** (24h consecutivas)
5. Ação de notificação: selecione ou crie um tópico SNS (ex: `rightsizing-alerts`).
6. Nomeie como `low-cpu-i-0abc123`.
7. Crie o alarme.

### 7. Redimensionar a Instância

1. No console EC2, selecione a instância identificada.
2. Clique em **Instance state > Stop instance**. Aguarde o estado `stopped`.
3. Clique em **Actions > Instance settings > Change instance type**.
4. Selecione o novo tipo (ex: de `m5.xlarge` para `m5.large`).
5. Clique em **Apply**.
6. Inicie a instância: **Instance state > Start instance**.

Via CLI:

```bash
INSTANCE_ID="i-0abc123def456"

aws ec2 stop-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --instance-type '{"Value":"m5.large"}'
aws ec2 start-instances --instance-ids $INSTANCE_ID
```

### 8. Verificar Métricas Após Redimensionamento

1. Aguarde 24-48h para coletar dados representativos.
2. No dashboard CloudWatch, compare as métricas antes e depois:
   - CPU deve subir (ex: de 8% para 15-20%)
   - Memória deve subir (ex: de 22% para 40-50%)
3. Se a utilização ficar acima de 80% consistentemente, considere voltar ao tipo anterior.
4. Atualize o alarme se necessário.

## Dicas de Economia

- **Rightsizing é a ação de maior impacto em FinOps.** A AWS estima que 30-40% das instâncias estão superdimensionadas.
- **Métricas de memória não são nativas** — sem o agente CloudWatch, você só vê CPU e rede. Instale o agente para ter visibilidade real.
- **Use o AWS Compute Optimizer** como complemento — ele analisa 14 dias de métricas e sugere tipos ideais automaticamente.
- **Reduza um tamanho por vez** (ex: xlarge → large). Mudanças drásticas podem causar problemas de performance.
- **Considere a família da instância** — se CPU é baixa mas memória é alta, migre para família R (memory-optimized) em vez de apenas reduzir tamanho.
- **Custo do agente CloudWatch**: métricas customizadas custam US$ 0,30/métrica/mês. Com 2 métricas por instância, o custo é mínimo comparado à economia do rightsizing.
- **Automatize com Lambda** — crie uma função que redimensiona automaticamente quando o alarme dispara (após aprovação via SNS).
