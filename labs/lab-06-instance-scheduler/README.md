# Lab 06 – Reduzir Custos de Computação com AWS Instance Scheduler

## Objetivo

Reduzir custos de EC2 e RDS usando o AWS Instance Scheduler para ligar e desligar instâncias automaticamente fora do horário comercial, economizando até ~70% em ambientes de desenvolvimento e teste.

## Serviços Utilizados

- AWS Instance Scheduler
- AWS CloudFormation
- Amazon DynamoDB
- AWS Lambda
- Amazon EventBridge
- Amazon EC2
- Amazon RDS

## Arquitetura

O EventBridge aciona uma função Lambda a cada 5 minutos. A Lambda consulta uma tabela DynamoDB que contém os schedules (períodos e horários configurados). Com base nas tags das instâncias EC2 e RDS, a Lambda liga ou desliga os recursos conforme o horário definido.

```
EventBridge (a cada 5 min) → Lambda (Instance Scheduler)
                                  ↓
                          DynamoDB (schedules/periods)
                                  ↓
                    EC2/RDS com tag "Schedule=office-hours"
                         Liga 8h → Desliga 18h (seg-sex)
```

## Passo a Passo

### 1. Deploy do template CloudFormation

```bash
aws cloudformation create-stack \
  --stack-name instance-scheduler \
  --template-url https://s3.amazonaws.com/solutions-reference/aws-instance-scheduler-on-aws/latest/aws-instance-scheduler-on-aws.template \
  --parameters \
    ParameterKey=SchedulingActive,ParameterValue=Yes \
    ParameterKey=ScheduledServices,ParameterValue=Both \
    ParameterKey=Regions,ParameterValue=<REGION> \
    ParameterKey=DefaultTimezone,ParameterValue=America/Sao_Paulo \
    ParameterKey=SchedulerFrequency,ParameterValue=5 \
  --capabilities CAPABILITY_IAM
```

Aguarde o stack ficar com status `CREATE_COMPLETE`.

### 2. Configurar período: horário comercial

```bash
# Instalar o CLI do Instance Scheduler
pip install aws-instance-scheduler-cli

# Criar período de horário comercial
scheduler-cli create-period \
  --stack instance-scheduler \
  --name office-hours-period \
  --begintime 08:00 \
  --endtime 18:00 \
  --weekdays mon-fri
```

### 3. Criar schedule usando o CLI

```bash
scheduler-cli create-schedule \
  --stack instance-scheduler \
  --name office-hours \
  --periods office-hours-period \
  --timezone America/Sao_Paulo
```

### 4. Adicionar tag nas instâncias EC2 e RDS

```bash
# EC2
aws ec2 create-tags \
  --resources i-xxxxxxxxxxxxxxxxx i-yyyyyyyyyyyyyyyyy \
  --tags Key=Schedule,Value=office-hours

# RDS
aws rds add-tags-to-resource \
  --resource-name arn:aws:rds:<REGION>:<ACCOUNT_ID>:db:meu-banco-dev \
  --tags Key=Schedule,Value=office-hours
```

### 5. Aguardar o EventBridge acionar a Lambda

O scheduler roda a cada 5 minutos. Verifique os logs:

```bash
# Encontrar o log group
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/instance-scheduler

# Ver execuções recentes
aws logs tail /aws/lambda/<FUNCTION_NAME> --since 10m
```

### 6. Verificar que instâncias são paradas fora do horário

```bash
# Verificar estado das instâncias EC2
aws ec2 describe-instances \
  --filters "Name=tag:Schedule,Values=office-hours" \
  --query "Reservations[].Instances[].[InstanceId,State.Name]" \
  --output table

# Verificar estado do RDS
aws rds describe-db-instances \
  --db-instance-identifier meu-banco-dev \
  --query "DBInstances[].DBInstanceStatus"
```

### 7. Verificar métricas no CloudWatch

O Instance Scheduler publica métricas customizadas:

- `StartedInstances` — instâncias ligadas pelo scheduler
- `StoppedInstances` — instâncias desligadas pelo scheduler

```bash
aws cloudwatch get-metric-statistics \
  --namespace InstanceScheduler \
  --metric-name StoppedInstances \
  --start-time 2026-05-01T00:00:00Z \
  --end-time 2026-05-04T23:59:59Z \
  --period 86400 \
  --statistics Sum
```

### 8. Calcular economia

| Cenário | Horas/semana | Custo (t3.large) |
|---------|-------------|-----------------|
| Sem scheduler (24/7) | 168h | ~$60/mês |
| Com scheduler (seg-sex 8h-18h) | 50h | ~$18/mês |
| **Economia** | **118h** | **~70%** |

Para 10 instâncias de dev/test:
- Antes: ~$600/mês
- Depois: ~$180/mês
- **Economia: ~$420/mês (~$5.000/ano)**

## Dicas de Economia

- **Comece pelos ambientes de dev/test** — produção geralmente precisa rodar 24/7.
- **Crie schedules diferentes** — dev (8h-18h seg-sex), staging (6h-22h seg-sex), demo (sob demanda).
- **RDS demora mais para ligar** — considere iniciar 15 min antes do horário de trabalho.
- **Combine com Reserved Instances** — scheduler reduz On-Demand; RI reduz o custo base.
- **Use o tag `ScheduleMessage`** — o scheduler adiciona essa tag com info de quando vai ligar/desligar.
- **Cuidado com Auto Scaling Groups** — o scheduler não gerencia ASGs diretamente. Use `min=0/max=0` via scheduled actions para o mesmo efeito.
- **Monitore exceções** — se alguém precisa trabalhar fora do horário, crie um schedule `override` ou remova a tag temporariamente.
- **Não esqueça dos discos** — instâncias paradas não cobram computação, mas EBS continua cobrando.
