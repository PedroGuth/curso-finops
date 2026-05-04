# Scripts de Automação FinOps 🤖

Scripts prontos para identificar e corrigir desperdícios comuns na AWS.

## Pré-requisitos

- AWS CLI configurado (`aws configure`)
- `jq` instalado
- Permissões IAM adequadas (EC2, EBS)

## Scripts Disponíveis

| Script | O que faz | Economia estimada |
|--------|-----------|-------------------|
| `migrate-gp2-to-gp3.sh` | Migra volumes EBS de gp2 para gp3 | ~20% no custo de EBS |
| `cleanup-unused-eips.sh` | Libera Elastic IPs não associados | ~$3.65/mês por EIP |
| `cleanup-orphan-snapshots.sh` | Remove snapshots de volumes deletados | $0.05/GB/mês |

## Uso

Todos os scripts suportam `--dry-run` para visualizar sem alterar nada:

```bash
# Ver o que seria migrado
./scripts/migrate-gp2-to-gp3.sh --dry-run

# Executar em uma região específica
./scripts/cleanup-unused-eips.sh --region sa-east-1

# Limpar snapshots órfãos
./scripts/cleanup-orphan-snapshots.sh --dry-run
```

> ⚠️ Sempre execute com `--dry-run` primeiro para revisar as alterações.
