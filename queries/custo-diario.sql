-- =====================================================
-- Custo diário dos últimos 30 dias
-- =====================================================
SELECT
  line_item_usage_start_date AS dia,
  ROUND(SUM(line_item_unblended_cost), 2) AS custo_usd
FROM cur_database.cur_table
WHERE line_item_usage_start_date >= DATE_ADD('day', -30, CURRENT_DATE)
GROUP BY line_item_usage_start_date
ORDER BY dia;
