# =============================================================================
# Landing Zone FinOps - Recursos Principais
# Módulo completo para configurar FinOps na conta AWS
# =============================================================================

data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id

  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "landing-zone-finops"
  }
}

# =============================================================================
# SNS - Tópico para alertas de custo
# =============================================================================

resource "aws_sns_topic" "finops_alerts" {
  name = "finops-cost-alerts-${var.environment}"
  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.finops_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# =============================================================================
# AWS Budget - Budget mensal com 3 alertas (50%, 80%, 100%)
# =============================================================================

resource "aws_budgets_budget" "monthly" {
  name         = "finops-monthly-budget-${var.environment}"
  budget_type  = "COST"
  limit_amount = var.budget_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Alerta em 50% - previsão de gasto
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }

  # Alerta em 80% - gasto real
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Alerta em 100% - gasto real atingiu o limite
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}

# =============================================================================
# Cost Anomaly Detection - Monitor por serviço + subscription
# =============================================================================

resource "aws_ce_anomaly_monitor" "by_service" {
  name              = "finops-anomaly-monitor-${var.environment}"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"

  tags = local.common_tags
}

resource "aws_ce_anomaly_subscription" "alerts" {
  name = "finops-anomaly-subscription-${var.environment}"

  monitor_arn_list = [aws_ce_anomaly_monitor.by_service.arn]

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
    address = aws_sns_topic.finops_alerts.arn
  }

  tags = local.common_tags
}

# =============================================================================
# S3 Bucket - Armazenamento do CUR com lifecycle
# =============================================================================

resource "aws_s3_bucket" "cur" {
  bucket = var.cur_bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "cur" {
  bucket = aws_s3_bucket.cur.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cur" {
  bucket = aws_s3_bucket.cur.id

  # Transição para IA em 90 dias, Glacier em 365 dias
  rule {
    id     = "cur-lifecycle"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cur" {
  bucket = aws_s3_bucket.cur.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cur" {
  bucket = aws_s3_bucket.cur.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Política do bucket para permitir que o serviço CUR escreva
resource "aws_s3_bucket_policy" "cur" {
  bucket = aws_s3_bucket.cur.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCURDelivery"
        Effect    = "Allow"
        Principal = { Service = "billingreports.amazonaws.com" }
        Action    = ["s3:GetBucketAcl", "s3:GetBucketPolicy"]
        Resource  = aws_s3_bucket.cur.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
            "aws:SourceArn"     = "arn:aws:cur:us-east-1:${local.account_id}:definition/*"
          }
        }
      },
      {
        Sid       = "AllowCURWrite"
        Effect    = "Allow"
        Principal = { Service = "billingreports.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cur.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
            "aws:SourceArn"     = "arn:aws:cur:us-east-1:${local.account_id}:definition/*"
          }
        }
      }
    ]
  })
}

# =============================================================================
# CloudWatch Dashboard - Billing estimado + top serviços
# =============================================================================

resource "aws_cloudwatch_dashboard" "finops" {
  dashboard_name = "FinOps-Billing-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Custo Estimado Total (USD)"
          region = "us-east-1"
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "Currency", "USD", { stat = "Maximum", period = 86400 }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Custo por Serviço - EC2"
          region = "us-east-1"
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "ServiceName", "Amazon Elastic Compute Cloud - Compute", "Currency", "USD", { stat = "Maximum", period = 86400 }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "Custo por Serviço - S3"
          region = "us-east-1"
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "ServiceName", "Amazon Simple Storage Service", "Currency", "USD", { stat = "Maximum", period = 86400 }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "Custo por Serviço - RDS"
          region = "us-east-1"
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "ServiceName", "Amazon Relational Database Service", "Currency", "USD", { stat = "Maximum", period = 86400 }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "Custo por Serviço - Lambda"
          region = "us-east-1"
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "ServiceName", "AWS Lambda", "Currency", "USD", { stat = "Maximum", period = 86400 }]
          ]
          view = "timeSeries"
        }
      }
    ]
  })
}

# =============================================================================
# CloudWatch Alarm - Billing acima do threshold
# =============================================================================

resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name          = "finops-billing-alarm-${var.environment}"
  alarm_description   = "Alarme quando billing estimado ultrapassa ${var.billing_alarm_threshold} USD"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 86400
  statistic           = "Maximum"
  threshold           = var.billing_alarm_threshold

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.finops_alerts.arn]
  ok_actions    = [aws_sns_topic.finops_alerts.arn]

  tags = local.common_tags
}

# =============================================================================
# IAM Policy - Exige tags ao criar instâncias EC2
# =============================================================================

resource "aws_iam_policy" "require_tags_ec2" {
  name        = "finops-require-tags-ec2-${var.environment}"
  description = "Exige tags obrigatórias ao criar instâncias EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyEC2WithoutRequiredTags"
        Effect   = "Deny"
        Action   = "ec2:RunInstances"
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          "Null" = {
            for key, _ in var.required_tags : "aws:RequestTag/${key}" => "true"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# =============================================================================
# IAM Policy - Restringe tipos de instância permitidos
# =============================================================================

resource "aws_iam_policy" "restrict_instance_types" {
  name        = "finops-restrict-instance-types-${var.environment}"
  description = "Permite apenas tipos de instância aprovados para controle de custos"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyUnapprovedInstanceTypes"
        Effect   = "Deny"
        Action   = "ec2:RunInstances"
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          "ForAnyValue:StringNotEquals" = {
            "ec2:InstanceType" = var.allowed_instance_types
          }
        }
      }
    ]
  })

  tags = local.common_tags
}
