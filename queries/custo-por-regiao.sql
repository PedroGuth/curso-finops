-- custo-por-regiao.sql
-- Custo total por região AWS no mês atual
-- Identifica regiões com maior gasto para avaliar consolidação

SELECT
  product_region AS regiao,
  SUM(line_item_unblended_cost) AS custo_total
FROM cur_table
WHERE year = CAST(YEAR(CURRENT_DATE) AS VARCHAR)
  AND month = CAST(MONTH(CURRENT_DATE) AS VARCHAR)
  AND line_item_line_item_type = 'Usage'
  AND product_region <> ''
GROUP BY product_region
ORDER BY custo_total DESC;
