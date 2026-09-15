/*
=======================================================================================================
Quality Checks
=======================================================================================================
Script Purpose:
  This Script performs various quality checks for data consistency, accuracy, and standardization across the'silver' schemsa. It indicates checks for :
      -Null or duplicates in primary keys.
      -Unwanted spaces in strings fields.
      -Data standardization and consistency.
      -Invalid date ranges and orders.
      -Data consistency between related fields.
Usage Notes:
      -Run after loading Silver Layer.
      - Investigate and resolve any discrepancies found during the checks.
=========================================================================================================
*/



--------------------------------CRM--------------------------------------------------------------------

--=============================================================================================
--- Checking 'silver.crm_cust_info'
--=============================================================================================

--- Check for Nulls or Duplicates in Primary Key

SELECT 
cst_id,
COUNT(*)
FROM 
silver.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL
ORDER BY COUNT(*) DESC;


--- Checking for Duplicates

SELECT
*
FROM(
SELECT
*,
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM silver.crm_cust_info) t
WHERE flag_last != 1 
;

----Check date datatype
SELECT pg_typeof(cst_create_date)
FROM silver.crm_cust_info
LIMIT 1;

----- Check for Unwanted Spaces ------
SELECT 
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT 
cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

---Data Standardization and Consistency

SELECT
DISTINCT
cst_marital_status
FROM
silver.crm_cust_info;

SELECT
DISTINCT
cst_gndr
FROM
silver.crm_cust_info;


SELECT * FROM silver.crm_cust




--=============================================================================================
--- Checking 'silver.crm_prd_info'
--=============================================================================================

-- Check for Unwanted Spaces
SELECT 
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


--- Check for NULLS or Negative Numbers
SELECT 
prd_cost,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_cost
HAVING prd_cost IS NULL OR prd_cost < 0

---Data Standardization, Normalization and Conssistency 
SELECT DISTINCT
prd_line
FROM silver.crm_prd_info


--- Check date datatype

SELECT pg_typeof(prd_start_dt),
pg_typeof(prd_end_dt)
FROM silver.crm_prd_info
LIMIT 1;

---Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;



SELECT * FROM silver.crm_prd_info;




--=============================================================================================
--- Checking 'silver.crm_sales_details'
--=============================================================================================

---Check for Unwanted Spaces--------
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE  sls_ord_num != TRIM(sls_ord_num);


--- Check date datatype
SELECT pg_typeof(sls_order_dt)
FROM silver.crm_sales_details
LIMIT 1;


----- Check quality of Order date ---------
SELECT 
sls_order_dt 
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0;


SELECT 
sls_order_dt,
sls_ship_dt,
sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_due_dt OR sls_order_dt > sls_ship_dt; 

------- Check data Consistency: Between Sales, Quantity, and Price
-->>>>>>>> Sales = Quantity * Price
-->>>>>>>> Values must not be NULL, Zero or Negative
SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM  silver.crm_sales_details
WHERE sls_quantity * sls_price != sls_sales 
OR sls_sales <= 0 
OR sls_price <= 0
OR sls_quantity <=0
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL;


SELECT * FROM silver.crm_sales_details;




--------------------------------ERP--------------------------------------------------------------------



--=============================================================================================
--- Checking 'silver.erp_cust_az12'
--=============================================================================================

SELECT 
cid,
bdate,
gen
FROM silver.erp_cust_az12
;


------ Check for Duplicates in Primary Key--------------
SELECT 
cid,
COUNT(*)
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1;

-------Data Transformation---------------------
SELECT 
cid AS id
FROM silver.erp_cust_az12
WHERE
cid NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)
;


-------DataType-------------
SELECT pg_typeof(bdate)
FROM silver.erp_cust_az12
LIMIT 1;


SELECT pg_typeof(gen)
FROM silver.erp_cust_az12
LIMIT 1;

-------Data Standardization & Consistency-----------
SELECT DISTINCT
gen
FROM 
silver.erp_cust_az12;

-------Identify Out of Range date------------------------
SELECT DISTINCT 
bdate
FROM silver.erp_cust_az12
WHERE TO_DATE(bdate, 'DD-MM-YYYY') < '1924-01-01' 
OR TO_DATE(bdate, 'DD-MM-YYYY') > CURRENT_DATE;


SELECT * FROM silver.erp_cust_az12;

--=============================================================================================
--- Checking 'silver.erp_loc_a101'
--=============================================================================================
------ Check for Duplicates in Primary Key --------------
SELECT 
cid,
COUNT(*)
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) >1;

-------- Check for Unwanted Spaces --------
SELECT 
cid
FROM silver.erp_loc_a101
WHERE cid != TRIM(cid);

-------- view data to compare cid --------
SELECT cid FROM silver.erp_loc_a101;
SELECT * FROM silver.erp_cust_az12;

-----------------------Data Consistency ---------------------------------------------
SELECT DISTINCT
cntry
FROM silver.erp_loc_a101;

SELECT * FROM silver.erp_loc_a101;


--=============================================================================================
---- Checking 'silver.erp_px_cat_g1v2'
--=============================================================================================
-----------------------Data Consistency ---------------------------------------------
SELECT DISTINCT
prd_key
FROM silver.crm_prd_info

-----------------------Data Consistency ---------------------------------------------
SELECT DISTINCT
id
FROM bronze.erp_px_cat_g1v2;



------ Check for id with no match in erp_crm_prd_info --------------
SELECT 
id FROM silver.erp_px_cat_g1v2
WHERE id NOT IN 
(SELECT  prd_key FROM silver.crm_prd_info);


SELECT 
* FROM silver.erp_px_cat_g1v2
WHERE id NOT IN 
(SELECT  prd_key FROM silver.crm_prd_info);

SELECT  * FROM silver.crm_prd_info
WHERE prd_key NOT IN (SELECT 
id FROM silver.erp_px_cat_g1v2)
;

SELECT  prd_key FROM silver.crm_prd_info
WHERE prd_key NOT IN (SELECT 
id FROM silver.erp_px_cat_g1v2)
;

-----------------------Check for Unwanted Spaces----------------------------------
SELECT 
* 
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat);



-----------------------Data Consistency ---------------------------------------------
SELECT DISTINCT
subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT
cat
FROM bronze.erp_px_cat_g1v2;


SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2;







