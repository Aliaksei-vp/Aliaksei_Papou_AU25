
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
