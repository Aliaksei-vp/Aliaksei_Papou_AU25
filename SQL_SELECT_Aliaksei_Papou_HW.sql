--Task 1.1:Show all animation movies released between 2017 and 2019 with rental_rate more than 1, sorted alphabetically by title.

--JOIN 
SELECT fil.title, 
	   fil.release_year,
	   fil.rental_rate 
FROM public.film fil
INNER JOIN public.film_category fil_cat
	ON fil.film_id = fil_cat.film_id
INNER JOIN public.category cat
	ON fil_cat.category_id = cat.category_id
WHERE LOWER (cat.name) =  LOWER ('Animation') 
	AND fil.release_year 
	BETWEEN 2017 AND 2019
	AND fil.rental_rate > 1
ORDER BY title;


--Subquery
SELECT fil.title, 
	   fil.release_year, 
	   fil.rental_rate 
FROM public.film fil
WHERE fil.film_id IN (
		SELECT fil_cat.film_id 
	    FROM public.film_category fil_cat
WHERE fil_cat.category_id IN (
		SELECT cat.category_id 
		FROM public.category cat
		WHERE LOWER (cat.name) =  LOWER ('Animation') 
)) 
AND fil.release_year BETWEEN 2017 AND 2019
AND fil.rental_rate >1
ORDER BY title;


--CTE
WITH Film_Category_CTE AS (
    SELECT fil.title, cat.name, fil.release_year, fil.rental_rate
    FROM public.film fil
    INNER JOIN public.film_category fil_cat 
	ON fil.film_id = fil_cat.film_id
    INNER JOIN public.category cat 
	ON fil_cat.category_id = cat.category_id
    WHERE LOWER (cat.name) =  LOWER ('Animation') 
)
SELECT title, release_year, rental_rate
FROM Film_Category_CTE
WHERE release_year BETWEEN 2017 AND 2019
  AND rental_rate > 1
ORDER BY title;

/*Best Approach: Join - Simple, direct relationships; best performance and clarity;
Reason: The query is straightforward, with simple filters and direct relationships. Join offers optimal performance and clarity, while CTE and subquery add unnecessary complexity.*/


--Task 1.2:Calculate the revenue earned by each rental store after March 2017 (since April)(include columns: address and address2 – as one column, revenue)

--JOIN
SELECT
    	CONCAT_WS (', ', ad.address, ad.address2) AS store_address,
    	SUM(pay.amount) AS revenue
FROM public.payment pay
INNER JOIN public.rental ren 
	ON pay.rental_id = ren.rental_id
INNER JOIN public.inventory inv 
	ON ren.inventory_id = inv.inventory_id
INNER JOIN public.store st 
	ON inv.store_id = st.store_id
INNER JOIN public.address ad 
	ON st.address_id = ad.address_id
WHERE CAST(payment_date AS DATE) >= '2017-04-01'::date
GROUP BY store_address;


--Subquery
SELECT store_address,
       SUM(amount) AS revenue
FROM (
    SELECT pay.amount,
           CONCAT_WS (', ', ad.address, ad.address2) AS store_address,
           pay.payment_date
    FROM public.payment pay
    INNER JOIN public.rental ren 
	ON pay.rental_id = ren.rental_id
    INNER JOIN public.inventory inv 
	ON ren.inventory_id = inv.inventory_id
    INNER JOIN public.store st 
	ON inv.store_id = st.store_id
    INNER JOIN public.address ad 
	ON st.address_id = ad.address_id
) AS Store_Payments
WHERE CAST(payment_date AS DATE) >= '2017-04-01'::date
GROUP BY store_address;	


--CTE
WITH Store_Payments AS (
    SELECT pay.amount,
           CONCAT_WS (', ', ad.address, ad.address2) AS store_address,
		   pay.payment_date
    FROM public.payment pay
    INNER JOIN public.rental ren 
	ON pay.rental_id = ren.rental_id
    INNER JOIN public.inventory inv 
	ON ren.inventory_id = inv.inventory_id
    INNER JOIN public.store st 
	ON inv.store_id = st.store_id
    INNER JOIN public.address ad 
	ON st.address_id = ad.address_id
)
SELECT store_address,
       SUM(amount) AS revenue
