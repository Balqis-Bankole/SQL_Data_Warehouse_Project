CREATE OR REPLACE VIEW gold.report_customers AS
WITH  base_query AS(
/*--------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
--------------------------------------------------------------------------*/
SELECT
s.order_number,
s.product_key,
s.order_date,
s.sales_amount,
s.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ', c.last_name) customer_name,
DATE_PART('YEAR', AGE(CURRENT_DATE,c.birth_date)) age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
WHERE s.order_date IS NOT NULL
), customer_segregation AS(
/*--------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
--------------------------------------------------------------------------*/
SELECT 
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) total_orders,
SUM(sales_amount) total_revenue,
SUM(quantity) total_quantity,
COUNT(DISTINCT product_key) total_products,
MAX(order_date) last_order_date,
EXTRACT('YEAR' FROM AGE(MAX(order_date),MIN(order_date))) * 12 
+ EXTRACT('Month' FROM AGE(MAX(order_date),MIN(order_date))) observed_lifespan
FROM base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    age
)
/*--------------------------------------------------------------------------
2) Final query: Combines all customer results into one output
--------------------------------------------------------------------------*/
SELECT 
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
    WHEN age BETWEEN 20 AND 29 THEN '20-29'
    WHEN age BETWEEN 30 AND 39 THEN '30-39'
    WHEN age BETWEEN 40 AND 49 THEN '40-49'
    ELSE '50 and above'
END age_group,
CASE WHEN age >= 12 AND total_sales > 5000 THEN 'VIP'
    WHEN age >= 12 AND total_sales <= 5000 THEN 'Regular'
    ELSE 'New'
END customer_segment,
last_order_date,
total_orders,
total_revenue,
total_quantity,
total_products,
observed_lifespan,
---compute recency
EXTRACT(YEAR FROM AGE('2014-01-28', last_order_date))* 12 
+ EXTRACT(MONTH FROM AGE('2014-01-28', last_order_date)) recency,

---compute average order value (aov)
CASE WHEN total_orders = 0 THEN 0
    ELSE total_revenue/total_orders 
END average_order_value,

---compute average monthly spend  
CASE WHEN observed_lifespan = 0 THEN total_sales
    ELSE ROUND(total_sales/lifespan,2)
END average_monthly_spend
FROM  customer_segregation







