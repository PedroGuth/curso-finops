-- =====================================================
-- Recursos sem tag Environment (desperdício potencial)
-- =====================================================
SELECT
  line_item_product_code AS servico,
  line_item_resource_id AS recurso,
  ROUND(SUM(line_item_unblended_cost), 2) AS custo_usd
FROM cur_database.cur_table
WHERE (resource_tags_user_environment IS NULL OR resource_tags_user_environment = '')
  AND line_item_unblended_cost > 0
  AND month = CAST(MONTH(CURRENT_DATE) AS VARCHAR)
  AND year = CAST(YEAR(CURRENT_DATE) AS VARCHAR)
GROUP BY line_item_product_code, line_item_resource_id
ORDER BY custo_usd DESC
LIMIT 50;
