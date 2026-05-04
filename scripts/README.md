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
| `find-idle-rds.sh` | Identifica instâncias RDS com 0 conexões | Varia por classe |
| `find-old-gen-instances.sh` | Lista EC2 de gerações antigas com sugestão | ~20% por instância |
| `finops-audit.sh` | Auditoria completa da conta (10 verificações) | Identifica tudo |

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

## Exemplo de Output

### migrate-gp2-to-gp3.sh --dry-run

```text
🔍 Buscando volumes gp2 na região us-east-1...

Encontrados 3 volumes gp2:

  VOLUME ID             TAMANHO    IOPS    NOME                    CUSTO ATUAL   CUSTO GP3    ECONOMIA
  vol-0a1b2c3d4e5f6789  100 GB     300     app-server-root         $10.00/mês    $8.00/mês    $2.00/mês
  vol-0f9e8d7c6b5a4321  500 GB     1500    database-data           $50.00/mês    $40.00/mês   $10.00/mês
  vol-0ab12cd34ef56789  200 GB     600     logs-volume             $20.00/mês    $16.00/mês   $4.00/mês

📊 Resumo:
   Total de volumes: 3
   Economia mensal estimada: $16.00/mês ($192.00/ano)

⚠️  Modo DRY-RUN: nenhuma alteração foi feita.
    Remova --dry-run para executar a migração.
```

### cleanup-unused-eips.sh

```text
🔍 Buscando Elastic IPs não associados na região us-east-1...

Encontrados 2 EIPs não utilizados:

  ALLOCATION ID              IP PÚBLICO        CRIADO EM       CUSTO MENSAL
  eipalloc-0a1b2c3d4e5f6789  54.233.100.42     2025-08-15      $3.65/mês
  eipalloc-0f9e8d7c6b5a4321  18.230.55.101     2025-11-02      $3.65/mês

📊 Resumo:
   Total de EIPs ociosos: 2
   Custo mensal desperdiçado: $7.30/mês ($87.60/ano)

✅ 2 Elastic IPs liberados com sucesso.
```

### cleanup-orphan-snapshots.sh --dry-run

```text
🔍 Buscando snapshots órfãos na região us-east-1...
   (snapshots cujo volume de origem não existe mais)

Encontrados 5 snapshots órfãos:

  SNAPSHOT ID               TAMANHO   VOLUME ORIGINAL         CRIADO EM       DESCRIÇÃO
  snap-0a1b2c3d4e5f6789     50 GB     vol-deleted-001         2025-03-10      Daily backup app-server
  snap-0f9e8d7c6b5a4321     100 GB    vol-deleted-002         2025-04-22      Manual snapshot before update
  snap-0ab12cd34ef56789     200 GB    vol-deleted-003         2025-05-15      Pre-migration backup
  snap-0123456789abcdef     30 GB     vol-deleted-004         2025-06-01      Test environment snapshot
  snap-0fedcba987654321     80 GB     vol-deleted-005         2025-07-18      Old database backup

📊 Resumo:
   Total de snapshots órfãos: 5
   Tamanho total: 460 GB
   Custo mensal desperdiçado: $23.00/mês ($276.00/ano)

⚠️  Modo DRY-RUN: nenhum snapshot foi removido.
    Remova --dry-run para executar a limpeza.
```
