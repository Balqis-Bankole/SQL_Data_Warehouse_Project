/* 
==============================================================
Create Database and Schemas
==============================================================
Script purpose:
This script creates the data warehouse database and the bronze, silver, and gold schemas.
*/
-- Create the data warehouse database.
CREATE DATABASE data_warehouse;

-- Create the schemas.
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
