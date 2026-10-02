CREATE OR REPLACE VIEW gold.report_geography AS
SELECT
    c.country,
    COUNT(DISTINCT s.customer_key) AS active_customers,
    COUNT(DISTINCT s.order_number) AS total_orders,
    SUM(s.quantity) AS units_sold,
    SUM(s.sales_amount) AS total_revenue,
    ROUND(SUM(s.sales_amount) / NULLIF(COUNT(DISTINCT s.customer_key), 0), 2) AS revenue_per_customer,
    ROUND(SUM(s.sales_amount)/ NULLIF(COUNT(DISTINCT s.order_number), 0),2) AS average_order_value
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.country;
