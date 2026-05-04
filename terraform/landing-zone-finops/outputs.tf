# =============================================================================
# Landing Zone FinOps - Outputs
# =============================================================================

output "sns_topic_arn" {
  description = "ARN do tópico SNS para alertas de custo"
  value       = aws_sns_topic.finops_alerts.arn
}

output "budget_name" {
  description = "Nome do budget mensal criado"
  value       = aws_budgets_budget.monthly.name
}

output "cur_bucket_name" {
  description = "Nome do bucket S3 para CUR"
  value       = aws_s3_bucket.cur.id
}

output "dashboard_name" {
  description = "Nome do dashboard CloudWatch de billing"
  value       = aws_cloudwatch_dashboard.finops.dashboard_name
}

output "anomaly_monitor_arn" {
  description = "ARN do monitor de anomalias de custo"
  value       = aws_ce_anomaly_monitor.by_service.arn
}
