/*==================================================================================
   CUSTOMER PERFORMANCE ANALYSIS

   Business Questions:
   - Which customers contribute most revenue?
   - How is revenue distributed across customers?
   - How does purchasing behaviour differ across customers?

   Analysis:
   - Customer revenue
   - Orders per customer
   - Average order value
   - Customer segmentation
   - Repeat customers
   - Revenue concentration
================================================================================== */
/* ===============================================================================
   1. CUSTOMER PERFORMANCE
===================================================================================*/
SELECT
    c.customer_key,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT s.order_number) AS total_orders,
    SUM(s.sales_amount) AS total_revenue,
    SUM(s.quantity) AS total_units,
    ROUND(
        SUM(s.sales_amount)
        / NULLIF(COUNT(DISTINCT s.order_number), 0),
        2
    ) AS average_order_value,
    MIN(s.order_date) AS first_order_date,
    MAX(s.order_date) AS last_order_date
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
WHERE s.order_date IS NOT NULL
GROUP BY
    c.customer_key,
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

/* ===============================================================================
   2. TOP 10 CUSTOMERS BY REVENUE
================================================================================== */
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT s.order_number) AS total_orders,
    SUM(s.sales_amount) AS total_revenue,
    ROUND(
        SUM(s.sales_amount)::NUMERIC
        / NULLIF(COUNT(DISTINCT s.order_number), 0),
        2
    ) AS average_order_value
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC
LIMIT 10;

/* ===============================================================================
   3. CUSTOMER SEGMENTATION
================================================================================== */
WITH customer_summary AS (
    SELECT
        c.customer_key,
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(s.sales_amount) AS total_revenue,
        COUNT(DISTINCT s.order_number) AS total_orders,
        MIN(s.order_date) AS first_order_date,
        MAX(s.order_date) AS last_order_date
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name
),
customer_segments AS (
    SELECT
        *,
        (
            EXTRACT(YEAR FROM AGE(last_order_date, first_order_date)) * 12
            + EXTRACT(MONTH FROM AGE(last_order_date, first_order_date))
        )::INT AS observed_lifespan_months
    FROM customer_summary
)
SELECT
    customer_id,
    customer_name,
    total_revenue,
    total_orders,
    observed_lifespan_months,
    CASE
        WHEN observed_lifespan_months >= 12
             AND total_revenue > 5000
            THEN 'VIP'
        WHEN observed_lifespan_months >= 12
             AND total_revenue <= 5000
            THEN 'Regular'
        ELSE 'New'
    END AS customer_segment
FROM customer_segments
ORDER BY total_revenue DESC;

/* ===============================================================================
   4. CUSTOMER SEGMENT SUMMARY
================================================================================== */
WITH customer_summary AS (
    SELECT
        c.customer_key,
        SUM(s.sales_amount) AS total_revenue,
        COUNT(DISTINCT s.order_number) AS total_orders,
        MIN(s.order_date) AS first_order_date,
        MAX(s.order_date) AS last_order_date
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY c.customer_key
),
customer_segments AS (
    SELECT
        *
        (
            EXTRACT(YEAR FROM AGE(last_order_date, first_order_date)) * 12
            + EXTRACT(MONTH FROM AGE(last_order_date, first_order_date))
        )::INT AS observed_lifespan_months
    FROM customer_summary
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN observed_lifespan_months >= 12
                 AND total_revenue > 5000
                THEN 'VIP'
            WHEN observed_lifespan_months >= 12
                 AND total_revenue <= 5000
                THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_segments
)
SELECT
    customer_segment,
    COUNT(*) AS customers,
    SUM(total_revenue) AS revenue,
    ROUND(
        SUM(total_revenue)
        / NULLIF(SUM(SUM(total_revenue)) OVER (), 0) * 100,
        2
    ) AS revenue_contribution_pct
FROM segmented
GROUP BY customer_segment
ORDER BY revenue DESC;

/* ===============================================================================
   5. REPEAT CUSTOMER RATE
================================================================================== */
WITH customer_orders AS (
    SELECT
        customer_key,
        COUNT(DISTINCT order_number) AS total_orders
    FROM gold.fact_sales
    GROUP BY customer_key
)
SELECT
    COUNT(*) AS active_customers,
    COUNT(*) FILTER (WHERE total_orders > 1) AS repeat_customers,
    ROUND(
        COUNT(*) FILTER (WHERE total_orders > 1)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS repeat_customer_rate_pct
FROM customer_orders;

/* ===============================================================================
   6. REVENUE CONCENTRATION: TOP 10 CUSTOMERS
================================================================================== */
WITH customer_revenue AS (
    SELECT
        customer_key,
        SUM(sales_amount) AS revenue
    FROM gold.fact_sales
    GROUP BY customer_key
),
ranked_customers AS (
    SELECT
        customer_key,
        revenue,
        ROW_NUMBER() OVER (
            ORDER BY revenue DESC
        ) AS customer_rank
    FROM customer_revenue
)
SELECT
    SUM(revenue) AS top_10_customer_revenue,
    (
        SELECT SUM(revenue)
        FROM customer_revenue
    ) AS total_revenue,
    ROUND(
        SUM(revenue)
        / NULLIF(
            (
                SELECT SUM(revenue)
                FROM customer_revenue
            ),
            0
        ) * 100,
        2
    ) AS top_10_revenue_contribution_pct
FROM ranked_customers
WHERE customer_rank <= 10;
