
--create a procedure for writing logs
CREATE OR REPLACE PROCEDURE BL_CL.PRC_WRITE_LOG(
    p_proc_name VARCHAR,
    p_rows      INT,
    p_status    VARCHAR,
    p_message   TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO BL_CL.MTA_LOGGING (procedure_name, rows_affected, log_status, log_message)
    VALUES (p_proc_name, p_rows, p_status, p_message);
END;
$$;


--Create a procedure for load CE_REGIONS table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_REGIONS()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_REGIONS';
    v_rows INT := 0;
    v_cnt INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_REGIONS_DATA()) LOOP
        INSERT INTO BL_3NF.CE_REGIONS (REGION_ID, REGION_SRC_ID, REGION_NAME, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT nextval('BL_3NF.SEQ_CE_REGIONS'), r.src_id, r.r_name, r.s_system, r.s_entity, NOW(), NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_REGIONS t 
            WHERE t.REGION_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_system 
              AND t.SOURCE_ENTITY = r.s_entity);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_COUNTRIES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_COUNTRIES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_COUNTRIES';
    v_rows INT := 0;
    v_cnt INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_COUNTRIES_DATA()) LOOP
        INSERT INTO BL_3NF.CE_COUNTRIES (COUNTRY_ID, COUNTRY_SRC_ID, COUNTRY_NAME, REGION_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT 
            nextval('BL_3NF.SEQ_CE_COUNTRIES'), r.src_id, r.c_name, COALESCE(reg.REGION_ID, -1), r.s_sys, 
            r.s_ent, NOW(), NOW()
        FROM (SELECT 1) AS d
        LEFT JOIN BL_3NF.CE_REGIONS reg 
            ON reg.REGION_SRC_ID = r.r_key 
            AND reg.SOURCE_SYSTEM = r.s_sys
            AND reg.SOURCE_ENTITY = r.s_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_COUNTRIES t 
            WHERE t.COUNTRY_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_STATES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_STATES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_STATES';
    v_rows INT := 0;
    v_cnt INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_STATES_DATA()) LOOP
        INSERT INTO BL_3NF.CE_STATES (STATE_ID, STATE_SRC_ID, STATE_NAME, COUNTRY_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT 
            nextval('BL_3NF.SEQ_CE_STATES'), r.src_id, r.s_name, COALESCE(c.COUNTRY_ID, -1), r.s_sys, r.s_ent, NOW(), NOW()
        FROM (SELECT 1) AS d
        LEFT JOIN BL_3NF.CE_COUNTRIES c 
            ON c.COUNTRY_SRC_ID = r.c_key 
            AND c.SOURCE_SYSTEM = r.s_sys
            AND c.SOURCE_ENTITY = r.s_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_STATES t 
            WHERE t.STATE_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_CITIES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_CITIES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_CITIES';
    v_rows INT := 0;
    v_cnt INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_CITIES_DATA()) LOOP
        INSERT INTO BL_3NF.CE_CITIES (CITY_ID, CITY_SRC_ID, CITY_NAME, REGION_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT 
            nextval('BL_3NF.SEQ_CE_CITIES'), r.src_id, r.cit_name, COALESCE(s.state_id, -1), r.s_sys, r.s_ent, NOW(), NOW()
        FROM (SELECT 1) AS d
        LEFT JOIN BL_3NF.CE_STATES s 
            ON s.STATE_SRC_ID = r.s_key 
            AND s.SOURCE_SYSTEM = r.s_sys
            AND s.SOURCE_ENTITY = r.s_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_CITIES t 
            WHERE t.CITY_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_DISTRICTS table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_DISTRICTS()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_DISTRICTS';
    v_rows INT := 0;
    v_cnt INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_DISTRICTS_DATA()) LOOP
        INSERT INTO BL_3NF.CE_DISTRICTS (DISTRICT_ID, DISTRICT_SRC_ID, DISTRICT_NAME, CITY_ID, SOURCE_SYSTEM, SOURCE_ENTITY, 
            INSERT_DT, UPDATE_DT)
        SELECT 
            nextval('BL_3NF.SEQ_CE_DISTRICTS'), r.src_id, r.d_name, COALESCE(cit.CITY_ID, -1), r.s_sys, r.s_ent, NOW(), NOW()
        FROM (SELECT 1) AS d
        LEFT JOIN BL_3NF.CE_CITIES cit 
            ON cit.CITY_SRC_ID = r.city_key 
            AND cit.SOURCE_SYSTEM = r.s_sys
            AND cit.SOURCE_ENTITY = r.s_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_DISTRICTS t 
            WHERE t.DISTRICT_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);      
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_ADDRESSES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_ADDRESSES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_ADDRESSES';
    v_rows_cnt INT := 0;
