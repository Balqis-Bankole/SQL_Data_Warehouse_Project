/* ========================================================================================================================
   SALES PERFORMANCE & REVENUE DRIVERS ANALYSIS
   EXPLORATORY DATA ANALYSIS

   Purpose:
   Explore the structure, quality, coverage and basic patterns in the Gold-layer data before conducting the final business analysis.

   Gold tables:
   - gold.fact_sales
   - gold.dim_customers
   - gold.dim_products
============================================================================================================================ */


/* ==========================================================================================================================
   1. DATA STRUCTURE
   Understand the available tables and columns
============================================================================================================================= */
/* 1.1 Available tables */

SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'gold'
ORDER BY table_name;

/* 1.2 Fact sales columns */

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'gold'
  AND table_name = 'fact_sales'
ORDER BY ordinal_position;

/* 1.3 Customer columns */

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'gold'
  AND table_name = 'dim_customers'
ORDER BY ordinal_position;

/* 1.4 Product columns */

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'gold'
  AND table_name = 'dim_products'
ORDER BY ordinal_position;


/* ========================================================================================================================
   2. INITIAL DATA PREVIEW
======================================================================================================================== */
/* 2.1 Sales */
SELECT *
FROM gold.fact_sales
LIMIT 10;

/* 2.2 Customers */
SELECT *
FROM gold.dim_customers
LIMIT 10;


/* 2.3 Products */
SELECT *
FROM gold.dim_products
LIMIT 10;


/* ========================================================================================================================
   3. DATASET SIZE
   Understand the number of records in each table
======================================================================================================================== */
SELECT
    COUNT(*) AS total_sales_records
FROM gold.fact_sales;


SELECT
    COUNT(*) AS total_customers
FROM gold.dim_customers;


SELECT
    COUNT(*) AS total_products
FROM gold.dim_products;


/* ========================================================================================================================
   4. SALES DATA COVERAGE
   Understand the period covered by the sales data
======================================================================================================================== */
/* 4.1 First and last order */

SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM gold.fact_sales;


/* 4.2 Number of years covered */
SELECT
    EXTRACT(
        YEAR FROM AGE(
            MAX(order_date),
            MIN(order_date)
        )
    ) AS years_between_orders
FROM gold.fact_sales;


/* 4.3 Number of distinct years */
SELECT
    COUNT(DISTINCT EXTRACT(YEAR FROM order_date)) AS years_of_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL;


/* 4.4 Sales by year */
SELECT
    EXTRACT(YEAR FROM order_date)::INT AS year,
    COUNT(*) AS sales_records,
    COUNT(DISTINCT order_number) AS orders,
    SUM(sales_amount) AS revenue
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;


/* ============================================================
   5. DATA QUALITY CHECKS
============================================================ */
/* 5.1 Missing values in key sales fields */
SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE order_date IS NULL
    ) AS missing_order_date,

    COUNT(*) FILTER (
        WHERE customer_key IS NULL
    ) AS missing_customer_key,

    COUNT(*) FILTER (
        WHERE product_key IS NULL
    ) AS missing_product_key,

    COUNT(*) FILTER (
        WHERE order_number IS NULL
    ) AS missing_order_number,

    COUNT(*) FILTER (
        WHERE sales_amount IS NULL
    ) AS missing_sales_amount,

    COUNT(*) FILTER (
        WHERE quantity IS NULL
    ) AS missing_quantity

FROM gold.fact_sales;


/* 5.2 Missing values in customer table */
SELECT
    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,

    COUNT(*) FILTER (
        WHERE first_name IS NULL
    ) AS missing_first_name,

    COUNT(*) FILTER (
        WHERE last_name IS NULL
    ) AS missing_last_name,

    COUNT(*) FILTER (
        WHERE country IS NULL
    ) AS missing_country,

    COUNT(*) FILTER (
        WHERE birth_date IS NULL
    ) AS missing_birth_date

FROM gold.dim_customers;


/* 5.3 Missing values in product table */
SELECT
    COUNT(*) AS total_products,

    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS missing_product_id,

    COUNT(*) FILTER (
        WHERE product_name IS NULL
    ) AS missing_product_name,

    COUNT(*) FILTER (
        WHERE category IS NULL
    ) AS missing_category,

    COUNT(*) FILTER (
        WHERE sub_category IS NULL
    ) AS missing_subcategory,

    COUNT(*) FILTER (
        WHERE cost IS NULL
    ) AS missing_cost

