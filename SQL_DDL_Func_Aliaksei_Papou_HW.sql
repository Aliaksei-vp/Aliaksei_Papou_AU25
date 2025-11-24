
--Task 1: Create a view called 'sales_revenue_by_category_qtr' that shows the film category and total sales revenue for the current quarter and year. The view should only display categories with at least one sale in the current quarter. 

CREATE OR REPLACE VIEW public.sales_revenue_by_category_qtr AS
SELECT
    cat.name AS category_name,
    SUM(CASE
        WHEN EXTRACT(QUARTER FROM pay.payment_date) = EXTRACT(QUARTER FROM CURRENT_DATE)
    	THEN pay.amount
    	ELSE 0 END) AS total_revenue_current_quarter,
    SUM(pay.amount) AS total_revenue_current_year,
    EXTRACT(QUARTER FROM CURRENT_DATE) AS current_quarter,
    EXTRACT(YEAR FROM CURRENT_DATE) AS current_year
FROM public.category cat
JOIN public.film_category fcat 
     ON cat.category_id = fcat.category_id
JOIN public.inventory inv 
     ON fcat.film_id = inv.film_id
JOIN public.rental ren 
     ON inv.inventory_id = ren.inventory_id
JOIN public.payment pay 
     ON ren.rental_id = pay.rental_id
