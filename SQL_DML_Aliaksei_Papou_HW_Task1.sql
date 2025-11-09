--Task 1: Add three favorite films with specified rates and rental durations.
--Using WHERE NOT EXISTS to avoid duplicates, and RETURNING to get new film_id

BEGIN;
INSERT INTO public.film (title, description, release_year, language_id, 
rental_duration, rental_rate, length, replacement_cost, last_update)
SELECT * FROM (
SELECT 'HACHIKO: A DOG’S TALE' AS title,
	   'Film told the true story of the Akita dog named Hachikō who lived in Japan' AS description, 
	   2009 AS release_year, 
	   1 AS language_id, 
	   1 AS rental_duration, 
	   4.99 AS rental_rate, 
	   136 AS length, 
	   19.99 AS replacement_cost, 
	   CURRENT_DATE AS last_update
UNION ALL
SELECT 'WHAT WOMEN WANT' AS title,
	   'He has the power to hear everything women are thinking. Finally... a man is listening' AS description, 
	   2000 AS release_year, 
	   1 AS language_id, 
	   2 AS rental_duration, 
	   9.99 AS rental_rate, 
	   154 AS length, 
	   19.99 AS replacement_cost, 
	   CURRENT_DATE AS last_update
UNION ALL
SELECT 'F1' AS title,
	   'Racing driver Sonny Hayes, who returns after a 30-year absence to save his former teammate underdog team, APXGP, from collapse' AS description, 
	   2025 AS release_year, 
	   1 AS language_id, 
	   3 AS rental_duration, 
	   19.99 AS rental_rate, 
	   148 AS length, 
	   19.99 AS replacement_cost, 
	   CURRENT_DATE AS last_update)
	   AS new_film
WHERE NOT EXISTS (
	SELECT 1 FROM public.film AS pf 
	WHERE pf.title = new_film.title)
RETURNING film_id, title;
COMMIT;


--Task 1.2: Add the real actors who play leading roles in your favorite movies.
--Using WHERE NOT EXISTS to avoid duplicates, and RETURNING to get new actor_id

BEGIN;
INSERT INTO public.actor (first_name, last_name, last_update)
SELECT * FROM 
	(SELECT 'RICHARD' AS first_name, 'GERE' AS last_name, CURRENT_DATE AS last_update
	 UNION ALL
	 SELECT 'JOAN', 'ALLEN', CURRENT_DATE
	 UNION ALL
	 SELECT 'MEL', 'GIBSON', CURRENT_DATE
	 UNION ALL
	 SELECT 'HELEN', 'HUNT', CURRENT_DATE
	 UNION ALL
	 SELECT 'BRAD', 'PITT', CURRENT_DATE
	 UNION ALL
	 SELECT 'DAMSON', 'IDRIS', CURRENT_DATE
	 UNION ALL
	 SELECT 'TOBIAS', 'MENZIES', CURRENT_DATE)
	 AS new_actor
WHERE NOT EXISTS (
	SELECT * FROM public.actor AS pa 
	WHERE pa.first_name = new_actor.first_name 
	and pa.last_name = new_actor.last_name)
RETURNING actor_id, first_name, last_name;
COMMIT;


--Task 1.3: Add relationships between films and actors. 
--Using ON CONFLICT DO NOTHING to avoid duplicates, and dynamic IDs from previous inserts

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id, last_update)
SELECT
    actor_id,
    film_id,
    CURRENT_DATE
FROM public.actor, public.film
WHERE
    (actor.first_name = 'RICHARD' AND actor.last_name = 'GERE' AND film.title = 'HACHIKO: A DOG’S TALE') OR
    (actor.first_name = 'JOAN' AND actor.last_name = 'ALLEN' AND film.title = 'HACHIKO: A DOG’S TALE') OR
    (actor.first_name = 'MEL' AND actor.last_name = 'GIBSON' AND film.title = 'WHAT WOMEN WANT') OR
    (actor.first_name = 'HELEN' AND actor.last_name = 'HUNT' AND film.title = 'WHAT WOMEN WANT') OR
    (actor.first_name = 'BRAD' AND actor.last_name = 'PITT' AND film.title = 'F1') OR
    (actor.first_name = 'DAMSON' AND actor.last_name = 'IDRIS' AND film.title = 'F1') OR
    (actor.first_name = 'TOBIAS' AND actor.last_name = 'MENZIES' AND film.title = 'F1')
