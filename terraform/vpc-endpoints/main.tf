# ============================================================
# VPC Endpoints Gateway - Economia eliminando tráfego pelo NAT Gateway
# ============================================================
#
# 💰 ECONOMIA: VPC Endpoints Gateway são GRATUITOS!
# Um NAT Gateway custa ~$32/mês + $0.045/GB de dados processados.
# Com endpoints Gateway, o tráfego para S3 e DynamoDB vai direto
# pela rede privada da AWS sem passar pelo NAT Gateway.
#
# Exemplo: 1TB/mês para S3 via NAT = $32 + $45 = $77/mês
#          1TB/mês para S3 via Endpoint = $0/mês
#
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

variable "vpc_id" {
  description = "ID da VPC onde criar os endpoints"
  type        = string
  default     = ""
}

variable "route_table_ids" {
  description = "Lista de IDs das route tables para associar aos endpoints"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

# ------------------------------
# VPC Endpoint Gateway para S3
# Elimina custo de NAT Gateway para tráfego S3
# ------------------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = {
    Name      = "vpce-s3-gateway"
    ManagedBy = "terraform"
    Purpose   = "finops-economia-nat"
  }
}

# ------------------------------
# VPC Endpoint Gateway para DynamoDB
# Elimina custo de NAT Gateway para tráfego DynamoDB
# ------------------------------

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = {
    Name      = "vpce-dynamodb-gateway"
    ManagedBy = "terraform"
    Purpose   = "finops-economia-nat"
  }
}

# ------------------------------
# Outputs
# ------------------------------

output "s3_endpoint_id" {
  description = "ID do VPC Endpoint para S3"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "ID do VPC Endpoint para DynamoDB"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "economia_estimada" {
  description = "Economia estimada ao usar endpoints Gateway vs NAT Gateway"
  value       = "Mínimo ~$32/mês (custo fixo NAT) + $0.045/GB processado. Endpoints Gateway são gratuitos."
}