FROM Store_Payments
WHERE CAST(payment_date AS DATE) >= '2017-04-01'::date
GROUP BY store_address;

/*Best Approach: Join - Straightforward aggregation; efficient and readable;
Reason: Aggregation and grouping are simple, and the relationships are direct. Join is efficient and readable. CTE or subquery would only be preferable if the logic became more complex*/


--Task 1.3:Show top-5 actors by number of movies (released after 2015) they took part in (columns: first_name, last_name, number_of_movies, sorted by number_of_movies in descending order)

--JOIN
SELECT act.first_name, 
	   act.last_name, 
	   count(fil_act.film_id) as number_of_movies 
FROM public.actor act
INNER JOIN public.film_actor fil_act
	ON act.actor_id = fil_act.actor_id
INNER JOIN public.film fil
	ON fil_act.film_id = fil.film_id
WHERE fil.release_year >= 2015
GROUP BY act.actor_id
ORDER BY number_of_movies DESC
LIMIT 5;


--Subquery
SELECT first_name, 
	   last_name, 
	   COUNT(film_id) AS number_of_movies
FROM (
    SELECT act.actor_id, 
		   act.first_name, 
		   act.last_name, 
		   fil_act.film_id
    FROM public.actor act
    INNER JOIN public.film_actor fil_act 
	ON act.actor_id = fil_act.actor_id
    INNER JOIN public.film fil 
	ON fil_act.film_id = fil.film_id
    WHERE fil.release_year >= 2015
) AS ActorMovies
GROUP BY actor_id, first_name, last_name
ORDER BY number_of_movies DESC
LIMIT 5;


--CTE
WITH Actor_Movies AS (
    SELECT act.actor_id, 
		   act.first_name, 
		   act.last_name, 
		   fil_act.film_id
    FROM public.actor act
    INNER JOIN public.film_actor fil_act 
	ON act.actor_id = fil_act.actor_id
    INNER JOIN public.film fil 
	ON fil_act.film_id = fil.film_id
    WHERE fil.release_year >= 2015
)
SELECT first_name, 
	   last_name, 
	   COUNT(film_id) AS number_of_movies
FROM Actor_Movies
GROUP BY actor_id, first_name, last_name
ORDER BY number_of_movies DESC
LIMIT 5;

/*Best Approach: Join - Direct counting; optimal for performance and simplicity;
Reason: Counting related records after filtering is direct and efficient with Join. CTE or subquery do not provide significant readability or maintainability benefits for this level of complexity*/


--Task 1.4:Show number of Drama, Travel, Documentary per year (include columns: release_year, number_of_drama_movies, number_of_travel_movies, number_of_documentary_movies), sorted by release year in descending order)

--JOIN 
SELECT fil.release_year,
       COUNT(CASE WHEN cat.name = 'Drama' THEN 1 END) AS number_of_drama_movies,
       COUNT(CASE WHEN cat.name = 'Travel' THEN 1 END) AS number_of_travel_movies,
       COUNT(CASE WHEN cat.name = 'Documentary' THEN 1 END) AS number_of_documentary_movies
FROM public.film fil
INNER JOIN public.film_category fil_cat
	ON fil.film_id = fil_cat.film_id
INNER JOIN public.category cat
	ON fil_cat.category_id = cat.category_id
WHERE cat.name IN ('Drama', 'Travel', 'Documentary')
GROUP BY fil.release_year
ORDER BY fil.release_year DESC;


--Subquery
SELECT release_year,
       COUNT(CASE WHEN name = 'Drama' THEN 1 END) AS number_of_drama_movies,
       COUNT(CASE WHEN name = 'Travel' THEN 1 END) AS number_of_travel_movies,
       COUNT(CASE WHEN name = 'Documentary' THEN 1 END) AS number_of_documentary_movies
FROM (
    SELECT fil.release_year, 
		   cat.name
    FROM public.film fil
    INNER JOIN public.film_category fil_cat 
	ON fil.film_id = fil_cat.film_id
    INNER JOIN public.category cat 
	ON fil_cat.category_id = cat.category_id
    WHERE cat.name IN ('Drama', 'Travel', 'Documentary')
) AS Film_Categories
GROUP BY release_year
ORDER BY release_year DESC;


