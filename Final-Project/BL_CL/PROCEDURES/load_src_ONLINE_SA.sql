
--Create a procedure to load SRC_APPLE_ONLINE
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_SRC_APPLE_ONLINE()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_SRC_APPLE_ONLINE';
    v_rows_cnt INT := 0;
BEGIN
    INSERT INTO SA_APPLE_ONLINE.SRC_APPLE_ONLINE (
        order_code, order_time, year, quarter, month, sku_id, product_name, category_id, category_name, sub_category_name,
        model_year, color, storage_capacity, warranty_period, customer_id, first_name, last_name, age, gender, segment,
        email, phone, address_id, address, country, region, city, district, postal_code, promotion_id,
        promotion_name, promotion_type, is_active, promo_start_date, promo_end_date, discount_value, 
        payment_method_name, payment_type, list_price, unit_cost, qty, insert_dt)
    SELECT 
        order_code, order_time, year, quarter, month, sku_id, product_name, category_id, category_name, sub_category_name,
        model_year, color, storage_capacity, warranty_period, customer_id, first_name, last_name, age, gender, segment,
        email, phone, address_id, address, country, region, city, district, postal_code, promotion_id,
        promotion_name, promotion_type, is_active, promo_start_date, promo_end_date, discount_value, 
        payment_method_name, payment_type, list_price, unit_cost, qty, CURRENT_TIMESTAMP
    FROM SA_APPLE_ONLINE.EXT_APPLE_ONLINE;
    GET DIAGNOSTICS v_rows_cnt = ROW_COUNT;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows_cnt, 'SUCCESS', 'SRC ONLINE load from external table finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;




