-- =====================================================
-- Cobertura de Savings Plans e Reserved Instances
-- =====================================================
SELECT
  line_item_product_code AS servico,
  pricing_term AS modelo_preco,
  ROUND(SUM(line_item_unblended_cost), 2) AS custo_usd,
  ROUND(SUM(reservation_effective_cost), 2) AS custo_efetivo_ri,
  ROUND(SUM(savings_plan_savings_plan_effective_cost), 2) AS custo_efetivo_sp
FROM cur_database.cur_table
WHERE line_item_product_code IN ('AmazonEC2', 'AmazonRDS', 'AmazonElastiCache')
  AND month = CAST(MONTH(CURRENT_DATE) AS VARCHAR)
  AND year = CAST(YEAR(CURRENT_DATE) AS VARCHAR)
GROUP BY line_item_product_code, pricing_term
ORDER BY servico, custo_usd DESC;