WHERE EXTRACT(YEAR FROM pay.payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY cat.name, current_year, current_quarter
HAVING SUM(pay.amount) > 0;


--Task 2: Create a query language function called 'get_sales_revenue_by_category_qtr' that accepts one parameter representing the current quarter and year and returns the same result as the 'sales_revenue_by_category_qtr' view.

CREATE OR REPLACE FUNCTION public.get_sales_revenue_by_category_qtr(p_date DATE)
RETURNS TABLE(
    category_name TEXT,
    total_revenue_current_quarter NUMERIC,
    total_revenue_current_year NUMERIC,
    current_quarter INT,
    current_year INT)
AS $$
SELECT
    cat.name::text AS category_name,
    SUM(CASE
        WHEN EXTRACT(QUARTER FROM pay.payment_date) = EXTRACT(QUARTER FROM p_date)
        THEN pay.amount
        ELSE 0 END)::numeric AS total_revenue_current_quarter,
    SUM(pay.amount)::numeric AS total_revenue_current_year,
    EXTRACT(QUARTER FROM p_date)::int AS current_quarter,
    EXTRACT(YEAR FROM p_date)::int AS current_year
FROM public.category cat
JOIN public.film_category fcat 
     ON cat.category_id = fcat.category_id
JOIN public.inventory inv 
     ON fcat.film_id = inv.film_id
JOIN public.rental ren 
     ON inv.inventory_id = ren.inventory_id
JOIN public.payment pay 
     ON ren.rental_id = pay.rental_id
WHERE EXTRACT(YEAR FROM pay.payment_date) = EXTRACT(YEAR FROM p_date)
GROUP BY cat.name, EXTRACT(YEAR FROM p_date), EXTRACT(QUARTER FROM p_date)
HAVING SUM(pay.amount) > 0;
$$
LANGUAGE SQL;

--Query (example): 
--SELECT * FROM public.get_sales_revenue_by_category_qtr('2017-01-01'::DATE);


--Task 3: Create a procedure language function that takes a country as an input parameter and returns the most popular film in that specific country. 
--Use RAISE EXCEPTION to identify errors.

CREATE OR REPLACE FUNCTION public.most_popular_films_by_countries(p_countries text[])
RETURNS TABLE (
    country text,
    film_title text,
    rating public.mpaa_rating, --Use this data type because it is defined in the table film as mpaa_rating
    language text,
    length integer,
    release_year public.year) --Use this data type because it is defined in the table film as year
LANGUAGE plpgsql
AS $$
DECLARE
    v_country text;
    v_film_data RECORD;
    v_max_rentals integer;
BEGIN
    IF p_countries IS NULL OR array_length(p_countries, 1) = 0 THEN
        RAISE EXCEPTION 'The list of countries cannot be empty.';
    END IF;
    FOREACH v_country IN ARRAY p_countries LOOP
        PERFORM 1 FROM country WHERE country.country = v_country;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Country "%" not found in database.', v_country;
        END IF;
        WITH country_rentals AS (
        	SELECT fil.film_id,
                COUNT(ren.rental_id) AS rental_count
           	FROM public.country cntr
                JOIN public.city cit ON cntr.country_id = cit.country_id
                JOIN public.address adr ON cit.city_id = adr.city_id
                JOIN public.customer cust ON adr.address_id = cust.address_id
                JOIN public.rental ren ON cust.customer_id = ren.customer_id
                JOIN public.inventory inv ON ren.inventory_id = inv.inventory_id
                JOIN public.film fil ON inv.film_id = fil.film_id
            WHERE cntr.country = v_country
            GROUP BY fil.film_id)
        SELECT MAX(rental_count) INTO v_max_rentals FROM country_rentals;
        IF v_max_rentals IS NULL OR v_max_rentals = 0 THEN
            CONTINUE; 
        END IF;
        FOR v_film_data IN
        SELECT
            cntr.country AS country,
            fil.title AS film_title,
            fil.rating AS rating,
            lng.name AS language,
            fil.length AS length,
            fil.release_year AS release_year
        FROM public.country cntr
            JOIN public.city ci ON cntr.country_id = ci.country_id
            JOIN public.address adr ON ci.city_id = adr.city_id
            JOIN public.customer cust ON adr.address_id = cust.address_id
            JOIN public.rental ren ON cust.customer_id = ren.customer_id
            JOIN public.inventory inv ON ren.inventory_id = inv.inventory_id
            JOIN public.film fil ON inv.film_id = fil.film_id
            JOIN public.language lng ON fil.language_id = lng.language_id
        WHERE cntr.country = v_country
        GROUP BY cntr.country_id, cntr.country, fil.film_id, fil.title, fil.rating, lng.name, fil.length, fil.release_year
        HAVING COUNT(ren.rental_id) = v_max_rentals
        ORDER BY fil.title ASC -- I checked, sometimes films have the same number of rentals, so I decided to add sorting
        LIMIT 1
        LOOP
            country := v_film_data.country;
            film_title := v_film_data.film_title;
            rating := v_film_data.rating;
            language := v_film_data.language;
            length := v_film_data.length;
            release_year := v_film_data.release_year;
            RETURN NEXT;
        END LOOP;
    END LOOP;

    RETURN;
END;
$$;

--Query (example): 
--SELECT * FROM public.most_popular_films_by_countries(ARRAY['Belarus','Brazil','United States']);


--Task 4: Create a procedure language function that generates a list of movies available in stock based on a partial title match (e.g., movies containing the word 'love' in their title).
--The function produce the result set with: automatically generated row_number, film title, language, last customer's name, last rental's date. Use RAISE EXCEPTION to identify errors.

CREATE OR REPLACE FUNCTION public.films_in_stock_by_title(p_partial_title text)
RETURNS TABLE (
    row_num integer,
    film_title text,
    "language" text,
    customer_name text,
    rental_date timestamp 
)
LANGUAGE plpgsql
AS $$
DECLARE
    film_data RECORD;
    v_row_num integer := 0;
    v_title_count integer := 0;
BEGIN
    SELECT COUNT(film_id) INTO v_title_count
    FROM public.film
    WHERE title ILIKE p_partial_title;
    IF v_title_count = 0 THEN
        RAISE EXCEPTION 'Film with the template title % not found', p_partial_title;
    END IF;
    FOR film_data IN
        SELECT
            fil.title::text AS title,
            lng.name::text AS lang,
            (SELECT cust.first_name || ' ' || cust.last_name
             FROM public.rental rnt_last
             JOIN public.customer cust ON rnt_last.customer_id = cust.customer_id
             WHERE rnt_last.inventory_id = inv.inventory_id
             ORDER BY rnt_last.rental_date DESC
             LIMIT 1)::text AS cust_name,
            (SELECT rnt_last.rental_date
             FROM public.rental rnt_last
             WHERE rnt_last.inventory_id = inv.inventory_id
             ORDER BY rnt_last.rental_date DESC
             LIMIT 1)::timestamp AS rental_dt
        FROM public.film fil
        JOIN public.language lng ON fil.language_id = lng.language_id
        JOIN public.inventory inv ON fil.film_id = inv.film_id
        WHERE fil.title ILIKE p_partial_title
        AND NOT EXISTS (SELECT 1 FROM public.rental rnt_current
                	WHERE rnt_current.inventory_id = inv.inventory_id
                	AND rnt_current.return_date IS NULL)
        ORDER BY fil.title, inv.inventory_id
    LOOP
        v_row_num := v_row_num + 1;
        film_title := film_data.title;
        "language" := film_data.lang;
        customer_name := film_data.cust_name; 
        rental_date := film_data.rental_dt; 
        row_num := v_row_num; 
        RETURN NEXT; 
    END LOOP;
    IF v_row_num = 0 THEN
         RAISE EXCEPTION 'All films found with the template title % are currently rented', p_partial_title;
    END IF;
END;
$$;

--Query (example): 
--SELECT * FROM public.films_in_stock_by_title('%love%');


--Task 5: Create a procedure language function called 'new_movie' that takes a movie title as a parameter and inserts a new movie with the given title in the film table. The function should generate a new unique film ID, set the rental rate to 4.99, the rental duration to three days, the replacement cost to 19.99. The release year and language are optional and by default should be current year and Klingon respectively. Use RAISE EXCEPTION to identify errors. 

CREATE OR REPLACE FUNCTION public.new_movie(
    p_title VARCHAR,
    p_release_year INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
    p_language_name VARCHAR DEFAULT 'Klingon'
) RETURNS INTEGER AS $$
DECLARE
    v_language_id SMALLINT;
    v_film_id INTEGER;
    v_rental_duration SMALLINT := 3;
    v_rental_rate NUMERIC(4, 2) := 4.99;
    v_replacement_cost NUMERIC(5, 2) := 19.99;
    v_language_exists BOOLEAN;
BEGIN
    SELECT EXISTS (SELECT 1 FROM public.language
        	   WHERE name = p_language_name) 
    INTO v_language_exists;
    IF NOT v_language_exists THEN
        RAISE EXCEPTION 'Language "%" not found in table "language".', p_language_name;
    END IF;
    SELECT language_id INTO v_language_id
    FROM public.language
    WHERE name = p_language_name;
    IF EXISTS (SELECT 1 FROM film
               WHERE title = p_title AND release_year = p_release_year) 
    THEN
        RAISE EXCEPTION 'A film with the title "%" and release year "%" already exists.', p_title, p_release_year;
    END IF;
    SELECT NEXTVAL('film_film_id_seq') INTO v_film_id;
    INSERT INTO film (film_id, title, release_year, language_id, rental_duration, rental_rate,
        replacement_cost, last_update, length, rating)
    SELECT
        v_film_id, p_title, p_release_year, v_language_id, v_rental_duration, v_rental_rate,
        v_replacement_cost, CURRENT_TIMESTAMP, 90, 'G'::mpaa_rating;
    RETURN v_film_id;
END;
$$ LANGUAGE plpgsql;

--Query (example): 
--SELECT new_movie('New super movie');

--Add 'Klingon' language if it doesn't exist
INSERT INTO language (name, last_update)
SELECT 'Klingon', CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM language WHERE name = 'Klingon');


















