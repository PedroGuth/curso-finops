# 🔍 Runbook: Recursos Esquecidos / Ociosos

**Situação**: Encontrei recursos que parecem não estar em uso — instâncias paradas, volumes desanexados, snapshots órfãos, EIPs não associados.

**Tempo estimado**: 20–40 minutos

---

## Passo 1 — Identificar Recursos Ociosos

Use os scripts do repositório:

```bash
# Auditoria completa (EC2, EBS, EIP, RDS, S3)
python3 tools/aws-cost-optimizer.py

# EIPs não associados
bash scripts/cleanup-unused-eips.sh --dry-run

# Snapshots órfãos (volumes já deletados)
bash scripts/cleanup-orphan-snapshots.sh --dry-run
```

Ou manualmente via AWS CLI:

```bash
# EC2 paradas
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=stopped" \
  --query 'Reservations[].Instances[].{ID: InstanceId, Type: InstanceType, Name: Tags[?Key==`Name`].Value | [0], Stopped: StateTransitionReason}' \
  --output table

# Volumes EBS não anexados
aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query 'Volumes[].{ID: VolumeId, Size: Size, Type: VolumeType, Created: CreateTime}' \
  --output table

# EIPs não associados
aws ec2 describe-addresses \
  --query 'Addresses[?AssociationId==null].{IP: PublicIp, AllocID: AllocationId}' \
  --output table
```

---

## Passo 2 — Validar com o Dono (Tag Owner)

```bash
# Ver tags de um recurso específico
aws ec2 describe-tags \
  --filters "Name=resource-id,Values=<resource-id>" \
  --output table

# Listar recursos SEM tag Owner
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=Owner,Values= \
  --query 'ResourceTagMappingList[].ResourceARN' \
  --output table

# Verificar compliance de tags
bash tools/tag-compliance-checker.sh
```

**Ação**: Se tem tag `Owner`, entre em contato antes de deletar. Se não tem tag, é candidato forte a remoção.

---

## Passo 3 — Snapshot / Backup

Antes de deletar, faça backup:

```bash
# Snapshot de volume EBS
aws ec2 create-snapshot \
  --volume-id <volume-id> \
  --description "Backup antes de cleanup - $(date +%Y-%m-%d)" \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Purpose,Value=pre-cleanup-backup}]'

# AMI de instância EC2
aws ec2 create-image \
  --instance-id <instance-id> \
  --name "backup-pre-cleanup-$(date +%Y%m%d)" \
  --no-reboot

# Snapshot de RDS
aws rds create-db-snapshot \
  --db-instance-identifier <db-name> \
  --db-snapshot-identifier "backup-pre-cleanup-$(date +%Y%m%d)"
```

---

## Passo 4 — Deletar Recursos

Após confirmação:

```bash
# Terminar instância EC2 parada
aws ec2 terminate-instances --instance-ids <instance-id>

# Deletar volume EBS não anexado
aws ec2 delete-volume --volume-id <volume-id>

# Liberar Elastic IP
aws ec2 release-address --allocation-id <alloc-id>

# Deletar snapshots órfãos (script do repo)
bash scripts/cleanup-orphan-snapshots.sh
```

> ⚠️ Sempre rode com `--dry-run` primeiro quando disponível.

---

## Passo 5 — Prevenir Recorrência

### Instance Scheduler (liga/desliga automático):

```bash
cd terraform/instance-scheduler
terraform init && terraform apply
# Ou: labs/lab-06-instance-scheduler/
```

### Exigir tags obrigatórias:

```bash
# Aplicar policy IAM que exige tags
aws iam put-group-policy \
  --group-name Developers \
  --policy-name RequireTags \
  --policy-document file://policies/require-tags-ec2.json
```

### AWS Config para monitorar continuamente:

```bash
# Referência: labs/lab-01-config-tags/
```

---

## Checklist Final

- [ ] Executei a varredura de recursos ociosos
- [ ] Validei com os donos dos recursos
- [ ] Fiz backup/snapshot antes de deletar
- [ ] Deletei os recursos confirmados como desnecessários
- [ ] Implementei Instance Scheduler para dev/staging
- [ ] Configurei tags obrigatórias para novos recursos
