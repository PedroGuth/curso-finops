# Lab 02 – Ambientes Temporários com EC2 Auto Scaling

## Objetivo

Criar um ambiente de teste que liga automaticamente no horário comercial e desliga fora dele, usando Auto Scaling com ações programadas. Uma função Lambda mantém a AMI atualizada a partir de backups diários da instância de produção.

## Serviços Utilizados

| Serviço | Função no Lab |
|---------|---------------|
| EC2 Auto Scaling | Gerenciar ciclo de vida do ambiente de teste |
| AWS Backup | Criar snapshots diários da instância de produção |
| Lambda | Atualizar AMI no Launch Template automaticamente |
| EventBridge | Agendar execução da Lambda |

## Arquitetura

Uma VPC com sub-rede pública contém o servidor de produção (sempre ativo) e o servidor de teste (temporário). O fluxo funciona assim:

1. **AWS Backup** cria um snapshot diário da instância de produção.
2. Uma **função Lambda**, acionada por uma **regra EventBridge** com cron, busca a AMI mais recente gerada a partir do snapshot e atualiza o **Launch Template**.
3. O **grupo de Auto Scaling** possui ações programadas: escala para 1 instância às 8h e volta para 0 às 18h.
4. Quando o Auto Scaling escala, ele usa o Launch Template atualizado, garantindo que o ambiente de teste sempre reflita a produção.

## Passo a Passo

### 1. Criar Plano de Backup no AWS Backup

1. Acesse **AWS Backup > Backup plans > Create backup plan**.
2. Escolha **Build a new plan** e nomeie como `ProductionDailyBackup`.
3. Adicione uma regra de backup:
   - Frequência: **Daily**
   - Janela de backup: 03:00 UTC (fora do horário comercial)
   - Retenção: 7 dias
4. Em **Resource assignments**, adicione a instância de produção por tag (`Environment=Production`).
5. Salve o plano.

### 2. Criar AMI a Partir da Instância de Produção

1. No console EC2, selecione a instância de produção.
2. Clique em **Actions > Image and templates > Create image**.
3. Nomeie como `production-base-YYYY-MM-DD`.
4. Marque **No reboot** para evitar downtime.
5. Anote o AMI ID gerado.

### 3. Criar Launch Template

1. Vá em **EC2 > Launch Templates > Create launch template**.
2. Nomeie como `test-environment-template`.
3. Configure:
   - AMI: a AMI criada no passo anterior
   - Tipo de instância: `t3.micro` (teste não precisa de produção)
   - Key pair: selecione sua chave
   - Security group: selecione o grupo adequado
   - Em **Advanced details > IAM instance profile**, selecione um perfil se necessário
4. Crie o template.

### 4. Criar Grupo de Auto Scaling

1. Vá em **EC2 > Auto Scaling Groups > Create**.
2. Nomeie como `test-environment-asg`.
3. Selecione o Launch Template `test-environment-template`.
4. Selecione a VPC e sub-rede pública.
5. Configure capacidade:
   - Desejada: **0**
   - Mínima: **0**
   - Máxima: **2**
6. Não configure políticas de scaling (usaremos ações programadas).
7. Crie o grupo.

### 5. Criar Ações Programadas

1. Selecione o ASG e vá na aba **Automatic scaling > Scheduled actions**.
2. Crie a ação **scale-up**:
   - Nome: `start-test-environment`
   - Capacidade desejada: **1**
   - Recorrência: `0 8 * * MON-FRI` (8h, segunda a sexta)
   - Fuso: selecione o seu (ex: America/Sao_Paulo)
3. Crie a ação **scale-down**:
   - Nome: `stop-test-environment`
   - Capacidade desejada: **0**
   - Recorrência: `0 18 * * MON-FRI` (18h, segunda a sexta)

### 6. Criar Função Lambda

Crie uma função Lambda com Python 3.12 e a seguinte lógica:

```python
import boto3
from datetime import datetime

ec2 = boto3.client('ec2')
autoscaling = boto3.client('autoscaling')

LAUNCH_TEMPLATE_NAME = 'test-environment-template'
PRODUCTION_INSTANCE_TAG = 'Production'

def handler(event, context):
    # Buscar AMI mais recente da instância de produção
    images = ec2.describe_images(
        Owners=['self'],
        Filters=[
            {'Name': 'name', 'Values': ['production-base-*']},
            {'Name': 'state', 'Values': ['available']}
        ]
    )['Images']

    if not images:
        print('Nenhuma AMI encontrada.')
        return

    # Ordenar por data de criação (mais recente primeiro)
    latest_ami = sorted(images, key=lambda x: x['CreationDate'], reverse=True)[0]
    ami_id = latest_ami['ImageId']
    print(f'AMI mais recente: {ami_id} ({latest_ami["Name"]})')

    # Criar nova versão do Launch Template
    ec2.create_launch_template_version(
        LaunchTemplateName=LAUNCH_TEMPLATE_NAME,
        SourceVersion='$Latest',
        LaunchTemplateData={'ImageId': ami_id},
        VersionDescription=f'Updated AMI to {ami_id}'
    )

    # Definir nova versão como padrão
    ec2.modify_launch_template(
        LaunchTemplateName=LAUNCH_TEMPLATE_NAME,
        DefaultVersion='$Latest'
    )

    print(f'Launch Template atualizado com AMI {ami_id}')
    return {'statusCode': 200, 'ami': ami_id}
```

**Permissões IAM necessárias para a Lambda:**
- `ec2:DescribeImages`
- `ec2:CreateLaunchTemplateVersion`
- `ec2:ModifyLaunchTemplate`

### 7. Criar Regra EventBridge

1. Acesse **EventBridge > Rules > Create rule**.
2. Nomeie como `update-test-ami-daily`.
3. Tipo: **Schedule**.
4. Expressão cron: `cron(0 7 * * ? *)` (7h UTC, antes do scale-up).
5. Target: a função Lambda criada no passo anterior.
6. Crie a regra.

### 8. Testar o Fluxo Completo

1. Execute a Lambda manualmente no console para validar a atualização da AMI.
2. Altere temporariamente a ação programada de scale-up para os próximos 5 minutos.
3. Verifique se uma instância é criada com a AMI correta.
4. Confirme que às 18h (ou no horário configurado) a instância é terminada.
5. Verifique no AWS Backup se os snapshots estão sendo criados diariamente.

## Dicas de Economia

- **Ambientes de teste ligados 24/7 são desperdício puro.** Com este padrão, você paga apenas 10h/dia em dias úteis — economia de ~70% comparado a rodar 24/7.
- **Use `t3.micro` ou `t3.small` para teste** — não replique o tipo de instância de produção se não for necessário para os testes.
- **Defina retenção curta no AWS Backup** (7 dias) para não acumular snapshots desnecessários. Cada GB de snapshot EBS custa US$ 0,05/mês.
- **Considere Spot Instances no Launch Template** para ambientes de teste — economia de até 90% e interrupções são aceitáveis em teste.
- **Desligue nos feriados** — adicione exceções no cron ou use o AWS Instance Scheduler para calendários mais complexos.
