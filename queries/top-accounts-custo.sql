-- top-accounts-custo.sql
-- Top contas por custo no mês atual (AWS Organizations)
-- Útil para identificar quais contas estão gerando mais gastos

SELECT
  line_item_usage_account_id AS conta_id,
  SUM(line_item_unblended_cost) AS custo_total
FROM cur_table
WHERE month = CAST(MONTH(CURRENT_DATE) AS VARCHAR)
  AND year = CAST(YEAR(CURRENT_DATE) AS VARCHAR)
  AND line_item_line_item_type = 'Usage'
GROUP BY line_item_usage_account_id
ORDER BY custo_total DESC
LIMIT 20;
