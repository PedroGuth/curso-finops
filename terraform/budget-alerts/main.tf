# ============================================================
# Budget Alerts - Alertas de orçamento e detecção de anomalias
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

variable "budget_amount" {
  description = "Valor mensal do orçamento em USD"
  type        = number
  default     = 50.0
}

variable "email" {
  description = "E-mail para receber notificações de alerta"
  type        = string
  default     = "finops@empresa.com"
}

variable "budget_name" {
  description = "Nome do budget na AWS"
  type        = string
  default     = "budget-mensal-finops"
}

variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

# ------------------------------
# SNS Topic para notificações
# ------------------------------

resource "aws_sns_topic" "budget_alerts" {
  name = "${var.budget_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = var.email
}

# Política para permitir que o Budgets publique no SNS
resource "aws_sns_topic_policy" "budget_alerts" {
  arn = aws_sns_topic.budget_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "budgets.amazonaws.com" }
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.budget_alerts.arn
      }
    ]
  })
}

# ------------------------------
# AWS Budget com alertas em 50%, 80% e 100%
# ------------------------------

resource "aws_budgets_budget" "mensal" {
  name         = var.budget_name
  budget_type  = "COST"
  limit_amount = var.budget_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Alerta em 50% do orçamento
  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 50
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.budget_alerts.arn]
  }

  # Alerta em 80% do orçamento
  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.budget_alerts.arn]
  }

  # Alerta em 100% do orçamento
  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.budget_alerts.arn]
  }
}

# ------------------------------
# Cost Anomaly Detection
# ------------------------------

resource "aws_ce_anomaly_monitor" "principal" {
  name              = "${var.budget_name}-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "alertas" {
  name = "${var.budget_name}-anomaly-subscription"

  monitor_arn_list = [aws_ce_anomaly_monitor.principal.arn]

  frequency = "DAILY"

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = ["10"]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }

  subscriber {
    type    = "SNS"
    address = aws_sns_topic.budget_alerts.arn
  }
}

# ------------------------------
# Outputs
# ------------------------------

output "sns_topic_arn" {
  description = "ARN do tópico SNS para alertas de budget"
  value       = aws_sns_topic.budget_alerts.arn
}

output "budget_id" {
  description = "ID do budget criado"
  value       = aws_budgets_budget.mensal.id
}

output "anomaly_monitor_arn" {
  description = "ARN do monitor de anomalias de custo"
  value       = aws_ce_anomaly_monitor.principal.arn
}
