
--Сreate an extension and a server. To make the script reusable, use IF NOT EXISTS.
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS SA_APPLE_SRV FOREIGN DATA WRAPPER file_fdw;


--Сreate schema. Use IF NOT EXISTS for reusability.
CREATE SCHEMA IF NOT EXISTS SA_APPLE_POS;

--Create External (Foreign) table. To make the script reusable  use IF NOT EXISTS
--Wrap in transaction to ensure atomicity, data integrity. (I read that using transactions is best practice)
BEGIN;
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
    	payment_id VARCHAR(255), 
	payment_method_name VARCHAR(255), 
	payment_type VARCHAR(255), 
	payment_date VARCHAR(255), 
	payment_status VARCHAR(255),
    	unit_price VARCHAR(255), 
	unit_cost VARCHAR(255), 
	quantity VARCHAR(255)
) 
SERVER SA_APPLE_SRV
OPTIONS ( filename '/tmp/DWH/src_apple_pos.csv', format 'csv', header 'true' );
COMMIT;


--Create Source table. Use IF NOT EXISTS for reusability. 
--Wrap in transaction to ensure atomicity, data integrity.  

BEGIN;
CREATE TABLE IF NOT EXISTS SA_APPLE_POS.SRC_APPLE_POS (LIKE sa_apple_pos.ext_apple_pos, insert_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

INSERT INTO SA_APPLE_POS.SRC_APPLE_POS (
    sale_id, sale_date, year, quarter, month, product_id, product_name, category_id, category_name, sub_category_name,
    model_year, color, storage_capacity, warranty_period, store_id, store_name, store_type, store_status, store_size_sqm, opening_year,
    has_genius_bar, manager_id, employee_id, employee_first_name, employee_last_name, position, hire_date, employee_email, employee_phone,
    loyalty_card_no, address_id, address, global_region, country, state, city, district, postal_code, promotion_id, promotion_name,
    promotion_type, is_active, promo_start_date, promo_end_date, discount_value, payment_id, payment_method_name, payment_type,
    payment_date, payment_status, unit_price, unit_cost, quantity, insert_dt
)
SELECT 
    sale_id, sale_date, year, quarter, month, product_id, product_name, category_id, category_name, sub_category_name,
    model_year, color, storage_capacity, warranty_period, store_id, store_name, store_type, store_status, store_size_sqm, opening_year,
    has_genius_bar, manager_id, employee_id, employee_first_name, employee_last_name, position, hire_date, employee_email, employee_phone,
    loyalty_card_no, address_id, address, global_region, country, state, city, district, postal_code, promotion_id, promotion_name,
    promotion_type, is_active, promo_start_date, promo_end_date, discount_value, payment_id, payment_method_name, payment_type,
    payment_date, payment_status, unit_price, unit_cost, quantity, CURRENT_TIMESTAMP
FROM SA_APPLE_POS.EXT_APPLE_POS;
COMMIT;


--Сreate schema. Use IF NOT EXISTS for reusability.
CREATE SCHEMA IF NOT EXISTS SA_APPLE_ONLINE;

--Create External (Foreign) table. To make the script reusable use IF NOT EXISTS. 
--Wrap in transaction to ensure atomicity, data integrity.
BEGIN;
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
    	payment_id VARCHAR(255), 
	payment_method_name VARCHAR(255), 
	payment_type VARCHAR(255), 
	payment_date VARCHAR(255), 
	payment_status VARCHAR(255),
    	list_price VARCHAR(255), 
	unit_cost VARCHAR(255), 
	qty VARCHAR(255)
) 
SERVER SA_APPLE_SRV
OPTIONS ( filename '/tmp/DWH/src_apple_online.csv', format 'csv', header 'true' );
COMMIT;

--Create Source table. Use IF NOT EXISTS for reusability. 
--Wrap in transaction to ensure atomicity, data integrity. 
BEGIN;
CREATE TABLE IF NOT EXISTS SA_APPLE_ONLINE.SRC_APPLE_ONLINE (LIKE SA_APPLE_ONLINE.EXT_APPLE_ONLINE, insert_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
INSERT INTO SA_APPLE_ONLINE.SRC_APPLE_ONLINE (
    order_code, order_time, year, quarter, month, sku_id, product_name, category_id, category_name, sub_category_name,
    model_year, color, storage_capacity, warranty_period, customer_id, first_name, last_name, age, gender, segment,
    email, phone, address_id, address, country, region, city, district, postal_code, promotion_id,
    promotion_name, promotion_type, is_active, promo_start_date, promo_end_date, discount_value, payment_id,
    payment_method_name, payment_type, payment_date, payment_status, list_price, unit_cost, qty, insert_dt
)
SELECT 
    order_code, order_time, year, quarter, month, sku_id, product_name, category_id, category_name, sub_category_name,
    model_year, color, storage_capacity, warranty_period, customer_id, first_name, last_name, age, gender, segment,
    email, phone, address_id, address, country, region, city, district, postal_code, promotion_id,
    promotion_name, promotion_type, is_active, promo_start_date, promo_end_date, discount_value, payment_id,
    payment_method_name, payment_type, payment_date, payment_status, list_price, unit_cost, qty, CURRENT_TIMESTAMP
FROM SA_APPLE_ONLINE.EXT_APPLE_ONLINE;
COMMIT;













