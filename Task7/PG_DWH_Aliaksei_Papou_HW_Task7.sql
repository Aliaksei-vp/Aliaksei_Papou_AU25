--Create Role
CREATE ROLE admin_apple WITH LOGIN PASSWORD 'applepass';

--Grant usage to schemas
GRANT USAGE ON SCHEMA sa_apple_pos TO admin_apple;
GRANT USAGE ON SCHEMA sa_apple_online TO admin_apple;
GRANT USAGE ON SCHEMA bl_cl TO admin_apple;
GRANT USAGE ON SCHEMA bl_3nf TO admin_apple;
GRANT USAGE ON SCHEMA bl_dm TO admin_apple;

--Grant to DML operations (SELECT, INSERT, UPDATE, DELETE)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA sa_apple_pos TO admin_apple;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA sa_apple_online TO admin_apple;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA bl_cl TO admin_apple;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA bl_3nf TO admin_apple;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA bl_dm TO admin_apple;

--Grant usage to sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bl_3nf TO admin_apple;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bl_dm TO admin_apple;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bl_cl TO admin_apple;

--Grant to functions and procedures
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA bl_cl TO admin_apple;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA bl_cl TO admin_apple;

--Create a BL_CL schema
CREATE SCHEMA IF NOT EXISTS BL_CL;

--Create a sequence for BL_CL.MTA_LOGGING table
CREATE SEQUENCE IF NOT EXISTS BL_CL.SEQ_MTA_LOGGING START 1;

--Create a table BL_CL.MTA_LOGGING
CREATE TABLE IF NOT EXISTS BL_CL.MTA_LOGGING (
    log_id           BIGINT PRIMARY KEY DEFAULT nextval('BL_CL.SEQ_MTA_LOGGING'),
    log_dt           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    procedure_name   VARCHAR(100),
    rows_affected    INT,
    log_status       VARCHAR(20), -- SUCCESS or ERROR
    log_message      TEXT
);

