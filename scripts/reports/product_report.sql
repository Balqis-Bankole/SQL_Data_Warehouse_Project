CREATE OR REPLACE VIEW gold.report_products AS
WITH base_query AS(
/*--------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
--------------------------------------------------------------------------*/
SELECT 
    p.product_key,
    p.product_id,
    p.product_name,
    p.category,
    p.product_line,
    p.sub_category,
    p.cost,
    p.start_date,
    s.order_date,
    s.customer_key,
    s.order_number,
    s.sales_amount,
    s.quantity
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
/*--------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
--------------------------------------------------------------------------*/
), product_aggregations AS(
SELECT 
    product_id,
    product_name,
    product_line,
    category,
    sub_category,
    cost,
    start_date,
    EXTRACT (YEAR FROM AGE('2014-01-28',start_date)) * 12 +
    EXTRACT (MONTH FROM AGE('2014-01-28',start_date)) products_lifespan,
    MAX(order_date) last_order_date,
    COUNT(DISTINCT customer_key) total_customers,
    COUNT(DISTINCT order_number) total_product_order,
    ROUND(SUM(sales_amount),2) total_sales,
    SUM(quantity) total_quantity_sold,
    ROUND(AVG(sales_amount/NULLIF(quantity,0)),2) avg_selling_price
FROM base_query
GROUP BY 
    product_id,
    product_name,
    product_line,
    category,
    sub_category,
    cost,
    start_date
)
/*--------------------------------------------------------------------------
2) Final query: Combines all product results into one output
--------------------------------------------------------------------------*/
SELECT
    product_id,
    product_name,
    product_line,
    category,
    sub_category,
    cost,
    start_date,
    products_lifespan,
    last_order_date,
    EXTRACT(YEAR FROM AGE('2014-01-28',last_order_date)) * 12 
    + EXTRACT(MONTH FROM AGE('2014-01-28',last_order_date)) recency,
    total_customers,
    total_product_order,
    total_sales,
    CASE WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment, 
    ----Average Order Revenue(AOR)
    CASE WHEN total_product_order = 0 THEN 0
        ELSE ROUND(total_sales/total_product_order)
    END AS average_order_revenue,
    ----Average Monthly Revenue
    CASE WHEN products_lifespan = 0 THEN total_sales
        ELSE ROUND(total_sales/products_lifespan, 2) 
    END AS average_monthly_revenue,
    avg_selling_price,
    total_quantity_sold
FROM product_aggregations


