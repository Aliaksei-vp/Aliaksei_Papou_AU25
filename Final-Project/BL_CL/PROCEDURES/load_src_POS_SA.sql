
--Create a procedure to load SRC_APPLE_POS
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_SRC_APPLE_POS()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_SRC_APPLE_POS';
    v_rows_cnt INT := 0;
BEGIN
    INSERT INTO SA_APPLE_POS.SRC_APPLE_POS (
        sale_id, sale_date, year, quarter, month, product_id, product_name, category_id, category_name, sub_category_name,
        model_year, color, storage_capacity, warranty_period, store_id, store_name, store_type, store_status, store_size_sqm, opening_year,
        has_genius_bar, manager_id, employee_id, employee_first_name, employee_last_name, position, hire_date, employee_email, employee_phone,
        loyalty_card_no, address_id, address, global_region, country, state, city, district, postal_code, promotion_id, promotion_name,
        promotion_type, is_active, promo_start_date, promo_end_date, discount_value, payment_method_name, payment_type,
        unit_price, unit_cost, quantity, insert_dt)
    SELECT 
        sale_id, sale_date, year, quarter, month, product_id, product_name, category_id, category_name, sub_category_name,
        model_year, color, storage_capacity, warranty_period, store_id, store_name, store_type, store_status, store_size_sqm, opening_year,
        has_genius_bar, manager_id, employee_id, employee_first_name, employee_last_name, position, hire_date, employee_email, employee_phone,
        loyalty_card_no, address_id, address, global_region, country, state, city, district, postal_code, promotion_id, promotion_name,
        promotion_type, is_active, promo_start_date, promo_end_date, discount_value, payment_method_name, payment_type,
        unit_price, unit_cost, quantity, CURRENT_TIMESTAMP
    FROM SA_APPLE_POS.EXT_APPLE_POS;
    GET DIAGNOSTICS v_rows_cnt = ROW_COUNT;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows_cnt, 'SUCCESS', 'SRC POS load from external table finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;




