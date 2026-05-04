# Lambda Functions – Automação FinOps

Três funções Lambda em Python 3.12 para automação de FinOps na AWS.

## Funções

| Função | Trigger | Descrição |
|--------|---------|-----------|
| `auto-stop-idle-ec2` | EventBridge (cron) | Para instâncias com CPU < 5% nos últimos 7 dias |
| `tag-enforcer` | EventBridge (EC2 RunInstances) | Para instâncias sem tags obrigatórias |
| `cost-report-daily` | EventBridge (cron diário) | Envia relatório de custos dos últimos 7 dias |

---

## Deploy

### Opção 1: ZIP + AWS CLI

```bash
# Exemplo para auto-stop-idle-ec2
cd auto-stop-idle-ec2
zip handler.zip handler.py

aws lambda create-function \
  --function-name finops-auto-stop-idle-ec2 \
  --runtime python3.12 \
  --handler handler.handler \
  --role arn:aws:iam::ACCOUNT_ID:role/lambda-finops-role \
  --zip-file fileb://handler.zip \
  --timeout 300 \
  --environment "Variables={SNS_TOPIC_ARN=arn:aws:sns:us-east-1:ACCOUNT_ID:finops-alerts}"
```

### Opção 2: SAM (recomendado)

```yaml
# template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Globals:
  Function:
    Runtime: python3.12
    Timeout: 300

Resources:
  AutoStopIdleEC2:
    Type: AWS::Serverless::Function
    Properties:
      Handler: handler.handler
      CodeUri: auto-stop-idle-ec2/
      Environment:
        Variables:
          SNS_TOPIC_ARN: !Ref FinOpsAlertsTopic
      Events:
        Schedule:
          Type: Schedule
          Properties:
            Schedule: rate(1 day)

  TagEnforcer:
    Type: AWS::Serverless::Function
    Properties:
      Handler: handler.handler
      CodeUri: tag-enforcer/
      Environment:
        Variables:
          SNS_TOPIC_ARN: !Ref FinOpsAlertsTopic
      Events:
        EC2RunInstances:
          Type: EventBridgeRule
          Properties:
            Pattern:
              source: ["aws.ec2"]
              detail-type: ["AWS API Call via CloudTrail"]
              detail:
                eventName: ["RunInstances"]

  CostReportDaily:
    Type: AWS::Serverless::Function
    Properties:
      Handler: handler.handler
      CodeUri: cost-report-daily/
      Environment:
        Variables:
          SNS_TOPIC_ARN: !Ref FinOpsAlertsTopic
      Events:
        DailyCron:
          Type: Schedule
          Properties:
            Schedule: cron(0 8 * * ? *)

  FinOpsAlertsTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: finops-alerts
```

```bash
sam build
sam deploy --guided
```

---

## Variáveis de Ambiente

| Função | Variável | Obrigatória | Default | Descrição |
|--------|----------|-------------|---------|-----------|
| auto-stop-idle-ec2 | `SNS_TOPIC_ARN` | ✅ | — | Tópico SNS para alertas |
| auto-stop-idle-ec2 | `CPU_THRESHOLD` | ❌ | `5.0` | Limite de CPU (%) |
| auto-stop-idle-ec2 | `EVALUATION_DAYS` | ❌ | `7` | Dias para avaliar |
| tag-enforcer | `SNS_TOPIC_ARN` | ✅ | — | Tópico SNS para alertas |
| tag-enforcer | `REQUIRED_TAGS` | ❌ | `Department,Environment,Application` | Tags obrigatórias |
| cost-report-daily | `SNS_TOPIC_ARN` | ✅ | — | Tópico SNS para relatório |
| cost-report-daily | `REPORT_DAYS` | ❌ | `7` | Dias no relatório |

---

## Permissões IAM Mínimas

### auto-stop-idle-ec2

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StopInstances",
        "cloudwatch:GetMetricStatistics",
        "sns:Publish"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

### tag-enforcer

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StopInstances",
        "sns:Publish"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

### cost-report-daily

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ce:GetCostAndUsage",
        "sns:Publish"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

---

## Testando Localmente

```bash
# Instalar dependências (boto3 já vem no runtime Lambda)
pip install boto3

# Testar com evento vazio (auto-stop e cost-report)
python -c "from handler import handler; print(handler({}, None))"
```