ON CONFLICT (actor_id, film_id) DO NOTHING
RETURNING *;
COMMIT;


--Task 1.4: Add favorite movies to any store's inventory
--Using WHERE NOT EXISTS to avoid duplicates, and RETURNING to get new inventory_id

BEGIN;
INSERT INTO public.inventory (film_id, store_id, last_update)
SELECT film.film_id, 1, current_date
FROM public.film
WHERE film.title IN ('HACHIKO: A DOG’S TALE', 'WHAT WOMEN WANT', 'F1')
AND NOT EXISTS (
    SELECT 1 FROM public.inventory inv
    WHERE inv.film_id = film.film_id AND inv.store_id = 1
)
RETURNING inventory_id, film_id, store_id;
COMMIT;


--Task 1.5: Alter any existing customer in the database with at least 43 rental and 43 payment records. Change their personal data. Use existing address from the "address" table.

BEGIN;
WITH customer_change AS (SELECT cus.customer_id
        FROM public.customer cus
        INNER JOIN public.rental ren ON cus.customer_id = ren.customer_id
        INNER JOIN public.payment pay ON cus.customer_id = pay.customer_id
        GROUP BY cus.customer_id
        HAVING COUNT(ren.rental_id) >= 43 AND COUNT(pay.payment_id) >= 43
        LIMIT 1)
UPDATE public.customer
SET
    first_name = 'ALIAKSEI',
    last_name = 'PAPOU',
    address_id = (SELECT address_id FROM public.address 
    		  WHERE address = '270 Amroha Parkway'), 
    email = 'Aliaksei.Papou1@gmail.com',
    last_update = CURRENT_DATE
WHERE
    customer_id = (SELECT * FROM customer_change)
RETURNING customer_id, first_name, last_name, email;
COMMIT;


--Task 1.6: Remove any records related to you (as a customer) from tables except 'Customer' and 'Inventory'. Using dynamic ID and RETURNING for traceability.

BEGIN;
DELETE FROM public.payment 
WHERE customer_id = (SELECT customer_id FROM public.customer 
		     WHERE first_name = 'ALIAKSEI' 
		     AND last_name = 'PAPOU');
--delete from rental table
DELETE FROM public.rental
WHERE customer_id = (SELECT customer_id FROM public.customer 
		     WHERE first_name = 'ALIAKSEI' 
		     AND last_name = 'PAPOU')
RETURNING *;
COMMIT;


--Task 1.7: Rent favorite movies from the store they are in and pay for them.
--Using dynamic ID and RETURNING for traceability.

BEGIN;
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT CURRENT_TIMESTAMP, 
       inv.inventory_id, 
       (SELECT customer_id FROM public.customer 
	    	WHERE first_name = 'ALIAKSEI' 
	    	AND last_name = 'PAPOU'),
       CURRENT_DATE + (fil.rental_duration * INTERVAL '1 week'),
       1, 
       CURRENT_TIMESTAMP
FROM public.inventory inv
JOIN public.film fil 
ON inv.film_id = fil.film_id
WHERE fil.title IN ('HACHIKO: A DOG’S TALE', 'WHAT WOMEN WANT', 'F1') 
AND inv.store_id = 1
RETURNING *;
COMMIT;

--pay for them 
BEGIN;
INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT (SELECT customer_id FROM public.customer 
	    WHERE first_name = 'ALIAKSEI' 
	    AND last_name = 'PAPOU'), 
	1, 
	ren.rental_id, 
	fil.rental_rate, 
	'2017-02-01 00:00:00'
FROM public.rental ren
INNER JOIN public.inventory inv 
ON ren.inventory_id = inv.inventory_id
INNER JOIN public.film fil 
ON inv.film_id = fil.film_id
WHERE ren.customer_id = (SELECT customer_id FROM public.customer 
			 WHERE first_name = 'ALIAKSEI' 
			 AND last_name = 'PAPOU')
AND NOT EXISTS (SELECT 1 FROM public.payment pay 
		WHERE pay.rental_id = ren.rental_id)
RETURNING *;
COMMIT;

        
/*Summary: 
Using WHERE NOT EXISTS and ON CONFLICT DO NOTHING to avoid duplicates and make the script rerunnable; 
Using SELECT and dynamic ID's to avoid hard coding;
Using RETURNING for traceability; */





























