/* ==============================================================================
   GEOGRAPHIC PERFORMANCE ANALYSIS

   Business Question:
   How does sales performance differ across geographic markets?

   Analysis:
   - Customers by country
   - Revenue by country
   - Orders by country
   - Units sold by country
   - Revenue per customer
   - Market revenue contribution
============================================================================== */

/* ==============================================================================
   1. REVENUE BY COUNTRY
============================================================================== */
SELECT
    c.country,
    SUM(s.sales_amount) AS revenue,
    COUNT(DISTINCT s.order_number) AS total_orders,
    COUNT(DISTINCT s.customer_key) AS active_customers,
    SUM(s.quantity) AS units_sold
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY revenue DESC;

/* ==============================================================================
   2. REVENUE CONTRIBUTION BY COUNTRY
================================================================================ */
WITH country_sales AS (
    SELECT
        c.country,
        SUM(s.sales_amount) AS revenue
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY c.country
)
SELECT
    country,
    revenue,
    ROUND(
        revenue / NULLIF(SUM(revenue) OVER (), 0) * 100,
        2
    ) AS revenue_contribution_pct
FROM country_sales
ORDER BY revenue DESC;

/* ==============================================================================
   3. REVENUE PER CUSTOMER BY COUNTRY
================================================================================ */
SELECT
    c.country,
    COUNT(DISTINCT s.customer_key) AS active_customers,
    SUM(s.sales_amount) AS revenue,
    ROUND(
        SUM(s.sales_amount)
        / NULLIF(COUNT(DISTINCT s.customer_key), 0),
        2
    ) AS revenue_per_customer
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY revenue_per_customer DESC;

/* ==============================================================================
   4. CUSTOMERS BY COUNTRY
================================================================================ */
SELECT
    country,
    COUNT(DISTINCT customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

/* ==============================================================================
   5. COUNTRY SALES TREND
================================================================================ */
SELECT
    c.country,
    EXTRACT(YEAR FROM s.order_date)::INT AS year,
    SUM(s.sales_amount) AS revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
WHERE s.order_date IS NOT NULL
GROUP BY
    c.country,
    EXTRACT(YEAR FROM s.order_date)
ORDER BY
    c.country,
    year;
