--Create Composite Types.

DO $$
BEGIN
    -- 1. TYP_PAYMENT_METHODS
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace 
                   WHERE t.typname = 'typ_payment_methods' AND n.nspname = 'bl_cl') THEN
        CREATE TYPE BL_CL.TYP_PAYMENT_METHODS AS (
            p_src_id BIGINT, p_name VARCHAR(250), p_type VARCHAR(250), s_sys VARCHAR(50), s_ent VARCHAR(50));
    END IF;
    -- 2. TYP_DIM_STORES
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace 
                   WHERE t.typname = 'typ_dim_stores' AND n.nspname = 'bl_cl') THEN
        CREATE TYPE BL_CL.TYP_DIM_STORES AS (
            store_src_id BIGINT, store_name VARCHAR(255), store_type_id BIGINT, store_type VARCHAR(250),
            store_status_id BIGINT, store_status VARCHAR(50), store_size_sqm INT, opening_year INT,
            has_genius_bar BOOLEAN, manager_id BIGINT, mgr_first_name VARCHAR(250), mgr_last_name VARCHAR(250),
            address_id BIGINT, address VARCHAR(500), postal_code VARCHAR(50), district_id BIGINT,
            district_name VARCHAR(255), city_id BIGINT, city_name VARCHAR(255), state_id BIGINT,
            state_name VARCHAR(255), country_id BIGINT, country_name VARCHAR(255), region_id BIGINT, 
            region_name VARCHAR(100), s_sys VARCHAR(50), s_ent VARCHAR(50));
    END IF;
    -- 3. TYP_DIM_CUSTOMERS
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace 
                   WHERE t.typname = 'typ_dim_customers' AND n.nspname = 'bl_cl') THEN
        CREATE TYPE BL_CL.TYP_DIM_CUSTOMERS AS (
            cust_src_id BIGINT, loyalty_card VARCHAR(250), f_name VARCHAR(250), l_name VARCHAR(250),
            email VARCHAR(255), phone VARCHAR(50), age VARCHAR(10), gender VARCHAR(20), seg_id BIGINT, 
            seg_name VARCHAR(100), addr_id BIGINT, addr VARCHAR(500), post_code VARCHAR(20), 
            dist_id BIGINT, dist_name VARCHAR(255), city_id BIGINT, city_name VARCHAR(255), 
            state_id BIGINT, state_name VARCHAR(255), country_id BIGINT, country_name VARCHAR(255), 
            reg_id BIGINT, reg_name VARCHAR(100), s_sys VARCHAR(50), s_ent VARCHAR(50));
    END IF;
    -- 4. TYP_DIM_EMPLOYEES
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace 
                   WHERE t.typname = 'typ_dim_employees' AND n.nspname = 'bl_cl') THEN
        CREATE TYPE BL_CL.TYP_DIM_EMPLOYEES AS (
            emp_src_id BIGINT, f_name VARCHAR(100), l_name VARCHAR(100),
            pos_id BIGINT, pos_name VARCHAR(100), h_date DATE, email VARCHAR(255), 
            phone VARCHAR(50), s_sys VARCHAR(50), s_ent VARCHAR(50));
    END IF;
    -- 5. TYP_DIM_PRODUCTS_SCD
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace 
                   WHERE t.typname = 'typ_dim_products_scd' AND n.nspname = 'bl_cl') THEN
        CREATE TYPE BL_CL.TYP_DIM_PRODUCTS_SCD AS (
            product_src_id BIGINT, product_name VARCHAR(255), category_id BIGINT, 
            category_name VARCHAR(100), subcategory_id BIGINT, subcategory_name VARCHAR(100),
            model_year INT, color_id BIGINT, color_name VARCHAR(50), storage_id BIGINT,
            storage_name VARCHAR(50), warranty_period VARCHAR(50), source_system VARCHAR(50),
            source_entity VARCHAR(50), start_dt TIMESTAMP, end_dt TIMESTAMP, is_active VARCHAR(1));
    END IF;
    -- 6. TYP_DIM_PROMOTIONS
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace 
                   WHERE t.typname = 'typ_dim_promotions' AND n.nspname = 'bl_cl') THEN
        CREATE TYPE BL_CL.TYP_DIM_PROMOTIONS AS (
            p_src_id BIGINT, p_name VARCHAR(255), pt_id BIGINT, pt_name VARCHAR(100),
            is_act VARCHAR(10), p_start DATE, p_end DATE, s_sys VARCHAR(50), s_ent VARCHAR(50));
    END IF;
END $$;








