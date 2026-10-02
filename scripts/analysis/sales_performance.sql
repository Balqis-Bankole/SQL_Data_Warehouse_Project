/* ======================================================================================
   SALES PERFORMANCE ANALYSIS

   Business Question:
   How is the company's sales performance changing over time?

   Analysis:
   - Overall revenue by year
   - Monthly revenue trend
   - Orders and customers over time
   - Year-over-year revenue growth
   - Average order value
   - Units sold
   - Running revenue
   - Moving average
====================================================================================== */

/* ======================================================================================
   1. YEARLY SALES PERFORMANCE
====================================================================================== */
SELECT
    EXTRACT(YEAR FROM order_date)::INT AS year,
    SUM(sales_amount) AS revenue,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS active_customers,
    SUM(quantity) AS units_sold,
    ROUND(
        SUM(sales_amount) / NULLIF(COUNT(DISTINCT order_number), 0),
        2
    ) AS average_order_value
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

/* ======================================================================================
   2. MONTHLY SALES PERFORMANCE
====================================================================================== */
SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,
    SUM(sales_amount) AS revenue,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS active_customers,
    SUM(quantity) AS units_sold,
    ROUND(
        SUM(sales_amount) / NULLIF(COUNT(DISTINCT order_number), 0),
        2
    ) AS average_order_value
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

/* ======================================================================================
   3. YEAR-OVER-YEAR REVENUE GROWTH
====================================================================================== */
WITH yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM order_date)::INT AS year,
        SUM(sales_amount):: NUMERIC AS revenue
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT
    year,
    revenue,
    LAG(revenue) OVER (ORDER BY year) AS previous_year_revenue,
    ROUND(
        (
            revenue - LAG(revenue) OVER (ORDER BY year)
        )
        / NULLIF(LAG(revenue) OVER (ORDER BY year), 0) * 100,
        2
    ) AS yoy_growth_pct
FROM yearly_sales
ORDER BY year;

/* ======================================================================================
   4. AVERAGE ORDER VALUE OVER TIME
====================================================================================== */
SELECT
    EXTRACT(YEAR FROM order_date)::INT AS year,
    SUM(sales_amount) AS revenue,
    COUNT(DISTINCT order_number) AS total_orders,
    ROUND(
        SUM(sales_amount)
        / NULLIF(COUNT(DISTINCT order_number), 0),
        2
    ) AS average_order_value
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

/* ======================================================================================
   5. MONTHLY RUNNING REVENUE
====================================================================================== */
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(sales_amount) AS revenue
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    revenue,
    SUM(revenue) OVER (
        ORDER BY month
    ) AS cumulative_revenue
FROM monthly_sales
ORDER BY month;

/* ======================================================================================
   6. THREE-MONTH MOVING AVERAGE
====================================================================================== */
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(sales_amount) AS revenue
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    revenue,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average
FROM monthly_sales
ORDER BY month;

/* ======================================================================================
   7. MONTHLY REVENUE BY YEAR
====================================================================================== */
SELECT
    EXTRACT(YEAR FROM order_date)::INT AS year,
    EXTRACT(MONTH FROM order_date)::INT AS month_number,
    TO_CHAR(order_date, 'Month') AS month,
    SUM(sales_amount) AS revenue,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(quantity) AS units_sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date),
    TO_CHAR(order_date, 'Month')
ORDER BY year, month_number;