BEGIN
    INSERT INTO BL_3NF.CE_ADDRESSES (ADDRESS_ID, ADDRESS_SRC_ID, DISTRICT_ID, POSTAL_CODE, 
        ADDRESS, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT 
        nextval('BL_3NF.SEQ_CE_ADDRESSES'), src.src_id, COALESCE(d.DISTRICT_ID, -1), src.p_code, src.addr, src.s_sys, src.s_ent, NOW(), NOW()
    FROM BL_CL.FNC_GET_ADDRESSES_DATA() src
    LEFT JOIN BL_3NF.CE_DISTRICTS d 
        ON d.DISTRICT_SRC_ID = src.dist_key 
        AND d.SOURCE_SYSTEM = src.s_sys
        AND d.SOURCE_ENTITY = src.s_ent
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_ADDRESSES t 
        WHERE t.ADDRESS_SRC_ID = src.src_id 
          AND t.SOURCE_SYSTEM = src.s_sys
          AND t.SOURCE_ENTITY = src.s_ent);  
    GET DIAGNOSTICS v_rows_cnt = ROW_COUNT;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows_cnt, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_CATEGORIES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_CATEGORIES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_CATEGORIES';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_CATEGORIES_DATA()) LOOP
        INSERT INTO BL_3NF.CE_CATEGORIES (CATEGORY_ID, CATEGORY_SRC_ID, CATEGORY_NAME, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT nextval('BL_3NF.SEQ_CE_CATEGORIES'), r.src_id, r.c_name, r.s_sys, r.s_ent, NOW(), NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_CATEGORIES t 
            WHERE t.CATEGORY_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_SUBCATEGORIES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_SUBCATEGORIES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_SUBCATEGORIES';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_SUBCATEGORIES_DATA()) LOOP
        INSERT INTO BL_3NF.CE_SUBCATEGORIES (SUBCATEGORY_ID, SUBCATEGORY_SRC_ID, SUBCATEGORY_NAME, CATEGORY_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT 
            nextval('BL_3NF.SEQ_CE_SUBCATEGORIES'), r.src_id, r.s_name, COALESCE(c.CATEGORY_ID, -1), r.s_sys, r.s_ent, NOW(), NOW()
        FROM (SELECT 1) AS d
        LEFT JOIN BL_3NF.CE_CATEGORIES c 
            ON c.CATEGORY_SRC_ID = r.cat_key 
            AND c.SOURCE_SYSTEM = r.s_sys
            AND c.SOURCE_ENTITY = r.s_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_SUBCATEGORIES t 
            WHERE t.SUBCATEGORY_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_COLORS table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_COLORS()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_COLORS';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_COLORS_DATA()) LOOP
        INSERT INTO BL_3NF.CE_COLORS (COLOR_ID, COLOR_SRC_ID, COLOR_NAME, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT nextval('BL_3NF.SEQ_CE_COLORS'), r.src_id, r.col_name, r.s_sys, r.s_ent, NOW(), NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_COLORS t 
            WHERE t.COLOR_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_STORAGE_CAPACITIES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_STORAGE_CAPACITIES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_STORAGE_CAPACITIES';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_STORAGE_DATA()) LOOP
        INSERT INTO BL_3NF.CE_STORAGE_CAPACITIES (STORAGE_CAPACITY_ID, STORAGE_CAPACITY_SRC_ID, STORAGE_CAPACITY, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT nextval('BL_3NF.SEQ_CE_STORAGE_CAPACITIES'), r.src_id, r.cap_name, r.s_sys, r.s_ent, NOW(), NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_STORAGE_CAPACITIES t 
            WHERE t.STORAGE_CAPACITY_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_PRODUCTS_SCD table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_PRODUCTS_SCD()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_PRODUCTS_SCD';
    v_rows INT := 0;
    v_now  TIMESTAMP := NOW(); 
    v_is_initial BOOLEAN;
BEGIN
    SELECT NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_PRODUCTS_SCD WHERE PRODUCT_ID <> -1
    ) INTO v_is_initial;
    CREATE TEMP TABLE tmp_src_products ON COMMIT DROP AS
    SELECT DISTINCT ON (src.p_src_id, src.s_sys, src.s_ent) 
        src.p_src_id, src.p_name, src.m_y, src.war, src.s_sys, src.s_ent,
        COALESCE(col.COLOR_ID, -1) as v_col_id,
        COALESCE(sub.SUBCATEGORY_ID, -1) as v_sub_id, 
        COALESCE(stg.STORAGE_CAPACITY_ID, -1) as v_stg_id
    FROM BL_CL.FNC_GET_PRODUCTS_DATA() src
    LEFT JOIN BL_3NF.CE_COLORS col ON col.COLOR_SRC_ID = src.col_k 
        AND col.SOURCE_SYSTEM = src.s_sys AND col.SOURCE_ENTITY = src.s_ent
    LEFT JOIN BL_3NF.CE_SUBCATEGORIES sub ON sub.SUBCATEGORY_SRC_ID = src.sub_k 
        AND sub.SOURCE_SYSTEM = src.s_sys AND sub.SOURCE_ENTITY = src.s_ent
    LEFT JOIN BL_3NF.CE_STORAGE_CAPACITIES stg ON stg.STORAGE_CAPACITY_SRC_ID = src.cap_k 
        AND stg.SOURCE_SYSTEM = src.s_sys AND stg.SOURCE_ENTITY = src.s_ent
    ORDER BY src.p_src_id, src.s_sys, src.s_ent, src.war; 
    UPDATE BL_3NF.CE_PRODUCTS_SCD target
    SET END_DT = v_now, 
        IS_ACTIVE = 'N'
    FROM tmp_src_products src
    WHERE target.PRODUCT_SRC_ID = src.p_src_id 
      AND target.SOURCE_SYSTEM = src.s_sys 
      AND target.SOURCE_ENTITY = src.s_ent 
      AND target.IS_ACTIVE = 'Y'
      AND (
          target.PRODUCT_NAME       IS DISTINCT FROM src.p_name OR
          target.MODEL_YEAR         IS DISTINCT FROM src.m_y OR
          target.WARRANTY_PERIOD    IS DISTINCT FROM src.war OR
          target.COLOR_ID           IS DISTINCT FROM src.v_col_id OR
          target.SUBCATEGORY_ID     IS DISTINCT FROM src.v_sub_id OR
          target.STORAGE_CAPACITY_ID IS DISTINCT FROM src.v_stg_id);
    INSERT INTO BL_3NF.CE_PRODUCTS_SCD (
        PRODUCT_ID, PRODUCT_SRC_ID, PRODUCT_NAME, SUBCATEGORY_ID, MODEL_YEAR, 
        COLOR_ID, STORAGE_CAPACITY_ID, WARRANTY_PERIOD, 
        START_DT, END_DT, IS_ACTIVE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT)
    SELECT 
        COALESCE(
            (SELECT MAX(t.PRODUCT_ID) FROM BL_3NF.CE_PRODUCTS_SCD t 
             WHERE t.PRODUCT_SRC_ID = src.p_src_id AND t.SOURCE_SYSTEM = src.s_sys),
            nextval('BL_3NF.SEQ_CE_PRODUCTS')
        ),
        src.p_src_id, src.p_name, src.v_sub_id, src.m_y, src.v_col_id, src.v_stg_id, src.war, 
        CASE 
            WHEN v_is_initial THEN '1900-01-01'::TIMESTAMP 
            WHEN NOT EXISTS (SELECT 1 FROM BL_3NF.CE_PRODUCTS_SCD t2 
                             WHERE t2.PRODUCT_SRC_ID = src.p_src_id 
                               AND t2.SOURCE_SYSTEM = src.s_sys) THEN v_now
            ELSE v_now 
        END, 
        '9999-12-31 23:59:59', 'Y', src.s_sys, src.s_ent, v_now
    FROM tmp_src_products src
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_PRODUCTS_SCD t 
        WHERE t.PRODUCT_SRC_ID = src.p_src_id 
          AND t.SOURCE_SYSTEM = src.s_sys 
          AND t.SOURCE_ENTITY = src.s_ent
          AND t.IS_ACTIVE = 'Y');
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished SCD2');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_SEGMENTS table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_SEGMENTS()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_SEGMENTS';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_SEGMENTS_DATA()) LOOP
        INSERT INTO BL_3NF.CE_SEGMENTS (SEGMENT_ID, SEGMENT_SRC_ID, SEGMENT_NAME, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT nextval('BL_3NF.SEQ_CE_SEGMENTS'), r.src_id, r.seg_name, r.s_sys, r.s_ent, NOW(), NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_SEGMENTS t 
            WHERE t.SEGMENT_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load CE_CUSTOMERS table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_CUSTOMERS()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_CUSTOMERS';
    v_rows_cnt INT := 0;
BEGIN
    INSERT INTO BL_3NF.CE_CUSTOMERS (
        CUSTOMER_ID, CUSTOMER_SRC_ID, LOYALTY_CARD_NO, FIRST_NAME, LAST_NAME, 
        EMAIL, PHONE, AGE, GENDER, SEGMENT_ID, ADDRESS_ID, 
        SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT 
        nextval('BL_3NF.SEQ_CE_CUSTOMERS'), src.c_src_id, src.l_card, src.f_name, src.l_name, src.email, src.phone, src.age, src.gender, 
        COALESCE(s.SEGMENT_ID, -1), COALESCE(adr.ADDRESS_ID, -1), src.s_sys, src.s_ent, NOW(), NOW()
    FROM BL_CL.FNC_GET_CUSTOMERS_DATA() src
    LEFT JOIN BL_3NF.CE_SEGMENTS s 
        ON s.SEGMENT_SRC_ID = src.seg_key 
       AND s.SOURCE_SYSTEM = src.s_sys
       AND s.SOURCE_ENTITY = src.s_ent
    LEFT JOIN BL_3NF.CE_ADDRESSES adr 
        ON adr.ADDRESS_SRC_ID = src.addr_key 
       AND adr.SOURCE_SYSTEM = src.s_sys
       AND adr.SOURCE_ENTITY = src.s_ent
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_CUSTOMERS t 
        WHERE t.CUSTOMER_SRC_ID = src.c_src_id 
          AND t.SOURCE_SYSTEM = src.s_sys
          AND t.SOURCE_ENTITY = src.s_ent);
    GET DIAGNOSTICS v_rows_cnt = ROW_COUNT;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows_cnt, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


--Create a procedure for load CE_POSITIONS table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_POSITIONS()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_POSITIONS';
    v_rows INT := 0; 
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_POSITIONS_DATA()) LOOP
        INSERT INTO BL_3NF.CE_POSITIONS (POSITION_ID, POSITION_SRC_ID, POSITION_NAME, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT nextval('BL_3NF.SEQ_CE_POSITIONS'), r.src_id, r.p_name, r.s_sys, r.s_ent, NOW(), NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_POSITIONS t 
            WHERE t.POSITION_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


--Create a procedure for load CE_EMPLOYEES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_EMPLOYEES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_EMPLOYEES';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_EMPLOYEES_DATA()) LOOP
        INSERT INTO BL_3NF.CE_EMPLOYEES (EMPLOYEE_ID, EMPLOYEE_SRC_ID, EMPLOYEE_FIRST_NAME, EMPLOYEE_LAST_NAME, POSITION_ID, HIRE_DATE, 
        EMPLOYEE_EMAIL, EMPLOYEE_PHONE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT 
            nextval('BL_3NF.SEQ_CE_EMPLOYEES'), r.src_id, r.f_name, r.l_name, COALESCE(p.POSITION_ID, -1), r.h_date, r.email, r.phone, 
            r.s_sys, r.s_ent, NOW(), NOW()
        FROM (SELECT 1) d
        LEFT JOIN BL_3NF.CE_POSITIONS p 
            ON p.POSITION_SRC_ID = r.pos_k 
            AND p.SOURCE_SYSTEM = r.s_sys
            AND p.SOURCE_ENTITY = r.s_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_EMPLOYEES t 
            WHERE t.EMPLOYEE_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


--Create a procedure for load CE_STORE_TYPES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_STORE_TYPES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_STORE_TYPES';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_STORE_TYPES_DATA()) LOOP
        INSERT INTO BL_3NF.CE_STORE_TYPES (STORE_TYPE_ID, STORE_TYPE_SRC_ID, STORE_TYPE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT nextval('BL_3NF.SEQ_CE_STORE_TYPES'), r.src_id, r.s_type, r.s_sys, r.s_ent, NOW(), NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_STORE_TYPES t 
            WHERE t.STORE_TYPE_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


--Create a procedure for load CE_STORE_STATUSES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_STORE_STATUSES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_STORE_STATUSES';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_STORE_STATUSES_DATA()) LOOP
        INSERT INTO BL_3NF.CE_STORE_STATUSES (STORE_STATUS_ID, STORE_STATUS_SRC_ID, STORE_STATUS, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT nextval('BL_3NF.SEQ_CE_STORE_STATUSES'), r.src_id, r.s_status, r.s_sys, r.s_ent, NOW(), NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_STORE_STATUSES t 
            WHERE t.STORE_STATUS_SRC_ID = r.src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


--Create a procedure for load CE_STORES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_STORES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_STORES';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_STORES_DATA()) LOOP
        INSERT INTO BL_3NF.CE_STORES (STORE_ID, STORE_SRC_ID, STORE_NAME, STORE_TYPE_ID, STORE_STATUS_ID, STORE_SIZE_SQM, OPENING_YEAR, 
        HAS_GENIUS_BAR, MANAGER_ID, ADDRESS_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT 
            nextval('BL_3NF.SEQ_CE_STORES'), r.s_src_id, r.s_name, 
            COALESCE(tp.STORE_TYPE_ID, -1), COALESCE(st.STORE_STATUS_ID, -1),
            r.sz, r.op_y, r.genius, COALESCE(e.EMPLOYEE_ID, -1), COALESCE(a.ADDRESS_ID, -1),
            r.s_sys, r.s_ent, NOW(), NOW()
        FROM (SELECT 1) d
        LEFT JOIN BL_3NF.CE_STORE_TYPES tp ON tp.STORE_TYPE_SRC_ID = r.t_key AND tp.SOURCE_SYSTEM = r.s_sys AND tp.SOURCE_ENTITY = r.s_ent
        LEFT JOIN BL_3NF.CE_STORE_STATUSES st ON st.STORE_STATUS_SRC_ID = r.st_key AND st.SOURCE_SYSTEM = r.s_sys AND st.SOURCE_ENTITY = r.s_ent
        LEFT JOIN BL_3NF.CE_EMPLOYEES e ON e.EMPLOYEE_SRC_ID = r.m_key AND e.SOURCE_SYSTEM = r.s_sys AND e.SOURCE_ENTITY = r.s_ent
        LEFT JOIN BL_3NF.CE_ADDRESSES a ON a.ADDRESS_SRC_ID = r.a_key AND a.SOURCE_SYSTEM = r.s_sys AND a.SOURCE_ENTITY = r.s_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_STORES t 
            WHERE t.STORE_SRC_ID = r.s_src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


--Create a procedure for load CE_PROMOTION_TYPES table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_PROMOTION_TYPES()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_PROMOTION_TYPES';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_PROMO_TYPES_DATA()) LOOP
        INSERT INTO BL_3NF.CE_PROMOTION_TYPES (PROMOTION_TYPE_ID, PROMOTION_TYPE_SRC_ID, PROMOTION_TYPE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT nextval('BL_3NF.SEQ_CE_PROMOTION_TYPES'), r.p_type_src_id, r.p_name, r.s_sys, r.s_ent, NOW(), NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_PROMOTION_TYPES t 
            WHERE t.PROMOTION_TYPE_SRC_ID = r.p_type_src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


--Create a procedure for load CE_PROMOTIONS table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_PROMOTIONS()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_PROMOTIONS';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_PROMOTIONS_DATA()) LOOP
        INSERT INTO BL_3NF.CE_PROMOTIONS (
            PROMOTION_ID, PROMOTION_SRC_ID, PROMOTION_NAME, PROMOTION_TYPE_ID, 
            IS_ACTIVE, PROMO_START_DATE, PROMO_END_DATE, 
            SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT 
            nextval('BL_3NF.SEQ_CE_PROMOTIONS'), r.p_src_id, r.p_name, COALESCE(pt.PROMOTION_TYPE_ID, -1), r.is_act, r.s_dt, r.e_dt, r.s_sys, r.s_ent, NOW(), NOW()
        FROM (SELECT 1) d
        LEFT JOIN BL_3NF.CE_PROMOTION_TYPES pt 
            ON pt.PROMOTION_TYPE_SRC_ID = r.pt_key 
            AND pt.SOURCE_SYSTEM = r.s_sys
            AND pt.SOURCE_ENTITY = r.s_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_PROMOTIONS t 
            WHERE t.PROMOTION_SRC_ID = r.p_src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);        
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


--Create a procedure for load CE_PAYMENT_METHODS table
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_PAYMENT_METHODS()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_PAYMENT_METHODS';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM BL_CL.FNC_GET_PAYMENT_METHODS_DATA()) LOOP
        INSERT INTO BL_3NF.CE_PAYMENT_METHODS (
            PAYMENT_METHOD_ID, PAYMENT_METHOD_SRC_ID, PAYMENT_METHOD_NAME, 
            PAYMENT_METHOD_TYPE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        SELECT 
            nextval('BL_3NF.SEQ_CE_PAYMENT_METHODS'), r.pay_src_id, r.pay_name, r.pay_type, r.s_sys, r.s_ent, NOW(), NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_PAYMENT_METHODS t 
            WHERE t.PAYMENT_METHOD_SRC_ID = r.pay_src_id 
              AND t.SOURCE_SYSTEM = r.s_sys
              AND t.SOURCE_ENTITY = r.s_ent);        
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'Load finished');
EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;