FROM gold.dim_products;


/* ============================================================
   6. DUPLICATE CHECKS
============================================================ */


/* 6.1 Duplicate customer IDs */
SELECT
    customer_id,
    COUNT(*) AS occurrences
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


/* 6.2 Duplicate product IDs */
SELECT
    product_id,
    COUNT(*) AS occurrences
FROM gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


/* 6.3 Duplicate order/product combinations */
SELECT
    order_number,
    product_key,
    COUNT(*) AS occurrences
FROM gold.fact_sales
GROUP BY
    order_number,
    product_key
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


/* ============================================================
   7. KEY VALUE CHECKS
   Understand the basic numerical ranges
============================================================ */
/* 7.1 Sales amount */
SELECT
    MIN(sales_amount) AS minimum_sales,
    MAX(sales_amount) AS maximum_sales,
    ROUND(AVG(sales_amount), 2) AS average_sales,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;


/* 7.2 Quantity */
SELECT
    MIN(quantity) AS minimum_quantity,
    MAX(quantity) AS maximum_quantity,
    ROUND(AVG(quantity), 2) AS average_quantity,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales;


/* 7.3 Price */
SELECT
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    ROUND(AVG(price), 2) AS average_price
FROM gold.fact_sales;


/* 7.4 Product cost */
SELECT
    MIN(cost) AS minimum_cost,
    MAX(cost) AS maximum_cost,
    ROUND(AVG(cost), 2) AS average_cost
FROM gold.dim_products;


/* ============================================================
   8. CHECK SALES VALUES
   Identify unusual or potentially problematic values
============================================================ */


/* 8.1 Zero or negative sales */
SELECT
    COUNT(*) FILTER (
        WHERE sales_amount = 0
    ) AS zero_sales,

    COUNT(*) FILTER (
        WHERE sales_amount < 0
    ) AS negative_sales

FROM gold.fact_sales;


/* 8.2 Zero or negative quantity */
SELECT
    COUNT(*) FILTER (
        WHERE quantity = 0
    ) AS zero_quantity,

    COUNT(*) FILTER (
        WHERE quantity < 0
    ) AS negative_quantity

FROM gold.fact_sales;


/* 8.3 Zero or negative prices */
SELECT
    COUNT(*) FILTER (
        WHERE price = 0
    ) AS zero_price,

    COUNT(*) FILTER (
        WHERE price < 0
    ) AS negative_price

FROM gold.fact_sales;


/* ============================================================
   9. SALES DATE EXPLORATION
============================================================ */
/* 9.1 Sales by year */
SELECT
    EXTRACT(YEAR FROM order_date)::INT AS year,
    SUM(sales_amount) AS revenue,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT order_number) AS orders,
    COUNT(DISTINCT customer_key) AS customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;


/* 9.2 Sales by month */
SELECT
    EXTRACT(MONTH FROM order_date)::INT AS month_number,
    TO_CHAR(order_date, 'Month') AS month,
    SUM(sales_amount) AS revenue,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT order_number) AS orders
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    EXTRACT(MONTH FROM order_date),
    TO_CHAR(order_date, 'Month')
ORDER BY month_number;


/* ============================================================
   10. CUSTOMER EXPLORATION
============================================================ */
/* 10.1 Number of customers */
SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM gold.dim_customers;


/* 10.2 Customers who placed orders */
SELECT
    COUNT(DISTINCT customer_key) AS customers_with_orders
FROM gold.fact_sales;


/* 10.3 Countries represented */
SELECT DISTINCT
    country
FROM gold.dim_customers
ORDER BY country;


/* 10.4 Number of customers by country */
SELECT
    country,
    COUNT(DISTINCT customer_id) AS customers
FROM gold.dim_customers
GROUP BY country
ORDER BY customers DESC;


/* 10.5 Customers by gender */
SELECT
    gender,
    COUNT(DISTINCT customer_id) AS customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY customers DESC;


/* 10.6 Customer birth-date range */
SELECT
    MIN(birth_date) AS oldest_birth_date,
    MAX(birth_date) AS youngest_birth_date
