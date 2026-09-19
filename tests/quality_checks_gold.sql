/*
========================================================================================================================================
Quality Checks
========================================================================================================================================
Script Purpose:
  This script performs quality check to validate the integrity, consistency, and accuracy of the Gold layer. These checks ensures:
  - Uniqueness of surrogate keys in dimension tables.
  - Referential Integrity between facts and dimension tables.
  - Validation of relationships in the data model for analytical purposes.


Usage 
  - Run these checks after data loading the gold layer
  - Investigate and resolve discepancies found during the checks
========================================================================================================================================
*/


--========================================================================================================================================
-- Checking gold.dim_customers
--========================================================================================================================================
-- Check for uniqueness of customer key in gold.dim_customers
-- Expectation: no result
SELECT 
    customer_key,
    COUNT(*)
FROM gold.dim_customers
GROUP BY customer_key
HAVING   COUNT(*) > 1




--========================================================================================================================================
-- Checking gold.dim_products
--========================================================================================================================================
-- Check for uniqueness of product key in gold.dim_products
-- Expectation: no result

SELECT 
    product_key,
    COUNT(*)
FROM gold.dim_product
GROUP BY product_key
HAVING   COUNT(*) > 1