--CTE
WITH FilmCategories AS (
    SELECT fil.release_year, 
		   cat.name
    FROM public.film fil
    INNER JOIN public.film_category fil_cat 
	ON fil.film_id = fil_cat.film_id
    INNER JOIN public.category cat 
	ON fil_cat.category_id = cat.category_id
    WHERE cat.name IN ('Drama', 'Travel', 'Documentary')
)
SELECT release_year,
       COUNT(CASE WHEN name = 'Drama' THEN 1 END) AS number_of_drama_movies,
       COUNT(CASE WHEN name = 'Travel' THEN 1 END) AS number_of_travel_movies,
       COUNT(CASE WHEN name = 'Documentary' THEN 1 END) AS number_of_documentary_movies
FROM FilmCategories
GROUP BY release_year
ORDER BY release_year DESC;

/*Best Approach: Join - Multiple conditional counts; clean and efficient;
Reason: Multiple conditional counts and grouping by year are handled cleanly with Join. CTE or subquery would only help if the query logic expanded or required reuse.*/


--Task 2.1:Show which three employees generated the most revenue in 2017

--JOIN
SELECT st.first_name,
  	   st.last_name,
  	   st.store_id,
  	   SUM(pay.amount) AS total_revenue
FROM public.payment AS pay
INNER JOIN public.staff AS st
	ON pay.staff_id = st.staff_id
WHERE EXTRACT(YEAR FROM pay.payment_date) = 2017
GROUP BY st.staff_id
ORDER BY total_revenue DESC
LIMIT 3;


--Subquery
SELECT first_name,
       last_name,
       store_id,
       SUM(amount) AS total_revenue
FROM (
    SELECT st.staff_id, 
		   st.first_name, 
		   st.last_name, 
		   st.store_id, 
		   pay.amount, 
		   pay.payment_date
    FROM public.payment AS pay
    INNER JOIN public.staff AS st 
	ON pay.staff_id = st.staff_id
) AS Staff_Payments
WHERE EXTRACT(YEAR FROM payment_date) = 2017
GROUP BY staff_id, first_name, last_name, store_id
ORDER BY total_revenue DESC
LIMIT 3;


--CTE
WITH Staff_Payments AS (
    SELECT st.staff_id, 
		   st.first_name, 
		   st.last_name, 
		   st.store_id, 
		   pay.amount, 
		   pay.payment_date
    FROM public.payment AS pay
    INNER JOIN public.staff AS st 
	ON pay.staff_id = st.staff_id
)
SELECT first_name,
       last_name,
       store_id,
       SUM(amount) AS total_revenue
FROM Staff_Payments
WHERE EXTRACT(YEAR FROM payment_date) = 2017
GROUP BY staff_id, first_name, last_name, store_id
ORDER BY total_revenue DESC
LIMIT 3;

/*Best Approach: Join - Simple aggregation/filtering; best for performance;
Reason: Simple aggregation and filtering by year, with direct relationships. Join is the most efficient and readable; CTE/subquery are not necessary unless logic grows.*/


--Task 2.2:Show which 5 movies were rented more than others (number of rentals), and what's the expected age of the audience for these movies? To determine expected age please use 'Motion Picture Association film rating system'

--JOIN
SELECT fil.title, 
  CASE fil.rating
      WHEN 'G' THEN '0+'
      WHEN 'PG' THEN '8+'
      WHEN 'PG-13' THEN '13+'
      WHEN 'R' THEN '17+'
      WHEN 'NC-17' THEN '18+'
      ELSE 'N/A'
  END AS age_group,
	  COUNT(ren.rental_id) as rentals from public.rental ren
INNER JOIN public.inventory inv
	ON ren.inventory_id = inv.inventory_id
INNER JOIN film fil
	ON inv.film_id = fil.film_id
GROUP BY fil.film_id
ORDER BY rentals DESC
LIMIT 5;


