/* 
=============================================================================================================================================================
DDL SCRIPT : Create Gold Views
=============================================================================================================================================================
Script Purpose:
  This Script creates views for the Gold layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables (Star Schema)
  
  Each view performs transformations and combines data from the silver layer to produce a clean, enriched, and business-ready dataset.


Usage:
  - These views can be queried directly for analytics and reporting
=============================================================================================================================================================
*/

--=============================================================================================================================================================
-- Create Dimension: gold.dim_customers
--=============================================================================================================================================================

CREATE VIEW gold.dim_customers AS
SELECT  
    ROW_NUMBER() OVER(ORDER BY cst_id) customer_key,
    ci.cst_id customer_id,
    ci.cst_key customer_number,
    ci.cst_firstname first_name,
    ci.cst_lastname last_name,
    la.cntry country,
    ci.cst_marital_status marital_status,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END gender,
    ca.bdate birth_date,
    ci.cst_create_date create_date
    
  
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON   ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;


--=============================================================================================================================================================
-- Create Dimension: gold_dim_products
--=============================================================================================================================================================

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY  pi.prd_start_dt, pi.prd_key) product_key,
    pi.prd_id product_id,
    pi.prd_key category_id,
    pi.prd_nm product_name,
    pi.cat_id product_number,
    pc.cat category,
    pc.subcat sub_category,
    pc.maintenance,
    pi.prd_cost cost,
    pi.prd_line product_line,
    pi.prd_start_dt start_date

FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON   pi.prd_key = pc.id
WHERE prd_end_dt IS NULL; -------Filter out all historical data

--=============================================================================================================================================================
-- Creat Fact: gold_fact_sales
--=============================================================================================================================================================

CREATE VIEW gold.fact_sales AS
SELECT 
sd.sls_ord_num order_number,
gp.product_key,
gc.customer_key,
sd.sls_order_dt order_date,
sd.sls_ship_dt shipping_date,
sd.sls_due_dt due_date,
sd.sls_sales sales_amount,
sd.sls_quantity quantity,
sd.sls_price price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customers gc
ON sd.sls_cust_id = gc.customer_id
LEFT JOIN gold.dim_products gp
ON sd.sls_prd_key = gp.product_number;
