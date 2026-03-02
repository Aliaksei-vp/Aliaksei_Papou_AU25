
--Create a function for CE_REGIONS table
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


--Create a function for CE_COUNTRIES table
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


--Create a function for CE_STATES table
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


--Create a function for CE_CITIES table
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


--Create a function for CE_DISTRICTS table
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


--Create a function for CE_ADDRESSES table
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


--Create a function for CE_CATEGORIES table
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


--Create a function for CE_SUBCATEGORIES table
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


--Create a function for CE_COLORS table
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


--Create a function for CE_STORAGE_CAPACITIES table
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


--Create a function for CE_PRODUCTS_SCD table
CREATE OR REPLACE FUNCTION BL_CL.FNC_GET_PRODUCTS_DATA()
RETURNS TABLE (
    p_src_id VARCHAR, p_name VARCHAR, sub_k VARCHAR, m_y INT, 
    col_k VARCHAR, cap_k VARCHAR, war VARCHAR, s_sys VARCHAR, s_ent VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH raw_prods AS (
        SELECT 
            UPPER(TRIM(COALESCE(t.product_id, 'n. a.')))::VARCHAR AS p_id, 
            COALESCE(TRIM(t.product_name), 'n. a.')::VARCHAR AS p_nm, 
            UPPER(TRIM(COALESCE(t.sub_category_name, 'n. a.')))::VARCHAR AS s_k, 
            COALESCE(t.model_year, '0')::INT AS model_y, 
            UPPER(TRIM(COALESCE(t.color, 'n. a.')))::VARCHAR AS c_k, 
            UPPER(TRIM(COALESCE(t.storage_capacity, 'n. a.')))::VARCHAR AS cp_k, 
            COALESCE(TRIM(t.warranty_period), 'n. a.')::VARCHAR AS w_p, 
            'SA_APPLE_POS'::VARCHAR AS sys_name, 
            'SRC_APPLE_POS'::VARCHAR AS ent_name,
            t.insert_dt
        FROM sa_apple_pos.src_apple_pos t
        UNION ALL       
        SELECT 
            UPPER(TRIM(COALESCE(o.sku_id, 'n. a.')))::VARCHAR, 
            COALESCE(TRIM(o.product_name), 'n. a.')::VARCHAR, 
            UPPER(TRIM(COALESCE(o.sub_category_name, 'n. a.')))::VARCHAR, 
            COALESCE(o.model_year, '0')::INT, 
            UPPER(TRIM(COALESCE(o.color, 'n. a.')))::VARCHAR, 
            UPPER(TRIM(COALESCE(o.storage_capacity, 'n. a.')))::VARCHAR, 
            COALESCE(TRIM(o.warranty_period), 'n. a.')::VARCHAR, 
            'SA_APPLE_ONLINE'::VARCHAR, 
            'SRC_APPLE_ONLINE'::VARCHAR,
            o.insert_dt
        FROM sa_apple_online.src_apple_online o)
    SELECT DISTINCT ON (r.p_id, r.sys_name, r.ent_name) 
        r.p_id, r.p_nm, r.s_k, r.model_y, r.c_k, r.cp_k, r.w_p, r.sys_name, r.ent_name
    FROM raw_prods r
    ORDER BY r.p_id, r.sys_name, r.ent_name, r.insert_dt DESC; 
END; $$;


--Create a function for CE_SEGMENTS table
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


--Create a function for CE_CUSTOMERS table
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


--Create a function for CE_POSITIONS table
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


--Create a function for CE_EMPLOYEES table
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


--Create a function for CE_STORE_TYPES table
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


--Create a function for CE_STORE_STATUSES table
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


--Create a function for CE_STORES table
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


--Create a function for CE_PROMOTION_TYPES table
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


--Create a function for CE_PROMOTIONS table
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


--Create a function for CE_PAYMENT_METHODS table
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



