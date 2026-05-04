# ============================================================
# Instance Scheduler - Liga/desliga EC2 por horário via Lambda
# ============================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ------------------------------
# Variáveis
# ------------------------------

variable "schedule_name" {
  description = "Nome do scheduler"
  type        = string
  default     = "horario-comercial"
}

variable "start_cron" {
  description = "Expressão cron para iniciar instâncias (UTC)"
  type        = string
  default     = "cron(0 12 ? * MON-FRI *)" # 09:00 BRT
}

variable "stop_cron" {
  description = "Expressão cron para parar instâncias (UTC)"
  type        = string
  default     = "cron(0 21 ? * MON-FRI *)" # 18:00 BRT
}

variable "tag_key" {
  description = "Chave da tag para identificar instâncias"
  type        = string
  default     = "Schedule"
}

variable "tag_value" {
  description = "Valor da tag para identificar instâncias"
  type        = string
  default     = "horario-comercial"
}

variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

# ------------------------------
# IAM Role para Lambda
# ------------------------------

resource "aws_iam_role" "lambda" {
  name = "${var.schedule_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.schedule_name}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances", "ec2:StartInstances", "ec2:StopInstances"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ------------------------------
# CloudWatch Log Group
# ------------------------------

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.schedule_name}-scheduler"
  retention_in_days = 14
}

# ------------------------------
# Lambda Function (Python inline)
# ------------------------------

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    content  = <<-PYTHON
import boto3
import os

def handler(event, context):
    """Para ou inicia instâncias EC2 com base na tag e ação recebida."""
    ec2 = boto3.client('ec2', region_name=os.environ['AWS_REGION'])
    action = event.get('action', 'stop')
    tag_key = os.environ['TAG_KEY']
    tag_value = os.environ['TAG_VALUE']

    filters = [
        {'Name': f'tag:{tag_key}', 'Values': [tag_value]},
        {'Name': 'instance-state-name', 'Values': ['running' if action == 'stop' else 'stopped']}
    ]

    response = ec2.describe_instances(Filters=filters)
    instance_ids = [
        i['InstanceId']
        for r in response['Reservations']
        for i in r['Instances']
    ]

    if not instance_ids:
        print(f"Nenhuma instância encontrada para {action}")
        return {'statusCode': 200, 'body': 'Nenhuma instância encontrada'}

    if action == 'stop':
        ec2.stop_instances(InstanceIds=instance_ids)
        print(f"Parando instâncias: {instance_ids}")
    else:
        ec2.start_instances(InstanceIds=instance_ids)
        print(f"Iniciando instâncias: {instance_ids}")

    return {'statusCode': 200, 'body': f'{action} em {len(instance_ids)} instâncias'}
    PYTHON
    filename = "index.py"
  }
}

resource "aws_lambda_function" "scheduler" {
  function_name    = "${var.schedule_name}-scheduler"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  timeout          = 60
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      TAG_KEY   = var.tag_key
      TAG_VALUE = var.tag_value
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

# ------------------------------
# EventBridge Rules (cron)
# ------------------------------

# Regra para INICIAR instâncias
resource "aws_cloudwatch_event_rule" "start" {
  name                = "${var.schedule_name}-start"
  description         = "Inicia instâncias EC2 no horário configurado"
  schedule_expression = var.start_cron
}

resource "aws_cloudwatch_event_target" "start" {
  rule = aws_cloudwatch_event_rule.start.name
  arn  = aws_lambda_function.scheduler.arn

  input = jsonencode({ action = "start" })
}

resource "aws_lambda_permission" "start" {
  statement_id  = "AllowEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start.arn
}

# Regra para PARAR instâncias
resource "aws_cloudwatch_event_rule" "stop" {
  name                = "${var.schedule_name}-stop"
  description         = "Para instâncias EC2 no horário configurado"
  schedule_expression = var.stop_cron
}

resource "aws_cloudwatch_event_target" "stop" {
  rule = aws_cloudwatch_event_rule.stop.name
  arn  = aws_lambda_function.scheduler.arn

  input = jsonencode({ action = "stop" })
}

resource "aws_lambda_permission" "stop" {
  statement_id  = "AllowEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop.arn
}

# ------------------------------
# Outputs
# ------------------------------

output "lambda_function_arn" {
  description = "ARN da função Lambda do scheduler"
  value       = aws_lambda_function.scheduler.arn
}

output "start_rule_arn" {
  description = "ARN da regra EventBridge de início"
  value       = aws_cloudwatch_event_rule.start.arn
}

output "stop_rule_arn" {
  description = "ARN da regra EventBridge de parada"
  value       = aws_cloudwatch_event_rule.stop.arn
}
