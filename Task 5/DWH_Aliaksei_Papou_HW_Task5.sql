
--Сreate an extension and a server. To make the script reusable, use IF NOT EXISTS.
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS SA_APPLE_SRV FOREIGN DATA WRAPPER file_fdw;


--Сreate schema. Use IF NOT EXISTS for reusability.
CREATE SCHEMA IF NOT EXISTS SA_APPLE_POS;

--Create External (Foreign) table. To make the script reusable, and update data use DROP TABLE IF EXISTS. 
--Wrap in transaction to ensure atomicity, data integrity. (I read that using transactions is best practice)
BEGIN;
DROP FOREIGN TABLE IF EXISTS SA_APPLE_POS.EXT_APPLE_POS;
CREATE FOREIGN TABLE SA_APPLE_POS.EXT_APPLE_POS (
    	sale_id VARCHAR(100), 
	sale_date VARCHAR(100), 
	year VARCHAR(100), 
	quarter VARCHAR(100), 
	month VARCHAR(100),
    	product_id VARCHAR(100), 
	product_name VARCHAR(100), 
	category_id VARCHAR(100), 
	category_name VARCHAR(100), 
	sub_category_name VARCHAR(100),
    	model_year VARCHAR(100), 
	color VARCHAR(100), 
	storage_capacity VARCHAR(100), 
	warranty_period VARCHAR(100),
    	store_id VARCHAR(100), 
	store_name VARCHAR(100), 
	store_type VARCHAR(100), 
	store_status VARCHAR(100), 
	store_size_sqm VARCHAR(100), 
	opening_year VARCHAR(100), 
	has_genius_bar VARCHAR(100), 
	manager_id VARCHAR(100),
    	employee_id VARCHAR(100), 
	employee_first_name VARCHAR(100), 
	employee_last_name VARCHAR(100), 
	position VARCHAR(100), 
	hire_date VARCHAR(100), 
	employee_email VARCHAR(100), 
	employee_phone VARCHAR(100),
    	loyalty_card_no VARCHAR(100), 
	address_id VARCHAR(100), 
	address VARCHAR(100), 
	global_region VARCHAR(100), 
	country VARCHAR(100), 
	state VARCHAR(100), 
	city VARCHAR(100), 
	district VARCHAR(100), 
	postal_code VARCHAR(100),
    	promotion_id VARCHAR(100), 
	promotion_name VARCHAR(100), 
	promotion_type VARCHAR(100), 
	is_active VARCHAR(100), 
	promo_start_date VARCHAR(100), 
	promo_end_date VARCHAR(100), 
	discount_value VARCHAR(100),
    	payment_id VARCHAR(100), 
	payment_method_name VARCHAR(100), 
	payment_type VARCHAR(100), 
	payment_date VARCHAR(100), 
	payment_status VARCHAR(100),
    	unit_price VARCHAR(100), 
	unit_cost VARCHAR(100), 
	quantity VARCHAR(100)
) 
SERVER SA_APPLE_SRV
OPTIONS ( filename '/tmp/DWH/src_apple_pos.csv', format 'csv', header 'true' );
COMMIT;


--Create Source table. Use IF NOT EXISTS for reusability. Use TRUNCATE to clear old data before loading.
--Wrap in transaction to ensure atomicity, data integrity, and handle duplicates via DISTINCT.  

BEGIN;
CREATE TABLE IF NOT EXISTS SA_APPLE_POS.SRC_APPLE_POS (LIKE sa_apple_pos.ext_apple_pos);
TRUNCATE TABLE SA_APPLE_POS.SRC_APPLE_POS; 
INSERT INTO SA_APPLE_POS.SRC_APPLE_POS
SELECT DISTINCT ON (sale_id) * 
FROM SA_APPLE_POS.EXT_APPLE_POS;
COMMIT;


--Сreate schema. Use IF NOT EXISTS for reusability.
CREATE SCHEMA IF NOT EXISTS SA_APPLE_ONLINE;

--Create External (Foreign) table. To make the script reusable, and update data use DROP TABLE IF EXISTS. 
--Wrap in transaction to ensure atomicity, data integrity.
BEGIN;
DROP FOREIGN TABLE IF EXISTS SA_APPLE_ONLINE.EXT_APPLE_ONLINE;
CREATE FOREIGN TABLE SA_APPLE_ONLINE.EXT_APPLE_ONLINE (
    	order_code VARCHAR(100), 
	order_time VARCHAR(100), 
	year VARCHAR(100), 
	quarter VARCHAR(100), 
	month VARCHAR(100),
    	sku_id VARCHAR(100), 
	product_name VARCHAR(100), 
	category_id VARCHAR(100), 
	category_name VARCHAR(100), 
	sub_category_name VARCHAR(100),
    	model_year VARCHAR(100), 
	color VARCHAR(100), 
	storage_capacity VARCHAR(100), 
	warranty_period VARCHAR(100),
    	customer_id VARCHAR(100), 
	first_name VARCHAR(100), 
	last_name VARCHAR(100), 
	age VARCHAR(100), 
	gender VARCHAR(100), 
	segment VARCHAR(100), 
	email VARCHAR(100), 
	phone VARCHAR(100),
    	address_id VARCHAR(100), 
	address VARCHAR(100), 
	country VARCHAR(100), 
	region VARCHAR(100), 
	city VARCHAR(100), 
	district VARCHAR(100), 
	postal_code VARCHAR(100),
    	promotion_id VARCHAR(100), 
	promotion_name VARCHAR(100), 
	promotion_type VARCHAR(100), 
	is_active VARCHAR(100), 
	promo_start_date VARCHAR(100), 
	promo_end_date VARCHAR(100), 
	discount_value VARCHAR(100),
    	payment_id VARCHAR(100), 
	payment_method_name VARCHAR(100), 
	payment_type VARCHAR(100), 
	payment_date VARCHAR(100), 
	payment_status VARCHAR(100),
    	list_price VARCHAR(100), 
	unit_cost VARCHAR(100), 
	qty VARCHAR(100)
) 
SERVER SA_APPLE_SRV
OPTIONS ( filename '/tmp/DWH/src_apple_online.csv', format 'csv', header 'true' );
COMMIT;

--Create Source table. Use IF NOT EXISTS for reusability. Use TRUNCATE to clear old data before loading.
--Wrap in transaction to ensure atomicity, data integrity, and handle duplicates via DISTINCT. 
BEGIN;
CREATE TABLE IF NOT EXISTS SA_APPLE_ONLINE.SRC_APPLE_ONLINE (LIKE SA_APPLE_ONLINE.EXT_APPLE_ONLINE);
TRUNCATE TABLE SA_APPLE_ONLINE.SRC_APPLE_ONLINE; 
INSERT INTO SA_APPLE_ONLINE.SRC_APPLE_ONLINE
SELECT DISTINCT ON (order_code) * 
FROM SA_APPLE_ONLINE.EXT_APPLE_ONLINE;
COMMIT;













