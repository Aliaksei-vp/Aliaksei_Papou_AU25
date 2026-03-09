
--Create a procedure for load FCT_SALES_DD table (BL_DM)
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_FCT_SALES_DM_ROLLING()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_FCT_SALES_DM_ROLLING';
    v_total_rows INT := 0;
    v_inserted   INT := 0;
    v_is_initial_load BOOLEAN;
    v_start_date  DATE;
    v_end_date    DATE;
    v_iter_date   DATE;
    v_part_name     TEXT;
    v_staging_table TEXT;
    v_part_min      BIGINT;
    v_part_max      BIGINT;
BEGIN
    SELECT NOT EXISTS (SELECT 1 FROM BL_DM.FCT_SALES_DD LIMIT 1) INTO v_is_initial_load;
    
    IF v_is_initial_load THEN
        -- Initial load 
        v_start_date := '2023-01-01'::DATE;
        v_end_date   := DATE_TRUNC('month', CURRENT_DATE + INTERVAL '1 month')::DATE;
    ELSE
    	-- Rolling window
        v_start_date := DATE_TRUNC('month', CURRENT_DATE - INTERVAL '2 month')::DATE;
        v_end_date   := DATE_TRUNC('month', CURRENT_DATE + INTERVAL '1 month')::DATE;
    END IF;
    v_iter_date := v_start_date;    
    WHILE v_iter_date < v_end_date LOOP
        v_part_name   := 'fct_sales_p' || TO_CHAR(v_iter_date, 'YYYY_MM');
        v_staging_table := v_part_name || '_stg';
        v_part_min    := TO_CHAR(v_iter_date, 'YYYYMMDD')::BIGINT;
        v_part_max    := TO_CHAR(v_iter_date + INTERVAL '1 month', 'YYYYMMDD')::BIGINT;
        IF EXISTS (SELECT 1 FROM BL_3NF.CE_SALES 
                   WHERE SALE_DATE >= v_iter_date 
                     AND SALE_DATE < v_iter_date + INTERVAL '1 month') THEN
            EXECUTE format('DROP TABLE IF EXISTS BL_DM.%I', v_staging_table);
            EXECUTE format('CREATE TABLE BL_DM.%I (LIKE BL_DM.FCT_SALES_DD INCLUDING ALL)', v_staging_table);
            EXECUTE format('
                INSERT INTO BL_DM.%I (
                    SALE_SURR_ID, SALE_SRC_ID, SALE_CHANNEL, DATE_SURR_ID, 
                    PRODUCT_SURR_ID, CUSTOMER_SURR_ID, STORE_SURR_ID, EMPLOYEE_SURR_ID, 
                    PAYMENT_METHOD_SURR_ID, PROMOTION_SURR_ID, 
                    DISCOUNT_VALUE, QUANTITY, UNIT_PRICE, UNIT_COST, 
                    TOTAL_REVENUE, GROSS_PROFIT, INSERT_DT)
                SELECT 
                    nextval(''BL_DM.SEQ_FCT_SALES_DD''), 
                    src.SALE_ID, 
                    src.SALE_CHANNEL,
                    TO_CHAR(src.SALE_DATE, ''YYYYMMDD'')::BIGINT,
                    COALESCE(p.PRODUCT_SURR_ID, (
                        SELECT t.PRODUCT_SURR_ID 
                        FROM BL_DM.DIM_PRODUCTS_SCD t 
                        WHERE t.PRODUCT_SRC_ID = src.PRODUCT_ID 
                        ORDER BY t.START_DT ASC LIMIT 1), -1), 
                    COALESCE(c.CUSTOMER_SURR_ID, -1),
                    COALESCE(s.STORE_SURR_ID, -1), 
                    COALESCE(e.EMPLOYEE_SURR_ID, -1),
                    COALESCE(pm.PAYMENT_METHOD_SURR_ID, -1), 
                    COALESCE(pr.PROMOTION_SURR_ID, -1),
                    src.DISCOUNT_VALUE, src.QUANTITY, src.UNIT_PRICE, src.UNIT_COST,
                    (src.QUANTITY * src.UNIT_PRICE) - src.DISCOUNT_VALUE,
                    (src.QUANTITY * src.UNIT_PRICE) - src.DISCOUNT_VALUE - (src.QUANTITY * src.UNIT_COST),
                    NOW()
                FROM BL_3NF.CE_SALES src
                LEFT JOIN BL_DM.DIM_PRODUCTS_SCD p ON p.PRODUCT_SRC_ID = src.PRODUCT_ID 
                    AND src.SALE_DATE >= p.START_DT AND src.SALE_DATE < p.END_DT
                LEFT JOIN BL_DM.DIM_CUSTOMERS c ON c.CUSTOMER_SURR_ID = src.CUSTOMER_ID
                LEFT JOIN BL_DM.DIM_STORES s ON s.STORE_SURR_ID = src.STORE_ID
                LEFT JOIN BL_DM.DIM_EMPLOYEES e ON e.EMPLOYEE_SURR_ID = src.EMPLOYEE_ID
                LEFT JOIN BL_DM.DIM_PAYMENT_METHODS pm ON pm.PAYMENT_METHOD_SURR_ID = src.PAYMENT_METHOD_ID
                LEFT JOIN BL_DM.DIM_PROMOTIONS pr ON pr.PROMOTION_SURR_ID = src.PROMOTION_ID
                WHERE src.SALE_DATE >= %L AND src.SALE_DATE < %L', 
                v_staging_table, v_iter_date, v_iter_date + INTERVAL '1 month');
            GET DIAGNOSTICS v_inserted = ROW_COUNT;
            v_total_rows := v_total_rows + v_inserted;
            IF EXISTS (SELECT 1 FROM pg_inherits i 
                       JOIN pg_class c ON i.inhrelid = c.oid 
                       JOIN pg_namespace n ON n.oid = c.relnamespace 
                       WHERE n.nspname = 'bl_dm' AND c.relname = lower(v_part_name)) THEN
                EXECUTE format('ALTER TABLE BL_DM.FCT_SALES_DD DETACH PARTITION BL_DM.%I', v_part_name);
            END IF;
            EXECUTE format('DROP TABLE IF EXISTS BL_DM.%I', v_part_name);
            EXECUTE format('ALTER TABLE BL_DM.%I RENAME TO %I', v_staging_table, v_part_name);
            EXECUTE format('ALTER TABLE BL_DM.FCT_SALES_DD ATTACH PARTITION BL_DM.%I 
                            FOR VALUES FROM (%L) TO (%L)', v_part_name, v_part_min, v_part_max);
        END IF;
        v_iter_date := v_iter_date + INTERVAL '1 month';
    END LOOP;
    ANALYZE BL_DM.FCT_SALES_DD;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_total_rows, 'SUCCESS', 
        CASE WHEN v_is_initial_load THEN 'Initial load finished' ELSE 'Rolling window load finished' END);
EXCEPTION WHEN OTHERS THEN
    IF v_staging_table IS NOT NULL THEN
        EXECUTE format('DROP TABLE IF EXISTS BL_DM.%I', v_staging_table);
    END IF;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


