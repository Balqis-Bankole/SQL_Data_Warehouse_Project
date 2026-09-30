SELECT * FROM gold.fact_sales

------------Change Over Time Analysis--------------
--- Analyze Sales Performance Over Time
SELECT
order_date,
SUM(sales_amount) revenue
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date


-----Analyze Sales Performance Over Time BY YEAR
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(sales_amount) AS revenue
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;


SELECT 
    DATE_PART('YEAR',  order_date) AS year,
    SUM(sales_amount) AS revenue,
    COUNT(DISTINCT customer_key) customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('YEAR',  order_date)
ORDER BY year;


SELECT 
    DATE_PART('YEAR',  order_date) AS year,
    DATE_PART('MONTH',  order_date) AS month,
    SUM(sales_amount) AS revenue,
    COUNT(DISTINCT customer_key) customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('MONTH',  order_date), DATE_PART('YEAR',  order_date) 
ORDER BY year;


-----Analyze Sales Performance Over Time BY month

SELECT 
    TO_CHAR(order_date, 'Month') AS month,
    SUM(sales_amount) AS revenue,
    COUNT(DISTINCT customer_key) customers,
    SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY TO_CHAR(order_date, 'Month'), DATE_PART('Month', order_date) 
ORDER BY DATE_PART('Month', order_date);

SELECT 
    TO_CHAR(order_date, 'YYYY-Month') AS month,
    SUM(sales_amount) AS revenue,
    COUNT(DISTINCT customer_key) customers,
    SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY TO_CHAR(order_date, 'YYYY-Month'), DATE_PART('month', order_date) 
ORDER BY DATE_PART('month', order_date);



--------Cummulative Analysis------------------

---Calculate the total sales per month and the running total of sales over time

SELECT 
*
FROM gold.fact_sales

--------Running total/year
SELECT
TO_CHAR(mnth, 'YYYY-Month') mnths,
sales,
SUM(sales) OVER(PARTITION BY mnth ORDER BY DATE_TRUNC('Month', mnth) ASC  )
FROM(
    SELECT 
    DATE_TRUNC('Month', order_date) AS mnth,
    SUM(sales_amount) sales
    FROM gold.fact_sales
    WHERE DATE_TRUNC('Month', order_date) IS NOT NULL
    GROUP BY DATE_TRUNC('Month', order_date)
)

SELECT
TO_CHAR(mnth, 'YYYY-Month') mnths,
sales,
SUM(sales) OVER(PARTITION BY DATE_TRUNC('Year', mnth) ORDER BY DATE_TRUNC('Month', mnth) ASC  )
FROM(
    SELECT 
    DATE_TRUNC('Month', order_date) AS mnth,
    SUM(sales_amount) sales
    FROM gold.fact_sales
      WHERE DATE_TRUNC('Month', order_date) IS NOT NULL
    GROUP BY DATE_TRUNC('Month', order_date)
)
-------running total overtime-------------
----months overtime
SELECT
TO_CHAR(mnth, 'YYYY-Month') mnths,
sales,
CONCAT('$', SUM(sales) OVER(ORDER BY DATE_TRUNC('Month', mnth) ASC))running_total_sales
FROM(
    SELECT 
    DATE_TRUNC('Month', order_date) AS mnth,
    SUM(sales_amount) sales
    FROM gold.fact_sales
    WHERE DATE_TRUNC('Month', order_date) IS NOT NULL
    GROUP BY DATE_TRUNC('Month', order_date)
)

------year overtime
SELECT
TO_CHAR(mnth,'YYYY') mnths,
sales,
SUM(sales) OVER( ORDER BY DATE_TRUNC('Year', mnth) ASC ) running_total
FROM(
    SELECT 
    DATE_TRUNC('Year', order_date) AS mnth,
    SUM(sales_amount) sales
    FROM gold.fact_sales
    WHERE DATE_TRUNC('Month', order_date) IS NOT NULL
    GROUP BY DATE_TRUNC('Year', order_date)
)
-------- calculate the moving average
----- yearly(monthly) moving average 

SELECT
TO_CHAR(mnth, 'YYYY-Month') mnths,
sales,
SUM(sales) OVER(PARTITION BY DATE_TRUNC('Year', mnth) ORDER BY DATE_TRUNC('Month', mnth) ASC) running_total,
avg_sales,
AVG(avg_sales) OVER (PARTITION BY DATE_TRUNC('Year', mnth) ORDER BY DATE_TRUNC('Month', mnth) ASC) moving_avg
FROM(
    SELECT 
    DATE_TRUNC('Month', order_date) AS mnth,
    SUM(sales_amount) sales,
    AVG(sales_amount) avg_sales
    FROM gold.fact_sales
    WHERE DATE_TRUNC('Month', order_date) IS NOT NULL
    GROUP BY DATE_TRUNC('Month', order_date)
)

------- 5 years(monthly) moving average 2010, 2011, 2012, 2013, 2014
SELECT
TO_CHAR(mnth, 'YYYY-Month') mnths,
sales,
CONCAT('$', SUM(sales) OVER(ORDER BY DATE_TRUNC('Month', mnth) ASC))running_total_sales,
avg_price,
AVG(avg_price) OVER (ORDER BY DATE_TRUNC('Month', mnth) ASC) moving_avg
FROM(
    SELECT 
    DATE_TRUNC('Month', order_date) AS mnth,
    SUM(sales_amount) sales,
    AVG(sales_amount) avg_price
    FROM gold.fact_sales
    WHERE DATE_TRUNC('Month', order_date) IS NOT NULL
    GROUP BY DATE_TRUNC('Month', order_date)
)




