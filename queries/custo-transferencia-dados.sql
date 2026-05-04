-- =====================================================
-- Custos de transferência de dados por serviço e tipo
-- =====================================================
SELECT
  line_item_product_code AS servico,
  line_item_usage_type AS tipo_uso,
  ROUND(SUM(line_item_usage_amount), 2) AS gb_transferidos,
  ROUND(SUM(line_item_unblended_cost), 2) AS custo_usd
FROM cur_database.cur_table
WHERE line_item_usage_type LIKE '%DataTransfer%'
  AND month = CAST(MONTH(CURRENT_DATE) AS VARCHAR)
  AND year = CAST(YEAR(CURRENT_DATE) AS VARCHAR)
GROUP BY line_item_product_code, line_item_usage_type
ORDER BY custo_usd DESC;
