/* ======================================================================================
PRODUCT PERFORMANCE ANALYSIS

   Business Question:
   Which products and product categories contribute most to sales performance?

   Analysis:
   - Revenue by category
   - Revenue contribution
   - Revenue by product line
   - Revenue by subcategory
   - Top products
   - Bottom products
   - Product revenue vs quantity
   - Yearly product performance
====================================================================================== */

/* ==================================================================================== 
   1. REVENUE BY CATEGORY
====================================================================================  */
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
    SUM(revenue) OVER () AS total_revenue,
    ROUND(
        revenue / NULLIF(SUM(revenue) OVER (), 0) * 100,
        2
    ) AS revenue_contribution_pct
FROM category_sales
ORDER BY revenue DESC;

/* ====================================================================================
   2. REVENUE BY PRODUCT LINE
==================================================================================== */
SELECT
    p.product_line,
    SUM(s.sales_amount) AS revenue,
    SUM(s.quantity) AS units_sold,
    COUNT(DISTINCT s.order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_line
ORDER BY revenue DESC;

/* ====================================================================================
   3. REVENUE BY SUBCATEGORY
==================================================================================== */
SELECT
    p.sub_category,
    SUM(s.sales_amount) AS revenue,
    SUM(s.quantity) AS units_sold,
    COUNT(DISTINCT s.order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.sub_category
ORDER BY revenue DESC;

/* ====================================================================================
   4. TOP 10 PRODUCTS BY REVENUE
==================================================================================== */
SELECT
    p.product_name,
    p.category,
    p.sub_category,
    SUM(s.sales_amount) AS revenue,
    SUM(s.quantity) AS units_sold
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY
    p.product_name,
    p.category,
    p.sub_category
ORDER BY revenue DESC
LIMIT 10;

/* ====================================================================================
   5. BOTTOM 10 PRODUCTS BY REVENUE
==================================================================================== */
SELECT
    p.product_name,
    p.category,
    p.sub_category,
    SUM(s.sales_amount) AS revenue,
    SUM(s.quantity) AS units_sold
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY
    p.product_name,
    p.category,
    p.sub_category
ORDER BY revenue ASC
LIMIT 10;

/* ====================================================================================
   6. PRODUCT REVENUE VS UNITS SOLD
==================================================================================== */
SELECT
    p.product_name,
    p.category,
    SUM(s.sales_amount) AS revenue,
    SUM(s.quantity) AS units_sold,
    ROUND(
        SUM(s.sales_amount)
        / NULLIF(SUM(s.quantity), 0),
        2
    ) AS revenue_per_unit
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY
    p.product_name,
    p.category
ORDER BY revenue DESC;

/* ====================================================================================
   7. YEARLY PRODUCT PERFORMANCE
==================================================================================== */
WITH product_yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM s.order_date)::INT AS year,
        p.product_name,
        SUM(s.sales_amount)::NUMERIC AS revenue
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY
        EXTRACT(YEAR FROM s.order_date),
        p.product_name
)
SELECT
    year,
    product_name,
    revenue,
    LAG(revenue) OVER (
        PARTITION BY product_name
        ORDER BY year
    ) AS previous_year_revenue,
    revenue
        - LAG(revenue) OVER (
            PARTITION BY product_name
            ORDER BY year
        ) AS revenue_change,
    ROUND(
        (
            revenue
            - LAG(revenue) OVER (
                PARTITION BY product_name
                ORDER BY year
            )
        )
        / NULLIF(
            LAG(revenue) OVER (
                PARTITION BY product_name
                ORDER BY year
            ),
            0
        ) * 100,
        2
    ) AS yoy_growth_pct
FROM product_yearly_sales
ORDER BY product_name, year;
