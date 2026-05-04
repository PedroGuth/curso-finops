-- ec2-custo-por-tipo.sql
-- Custo de EC2 agrupado por tipo de instância e modelo de preço
-- Modelos: On-Demand, Spot, Reserved Instance (RI), Savings Plan (SP)

SELECT
  product_instance_type AS tipo_instancia,
  CASE
    WHEN savings_plan_savings_plan_a_r_n <> '' THEN 'Savings Plan'
    WHEN reservation_reservation_a_r_n <> '' THEN 'Reserved Instance'
    WHEN line_item_usage_type LIKE '%Spot%' THEN 'Spot'
    ELSE 'On-Demand'
  END AS modelo_preco,
  SUM(line_item_unblended_cost) AS custo_total,
  SUM(line_item_usage_amount) AS horas_uso
FROM cur_table
WHERE year = CAST(YEAR(CURRENT_DATE) AS VARCHAR)
  AND month = CAST(MONTH(CURRENT_DATE) AS VARCHAR)
  AND product_product_name = 'Amazon Elastic Compute Cloud'
  AND line_item_line_item_type IN ('Usage', 'SavingsPlanCoveredUsage', 'DiscountedUsage')
  AND product_instance_type <> ''
GROUP BY product_instance_type,
  CASE
    WHEN savings_plan_savings_plan_a_r_n <> '' THEN 'Savings Plan'
    WHEN reservation_reservation_a_r_n <> '' THEN 'Reserved Instance'
    WHEN line_item_usage_type LIKE '%Spot%' THEN 'Spot'
    ELSE 'On-Demand'
  END
ORDER BY custo_total DESC;