--Subquery
SELECT title,
    CASE rating
        WHEN 'G' THEN '0+'
        WHEN 'PG' THEN '8+'
        WHEN 'PG-13' THEN '13+'
        WHEN 'R' THEN '17+'
        WHEN 'NC-17' THEN '18+'
        ELSE 'N/A'
    END AS age_group,
    COUNT(rental_id) AS rentals
FROM (
    SELECT fil.film_id, 
		   fil.title, 
		   fil.rating, 
		   ren.rental_id
    FROM public.rental ren
    INNER JOIN public.inventory inv 
	ON ren.inventory_id = inv.inventory_id
    INNER JOIN film fil 
	ON inv.film_id = fil.film_id
) AS Film_Rentals
GROUP BY film_id, title, rating
ORDER BY rentals DESC
LIMIT 5;


--CTE
WITH Film_Rentals AS (
    SELECT fil.film_id, 
		   fil.title, 
		   fil.rating, 
		   ren.rental_id
    FROM public.rental ren
    INNER JOIN public.inventory inv 
	ON ren.inventory_id = inv.inventory_id
    INNER JOIN film fil 
	ON inv.film_id = fil.film_id
)
SELECT title,
    CASE rating
        WHEN 'G' THEN '0+'
        WHEN 'PG' THEN '8+'
        WHEN 'PG-13' THEN '13+'
        WHEN 'R' THEN '17+'
        WHEN 'NC-17' THEN '18+'
        ELSE 'N/A'
    END AS age_group,
    COUNT(rental_id) AS rentals
FROM Film_Rentals
GROUP BY film_id, title, rating
ORDER BY rentals DESC
LIMIT 5;

/*Best Approach: Join - Aggregation and CASE; join is optimal;
Reason: The query uses aggregation and a simple CASE statement. Join is optimal for performance and clarity. CTE/subquery would only be useful for more complex transformations.*/


--Task 3.1:Show gap between the latest release_year and current year per each actor

--JOIN
SELECT
    act.first_name,
    act.last_name,
    COUNT(fil.film_id) AS film_count, 
    MAX(fil.release_year) AS latest_release_year,
    (EXTRACT (YEAR FROM CURRENT_DATE) - MAX(fil.release_year)) AS years_of_inactivity
FROM
    public.actor act
JOIN
    public.film_actor fil_act ON act.actor_id = fil_act.actor_id
JOIN
    public.film fil ON fil_act.film_id = fil.film_id
GROUP BY
    act.actor_id, act.first_name, act.last_name
HAVING COUNT(fil.film_id) >= 7
ORDER BY
    years_of_inactivity DESC;


--Subquery
SELECT first_name,
       last_name,
	   film_count,	   
       latest_release_year,
       EXTRACT (YEAR FROM CURRENT_DATE) - latest_release_year AS years_of_inactivity
FROM (
    SELECT act.actor_id, 
		   act.first_name, 
		   act.last_name,
		   COUNT(fil.film_id) AS film_count,
		   MAX(release_year) AS latest_release_year
		   FROM public.actor act
    JOIN public.film_actor fil_act 
	ON act.actor_id = fil_act.actor_id
    JOIN public.film fil 
	ON fil_act.film_id = fil.film_id
	GROUP BY act.actor_id, act.first_name, act.last_name
HAVING COUNT(fil.film_id) >= 7 
) AS Actor_Films
ORDER BY years_of_inactivity DESC;


--CTE
WITH Actor_Films AS (
    SELECT act.actor_id, 
		   act.first_name, 
		   act.last_name, 
		   COUNT(fil.film_id) AS film_count,
		   MAX(release_year) AS latest_release_year
    FROM public.actor act
    JOIN public.film_actor fil_act 
	ON act.actor_id = fil_act.actor_id
    JOIN public.film fil 
	ON fil_act.film_id = fil.film_id
	GROUP BY act.actor_id, act.first_name, act.last_name
	HAVING COUNT(fil.film_id) >= 7
)
SELECT first_name,
       last_name,
	   film_count,
       latest_release_year,
       EXTRACT (YEAR FROM CURRENT_DATE) - latest_release_year AS years_of_inactivity
FROM Actor_Films
ORDER BY years_of_inactivity DESC;

