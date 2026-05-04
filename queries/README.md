# Queries Athena para CUR 📊

Queries SQL para analisar o AWS Cost and Usage Report (CUR) usando Amazon Athena.

## Pré-requisitos

1. Habilitar o Data Export (CUR 2.0) no console de Billing
2. Configurar o Athena com o bucket S3 do CUR
3. Substituir `cur_database.cur_table` pelo nome real da sua tabela

## Queries Disponíveis

| Arquivo | Descrição |
|---------|-----------|
| `custo-por-servico.sql` | Top serviços por custo no mês atual |
| `custo-diario.sql` | Custo diário dos últimos 30 dias |
| `custo-por-tag.sql` | Custo agrupado por tag Environment |
| `custo-transferencia-dados.sql` | Custos de transferência de dados por serviço |
| `recursos-sem-tags.sql` | Top 50 recursos sem tag Environment (desperdício) |
| `cobertura-savings-plans.sql` | Cobertura de Savings Plans e RIs por serviço |
| `top-accounts-custo.sql` | Top contas por custo (Organizations) |
| `ec2-custo-por-tipo.sql` | EC2 por tipo de instância e modelo de preço |
| `custo-por-regiao.sql` | Custo total por região AWS |

## Como Usar

1. Abra o console do **Amazon Athena**
2. Selecione o database do CUR
3. Cole a query e substitua `cur_database.cur_table`
4. Execute

> 💡 Combine essas queries com o **QuickSight** para criar dashboards visuais.
