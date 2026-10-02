/* ===================================================================================
   REVENUE CONCENTRATION ANALYSIS

   Business Question:
   How concentrated is company revenue across products customers and markets?
   
Analysis:
   - Category revenue concentration
   - Top customer contribution
   - Top product contribution
   - Country contribution
=================================================================================== */

/* ===================================================================================
   1. CATEGORY REVENUE CONCENTRATION
=================================================================================== */
WITH category_sales AS (
    SELECT
        p.category,
        SUM(s.sales_amount) AS revenue
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY p.category
)
SELECT
    category,
    revenue,
    ROUND(
        revenue / NULLIF(SUM(revenue) OVER (), 0) * 100,
        2
    ) AS revenue_contribution_pct,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS category_rank
FROM category_sales
ORDER BY revenue DESC;

/* ===================================================================================
   2. TOP PRODUCTS' REVENUE CONTRIBUTION
=================================================================================== */
WITH product_sales AS (
    SELECT
        p.product_name,
        SUM(s.sales_amount) AS revenue
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY p.product_name
),
ranked_products AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY revenue DESC
        ) AS product_rank
    FROM product_sales
)
SELECT
    product_name,
    revenue,
    ROUND(
        revenue / NULLIF(SUM(revenue) OVER (), 0) * 100,
        2
    ) AS revenue_contribution_pct,
    product_rank
FROM ranked_products
WHERE product_rank <= 10
ORDER BY product_rank;

/* ===================================================================================
   3. TOP 10 CUSTOMERS' REVENUE CONTRIBUTION
=================================================================================== */
WITH customer_sales AS (
    SELECT
        s.customer_key,
        SUM(s.sales_amount) AS revenue
    FROM gold.fact_sales s
    GROUP BY s.customer_key
),
ranked_customers AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY revenue DESC
        ) AS customer_rank
    FROM customer_sales
)
SELECT
    SUM(revenue) AS top_10_customer_revenue,
    ROUND(
        SUM(revenue)
        / NULLIF(
            (SELECT SUM(revenue) FROM customer_sales),
            0
        ) * 100,
        2
    ) AS top_10_customer_contribution_pct
FROM ranked_customers
WHERE customer_rank <= 10;