/*Best Approach: Join - Aggregation and calculation; join is efficient;
Reason: Aggregation (MAX) and calculation are straightforward. Join is efficient and readable. CTE/subquery would be justified only if the query required more modularity or intermediate steps.*/


--Task 3.2:Show gaps between sequential films per each actor

--JOIN
SELECT act.first_name,
       act.last_name,
       MAX(fil2.release_year - fil1.release_year) AS longest_gap_years
FROM public.actor act
INNER JOIN (SELECT actor_id FROM public.film_actor
    		GROUP BY actor_id
    		HAVING COUNT(film_id) >= 7) 
AS Notable_Actors_List ON act.actor_id = Notable_Actors_List.actor_id
INNER JOIN public.film_actor fil_act1 
	ON act.actor_id = fil_act1.actor_id
INNER JOIN public.film fil1 
	ON fil_act1.film_id = fil1.film_id
LEFT JOIN public.film fil2 
	ON fil2.film_id = (SELECT fil_next.film_id FROM public.film_actor fil_act_next
        JOIN public.film fil_next ON fil_act_next.film_id = fil_next.film_id
        WHERE fil_act_next.actor_id = act.actor_id
        AND fil_next.release_year > fil1.release_year
        ORDER BY fil_next.release_year
        LIMIT 1)
GROUP BY act.actor_id, act.first_name, act.last_name
ORDER BY longest_gap_years DESC;


--Subquery
SELECT act.first_name,
       act.last_name,
       MAX(fil2.release_year - fil1.release_year) AS longest_gap_years
FROM public.actor act
INNER JOIN public.film_actor fil_act1 
	ON act.actor_id = fil_act1.actor_id
INNER JOIN public.film fil1 
	ON fil_act1.film_id = fil1.film_id
LEFT JOIN public.film fil2 
	ON fil2.film_id = (SELECT fil_next.film_id FROM public.film_actor fil_act_next
    JOIN public.film fil_next 
		ON fil_act_next.film_id = fil_next.film_id
    WHERE fil_act_next.actor_id = act.actor_id
    AND fil_next.release_year > fil1.release_year
    ORDER BY fil_next.release_year
    LIMIT 1)
WHERE EXISTS (SELECT 1 FROM public.film_actor fa_count
    		  WHERE fa_count.actor_id = act.actor_id
   		  GROUP BY fa_count.actor_id
    		  HAVING COUNT(fa_count.film_id) >= 7)
GROUP BY act.actor_id, act.first_name, act.last_name
ORDER BY longest_gap_years DESC;



--CTE
WITH Notable_Actors AS (SELECT act.actor_id FROM public.actor act
    			JOIN public.film_actor fil_act 
			   ON act.actor_id = fil_act.actor_id
   			GROUP BY act.actor_id
   			HAVING COUNT(fil_act.film_id) >= 7),
Actor_Gaps AS (SELECT na.actor_id, fil1.release_year AS current_film_year,
       		     (SELECT MIN(fil_next.release_year)
           	      FROM public.film_actor fil_act_next
           	      JOIN public.film fil_next 
			   ON fil_act_next.film_id = fil_next.film_id
           	      WHERE fil_act_next.actor_id = na.actor_id
              	      AND fil_next.release_year > fil1.release_year) AS next_film_year
   		      FROM Notable_Actors na
                      JOIN public.film_actor fil_act1 
			   ON na.actor_id = fil_act1.actor_id
   		      JOIN public.film fil1 
			   ON fil_act1.film_id = fil1.film_id)
SELECT act.first_name,
       act.last_name,
       MAX(ag.next_film_year - ag.current_film_year) AS longest_gap_years
FROM Actor_Gaps ag
JOIN public.actor act 
ON ag.actor_id = act.actor_id
GROUP BY act.actor_id, act.first_name, act.last_name
ORDER BY longest_gap_years DESC;

/*Best Approach: CTE
Reason: The query involves a correlated subquery to find the next film year for each actor, which increases complexity. Using a CTE improves readability and maintainability, making it easier to debug and extend. Join is less readable due to the nested subquery, and subquery approach is similar but less modular than CTE.*/












































