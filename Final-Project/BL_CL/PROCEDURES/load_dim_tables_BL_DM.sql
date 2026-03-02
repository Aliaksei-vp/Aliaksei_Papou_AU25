
--Create a procedure for load DIM_STORES table.
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_DIM_STORES()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows_cnt INT := 0;
    v_cur_var  REFCURSOR;
    v_rec      BL_CL.TYP_DIM_STORES;
    v_sql      TEXT;
BEGIN
    v_sql := 'SELECT 
                s.STORE_ID, s.STORE_NAME, s.STORE_TYPE_ID, stp.STORE_TYPE,
                s.STORE_STATUS_ID, sts.STORE_STATUS, s.STORE_SIZE_SQM, s.OPENING_YEAR,
                s.HAS_GENIUS_BAR, s.MANAGER_ID, e.EMPLOYEE_FIRST_NAME, e.EMPLOYEE_LAST_NAME,
                s.ADDRESS_ID, a.ADDRESS, a.POSTAL_CODE, d.DISTRICT_ID, d.DISTRICT_NAME,
                ci.CITY_ID, ci.CITY_NAME, st.STATE_ID, st.STATE_NAME,
                co.COUNTRY_ID, co.COUNTRY_NAME, re.REGION_ID, re.REGION_NAME,
                s.SOURCE_SYSTEM, s.SOURCE_ENTITY
              FROM BL_3NF.CE_STORES s
              JOIN BL_3NF.CE_STORE_TYPES stp ON s.STORE_TYPE_ID = stp.STORE_TYPE_ID
              JOIN BL_3NF.CE_STORE_STATUSES sts ON s.STORE_STATUS_ID = sts.STORE_STATUS_ID
              JOIN BL_3NF.CE_EMPLOYEES e ON s.MANAGER_ID = e.EMPLOYEE_ID
              JOIN BL_3NF.CE_ADDRESSES a ON s.ADDRESS_ID = a.ADDRESS_ID
              JOIN BL_3NF.CE_DISTRICTS d ON a.DISTRICT_ID = d.DISTRICT_ID
              JOIN BL_3NF.CE_CITIES ci ON d.CITY_ID = ci.CITY_ID
              JOIN BL_3NF.CE_STATES st ON ci.REGION_ID = st.STATE_ID
              JOIN BL_3NF.CE_COUNTRIES co ON st.COUNTRY_ID = co.COUNTRY_ID
              JOIN BL_3NF.CE_REGIONS re ON co.REGION_ID = re.REGION_ID
              WHERE s.STORE_ID <> -1';
    OPEN v_cur_var FOR EXECUTE v_sql;
    LOOP
        FETCH v_cur_var INTO v_rec;
        EXIT WHEN NOT FOUND;
        INSERT INTO BL_DM.DIM_STORES (
            STORE_SURR_ID, STORE_SRC_ID, STORE_NAME, STORE_TYPE_ID, STORE_TYPE,
            STORE_STATUS_ID, STORE_STATUS, STORE_SIZE_SQM, OPENING_YEAR, HAS_GENIUS_BAR,
            MANAGER_ID, MANAGER_FIRST_NAME, MANAGER_LAST_NAME, ADDRESS_ID, ADDRESS,
            POSTAL_CODE, DISTRICT_ID, DISTRICT_NAME, CITY_ID, CITY_NAME,
            STATE_ID, STATE_NAME, COUNTRY_ID, COUNTRY_NAME, REGION_ID, REGION_NAME,
            SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        VALUES (
            nextval('BL_DM.SEQ_DIM_STORES'), v_rec.store_src_id, v_rec.store_name, v_rec.store_type_id, v_rec.store_type,
            v_rec.store_status_id, v_rec.store_status, v_rec.store_size_sqm, v_rec.opening_year, v_rec.has_genius_bar,
            v_rec.manager_id, v_rec.mgr_first_name, v_rec.mgr_last_name, v_rec.address_id, v_rec.address,
            v_rec.postal_code, v_rec.district_id, v_rec.district_name, v_rec.city_id, v_rec.city_name,
            v_rec.state_id, v_rec.state_name, v_rec.country_id, v_rec.country_name, v_rec.region_id, v_rec.region_name,
            v_rec.s_sys, v_rec.s_ent, NOW(), NOW())
        ON CONFLICT (STORE_SRC_ID, SOURCE_SYSTEM) DO UPDATE SET
            STORE_NAME = EXCLUDED.STORE_NAME,
            STORE_STATUS = EXCLUDED.STORE_STATUS,
            MANAGER_ID = EXCLUDED.MANAGER_ID,
            UPDATE_DT = NOW()
        WHERE DIM_STORES.STORE_NAME <> EXCLUDED.STORE_NAME OR DIM_STORES.STORE_STATUS <> EXCLUDED.STORE_STATUS;
        IF FOUND THEN v_rows_cnt := v_rows_cnt + 1; END IF;
    END LOOP;
    CLOSE v_cur_var;
    CALL BL_CL.PRC_WRITE_LOG('PRC_LOAD_DIM_STORES', v_rows_cnt, 'SUCCESS', 'DM Stores loaded');
EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG('PRC_LOAD_DIM_STORES', 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


--Create a procedure for load DIM_CUSTOMERS table.
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_DIM_CUSTOMERS()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows_cnt INT := 0;
    v_cur_var  REFCURSOR;
    v_rec      BL_CL.TYP_DIM_CUSTOMERS;
    v_sql      TEXT;
BEGIN
    v_sql := 'SELECT 
                c.CUSTOMER_ID, c.LOYALTY_CARD_NO, c.FIRST_NAME, c.LAST_NAME,
                c.EMAIL, c.PHONE, c.AGE, c.GENDER, 
                s.SEGMENT_ID, s.SEGMENT_NAME, a.ADDRESS_ID, a.ADDRESS,
                a.POSTAL_CODE, d.DISTRICT_ID, d.DISTRICT_NAME,
                ci.CITY_ID, ci.CITY_NAME, st.STATE_ID, st.STATE_NAME,
                co.COUNTRY_ID, co.COUNTRY_NAME, re.REGION_ID, re.REGION_NAME,
                c.SOURCE_SYSTEM, c.SOURCE_ENTITY
              FROM BL_3NF.CE_CUSTOMERS c
              JOIN BL_3NF.CE_SEGMENTS s ON c.SEGMENT_ID = s.SEGMENT_ID
              JOIN BL_3NF.CE_ADDRESSES a ON c.ADDRESS_ID = a.ADDRESS_ID
              JOIN BL_3NF.CE_DISTRICTS d ON a.DISTRICT_ID = d.DISTRICT_ID
              JOIN BL_3NF.CE_CITIES ci ON d.CITY_ID = ci.CITY_ID
              JOIN BL_3NF.CE_STATES st ON ci.REGION_ID = st.STATE_ID
              JOIN BL_3NF.CE_COUNTRIES co ON st.COUNTRY_ID = co.COUNTRY_ID
              JOIN BL_3NF.CE_REGIONS re ON co.REGION_ID = re.REGION_ID
              WHERE c.CUSTOMER_ID <> -1';
    OPEN v_cur_var FOR EXECUTE v_sql;
    LOOP
        FETCH v_cur_var INTO v_rec;
        EXIT WHEN NOT FOUND;
        INSERT INTO BL_DM.DIM_CUSTOMERS (
            CUSTOMER_SURR_ID, CUSTOMER_SRC_ID, LOYALITY_CARD_NO, FIRST_NAME, LAST_NAME,
            EMAIL, PHONE, AGE, GENDER, SEGMENT_ID, SEGMENT_NAME, ADDRESS_ID, ADDRESS,
            POSTAL_CODE, DISTRICT_ID, DISTRICT_NAME, CITY_ID, CITY_NAME, 
            STATE_ID, STATE_NAME, COUNTRY_ID, COUNTRY_NAME, REGION_ID, REGION_NAME,
            SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        VALUES (
            nextval('BL_DM.SEQ_DIM_CUSTOMERS'), v_rec.cust_src_id, v_rec.loyalty_card, v_rec.f_name, v_rec.l_name,
            v_rec.email, v_rec.phone, v_rec.age, v_rec.gender, v_rec.seg_id, v_rec.seg_name, v_rec.addr_id, v_rec.addr,
            v_rec.post_code, v_rec.dist_id, v_rec.dist_name, v_rec.city_id, v_rec.city_name,
            v_rec.state_id, v_rec.state_name, v_rec.country_id, v_rec.country_name, v_rec.reg_id, v_rec.reg_name,
            v_rec.s_sys, v_rec.s_ent, NOW(), NOW())
        ON CONFLICT (CUSTOMER_SRC_ID, SOURCE_SYSTEM) DO UPDATE SET
            LAST_NAME = EXCLUDED.LAST_NAME,
            EMAIL = EXCLUDED.EMAIL,
            UPDATE_DT = NOW()
        WHERE DIM_CUSTOMERS.EMAIL <> EXCLUDED.EMAIL;
        IF FOUND THEN v_rows_cnt := v_rows_cnt + 1; END IF;
    END LOOP;
    CLOSE v_cur_var;
    CALL BL_CL.PRC_WRITE_LOG('PRC_LOAD_DIM_CUSTOMERS', v_rows_cnt, 'SUCCESS', 'DM Customers loaded');
    EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG('PRC_LOAD_DIM_CUSTOMERS', 0, 'ERROR', SQLERRM); 
    RAISE;
END; $$;


--Create a procedure for load DIM_PRODUCTS_SCD type 2 table.
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_DIM_PRODUCTS_SCD()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc_name CONSTANT TEXT := 'PRC_LOAD_DIM_PRODUCTS_SCD';
    v_rows_cnt INT := 0;
    v_rec      RECORD; 
BEGIN
    FOR v_rec IN (
        SELECT 
            p.PRODUCT_ID AS product_3nf_id, 
            p.PRODUCT_NAME, 
            cat.CATEGORY_ID, cat.CATEGORY_NAME,
            sub.SUBCATEGORY_ID, sub.SUBCATEGORY_NAME,
            p.MODEL_YEAR, col.COLOR_ID, col.COLOR_NAME,
            st.STORAGE_CAPACITY_ID, st.STORAGE_CAPACITY,
            p.WARRANTY_PERIOD, p.SOURCE_SYSTEM, p.SOURCE_ENTITY,
            p.START_DT, p.END_DT, p.IS_ACTIVE
        FROM BL_3NF.CE_PRODUCTS_SCD p
        JOIN BL_3NF.CE_SUBCATEGORIES sub ON p.SUBCATEGORY_ID = sub.SUBCATEGORY_ID
        JOIN BL_3NF.CE_CATEGORIES cat ON sub.CATEGORY_ID = cat.CATEGORY_ID
        JOIN BL_3NF.CE_COLORS col ON p.COLOR_ID = col.COLOR_ID
        JOIN BL_3NF.CE_STORAGE_CAPACITIES st ON p.STORAGE_CAPACITY_ID = st.STORAGE_CAPACITY_ID
        WHERE p.PRODUCT_ID <> -1
    ) LOOP
        UPDATE BL_DM.DIM_PRODUCTS_SCD
        SET END_DT = v_rec.END_DT,
            IS_ACTIVE = v_rec.IS_ACTIVE,
            INSERT_DT = NOW()
        WHERE PRODUCT_SRC_ID = v_rec.product_3nf_id 
          AND SOURCE_SYSTEM = v_rec.SOURCE_SYSTEM
          AND START_DT = v_rec.START_DT
          AND (END_DT <> v_rec.END_DT OR IS_ACTIVE <> v_rec.IS_ACTIVE);
        INSERT INTO BL_DM.DIM_PRODUCTS_SCD (
            PRODUCT_SURR_ID, 
            PRODUCT_SRC_ID,  
            PRODUCT_NAME, CATEGORY_ID, CATEGORY_NAME, SUBCATEGORY_ID, SUBCATEGORY_NAME,
            MODEL_YEAR, COLOR_ID, COLOR_NAME, STORAGE_CAPACITY_ID, STORAGE_CAPACITY,
            WARRANTY_PERIOD, SOURCE_SYSTEM, SOURCE_ENTITY, 
            START_DT, END_DT, IS_ACTIVE, INSERT_DT)
        SELECT 
            nextval('BL_DM.SEQ_DIM_PRODUCTS_SCD'), 
            v_rec.product_3nf_id, 
            v_rec.PRODUCT_NAME, v_rec.CATEGORY_ID, v_rec.CATEGORY_NAME, 
            v_rec.SUBCATEGORY_ID, v_rec.SUBCATEGORY_NAME,
            v_rec.MODEL_YEAR, v_rec.COLOR_ID, v_rec.COLOR_NAME, 
            v_rec.STORAGE_CAPACITY_ID, v_rec.STORAGE_CAPACITY,
            v_rec.WARRANTY_PERIOD, v_rec.SOURCE_SYSTEM, v_rec.SOURCE_ENTITY,
            v_rec.START_DT, v_rec.END_DT, v_rec.IS_ACTIVE, NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_DM.DIM_PRODUCTS_SCD t
            WHERE t.PRODUCT_SRC_ID = v_rec.product_3nf_id 
              AND t.SOURCE_SYSTEM = v_rec.SOURCE_SYSTEM 
              AND t.START_DT = v_rec.START_DT);
        IF FOUND THEN 
            v_rows_cnt := v_rows_cnt + 1; 
        END IF;
    END LOOP;  
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, v_rows_cnt, 'SUCCESS', 'DM SCD2 synced with 3NF');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG(v_proc_name, 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load DIM_EMPLOYEES table.
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_DIM_EMPLOYEES()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows_cnt INT := 0;
    v_cur_var  REFCURSOR;
    v_rec      BL_CL.TYP_DIM_EMPLOYEES;
    v_sql      TEXT;
BEGIN
    v_sql := 'SELECT 
                e.EMPLOYEE_ID, e.EMPLOYEE_FIRST_NAME, e.EMPLOYEE_LAST_NAME,
                e.POSITION_ID, p.POSITION_NAME, e.HIRE_DATE, e.EMPLOYEE_EMAIL, e.EMPLOYEE_PHONE,
                e.SOURCE_SYSTEM, e.SOURCE_ENTITY
              FROM BL_3NF.CE_EMPLOYEES e
              JOIN BL_3NF.CE_POSITIONS p ON e.POSITION_ID = p.POSITION_ID
              WHERE e.EMPLOYEE_ID <> -1';
    OPEN v_cur_var FOR EXECUTE v_sql;
    LOOP
        FETCH v_cur_var INTO v_rec;
        EXIT WHEN NOT FOUND;
        INSERT INTO BL_DM.DIM_EMPLOYEES (
            EMPLOYEE_SURR_ID, EMPLOYEE_SRC_ID, FIRST_NAME, LAST_NAME,
            POSITION_ID, POSITION_NAME, HIRE_DATE, EMAIL, PHONE,
            SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        VALUES (
            nextval('BL_DM.SEQ_DIM_EMPLOYEES'), v_rec.emp_src_id, v_rec.f_name, v_rec.l_name,
            v_rec.pos_id, v_rec.pos_name, v_rec.h_date, v_rec.email, v_rec.phone,
            v_rec.s_sys, v_rec.s_ent, NOW(), NOW())
        ON CONFLICT (EMPLOYEE_SRC_ID, SOURCE_SYSTEM) DO UPDATE SET
            LAST_NAME = EXCLUDED.LAST_NAME,
            POSITION_NAME = EXCLUDED.POSITION_NAME,
            UPDATE_DT = NOW()
        WHERE DIM_EMPLOYEES.POSITION_NAME <> EXCLUDED.POSITION_NAME;
        IF FOUND THEN v_rows_cnt := v_rows_cnt + 1; END IF;
    END LOOP;
    CLOSE v_cur_var;
    CALL BL_CL.PRC_WRITE_LOG('PRC_LOAD_DIM_EMPLOYEES', v_rows_cnt, 'SUCCESS', 'DM Employees loaded');
    EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG('PRC_LOAD_DIM_EMPLOYEES', 0, 'ERROR', SQLERRM); 
    RAISE;    
END; $$;


--Create a procedure for load DIM_PAYMENT_METHODS table.
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_DIM_PAYMENT_METHODS()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows_cnt INT := 0;
    v_cur_var REFCURSOR;
    v_rec BL_CL.TYP_PAYMENT_METHODS;
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT 
                PAYMENT_METHOD_ID, 
                PAYMENT_METHOD_NAME, 
                PAYMENT_METHOD_TYPE, 
                SOURCE_SYSTEM, 
                SOURCE_ENTITY 
              FROM BL_3NF.CE_PAYMENT_METHODS 
              WHERE PAYMENT_METHOD_ID <> -1';
    OPEN v_cur_var FOR EXECUTE v_sql;
    LOOP
        FETCH v_cur_var INTO v_rec;
        EXIT WHEN NOT FOUND;
        INSERT INTO BL_DM.DIM_PAYMENT_METHODS (
            PAYMENT_METHOD_SURR_ID, PAYMENT_METHOD_SRC_ID, PAYMENT_METHOD_NAME, 
            PAYMENT_METHOD_TYPE, SOURCE_SYSTEM, SOURCE_ENTITY, INSERT_DT, UPDATE_DT)
        VALUES (
            nextval('BL_DM.SEQ_DIM_PAYMENT_METHODS'),
            v_rec.p_src_id, v_rec.p_name, v_rec.p_type, v_rec.s_sys, v_rec.s_ent, 
            NOW(), NOW())
        ON CONFLICT (PAYMENT_METHOD_SRC_ID, SOURCE_SYSTEM) 
        DO UPDATE SET 
            PAYMENT_METHOD_NAME = EXCLUDED.PAYMENT_METHOD_NAME,
            PAYMENT_METHOD_TYPE = EXCLUDED.PAYMENT_METHOD_TYPE,
            UPDATE_DT = NOW()
        WHERE DIM_PAYMENT_METHODS.PAYMENT_METHOD_NAME <> EXCLUDED.PAYMENT_METHOD_NAME 
           OR DIM_PAYMENT_METHODS.PAYMENT_METHOD_TYPE <> EXCLUDED.PAYMENT_METHOD_TYPE;
        IF FOUND THEN
            v_rows_cnt := v_rows_cnt + 1;
        END IF;
    END LOOP;
    CLOSE v_cur_var;
    CALL BL_CL.PRC_WRITE_LOG('PRC_LOAD_DIM_PAYMENT_METHODS', v_rows_cnt, 'SUCCESS', 'DM Payment Methods loaded');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.PRC_WRITE_LOG('PRC_LOAD_DIM_PAYMENT_METHODS', 0, 'ERROR', SQLERRM);
    RAISE;
END; $$;


--Create a procedure for load DIM_PROMOTIONS table.
CREATE OR REPLACE PROCEDURE BL_CL.PRC_LOAD_DIM_PROMOTIONS()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows_cnt INT := 0;
    v_cur_var  REFCURSOR;
    v_rec      BL_CL.TYP_DIM_PROMOTIONS;
    v_sql      TEXT;
BEGIN
    v_sql := 'SELECT 
                p.PROMOTION_ID, p.PROMOTION_NAME, 
                pt.PROMOTION_TYPE_ID, pt.PROMOTION_TYPE,
                p.IS_ACTIVE, p.PROMO_START_DATE, p.PROMO_END_DATE,
                p.SOURCE_SYSTEM, p.SOURCE_ENTITY
              FROM BL_3NF.CE_PROMOTIONS p
              JOIN BL_3NF.CE_PROMOTION_TYPES pt ON p.PROMOTION_TYPE_ID = pt.PROMOTION_TYPE_ID
              WHERE p.PROMOTION_ID <> -1';
    OPEN v_cur_var FOR EXECUTE v_sql;
    LOOP
        FETCH v_cur_var INTO v_rec;
        EXIT WHEN NOT FOUND;
        INSERT INTO BL_DM.DIM_PROMOTIONS (
            PROMOTION_SURR_ID, PROMOTION_SRC_ID, PROMOTION_NAME, 
            PROMOTION_TYPE_ID, PROMOTION_TYPE, IS_ACTIVE, 
            PROMO_START, PROMO_END, SOURCE_SYSTEM, SOURCE_ENTITY, 
            INSERT_DT, UPDATE_DT)
        VALUES (
            nextval('BL_DM.SEQ_DIM_PROMOTIONS'), v_rec.p_src_id, v_rec.p_name,
            v_rec.pt_id, v_rec.pt_name, v_rec.is_act,
            v_rec.p_start, v_rec.p_end, v_rec.s_sys, v_rec.s_ent,
            NOW(), NOW())
        ON CONFLICT (PROMOTION_SRC_ID, SOURCE_SYSTEM) DO UPDATE SET
            PROMOTION_NAME = EXCLUDED.PROMOTION_NAME,
            IS_ACTIVE = EXCLUDED.IS_ACTIVE,
            UPDATE_DT = NOW()
        WHERE DIM_PROMOTIONS.IS_ACTIVE <> EXCLUDED.IS_ACTIVE;
        IF FOUND THEN v_rows_cnt := v_rows_cnt + 1; END IF;
    END LOOP;
    CLOSE v_cur_var;
    CALL BL_CL.PRC_WRITE_LOG('PRC_LOAD_DIM_PROMOTIONS', v_rows_cnt, 'SUCCESS', 'DM Promotions loaded');
    EXCEPTION WHEN OTHERS THEN 
    CALL BL_CL.PRC_WRITE_LOG('PRC_LOAD_DIM_PROMOTIONS', 0, 'ERROR', SQLERRM); 
    RAISE;    
END; $$;


