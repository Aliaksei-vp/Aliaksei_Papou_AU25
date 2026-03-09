
--Create Source table. Use IF NOT EXISTS for reusability. 
--Wrap in transaction to ensure atomicity, data integrity.  

BEGIN;
CREATE TABLE IF NOT EXISTS SA_APPLE_POS.SRC_APPLE_POS (LIKE sa_apple_pos.ext_apple_pos, insert_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

INSERT INTO SA_APPLE_POS.SRC_APPLE_POS (
    sale_id, sale_date, year, quarter, month, product_id, product_name, category_id, category_name, sub_category_name,
    model_year, color, storage_capacity, warranty_period, store_id, store_name, store_type, store_status, store_size_sqm, opening_year,
    has_genius_bar, manager_id, employee_id, employee_first_name, employee_last_name, position, hire_date, employee_email, employee_phone,
    loyalty_card_no, address_id, address, global_region, country, state, city, district, postal_code, promotion_id, promotion_name,
    promotion_type, is_active, promo_start_date, promo_end_date, discount_value, payment_method_name, payment_type,
    unit_price, unit_cost, quantity, insert_dt
)
SELECT 
    sale_id, sale_date, year, quarter, month, product_id, product_name, category_id, category_name, sub_category_name,
    model_year, color, storage_capacity, warranty_period, store_id, store_name, store_type, store_status, store_size_sqm, opening_year,
    has_genius_bar, manager_id, employee_id, employee_first_name, employee_last_name, position, hire_date, employee_email, employee_phone,
    loyalty_card_no, address_id, address, global_region, country, state, city, district, postal_code, promotion_id, promotion_name,
    promotion_type, is_active, promo_start_date, promo_end_date, discount_value, payment_method_name, payment_type,
    unit_price, unit_cost, quantity, CURRENT_TIMESTAMP
FROM SA_APPLE_POS.EXT_APPLE_POS;
COMMIT;


