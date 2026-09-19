# Gold Layer Data Dictionary

## Overview

The Gold Layer is the business-level data representation designed to support analytical and reporting use cases. It consists of dimension tables and fact tables that organise business entities and metrics into a structure suitable for analysis.

---

## 1. gold.dim_customers

### Purpose

Stores customer details enriched with demographic and geographic information.

### Columns

| Column | Data Type | Description |
|---|---|---|
| customer_key | INT | Surrogate key that uniquely identifies each customer record in the dimension table. |
| customer_id | INT | Unique numerical identifier assigned to the customer. |
| customer_number | VARCHAR | Alphanumeric identifier assigned to the customer for tracking and reference. |
| first_name | VARCHAR | The customer's first name as recorded in the system. |
| last_name | VARCHAR | The customer's last or family name. |
| country | VARCHAR | The customer's country of residence. |
| marital_status | VARCHAR | The customer's marital status, such as Married or Single. |
| gender | VARCHAR | The customer's gender, such as Male, Female, or n/a. |
| birthdate | DATE | The customer's date of birth, stored in YYYY-MM-DD format. |
| create_date | DATE | The date on which the customer record was created in the system. |

---

## 2. gold.dim_products

### Purpose

Provides information about products and their attributes, including category, product line, cost, and availability.

### Columns

| Column | Data Type | Description |
|---|---|---|
| product_id | INT | Unique identifier for each product record in the product dimension. |
| product_number | INT | Structured identifier representing the product for tracking and reference. |
| product_name | VARCHAR | Descriptive name of the product, including relevant product details. |
| category_id | VARCHAR | Unique identifier for the product category. |
| category | VARCHAR | High-level classification used to group related products, such as Bikes or Components. |
| subcategory | VARCHAR | More detailed classification of the product within its category. |
| maintenance | VARCHAR | Indicates whether the product requires maintenance, such as Yes or No. |
| cost | INT | The base cost of the product, measured in monetary units. |
| product_line | VARCHAR | The product line or series to which the product belongs, such as Road or Mountain. |
| start_date | DATE | The date when the product became available for sale or use. |

---

## 3. gold.fact_sales

### Purpose

Stores transactional sales data used for business analysis and reporting.

### Columns

| Column | Data Type | Description |
|---|---|---|
| order_number | VARCHAR | Unique alphanumeric identifier for each sales order. |
| product_key | INT | Surrogate key linking the sales transaction to the product dimension. |
| customer_key | INT | Surrogate key linking the sales transaction to the customer dimension. |
| order_date | DATE | The date when the order was placed. |
| shipping_date | DATE | The date when the order was shipped to the customer. |
| due_date | DATE | The date when payment for the order was due. |
| sales_amount | INT | Total monetary value of the sale for the line item. |
| quantity | INT | Number of units of the product ordered for the line item. |
| price | INT | Price per unit of the product for the line item. |

---

## Gold Layer Structure

The Gold Layer follows a dimensional modelling approach.

### Dimension Tables

Dimension tables provide descriptive information about business entities:

- gold.dim_customers
- gold.dim_products

### Fact Tables

Fact tables store measurable business events and metrics:

- gold.fact_sales

### Relationships

The Gold Layer allows sales transactions to be analysed across different business dimensions, including:

- Customers
- Products
- Product categories
- Geography
- Dates
- Sales metrics

This structure supports analytical queries, reporting, dashboards, and business intelligence use cases.


