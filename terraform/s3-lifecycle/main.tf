# ============================================================
# S3 Lifecycle - Bucket com regras de ciclo de vida para FinOps
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

variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
  default     = "finops-lifecycle-bucket"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

# ------------------------------
# S3 Bucket
# ------------------------------

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Purpose     = "finops-lifecycle"
  }
}

# Versionamento habilitado para proteção de dados
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Criptografia server-side com AES-256 (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquear acesso público
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Regras de ciclo de vida para otimização de custos
# Standard → IA (30 dias) → Glacier (90 dias) → Expirar (365 dias)
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  depends_on = [aws_s3_bucket_versioning.this]

  rule {
    id     = "otimizacao-custos"
    status = "Enabled"

    # Mover para Infrequent Access após 30 dias
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Mover para Glacier após 90 dias
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Expirar objetos após 365 dias
    expiration {
      days = 365
    }

    # Limpar versões antigas para economizar
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# ------------------------------
# Outputs
# ------------------------------

output "bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  description = "Nome do bucket S3 criado"
  value       = aws_s3_bucket.this.id
}

output "bucket_region" {
  description = "Região do bucket"
  value       = aws_s3_bucket.this.region
}
