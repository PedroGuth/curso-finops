# =============================================================================
# Landing Zone FinOps - Variáveis
# =============================================================================

variable "budget_amount" {
  description = "Valor mensal do budget em USD"
  type        = number
  default     = 100
}

variable "alert_email" {
  description = "E-mail para receber alertas de custo"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Ambiente deve ser: dev, staging ou prod."
  }
}

variable "allowed_instance_types" {
  description = "Lista de tipos de instância EC2 permitidos"
  type        = list(string)
  default     = ["t3.micro", "t3.small", "t3.medium", "t3a.micro", "t3a.small", "t3a.medium"]
}

variable "required_tags" {
  description = "Tags obrigatórias ao criar recursos EC2"
  type        = map(string)
  default = {
    Environment = "Ambiente (dev/staging/prod)"
    Project     = "Nome do projeto"
    Owner       = "Responsável pelo recurso"
  }
}

variable "billing_alarm_threshold" {
  description = "Threshold em USD para alarme de billing no CloudWatch"
  type        = number
  default     = 80
}

variable "cur_bucket_name" {
  description = "Nome do bucket S3 para armazenar o Cost and Usage Report"
  type        = string
}
