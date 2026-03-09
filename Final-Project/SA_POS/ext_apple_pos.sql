
--Сreate an extension and a server. To make the script reusable, use IF NOT EXISTS.
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS SA_APPLE_SRV FOREIGN DATA WRAPPER file_fdw;


--Сreate schema. Use IF NOT EXISTS for reusability.
CREATE SCHEMA IF NOT EXISTS SA_APPLE_POS;

--Create External (Foreign) table. To make the script reusable  use IF NOT EXISTS

CREATE FOREIGN TABLE IF NOT EXISTS SA_APPLE_POS.EXT_APPLE_POS (
    	sale_id VARCHAR(255), 
	sale_date VARCHAR(255), 
	year VARCHAR(255), 
	quarter VARCHAR(255), 
	month VARCHAR(255),
    	product_id VARCHAR(255), 
	product_name VARCHAR(255), 
	category_id VARCHAR(255), 
	category_name VARCHAR(255), 
	sub_category_name VARCHAR(255),
    	model_year VARCHAR(255), 
	color VARCHAR(255), 
	storage_capacity VARCHAR(255), 
	warranty_period VARCHAR(255),
    	store_id VARCHAR(255), 
	store_name VARCHAR(255), 
	store_type VARCHAR(255), 
	store_status VARCHAR(255), 
	store_size_sqm VARCHAR(255), 
	opening_year VARCHAR(255), 
	has_genius_bar VARCHAR(255), 
	manager_id VARCHAR(255),
    	employee_id VARCHAR(255), 
	employee_first_name VARCHAR(255), 
	employee_last_name VARCHAR(255), 
	position VARCHAR(255), 
	hire_date VARCHAR(255), 
	employee_email VARCHAR(255), 
	employee_phone VARCHAR(255),
    	loyalty_card_no VARCHAR(255), 
	address_id VARCHAR(255), 
	address VARCHAR(255), 
	global_region VARCHAR(255), 
	country VARCHAR(255), 
	state VARCHAR(255), 
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
    	unit_price VARCHAR(255), 
	unit_cost VARCHAR(255), 
	quantity VARCHAR(255)
) 
SERVER SA_APPLE_SRV
OPTIONS ( filename '/tmp/DWH/src_apple_pos.csv', format 'csv', header 'true' );






