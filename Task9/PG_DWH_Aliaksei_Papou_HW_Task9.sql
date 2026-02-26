
--Create table BL_DM.FCT_SALES_DD 
CREATE TABLE BL_DM.FCT_SALES_DD (
    SALE_SURR_ID BIGINT NOT NULL,
    SALE_SRC_ID BIGINT NOT NULL, 
    SALE_CHANNEL VARCHAR(250) NOT NULL,
    DATE_SURR_ID BIGINT NOT NULL REFERENCES BL_DM.DIM_DATES(DATE_SURR_ID), 
    PRODUCT_SURR_ID BIGINT NOT NULL REFERENCES BL_DM.DIM_PRODUCTS_SCD(PRODUCT_SURR_ID),
    CUSTOMER_SURR_ID BIGINT NOT NULL REFERENCES BL_DM.DIM_CUSTOMERS(CUSTOMER_SURR_ID),
    STORE_SURR_ID BIGINT NOT NULL REFERENCES BL_DM.DIM_STORES(STORE_SURR_ID),
    EMPLOYEE_SURR_ID BIGINT NOT NULL REFERENCES BL_DM.DIM_EMPLOYEES(EMPLOYEE_SURR_ID),
    PAYMENT_METHOD_SURR_ID BIGINT NOT NULL REFERENCES BL_DM.DIM_PAYMENT_METHODS(PAYMENT_METHOD_SURR_ID),
    PROMOTION_SURR_ID BIGINT NOT NULL REFERENCES BL_DM.DIM_PROMOTIONS(PROMOTION_SURR_ID),
    DISCOUNT_VALUE DECIMAL(10,2) NOT NULL,
    QUANTITY INT,
    UNIT_PRICE DECIMAL(18,2),
    UNIT_COST DECIMAL(18,2),
    TOTAL_REVENUE DECIMAL(18,2),
    GROSS_PROFIT DECIMAL(18,2),
    INSERT_DT TIMESTAMP NOT NULL
) PARTITION BY RANGE (DATE_SURR_ID);
ALTER TABLE BL_DM.FCT_SALES_DD ADD CONSTRAINT PK_FCT_SALES_DD PRIMARY KEY (SALE_SURR_ID, DATE_SURR_ID);


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
            'SRC_APPLE_POS' AS SRC_ENT 
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
            'SRC_APPLE_ONLINE' AS SRC_ENT
        FROM sa_apple_online.src_apple_online)
    SELECT 
        nextval('BL_3NF.SEQ_CE_SALES'),
        src.SALE_SRC_ID,
        src.SALE_CHANNEL,
        src.S_DATE,
        COALESCE(p.PRODUCT_ID, -1), 
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
                    SALE_SURR_ID, 
                    SALE_SRC_ID, 
                    SALE_CHANNEL, 
                    DATE_SURR_ID, 
                    PRODUCT_SURR_ID, CUSTOMER_SURR_ID, STORE_SURR_ID, EMPLOYEE_SURR_ID, 
                    PAYMENT_METHOD_SURR_ID, PROMOTION_SURR_ID, 
                    DISCOUNT_VALUE, QUANTITY, UNIT_PRICE, UNIT_COST, 
                    TOTAL_REVENUE, GROSS_PROFIT, INSERT_DT)
                SELECT 
                    nextval(''BL_DM.SEQ_FCT_SALES_DD''), 
                    src.SALE_ID, 
                    src.SALE_CHANNEL,
                    TO_CHAR(src.SALE_DATE, ''YYYYMMDD'')::BIGINT,
                    COALESCE(p.PRODUCT_SURR_ID, -1), COALESCE(c.CUSTOMER_SURR_ID, -1),
                    COALESCE(s.STORE_SURR_ID, -1), COALESCE(e.EMPLOYEE_SURR_ID, -1),
                    COALESCE(pm.PAYMENT_METHOD_SURR_ID, -1), COALESCE(pr.PROMOTION_SURR_ID, -1),
                    src.DISCOUNT_VALUE, src.QUANTITY, src.UNIT_PRICE, src.UNIT_COST,
                    (src.QUANTITY * src.UNIT_PRICE) - src.DISCOUNT_VALUE,
                    (src.QUANTITY * src.UNIT_PRICE) - src.DISCOUNT_VALUE - (src.QUANTITY * src.UNIT_COST),
                    NOW()
                FROM BL_3NF.CE_SALES src
                LEFT JOIN BL_DM.DIM_PRODUCTS_SCD p ON p.PRODUCT_SRC_ID = src.PRODUCT_ID 
                    AND src.SALE_DATE >= p.START_DT AND src.SALE_DATE < p.END_DT
                LEFT JOIN BL_DM.DIM_CUSTOMERS c ON c.CUSTOMER_SRC_ID = src.CUSTOMER_ID
                LEFT JOIN BL_DM.DIM_STORES s ON s.STORE_SRC_ID = src.STORE_ID
                LEFT JOIN BL_DM.DIM_EMPLOYEES e ON e.EMPLOYEE_SRC_ID = src.EMPLOYEE_ID
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
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_total_rows, 'SUCCESS', 
        CASE WHEN v_is_initial_load THEN 'Initial load finished' ELSE 'Rolling window load finished' END);
EXCEPTION WHEN OTHERS THEN
    IF v_staging_table IS NOT NULL THEN
        EXECUTE format('DROP TABLE IF EXISTS BL_DM.%I', v_staging_table);
    END IF;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;
















