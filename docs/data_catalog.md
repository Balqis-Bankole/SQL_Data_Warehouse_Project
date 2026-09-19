Data Dictionary for Gold Layer

Overview

The Gold layer is the business level data representation structured to support analytical and reporting use cases. it consists of dimension tables and fact tables for specific business metrics

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

1. gold.dim_customers

   Purpose: Stores customer details enriched with demographic and geographic data.
   Columns

   |Column | Data Type | Description|
   customer_key | INT | Surragate key uniquely identifying each customer record in the dimension table.
   customer_id | INT | Unique numerical identifier assigned to each customer.
   customer_number | VARCHAR | Alphanumeric identifier representing the customer used for tracking and referencing,
   first_name | VARCHAR | The customer's first name as recorded in the system.
   last_name | VARCHAR | The customer's last name of family name.
   country | VARCHAR | The country of residence for the customer (e.g. 'Australia').
   marital_status | VARCHAR | The marital status of  the customer(e.g. 'Married', 'Single').
   gender | VARCHAR | The gender of the customer (e.g. 'Male', 'Female', 'n/a').
   birthdate | DATE | The date of birth of the customer, formatted as YYYY-MM-DD (e.g. 1971-10-06).
   create_date | DATE | The date and time when the customer record was created in the system.



2. gold.dim_products

   Purpose: Provides information about the products and their attributes.
   Columns

   |Column | Data Type | Description|
   product_id | INT | Surrogate key uniquely identifying each product record in the product dimension table.
   product_number | INT | A structured alphanumeric code representing the product, often used for categorization or inventory.
   product_name | VARCHAR | Descriptive name of the product, including key details such as type, code, and size.
   category_id | VARCHAR | A unique identifier for the product's category, linking to it's high-level classification.
   category | VARCHAR | A broader classification of the product (e.g. Bikes, Components) to group related items.
   subcategory | VARCHAR | A more detailed classification of the product within the category, such as product type.
   maintenance | VARCHAR | Indicates whether the product requires maintenance (e.g. 'Yes', 'No').
   cost | INT | The cost or base price of the product, measured in monetary units.
   product_line | VARCHAR | The specific product line or series to which the product belongs (e.g. Road, Mountain).
   start_date | DATE | The date when the product became available for sale or use, stored in. 

3. gold.fact_sales
   
   Purpose: Stores transactional sales data for analytical purposes.
   Columns

   |Column | Data Type | Description|
   order_number | VARCHAR | A unique alphanumeric identifier for each sales order (e.g. 'SOS4496').
   product_key | INT | Surrogate key linking the order to the product dimension table.
   customer_key | INT | Surrogate key linking the order to the customer dimension table.
   order_date | DATE | The date when the order was placed. 
   shipping date | DATE | The date when the order was shipped to the customer.
   due_date | DATE | The date when the order payment was due.
   sales_amount | INT | The total monetery value of the sale for the line item, in whole currency units (e.g. 25).
   quantity | INT | The number of units of the products ordere for the line item (e.g. 1).
   price | INT | The price per unit of the product for the line item, in whole currency unit (e.g. 25).


