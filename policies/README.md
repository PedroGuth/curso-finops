# IAM Policies e SCPs para FinOps 🔒

Exemplos de políticas para governança de custos na AWS.

## IAM Policies

| Arquivo | Descrição |
|---------|-----------|
| `require-tags-ec2.json` | Exige tags (Department, Application, Environment) ao criar instâncias EC2 |
| `restrict-instance-types.json` | Permite apenas tipos de instância aprovados (família t3, t3a, m6i) |
| `abac-department-access.json` | Controle de acesso baseado em atributos — usuários só gerenciam recursos do próprio departamento |

## Service Control Policies (SCPs)

| Arquivo | Descrição |
|---------|-----------|
| `scp-deny-regions.json` | Bloqueia uso de regiões não autorizadas (permite apenas us-east-1 e sa-east-1) |
| `scp-deny-expensive-resources.json` | Impede criação de instâncias EC2 e RDS muito caras (p4d, p5, x2idn, etc.) |

## Como Usar

### IAM Policy

```bash
aws iam create-policy \
  --policy-name RequireTagsEC2 \
  --policy-document file://policies/require-tags-ec2.json
```

### SCP (requer AWS Organizations)

```bash
aws organizations create-policy \
  --name "DenyNonApprovedRegions" \
  --type SERVICE_CONTROL_POLICY \
  --content file://policies/scp-deny-regions.json \
  --description "Bloqueia regiões não autorizadas"
```

> ⚠️ Teste SCPs em uma OU de sandbox antes de aplicar em produção.
