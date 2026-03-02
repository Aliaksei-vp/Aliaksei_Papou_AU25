
--Create a procedure for load CE_SALES table (BL_3NF)
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_SALES_INCREMENTAL()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_SALES_INCREMENTAL';
    v_rows_cnt INT := 0;
BEGIN
    INSERT INTO BL_3NF.CE_SALES (
        SALE_ID, SALE_SRC_ID, SALE_CHANNEL, SALE_DATE, 
        PRODUCT_ID, CUSTOMER_ID, STORE_ID, EMPLOYEE_ID, 
        PROMOTION_ID, PAYMENT_METHOD_ID, ADDRESS_ID, 
        DISCOUNT_VALUE, QUANTITY, UNIT_PRICE, UNIT_COST, INSERT_DT)
    WITH all_sales_src AS (
        SELECT DISTINCT ON (sub.SALE_SRC_ID, sub.SALE_CHANNEL) 
            sub.SALE_SRC_ID, sub.SALE_CHANNEL, sub.S_DATE, sub.PRODUCT_SRC_ID,
            sub.CUSTOMER_SRC_ID, sub.STORE_SRC_ID, sub.EMPLOYEE_SRC_ID, sub.PROMOTION_SRC_ID,
            sub.PM_NAME, sub.ADDRESS_SRC_ID, sub.DISCOUNT_VALUE, sub.QUANTITY, 
            sub.UNIT_PRICE, sub.UNIT_COST, sub.SRC_SYS, sub.SRC_ENT
        FROM (
            SELECT 
                UPPER(TRIM(sale_id)) AS SALE_SRC_ID, 
                'POS' AS SALE_CHANNEL, 
                sale_date::TIMESTAMP AS S_DATE, 
                UPPER(TRIM(product_id)) AS PRODUCT_SRC_ID,
                UPPER(TRIM(loyalty_card_no)) AS CUSTOMER_SRC_ID, 
                UPPER(TRIM(store_id)) AS STORE_SRC_ID, 
                UPPER(TRIM(employee_id)) AS EMPLOYEE_SRC_ID, 
                UPPER(TRIM(promotion_id)) AS PROMOTION_SRC_ID,
                COALESCE(UPPER(TRIM(payment_method_name)), 'N. A.') AS PM_NAME, 
                UPPER(TRIM(address_id)) AS ADDRESS_SRC_ID,
                COALESCE(NULLIF(TRIM(discount_value), ''), '0')::DECIMAL(10,2) AS DISCOUNT_VALUE, 
                quantity::INT AS QUANTITY, 
                unit_price::DECIMAL(18,2) AS UNIT_PRICE, 
                unit_cost::DECIMAL(18,2) AS UNIT_COST,
                'SA_APPLE_POS' AS SRC_SYS, 
                'SRC_APPLE_POS' AS SRC_ENT,
                insert_dt
            FROM sa_apple_pos.src_apple_pos
            UNION ALL
            SELECT 
                UPPER(TRIM(order_code)) AS SALE_SRC_ID, 
                'ONLINE' AS SALE_CHANNEL, 
                order_time::TIMESTAMP AS S_DATE, 
                UPPER(TRIM(sku_id)) AS PRODUCT_SRC_ID,
                UPPER(TRIM(customer_id)) AS CUSTOMER_SRC_ID, 
                '-1' AS STORE_SRC_ID, 
                '-1' AS EMPLOYEE_SRC_ID, 
                UPPER(TRIM(promotion_id)) AS PROMOTION_SRC_ID,
                COALESCE(UPPER(TRIM(payment_method_name)), 'N. A.') AS PM_NAME, 
                UPPER(TRIM(address_id)) AS ADDRESS_SRC_ID,
                COALESCE(NULLIF(TRIM(discount_value), ''), '0')::DECIMAL(10,2) AS DISCOUNT_VALUE, 
                qty::INT AS QUANTITY, 
                list_price::DECIMAL(18,2) AS UNIT_PRICE, 
                unit_cost::DECIMAL(18,2) AS UNIT_COST,
                'SA_APPLE_ONLINE' AS SRC_SYS, 
                'SRC_APPLE_ONLINE' AS SRC_ENT,
                insert_dt
            FROM sa_apple_online.src_apple_online
        ) sub
        ORDER BY sub.SALE_SRC_ID, sub.SALE_CHANNEL, sub.insert_dt DESC)
    SELECT 
        nextval('BL_3NF.SEQ_CE_SALES'),
        src.SALE_SRC_ID,
        src.SALE_CHANNEL,
        src.S_DATE,
        COALESCE(p.PRODUCT_ID, (
            SELECT t.PRODUCT_ID FROM BL_3NF.CE_PRODUCTS_SCD t 
            WHERE t.PRODUCT_SRC_ID = src.PRODUCT_SRC_ID 
              AND t.SOURCE_SYSTEM = src.SRC_SYS 
            ORDER BY t.START_DT ASC LIMIT 1), -1), 
        COALESCE(c.CUSTOMER_ID, -1),
        COALESCE(st.STORE_ID, -1),
        COALESCE(e.EMPLOYEE_ID, -1),
        COALESCE(pr.PROMOTION_ID, -1),
        COALESCE(pm.PAYMENT_METHOD_ID, -1),
        COALESCE(a.ADDRESS_ID, -1),
        src.DISCOUNT_VALUE,
        src.QUANTITY, src.UNIT_PRICE, src.UNIT_COST, NOW()
    FROM all_sales_src src
    LEFT JOIN BL_3NF.CE_PRODUCTS_SCD p ON p.PRODUCT_SRC_ID = src.PRODUCT_SRC_ID
        AND p.SOURCE_SYSTEM = src.SRC_SYS AND p.SOURCE_ENTITY = src.SRC_ENT
        AND src.S_DATE >= p.START_DT AND src.S_DATE < p.END_DT 
    LEFT JOIN BL_3NF.CE_CUSTOMERS c ON c.CUSTOMER_SRC_ID = src.CUSTOMER_SRC_ID
        AND c.SOURCE_SYSTEM = src.SRC_SYS AND c.SOURCE_ENTITY = src.SRC_ENT
    LEFT JOIN BL_3NF.CE_STORES st ON st.STORE_SRC_ID = src.STORE_SRC_ID
        AND st.SOURCE_SYSTEM = src.SRC_SYS AND st.SOURCE_ENTITY = src.SRC_ENT
    LEFT JOIN BL_3NF.CE_EMPLOYEES e ON e.EMPLOYEE_SRC_ID = src.EMPLOYEE_SRC_ID
        AND e.SOURCE_SYSTEM = src.SRC_SYS AND e.SOURCE_ENTITY = src.SRC_ENT
    LEFT JOIN BL_3NF.CE_PROMOTIONS pr ON pr.PROMOTION_SRC_ID = src.PROMOTION_SRC_ID
        AND pr.SOURCE_SYSTEM = src.SRC_SYS AND pr.SOURCE_ENTITY = src.SRC_ENT
    LEFT JOIN BL_3NF.CE_PAYMENT_METHODS pm ON pm.PAYMENT_METHOD_SRC_ID = src.PM_NAME
        AND pm.SOURCE_SYSTEM = src.SRC_SYS AND pm.SOURCE_ENTITY = src.SRC_ENT
    LEFT JOIN BL_3NF.CE_ADDRESSES a ON a.ADDRESS_SRC_ID = src.ADDRESS_SRC_ID
        AND a.SOURCE_SYSTEM = src.SRC_SYS AND a.SOURCE_ENTITY = src.SRC_ENT
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_SALES t 
        WHERE t.SALE_SRC_ID = src.SALE_SRC_ID
          AND t.SALE_CHANNEL = src.SALE_CHANNEL);
    GET DIAGNOSTICS v_rows_cnt = ROW_COUNT;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows_cnt, 'SUCCESS', 'Incremental load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


