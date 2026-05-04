-- =====================================================
-- Custo por tag Environment (ex: Production, Development)
-- =====================================================
SELECT
  resource_tags_user_environment AS ambiente,
  line_item_product_code AS servico,
  ROUND(SUM(line_item_unblended_cost), 2) AS custo_usd
FROM cur_database.cur_table
WHERE month = CAST(MONTH(CURRENT_DATE) AS VARCHAR)
  AND year = CAST(YEAR(CURRENT_DATE) AS VARCHAR)
GROUP BY resource_tags_user_environment, line_item_product_code
ORDER BY ambiente, custo_usd DESC;
