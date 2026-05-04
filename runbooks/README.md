# 🚨 Runbooks FinOps — Procedimentos Operacionais

Runbooks são procedimentos passo a passo para responder a situações comuns de custos na AWS. Use-os quando precisar agir rápido e com segurança.

---

## Índice de Runbooks

| Runbook | Quando usar |
|---------|-------------|
| [Custo Inesperado](custo-inesperado.md) | Fatura veio mais alta que o esperado ou custo subiu repentinamente |
| [Recurso Esquecido](recurso-esquecido.md) | Encontrou recursos ociosos, órfãos ou sem dono identificado |
| [Savings Plan Expirando](savings-plan-expirando.md) | Savings Plan ou Reserved Instance está próximo do vencimento |
| [Nova Conta AWS](nova-conta-aws.md) | Configurando FinOps do zero em uma conta nova |

---

## Como Usar os Runbooks

1. **Identifique a situação** — Escolha o runbook adequado na tabela acima
2. **Siga os passos na ordem** — Cada runbook tem passos numerados com comandos prontos
3. **Adapte à sua realidade** — Substitua valores como `<account-id>`, `<region>` e `<resource-id>`
4. **Documente o que fez** — Registre as ações tomadas para referência futura

## Pré-requisitos

- AWS CLI v2 configurada (`aws configure`)
- Permissões de leitura em Cost Explorer e billing
- Acesso aos scripts deste repositório (`tools/`, `scripts/`)

---

> 💡 **Dica**: Combine os runbooks com os [templates de relatórios](../templates/) para documentar as ações tomadas.
