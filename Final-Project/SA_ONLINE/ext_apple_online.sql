
--Сreate an extension and a server. To make the script reusable, use IF NOT EXISTS.
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS SA_APPLE_SRV FOREIGN DATA WRAPPER file_fdw;


--Сreate schema. Use IF NOT EXISTS for reusability.
CREATE SCHEMA IF NOT EXISTS SA_APPLE_ONLINE;

--Create External (Foreign) table. To make the script reusable use IF NOT EXISTS. 

CREATE FOREIGN TABLE IF NOT EXISTS SA_APPLE_ONLINE.EXT_APPLE_ONLINE (
    	order_code VARCHAR(255), 
	order_time VARCHAR(255), 
	year VARCHAR(255), 
	quarter VARCHAR(255), 
	month VARCHAR(255),
    	sku_id VARCHAR(255), 
	product_name VARCHAR(255), 
	category_id VARCHAR(255), 
	category_name VARCHAR(255), 
	sub_category_name VARCHAR(255),
    	model_year VARCHAR(255), 
	color VARCHAR(255), 
	storage_capacity VARCHAR(255), 
	warranty_period VARCHAR(255),
    	customer_id VARCHAR(255), 
	first_name VARCHAR(255), 
	last_name VARCHAR(255), 
	age VARCHAR(255), 
	gender VARCHAR(255), 
	segment VARCHAR(255), 
	email VARCHAR(255), 
	phone VARCHAR(255),
    	address_id VARCHAR(255), 
	address VARCHAR(255), 
	country VARCHAR(255), 
	region VARCHAR(255), 
	city VARCHAR(255), 
	district VARCHAR(255), 
	postal_code VARCHAR(255),
    	promotion_id VARCHAR(255), 
	promotion_name VARCHAR(255), 
	promotion_type VARCHAR(255), 
	is_active VARCHAR(255), 
	promo_start_date VARCHAR(255), 
	promo_end_date VARCHAR(255), 
	discount_value VARCHAR(255),
	payment_method_name VARCHAR(255), 
	payment_type VARCHAR(255), 
    	list_price VARCHAR(255), 
	unit_cost VARCHAR(255), 
	qty VARCHAR(255)
) 
SERVER SA_APPLE_SRV
OPTIONS ( filename '/tmp/DWH/src_apple_online.csv', format 'csv', header 'true' );



