# Terraform para FinOps na AWS

Módulos Terraform prontos para implementar práticas de FinOps na AWS.

## Módulos Disponíveis

| Módulo | Descrição |
|--------|-----------|
| `budget-alerts/` | AWS Budget com alertas (50%, 80%, 100%) + Cost Anomaly Detection |
| `s3-lifecycle/` | S3 com lifecycle rules para otimizar custos de armazenamento |
| `instance-scheduler/` | Liga/desliga EC2 por horário usando Lambda + EventBridge |
| `vpc-endpoints/` | VPC Endpoints Gateway para S3 e DynamoDB (economia vs NAT Gateway) |

## Como Usar

```bash
# 1. Entre no diretório do módulo desejado
cd terraform/budget-alerts/

# 2. Inicialize o Terraform (baixa providers e módulos)
terraform init

# 3. Visualize o plano de execução
terraform plan

# 4. Aplique as mudanças
terraform apply

# 5. Para destruir os recursos criados
terraform destroy
```

## Variáveis

Cada módulo possui variáveis com valores padrão. Para customizar, crie um arquivo `terraform.tfvars`:

```hcl
# Exemplo para budget-alerts/
budget_amount = 100.0
email         = "financeiro@empresa.com"
budget_name   = "budget-producao"
```

Ou passe via linha de comando:

```bash
terraform apply -var="budget_amount=200" -var="email=time@empresa.com"
```

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- AWS CLI configurado com credenciais válidas
- Permissões IAM adequadas para cada módulo

## Estrutura

```
terraform/
├── README.md
├── budget-alerts/
│   └── main.tf
├── s3-lifecycle/
│   └── main.tf
├── instance-scheduler/
│   └── main.tf
└── vpc-endpoints/
    └── main.tf
```
