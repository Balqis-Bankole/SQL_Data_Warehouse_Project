CREATE OR REPLACE VIEW gold.report_sales AS
SELECT
    s.order_number,
    s.order_date,
    EXTRACT(YEAR FROM s.order_date)::INT AS year,
    EXTRACT(MONTH FROM s.order_date)::INT AS month_number,
    TO_CHAR(s.order_date, 'Month') AS month,
    s.customer_key,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    s.product_key,
    p.product_id,
    p.product_name,
    p.category,
    p.product_line,
    p.sub_category,
    s.quantity,
    s.price,
    s.sales_amount
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL;