FROM gold.dim_customers;


/* ============================================================
   11. PRODUCT EXPLORATION
============================================================ */
/* 11.1 Number of products */
SELECT
    COUNT(DISTINCT product_id) AS total_products
FROM gold.dim_products;


/* 11.2 Product categories */
SELECT DISTINCT
    category
FROM gold.dim_products
ORDER BY category;


/* 11.3 Product subcategories */
SELECT DISTINCT
    sub_category
FROM gold.dim_products
ORDER BY sub_category;


/* 11.4 Product lines */
SELECT DISTINCT
    product_line
FROM gold.dim_products
ORDER BY product_line;


/* 11.5 Number of products by category */
SELECT
    category,
    COUNT(DISTINCT product_id) AS products
FROM gold.dim_products
GROUP BY category
ORDER BY products DESC;


/* 11.6 Average product cost by category */
SELECT
    category,
    ROUND(AVG(cost), 2) AS average_cost
FROM gold.dim_products
GROUP BY category
ORDER BY average_cost DESC;


/* ============================================================
   12. BASIC SALES DISTRIBUTION
   Understand where sales are coming from before deeper analysis
============================================================ */
/* 12.1 Revenue by category */

SELECT
    p.category,
    SUM(s.sales_amount) AS revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue DESC;


/* 12.2 Revenue by country */
SELECT
    c.country,
    SUM(s.sales_amount) AS revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY revenue DESC;


/* 12.3 Units sold by country */
SELECT
    c.country,
    SUM(s.quantity) AS units_sold
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY units_sold DESC;


/* 12.4 Revenue by product line */
SELECT
    p.product_line,
    SUM(s.sales_amount) AS revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_line
ORDER BY revenue DESC;


/* ============================================================
   13. BASIC BUSINESS KPIs
   Establish the starting point for the later analysis
============================================================ */
SELECT
    SUM(sales_amount) AS total_revenue,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS active_customers,
    SUM(quantity) AS total_units_sold,
    ROUND(AVG(price), 2) AS average_price,
    ROUND(
        SUM(sales_amount)
        / NULLIF(COUNT(DISTINCT order_number), 0),
        2
    ) AS average_order_value
FROM gold.fact_sales;


/* ============================================================
   14. ORDER DISTRIBUTION
============================================================ */
/* Number of orders per customer */

SELECT
    customer_key,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales
GROUP BY customer_key
ORDER BY total_orders DESC;


/* Number of customers by order frequency */
WITH customer_orders AS (
    SELECT
        customer_key,
        COUNT(DISTINCT order_number) AS total_orders
    FROM gold.fact_sales
    GROUP BY customer_key
)

SELECT
    CASE
        WHEN total_orders = 1 THEN '1 Order'
        WHEN total_orders BETWEEN 2 AND 5 THEN '2-5 Orders'
        WHEN total_orders BETWEEN 6 AND 10 THEN '6-10 Orders'
        ELSE 'More than 10 Orders'
    END AS order_frequency,
    COUNT(*) AS customers
FROM customer_orders
GROUP BY
    CASE
        WHEN total_orders = 1 THEN '1 Order'
        WHEN total_orders BETWEEN 2 AND 5 THEN '2-5 Orders'
        WHEN total_orders BETWEEN 6 AND 10 THEN '6-10 Orders'
        ELSE 'More than 10 Orders'
    END
ORDER BY customers DESC;


/* ============================================================
   15. PRODUCT SALES DISTRIBUTION
============================================================ */
/* Top products by revenue */

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


/* Bottom products by revenue */
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


/* ============================================================
   16. CUSTOMER REVENUE DISTRIBUTION
============================================================ */
/* Top customers */

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(s.sales_amount) AS revenue,
    COUNT(DISTINCT s.order_number) AS orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY revenue DESC
LIMIT 10;


/* ============================================================
   17. RELATIONSHIP CHECKS
   Check whether fact records successfully connect to dimensions
============================================================ */
/* Sales records without a matching product */

SELECT
    COUNT(*) AS unmatched_product_records
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
WHERE p.product_key IS NULL;


/* Sales records without a matching customer */
SELECT
    COUNT(*) AS unmatched_customer_records
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