-----------------Performance Analysis-------------------------

---Analyze the yearly performance of products by comparing each product's sales 
---to both its average sales performance and the previous year's sales

WITH product_yearly_performance AS
(
    SELECT 
    TO_CHAR(s.order_date, 'YYYY') datee,
    p.product_name,
    SUM(s.sales_amount) total_amount,
    AVG(SUM(s.sales_amount)) OVER(PARTITION BY p.product_name) avg_salesprice
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
    LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
    WHERE TO_CHAR(s.order_date, 'YYYY')  IS NOT NULL
    GROUP BY p.product_name, 
    TO_CHAR(s.order_date, 'YYYY')
)
SELECT 
datee,
product_name,
ROUND(total_amount,2) current_totalsales,
ROUND((avg_salesprice),2) avg_sales,
ROUND((total_amount),2) - ROUND((avg_salesprice),2) AS diff_avg,
CASE WHEN ROUND((total_amount),2) - ROUND((avg_salesprice),2) > 0 THEN 'Above Avg'
    WHEN ROUND((total_amount),2) - ROUND((avg_salesprice),2) < 0 THEN 'Below Avg'
    ELSE 'Avg'
END diff_avgstatement,
LAG(ROUND(total_amount,2) ) OVER(PARTITION BY product_name ORDER BY datee) prev_year_sales,
ROUND(total_amount,2)- LAG(ROUND(total_amount,2) ) OVER(PARTITION BY product_name ORDER BY datee) diff_ps,
CASE WHEN ROUND(total_amount,2)- LAG(ROUND(total_amount,2) ) OVER(PARTITION BY product_name ORDER BY datee) > 0 THEN 'Increase'
    WHEN ROUND(total_amount,2)- LAG(ROUND(total_amount,2) ) OVER(PARTITION BY product_name ORDER BY datee) < 0 THEN 'Decrease'
    ELSE 'No Change'
END diff_statement
FROM product_yearly_performance



SELECT
customer_key,
order_date
FROM  gold.fact_sales
ORDER BY customer_key

COUNT(customer_key) * 

LAG(SUM(s.sales_amount)) OVER(PARTITION BY p.product_name ORDER BY TO_CHAR(s.order_date, 'YYYY') )
ORDER BY p.product_name,TO_CHAR(s.order_date, 'YYYY')



------------Part-to-Whole Analysis--------------
--- Which category contribute the most to overrall sales
SELECT * FROM gold.dim_products;
SELECT * FROM gold.fact_sales;


SELECT 
category,
totalsales, 
SUM(totalsales) OVER() overalltotal,
CONCAT(ROUND(totalsales/ SUM(totalsales) OVER ()* 100, 1),'%') part
FROM
    (SELECT 
    p.category,
    SUM(s.sales_amount) totalsales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
    GROUP BY p.category)



WITH initial AS (
    SELECT 
    p.category,
    SUM(s.sales_amount) totalsales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
    GROUP BY p.category
)
SELECT 
category,
totalsales, 
SUM(totalsales) OVER() overalltotal,
CONCAT (ROUND(totalsales / SUM(totalsales) OVER () * 100, 3), '%')part
FROM initial



------------------Customer Segmentation---------------------
----Segment products into cost ranges and count how many products fall into each segments.

WITH product_price_category AS(
    SELECT 
    product_key,
    product_name,
    cost,
    CASE WHEN cost < 100 THEN 'Below 100'
        WHEN cost BETWEEN 100 AND 500 THEN '100-500'
        WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
        ELSE 'Above 1000'
    END cost_range
    FROM gold.dim_products
)
SELECT * FROM(
SELECT DISTINCT
COUNT(*) OVER(PARTITION BY cost_range ) AS count,
cost_range
FROM product_price_category)
ORDER BY count DESC;

-- Group customers into three segments based on their spending behaviour 

WITH main AS(
    SELECT
    c.customer_key,
    CONCAT(c.first_name, ' ', c.last_name) customersname,
    SUM(s.sales_amount) total,
    MIN(s.order_date) min_date,
    MAX(s.order_date) max_date,
    EXTRACT(YEAR FROM AGE(MAX(s.order_date), MIN(s.order_date))) * 12  + EXTRACT(Month FROM  AGE(MAX(s.order_date), MIN(s.order_date)))age
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
    GROUP BY c.customer_key, CONCAT(c.first_name, ' ', c.last_name)
)
SELECT
COUNT(customer_key) total_customers,
 spending_behaviour
FROM (
 SELECT
 customer_key,
 customersname,
 total,
 min_date,
 max_date,
 age,
 CASE WHEN age >= 12 AND total > 5000 THEN 'VIP'
    WHEN age >= 12 AND total <= 5000 THEN 'Regular'
    ELSE 'New'
END spending_behaviour
FROM main)
GROUP BY  spending_behaviour
ORDER BY COUNT(customer_key) DESC;
