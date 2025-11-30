
--Task 2.1: Create a new user with the username "rentaluser" and the password "rentalpassword". Give the user the ability to connect to the database but no other permissions.

--Create a new user with the username "rentaluser", set a password, and give them the ability to log in to the system (LOGIN). 
CREATE USER rentaluser WITH PASSWORD 'rentalpassword' LOGIN;

--Task 2.2: Grant "rentaluser" SELECT permission for the "customer" table. Сheck to make sure this permission works correctly—write a SQL query to select all customers.

--Grant the user "rentaluser" permission to read data from the "customer" table.
GRANT SELECT ON TABLE public.customer TO rentaluser;

--Permission check:
SELECT * FROM public.customer;

--Task 2.3: Create a new user group called "rental" and add "rentaluser" to the group. 

--Create a new role that will be used as a group and include the user rentaluser in it.
CREATE ROLE rental;
GRANT rental TO rentaluser;

--Task 2.4: Grant the "rental" group INSERT and UPDATE permissions for the "rental" table. Insert a new row and update one existing row in the "rental" table under that role. 

--Grant the "rental" group permission to INSERT and UPDATE rows in the "rental" table.
GRANT INSERT, UPDATE ON TABLE public.rental TO rental;

--Insert a new row in the "rental" table. 
--To avoid hard coding we would also need to grant the role permission to SELECT  “inventory”, "rental", "staff" and “film” tables and grant USAGE on the sequence required for automatic ID generation. The "rental" group already has permission to select the "customer" table.
GRANT USAGE ON SEQUENCE public.rental_rental_id_seq TO rental;
GRANT SELECT ON TABLE public.inventory, public.film, public.rental, public.staff TO rental;

INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT CURRENT_TIMESTAMP, 
       inv.inventory_id, 
       (SELECT customer_id FROM public.customer 
	WHERE UPPER (first_name) = UPPER ('ALIAKSEI') 
	AND UPPER (last_name) = UPPER ('PAPOU')),
       CURRENT_TIMESTAMP + (fil.rental_duration * INTERVAL '1 week'),
       (SELECT staff_id FROM staff ORDER BY RANDOM() LIMIT 1)
FROM public.inventory inv
JOIN public.film fil 
ON inv.film_id = fil.film_id
WHERE UPPER (fil.title) = UPPER ('F1');

--Update one existing row in the "rental" table.
UPDATE public.rental
SET return_date = CURRENT_TIMESTAMP
WHERE customer_id = (SELECT customer_id FROM public.customer 
		     WHERE UPPER (first_name) = UPPER ('ALIAKSEI') 
		     AND UPPER (last_name) = UPPER ('PAPOU'))
AND inventory_id = (SELECT inventory_id FROM inventory inv
		    INNER JOIN film fil ON inv.film_id = fil.film_id 
		    WHERE UPPER (fil.title) = UPPER ('F1'));
		    
		    
--Task 2.5: Revoke the "rental" group's INSERT permission for the "rental" table. Try to insert new rows into the "rental" table make sure this action is denied.

REVOKE INSERT ON TABLE public.rental FROM rental;

--After checking we get an error if we try to add new rows to the table. (ERROR: permission denied for table rental). 


--Task 2.6: Create a personalized role for any customer already existing in the dvd_rental database. The name of the role name must be client_{first_name}_{last_name} (omit curly brackets). The customer's payment and rental history must not be empty. 

--Choosing a customer with a payment and rental history
SELECT first_name, 
       last_name 
FROM public.customer cus
INNER JOIN public.payment pay ON cus.customer_id = pay.customer_id
INNER JOIN public.rental ren ON pay.rental_id = ren.rental_id
WHERE pay.amount IS NOT NULL 
AND ren.rental_date IS NOT NULL
ORDER BY ren.rental_date DESC
LIMIT 1;

--Create a personalized role
CREATE ROLE client_aliaksei_papou LOGIN PASSWORD 'custpass';


--Task 3: Configure that role so that the customer can only access their own data in the "rental" and "payment" tables. Write a query to make sure this user sees only their own data.

--Grant the user "client_aliaksei_papou" permission to select data from the "payment", "rental" and "customer" tables.
GRANT SELECT ON TABLE public.payment, public.rental, public.customer TO client_aliaksei_papou;

--RLS is disabled by default. Enable it for the payment and rental tables.
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;
ALTER TABLE rental ENABLE ROW LEVEL SECURITY;

CREATE POLICY client_aliaksei_papou ON rental
FOR SELECT
TO client_aliaksei_papou
USING (customer_id = (SELECT customer_id 
    		      FROM public.customer 
   		      WHERE LOWER (first_name) = LOWER ('Aliaksei')
  		      AND LOWER (last_name) = LOWER ('Papou')));
  		      
CREATE POLICY client_aliaksei_papou ON payment
FOR SELECT
TO client_aliaksei_papou
USING (customer_id = (SELECT customer_id 
    		      FROM public.customer 
   		      WHERE LOWER (first_name) = LOWER ('Aliaksei')
  		      AND LOWER (last_name) = LOWER ('Papou')));
          	      
          	      
--After checking, records related only to client_aliaksei_papou were returned.