--create a procedure for writing logs
CREATE OR REPLACE PROCEDURE BL_CL.PRC_WRITE_LOG(
    p_proc_name VARCHAR,
    p_rows      INT,
    p_status    VARCHAR,
    p_message   TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO BL_CL.MTA_LOGGING (procedure_name, rows_affected, log_status, log_message)
    VALUES (p_proc_name, p_rows, p_status, p_message);
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.PRC_INSERT_DEFAULT_ROWS_3NF()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_INSERT_DEFAULT_ROWS_3NF';
    v_rows_inserted INT := 0;
    v_cnt INT;
BEGIN
    INSERT INTO BL_3NF.CE_REGIONS (REGION_ID, REGION_SRC_ID, REGION_NAME, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT) 
    SELECT -1, 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_REGIONS WHERE REGION_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_COUNTRIES (COUNTRY_ID, COUNTRY_SRC_ID, COUNTRY_NAME, REGION_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', -1, 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_COUNTRIES WHERE COUNTRY_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_STATES (STATE_ID, STATE_SRC_ID, STATE_NAME, COUNTRY_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', -1, 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_STATES WHERE STATE_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_CITIES (CITY_ID, CITY_SRC_ID, CITY_NAME, REGION_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', -1, 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_CITIES WHERE CITY_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_DISTRICTS (DISTRICT_ID, DISTRICT_SRC_ID, DISTRICT_NAME, CITY_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', -1, 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_DISTRICTS WHERE DISTRICT_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_ADDRESSES (ADDRESS_ID, ADDRESS_SRC_ID, DISTRICT_ID, POSTAL_CODE, ADDRESS, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', -1, 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_ADDRESSES WHERE ADDRESS_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_CATEGORIES (CATEGORY_ID, CATEGORY_SRC_ID, CATEGORY_NAME, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_CATEGORIES WHERE CATEGORY_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_SUBCATEGORIES (SUBCATEGORY_ID, SUBCATEGORY_SRC_ID, SUBCATEGORY_NAME, CATEGORY_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', -1, 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_SUBCATEGORIES WHERE SUBCATEGORY_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_COLORS (COLOR_ID, COLOR_SRC_ID, COLOR_NAME, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_COLORS WHERE COLOR_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_STORAGE_CAPACITIES (STORAGE_CAPACITY_ID, STORAGE_CAPACITY_SRC_ID, STORAGE_CAPACITY, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_STORAGE_CAPACITIES WHERE STORAGE_CAPACITY_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_PRODUCTS_SCD (PRODUCT_ID, PRODUCT_SRC_ID, PRODUCT_NAME, SUBCATEGORY_ID, MODEL_YEAR, COLOR_ID, STORAGE_CAPACITY_ID, WARRANTY_PERIOD, START_DT, END_DT, IS_ACTIVE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT)
    SELECT -1, 'n. a.', 'n. a.', -1, 0, -1, -1, 'n. a.', '1900-01-01', '9999-12-31', 'Y', 'MANUAL', 'MANUAL', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_PRODUCTS_SCD WHERE PRODUCT_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_SEGMENTS (SEGMENT_ID, SEGMENT_SRC_ID, SEGMENT_NAME, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_SEGMENTS WHERE SEGMENT_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_CUSTOMERS (CUSTOMER_ID, CUSTOMER_SRC_ID, LOYALTY_CARD_NO, FIRST_NAME, LAST_NAME, EMAIL, PHONE, AGE, GENDER, SEGMENT_ID, ADDRESS_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', -1, -1, 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_CUSTOMERS WHERE CUSTOMER_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_POSITIONS (POSITION_ID, POSITION_SRC_ID, POSITION_NAME, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_POSITIONS WHERE POSITION_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_EMPLOYEES (EMPLOYEE_ID, EMPLOYEE_SRC_ID, EMPLOYEE_FIRST_NAME, EMPLOYEE_LAST_NAME, POSITION_ID, HIRE_DATE, EMPLOYEE_EMAIL, EMPLOYEE_PHONE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'n. a.', -1, '1900-01-01', 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_EMPLOYEES WHERE EMPLOYEE_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_STORE_TYPES (STORE_TYPE_ID, STORE_TYPE_SRC_ID, STORE_TYPE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_STORE_TYPES WHERE STORE_TYPE_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_STORE_STATUSES (STORE_STATUS_ID, STORE_STATUS_SRC_ID, STORE_STATUS, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_STORE_STATUSES WHERE STORE_STATUS_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_STORES (STORE_ID, STORE_SRC_ID, STORE_NAME, STORE_TYPE_ID, STORE_STATUS_ID, STORE_SIZE_SQM, OPENING_YEAR, HAS_GENIUS_BAR, MANAGER_ID, ADDRESS_ID, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', -1, -1, 0, 0, 'Y', -1, -1, 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_STORES WHERE STORE_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_PROMOTION_TYPES (PROMOTION_TYPE_ID, PROMOTION_TYPE_SRC_ID, PROMOTION_TYPE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_PROMOTION_TYPES WHERE PROMOTION_TYPE_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_PROMOTIONS (PROMOTION_ID, PROMOTION_SRC_ID, PROMOTION_NAME, PROMOTION_TYPE_ID, IS_ACTIVE, PROMO_START_DATE, PROMO_END_DATE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', -1, 'n. a.', '1900-01-01', '1900-01-01', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_PROMOTIONS WHERE PROMOTION_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;

    INSERT INTO BL_3NF.CE_PAYMENT_METHODS (PAYMENT_METHOD_ID, PAYMENT_METHOD_SRC_ID, PAYMENT_METHOD_NAME, PAYMENT_METHOD_TYPE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
    SELECT -1, 'n. a.', 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01', '1900-01-01'
    WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_PAYMENT_METHODS WHERE PAYMENT_METHOD_ID = -1);
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows_inserted := v_rows_inserted + v_cnt;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows_inserted, 'SUCCESS', 'Default Rows inserted');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;



--Cretate a function and procedure for CE_REGIONS table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_REGIONS_DATA()
RETURNS TABLE (src_id VARCHAR, r_name VARCHAR, s_system VARCHAR, s_entity VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH all_data AS (
        SELECT 
            UPPER(TRIM(COALESCE(global_region, 'n. a.')))::VARCHAR AS res_id, 
            TRIM(COALESCE(global_region, 'n. a.'))::VARCHAR AS res_name, 
            'SA_APPLE_POS'::VARCHAR AS res_sys, 
            'SRC_APPLE_POS'::VARCHAR AS res_ent 
        FROM sa_apple_pos.src_apple_pos
        UNION 
        SELECT 
            UPPER(TRIM(COALESCE(region, 'n. a.')))::VARCHAR, 
            TRIM(COALESCE(region, 'n. a.'))::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (res_id, res_sys, res_ent) 
        res_id, res_name, res_sys, res_ent 
    FROM all_data;
END; $$;

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


--Cretate a function and procedure for CE_COUNTRIES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_COUNTRIES_DATA()
RETURNS TABLE (src_id VARCHAR, c_name VARCHAR, r_key VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH all_sources AS (
        SELECT 
            UPPER(TRIM(COALESCE(country, 'n. a.')))::VARCHAR AS c_src_id,
            TRIM(COALESCE(country, 'n. a.'))::VARCHAR AS c_name,
            UPPER(TRIM(COALESCE(global_region, 'n. a.')))::VARCHAR AS r_key,
            'SA_APPLE_POS'::VARCHAR AS s_sys,
            'SRC_APPLE_POS'::VARCHAR AS s_ent
        FROM sa_apple_pos.src_apple_pos
        UNION 
        SELECT 
            UPPER(TRIM(COALESCE(country, 'n. a.')))::VARCHAR, 
            TRIM(COALESCE(country, 'n. a.'))::VARCHAR,
            UPPER(TRIM(COALESCE(region, 'n. a.')))::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (c_src_id, s_sys, s_ent) * FROM all_sources;
END; $$;

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


--Cretate a function and procedure for CE_STATES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_STATES_DATA()
RETURNS TABLE (src_id VARCHAR, s_name VARCHAR, c_key VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_states AS (
        SELECT 
            UPPER(TRIM(COALESCE(state, 'n. a.')))::VARCHAR AS st_id, 
            TRIM(COALESCE(state, 'n. a.'))::VARCHAR AS st_name, 
            UPPER(TRIM(COALESCE(country, 'n. a.')))::VARCHAR AS co_key, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos
        UNION 
        SELECT 
            (UPPER(TRIM(COALESCE(country, 'n. a.'))) || '_STATE')::VARCHAR, 
            'n. a.'::VARCHAR, 
            UPPER(TRIM(COALESCE(country, 'n. a.')))::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (st_id, sys, ent) * FROM raw_states;
END; $$;

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


--Cretate a function and procedure for CE_CITIES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_CITIES_DATA()
RETURNS TABLE (src_id VARCHAR, cit_name VARCHAR, s_key VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH all_cities AS (
        SELECT 
            UPPER(TRIM(COALESCE(city, 'n. a.')))::VARCHAR AS c_id, 
            TRIM(COALESCE(city, 'n. a.'))::VARCHAR AS c_name, 
            UPPER(TRIM(COALESCE(state, 'n. a.')))::VARCHAR AS st_key, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos
        UNION
        SELECT 
            UPPER(TRIM(COALESCE(city, 'n. a.')))::VARCHAR, 
            TRIM(COALESCE(city, 'n. a.'))::VARCHAR, 
            (UPPER(TRIM(COALESCE(country, 'n. a.'))) || '_STATE')::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (c_id, sys, ent) * FROM all_cities;
END; $$;


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


--Cretate a function and procedure for CE_DISTRICTS table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_DISTRICTS_DATA()
RETURNS TABLE (src_id VARCHAR, d_name VARCHAR, city_key VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH all_districts AS (
        SELECT 
            UPPER(TRIM(COALESCE(district, 'n. a.')))::VARCHAR AS d_id, 
            TRIM(COALESCE(district, 'n. a.'))::VARCHAR AS d_name, 
            UPPER(TRIM(COALESCE(city, 'n. a.')))::VARCHAR AS ci_key, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos
        UNION
        SELECT 
            UPPER(TRIM(COALESCE(district, 'n. a.')))::VARCHAR, 
            TRIM(COALESCE(district, 'n. a.'))::VARCHAR, 
            UPPER(TRIM(COALESCE(city, 'n. a.')))::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (d_id, sys, ent) * FROM all_districts;
END; $$;

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


--Cretate a function and procedure for CE_ADDRESSES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_ADDRESSES_DATA()
RETURNS TABLE (src_id VARCHAR, p_code VARCHAR, addr VARCHAR, dist_key VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH all_addresses AS (
        SELECT 
            UPPER(TRIM(COALESCE(address_id, 'n. a.')))::VARCHAR AS a_id, 
            COALESCE(TRIM(postal_code), 'n. a.')::VARCHAR AS pc, 
            COALESCE(TRIM(address), 'n. a.')::VARCHAR AS ad, 
            UPPER(TRIM(COALESCE(district, 'n. a.')))::VARCHAR AS d_key, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos
        UNION
        SELECT 
            UPPER(TRIM(COALESCE(address_id, 'n. a.')))::VARCHAR, 
            COALESCE(TRIM(postal_code), 'n. a.')::VARCHAR, 
            COALESCE(TRIM(address), 'n. a.')::VARCHAR, 
            UPPER(TRIM(COALESCE(district, 'n. a.')))::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (a_id, sys, ent) * FROM all_addresses;
END; $$;

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


--Cretate a function and procedure for CE_CATEGORIES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_CATEGORIES_DATA()
RETURNS TABLE (src_id VARCHAR, c_name VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_cats AS (
        SELECT 
            UPPER(TRIM(COALESCE(category_id, 'n. a.')))::VARCHAR AS cat_id, 
            COALESCE(TRIM(category_name), 'n. a.')::VARCHAR AS cat_name, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos
        UNION
        SELECT 
            UPPER(TRIM(COALESCE(category_id, 'n. a.')))::VARCHAR, 
            COALESCE(TRIM(category_name), 'n. a.')::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (cat_id, sys, ent) * FROM raw_cats;
END; $$;

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


--Cretate a function and procedure for CE_SUBCATEGORIES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_SUBCATEGORIES_DATA()
RETURNS TABLE (src_id VARCHAR, s_name VARCHAR, cat_key VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_subcats AS (
        SELECT 
            UPPER(TRIM(COALESCE(sub_category_name, 'n. a.')))::VARCHAR AS sub_src_id,
            COALESCE(TRIM(sub_category_name), 'n. a.')::VARCHAR AS sub_name, 
            UPPER(TRIM(COALESCE(category_id, 'n. a.')))::VARCHAR AS c_key, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos
        UNION
        SELECT 
            UPPER(TRIM(COALESCE(sub_category_name, 'n. a.')))::VARCHAR,
            COALESCE(TRIM(sub_category_name), 'n. a.')::VARCHAR, 
            UPPER(TRIM(COALESCE(category_id, 'n. a.')))::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (sub_src_id, sys, ent) * FROM raw_subcats;
END; $$;

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


--Cretate a function and procedure for CE_COLORS table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_COLORS_DATA()
RETURNS TABLE (src_id VARCHAR, col_name VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_colors AS (
        SELECT 
            UPPER(TRIM(COALESCE(color, 'n. a.')))::VARCHAR AS c_src_id,
            COALESCE(TRIM(color), 'n. a.')::VARCHAR AS c_name, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos
        UNION ALL
        SELECT 
            UPPER(TRIM(COALESCE(color, 'n. a.')))::VARCHAR,
            COALESCE(TRIM(color), 'n. a.')::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (c_src_id, sys, ent) * FROM raw_colors;
END; $$;

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


--Cretate a function and procedure for CE_STORAGE_CAPACITIES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_STORAGE_DATA()
RETURNS TABLE (src_id VARCHAR, cap_name VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_storage AS (
        SELECT 
            UPPER(TRIM(COALESCE(storage_capacity, 'n. a.')))::VARCHAR AS st_src_id,
            COALESCE(TRIM(storage_capacity), 'n. a.')::VARCHAR AS st_name, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos
        UNION ALL
        SELECT
            UPPER(TRIM(COALESCE(storage_capacity, 'n. a.')))::VARCHAR, 
            COALESCE(TRIM(storage_capacity), 'n. a.')::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (st_src_id, sys, ent) * FROM raw_storage;
END; $$;

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


--Cretate a function and procedure for CE_PRODUCTS_SCD table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_PRODUCTS_DATA()
RETURNS TABLE (
    p_src_id VARCHAR, p_name VARCHAR, sub_k VARCHAR, m_y INT, 
    col_k VARCHAR, cap_k VARCHAR, war VARCHAR, s_sys VARCHAR, s_ent VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_prods AS (
        SELECT 
            UPPER(TRIM(COALESCE(product_id, 'n. a.')))::VARCHAR AS p_id, 
            COALESCE(TRIM(product_name), 'n. a.')::VARCHAR AS name, 
            UPPER(TRIM(COALESCE(sub_category_name, 'n. a.')))::VARCHAR AS sub_k, 
            COALESCE(model_year, '0')::INT AS m_y, 
            UPPER(TRIM(COALESCE(color, 'n. a.')))::VARCHAR AS col_k, 
            UPPER(TRIM(COALESCE(storage_capacity, 'n. a.')))::VARCHAR AS cap_k, 
            COALESCE(TRIM(warranty_period), 'n. a.')::VARCHAR AS war, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos
        UNION ALL
        SELECT 
            UPPER(TRIM(COALESCE(sku_id, 'n. a.')))::VARCHAR, 
            COALESCE(TRIM(product_name), 'n. a.')::VARCHAR, 
            UPPER(TRIM(COALESCE(sub_category_name, 'n. a.')))::VARCHAR, 
            COALESCE(model_year, '0')::INT, 
            UPPER(TRIM(COALESCE(color, 'n. a.')))::VARCHAR, 
            UPPER(TRIM(COALESCE(storage_capacity, 'n. a.')))::VARCHAR, 
            COALESCE(TRIM(warranty_period), 'n. a.')::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (p_id, sys, ent) * FROM raw_prods;
END; $$;

CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_CE_PRODUCTS_SCD()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_CE_PRODUCTS_SCD';
    v_rows INT := 0;
    v_cnt  INT;
    r RECORD;
    v_now TIMESTAMP := NOW(); 
BEGIN
    FOR r IN (
        SELECT 
            src.*,
            COALESCE(col.COLOR_ID, -1) as v_col_id,
            COALESCE(sub.SUBCATEGORY_ID, -1) as v_sub_id,
            COALESCE(stg.STORAGE_CAPACITY_ID, -1) as v_stg_id,
            (SELECT DISTINCT PRODUCT_ID 
             FROM BL_3NF.CE_PRODUCTS_SCD 
             WHERE PRODUCT_SRC_ID = src.p_src_id 
               AND SOURCE_SYSTEM = src.s_sys 
               AND SOURCE_ENTITY = src.s_ent 
               AND PRODUCT_ID <> -1 
             LIMIT 1) as v_current_product_id
        FROM BL_CL.FNC_GET_PRODUCTS_DATA() src
        LEFT JOIN BL_3NF.CE_COLORS col 
            ON col.COLOR_SRC_ID = src.col_k 
            AND col.SOURCE_SYSTEM = src.s_sys 
            AND col.SOURCE_ENTITY = src.s_ent
        LEFT JOIN BL_3NF.CE_SUBCATEGORIES sub 
            ON sub.SUBCATEGORY_SRC_ID = src.sub_k 
            AND sub.SOURCE_SYSTEM = src.s_sys 
            AND sub.SOURCE_ENTITY = src.s_ent
        LEFT JOIN BL_3NF.CE_STORAGE_CAPACITIES stg 
            ON stg.STORAGE_CAPACITY_SRC_ID = src.cap_k 
            AND stg.SOURCE_SYSTEM = src.s_sys 
            AND stg.SOURCE_ENTITY = src.s_ent
    ) LOOP
        UPDATE BL_3NF.CE_PRODUCTS_SCD
        SET END_DT = v_now, 
            IS_ACTIVE = 'N'
        WHERE PRODUCT_SRC_ID = r.p_src_id 
          AND SOURCE_SYSTEM = r.s_sys 
          AND SOURCE_ENTITY = r.s_ent
          AND IS_ACTIVE = 'Y'
          AND (PRODUCT_NAME <> r.p_name 
               OR MODEL_YEAR <> r.m_y 
               OR WARRANTY_PERIOD <> r.war
               OR COLOR_ID <> r.v_col_id
               OR SUBCATEGORY_ID <> r.v_sub_id
               OR STORAGE_CAPACITY_ID <> r.v_stg_id);
        INSERT INTO BL_3NF.CE_PRODUCTS_SCD (
            PRODUCT_ID, PRODUCT_SRC_ID, PRODUCT_NAME, SUBCATEGORY_ID, MODEL_YEAR, 
            COLOR_ID, STORAGE_CAPACITY_ID, WARRANTY_PERIOD, START_DT, END_DT, IS_ACTIVE, 
            SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT)
        SELECT 
            COALESCE(r.v_current_product_id, nextval('BL_3NF.SEQ_CE_PRODUCTS')), 
            r.p_src_id, r.p_name, r.v_sub_id, r.m_y, r.v_col_id, r.v_stg_id, r.war, 
            CASE WHEN r.v_current_product_id IS NULL THEN '1900-01-01 00:00:00'::TIMESTAMP ELSE v_now END, 
            '9999-12-31 23:59:59', 'Y', r.s_sys, r.s_ent, NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_PRODUCTS_SCD t 
            WHERE t.PRODUCT_SRC_ID = r.p_src_id 
              AND t.SOURCE_SYSTEM = r.s_sys 
              AND t.SOURCE_ENTITY = r.s_ent
              AND t.IS_ACTIVE = 'Y');              
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows, 'SUCCESS', 'SCD Type 2 load finished with historical start date logic');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Cretate a function and procedure for CE_SEGMENTS table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_SEGMENTS_DATA()
RETURNS TABLE (src_id VARCHAR, seg_name VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_segments AS (
        SELECT 
            UPPER(TRIM(COALESCE(segment, 'n. a.')))::VARCHAR AS s_id, 
            TRIM(COALESCE(segment, 'n. a.'))::VARCHAR AS s_name, 
            'SA_APPLE_ONLINE'::VARCHAR AS sys, 
            'SRC_APPLE_ONLINE'::VARCHAR AS ent 
        FROM sa_apple_online.src_apple_online
        UNION ALL
        SELECT 
            'n. a.'::VARCHAR, 
            'n. a.'::VARCHAR, 
            'SA_APPLE_POS'::VARCHAR, 
            'SRC_APPLE_POS'::VARCHAR 
        FROM sa_apple_pos.src_apple_pos)
    SELECT DISTINCT ON (s_id, sys, ent) * FROM raw_segments;
END; $$;

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


--Cretate a function and procedure for CE_CUSTOMERS table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_CUSTOMERS_DATA()
RETURNS TABLE (
    c_src_id VARCHAR, l_card VARCHAR, f_name VARCHAR, l_name VARCHAR, 
    email VARCHAR, phone VARCHAR, age VARCHAR, gender VARCHAR, 
    seg_key VARCHAR, addr_key VARCHAR, s_sys VARCHAR, s_ent VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH unique_ids AS (
        SELECT UPPER(TRIM(loyalty_card_no))::VARCHAR AS s_id, 'SA_APPLE_POS'::VARCHAR AS sys, 'SRC_APPLE_POS'::VARCHAR AS ent, 
        'POS' AS origin FROM sa_apple_pos.src_apple_pos WHERE loyalty_card_no IS NOT NULL GROUP BY 1
        UNION ALL
        SELECT UPPER(TRIM(customer_id))::VARCHAR, 'SA_APPLE_ONLINE'::VARCHAR, 'SRC_APPLE_ONLINE'::VARCHAR, 
        'ONLINE' FROM sa_apple_online.src_apple_online WHERE customer_id IS NOT NULL GROUP BY 1
    )
    SELECT DISTINCT ON (ui.s_id, ui.sys, ui.ent)
        ui.s_id::VARCHAR,
        (CASE WHEN ui.origin = 'POS' THEN ui.s_id ELSE 'n. a.' END)::VARCHAR,
        COALESCE(TRIM(o.first_name), 'n. a.')::VARCHAR, 
        COALESCE(TRIM(o.last_name), 'n. a.')::VARCHAR,
        COALESCE(TRIM(o.email), 'n. a.')::VARCHAR, 
        COALESCE(TRIM(o.phone), 'n. a.')::VARCHAR,
        COALESCE(TRIM(o.age), 'n. a.')::VARCHAR, 
        COALESCE(TRIM(o.gender), 'n. a.')::VARCHAR,
        UPPER(TRIM(COALESCE(o.segment, 'n. a.')))::VARCHAR,
        UPPER(TRIM(COALESCE(o.address_id, p.address_id, 'n. a.')))::VARCHAR,
        ui.sys, ui.ent
    FROM unique_ids ui
    LEFT JOIN sa_apple_online.src_apple_online o ON UPPER(TRIM(o.customer_id)) = ui.s_id AND ui.origin = 'ONLINE'
    LEFT JOIN sa_apple_pos.src_apple_pos p ON UPPER(TRIM(p.loyalty_card_no)) = ui.s_id AND ui.origin = 'POS';
END; $$;

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


--Cretate a function and procedure for CE_POSITIONS table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_POSITIONS_DATA()
RETURNS TABLE (src_id VARCHAR, p_name VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_pos AS (
        SELECT 
            UPPER(TRIM(COALESCE(position, 'n. a.')))::VARCHAR AS p_id, 
            COALESCE(TRIM(position), 'n. a.')::VARCHAR AS p_n, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos)
    SELECT DISTINCT ON (p_id, sys, ent) p_id, p_n, sys, ent FROM raw_pos;
END; $$;

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


--Cretate a function and procedure for CE_EMPLOYEES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_EMPLOYEES_DATA()
RETURNS TABLE (src_id VARCHAR, f_name VARCHAR, l_name VARCHAR, pos_k VARCHAR, h_date DATE, email VARCHAR, phone VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_emp AS (
        SELECT 
            UPPER(TRIM(COALESCE(employee_id, 'n. a.')))::VARCHAR AS e_id, 
            COALESCE(TRIM(employee_first_name), 'n. a.')::VARCHAR AS fn, 
            COALESCE(TRIM(employee_last_name), 'n. a.')::VARCHAR AS ln, 
            UPPER(TRIM(COALESCE(position, 'n. a.')))::VARCHAR AS pk, 
            COALESCE(hire_date, '1900-01-01')::DATE AS hd, 
            COALESCE(TRIM(employee_email), 'n. a.')::VARCHAR AS em, 
            COALESCE(TRIM(employee_phone), 'n. a.')::VARCHAR AS ph,
            'SA_APPLE_POS'::VARCHAR AS sys, 'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos)
    SELECT DISTINCT ON (e_id, sys, ent) * FROM raw_emp;
END; $$;

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


--Cretate a function and procedure for CE_STORE_TYPES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_STORE_TYPES_DATA()
RETURNS TABLE (src_id VARCHAR, s_type VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_data AS (
        SELECT 
            UPPER(TRIM(COALESCE(store_type, 'n. a.')))::VARCHAR AS res_id,  
            COALESCE(TRIM(store_type), 'n. a.')::VARCHAR AS res_name, 
            'SA_APPLE_POS'::VARCHAR AS sys_name, 
            'SRC_APPLE_POS'::VARCHAR AS ent_name
        FROM sa_apple_pos.src_apple_pos)
    SELECT DISTINCT ON (res_id, sys_name) 
        res_id, res_name, sys_name, ent_name 
    FROM raw_data;
END; $$;

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


--Cretate a function and procedure for CE_STORE_STATUSES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_STORE_STATUSES_DATA()
RETURNS TABLE (src_id VARCHAR, s_status VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_data AS (
        SELECT 
            UPPER(TRIM(COALESCE(store_status, 'n. a.')))::VARCHAR AS res_id, 
            COALESCE(TRIM(store_status), 'n. a.')::VARCHAR AS res_name, 
            'SA_APPLE_POS'::VARCHAR AS sys_name, 
            'SRC_APPLE_POS'::VARCHAR AS ent_name
        FROM sa_apple_pos.src_apple_pos)
    SELECT DISTINCT ON (res_id, sys_name) 
        res_id, res_name, sys_name, ent_name 
    FROM raw_data;
END; $$;

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


--Cretate a function and procedure for CE_STORES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_STORES_DATA()
RETURNS TABLE (
    s_src_id VARCHAR, s_name VARCHAR, t_key VARCHAR, st_key VARCHAR, 
    sz INT, op_y INT, genius BOOLEAN, m_key VARCHAR, a_key VARCHAR,
    s_sys VARCHAR, s_ent VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_stores AS (
        SELECT 
            UPPER(COALESCE(store_id, 'n. a.'))::VARCHAR AS res_id, 
            COALESCE(TRIM(store_name), 'n. a.')::VARCHAR AS res_name, 
            UPPER(TRIM(COALESCE(store_type, 'n. a.')))::VARCHAR AS res_type, 
            UPPER(TRIM(COALESCE(store_status, 'n. a.')))::VARCHAR AS res_status, 
            COALESCE(store_size_sqm, '0')::INT AS res_size, 
            COALESCE(opening_year, '0')::INT AS res_year, 
            (CASE WHEN UPPER(has_genius_bar) = 'TRUE' THEN TRUE ELSE FALSE END) AS res_genius, 
            UPPER(COALESCE(manager_id, 'n. a.'))::VARCHAR AS res_mgr, 
            UPPER(COALESCE(address_id, 'n. a.'))::VARCHAR AS res_addr,
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos)
    SELECT DISTINCT ON (res_id, sys, ent) * FROM raw_stores;
END; $$;

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


--Cretate a function and procedure for CE_PROMOTION_TYPES table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_PROMO_TYPES_DATA()
RETURNS TABLE (p_type_src_id VARCHAR, p_name VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_promo_types AS (
        SELECT 
            UPPER(TRIM(COALESCE(promotion_type, 'n. a.')))::VARCHAR AS src_id,
            COALESCE(TRIM(promotion_type), 'n. a.')::VARCHAR AS nme, 
            'SA_APPLE_POS'::VARCHAR AS sys, 
            'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos 
        UNION ALL
        SELECT 
            UPPER(TRIM(COALESCE(promotion_type, 'n. a.')))::VARCHAR,
            COALESCE(TRIM(promotion_type), 'n. a.')::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (src_id, sys, ent) 
           src_id, nme, sys, ent 
    FROM raw_promo_types;
END; $$;

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


--Cretate a function and procedure for CE_PROMOTIONS table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_PROMOTIONS_DATA()
RETURNS TABLE (p_src_id VARCHAR, p_name VARCHAR, pt_key VARCHAR, is_act VARCHAR, s_dt DATE, e_dt DATE, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_promos AS (
        SELECT 
            UPPER(TRIM(COALESCE(promotion_id, 'n. a.')))::VARCHAR AS pr_id, 
            COALESCE(TRIM(promotion_name), 'n. a.')::VARCHAR AS pr_name, 
            UPPER(TRIM(COALESCE(promotion_type, 'n. a.')))::VARCHAR AS pr_type, 
            COALESCE(is_active, 'n. a.')::VARCHAR AS pr_act, 
            COALESCE(promo_start_date, '1900-01-01')::DATE AS pr_start, 
            COALESCE(promo_end_date, '9999-12-31')::DATE AS pr_end, 
            'SA_APPLE_POS'::VARCHAR AS sys, 'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos 
        UNION ALL
        SELECT 
            UPPER(TRIM(COALESCE(promotion_id, 'n. a.')))::VARCHAR, 
            COALESCE(TRIM(promotion_name), 'n. a.')::VARCHAR, 
            UPPER(TRIM(COALESCE(promotion_type, 'n. a.')))::VARCHAR, 
            COALESCE(is_active, 'n. a.')::VARCHAR, 
            COALESCE(promo_start_date, '1900-01-01')::DATE, 
            COALESCE(promo_end_date, '9999-12-31')::DATE, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (pr_id, sys, ent) * FROM raw_promos;
END; $$;

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


--Cretate a function and procedure for CE_PAYMENT_METHODS table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_PAYMENT_METHODS_DATA()
RETURNS TABLE (pay_src_id VARCHAR, pay_name VARCHAR, pay_type VARCHAR, s_sys VARCHAR, s_ent VARCHAR) 
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_payments AS (
        SELECT 
            UPPER(TRIM(COALESCE(payment_method_name, 'n. a.')))::VARCHAR AS src_id,
            COALESCE(TRIM(payment_method_name), 'n. a.')::VARCHAR AS nme, 
            COALESCE(TRIM(payment_type), 'n. a.')::VARCHAR AS p_t, 
            'SA_APPLE_POS'::VARCHAR AS sys, 'SRC_APPLE_POS'::VARCHAR AS ent 
        FROM sa_apple_pos.src_apple_pos 
        UNION ALL
        SELECT 
            UPPER(TRIM(COALESCE(payment_method_name, 'n. a.')))::VARCHAR, 
            COALESCE(TRIM(payment_method_name), 'n. a.')::VARCHAR, 
            COALESCE(TRIM(payment_type), 'n. a.')::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR 
        FROM sa_apple_online.src_apple_online)
    SELECT DISTINCT ON (src_id, sys, ent) * FROM raw_payments;
END; $$;

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


--Create a Master procedure
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_3NF_DATA_ALL()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_3NF_DATA_ALL';
BEGIN
    CALL BL_CL.PRC_LOAD_CE_REGIONS();
    CALL BL_CL.PRC_LOAD_CE_COUNTRIES();
    CALL BL_CL.PRC_LOAD_CE_STATES();
    CALL BL_CL.PRC_LOAD_CE_CITIES();
    CALL BL_CL.PRC_LOAD_CE_DISTRICTS();
    CALL BL_CL.PRC_LOAD_CE_ADDRESSES();
    CALL BL_CL.PRC_LOAD_CE_CATEGORIES();
    CALL BL_CL.PRC_LOAD_CE_SUBCATEGORIES();
    CALL BL_CL.PRC_LOAD_CE_COLORS();
    CALL BL_CL.PRC_LOAD_CE_STORAGE_CAPACITIES();
    CALL BL_CL.PRC_LOAD_CE_PRODUCTS_SCD();
    CALL BL_CL.PRC_LOAD_CE_POSITIONS();
    CALL BL_CL.PRC_LOAD_CE_EMPLOYEES();
    CALL BL_CL.PRC_LOAD_CE_STORE_TYPES();
    CALL BL_CL.PRC_LOAD_CE_STORE_STATUSES();
    CALL BL_CL.PRC_LOAD_CE_STORES();
    CALL BL_CL.PRC_LOAD_CE_SEGMENTS();
    CALL BL_CL.PRC_LOAD_CE_CUSTOMERS();
    CALL BL_CL.PRC_LOAD_CE_PROMOTION_TYPES();
    CALL BL_CL.PRC_LOAD_CE_PROMOTIONS();
    CALL BL_CL.PRC_LOAD_CE_PAYMENT_METHODS();
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'SUCCESS', 'Full 3NF load layer finished');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', 'Master failed at: ' || SQLERRM);
    RAISE;
END; $$;












































































