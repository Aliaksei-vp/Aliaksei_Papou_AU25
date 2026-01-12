--Create database 
CREATE DATABASE household_appliances_store_db;

--Create schema
CREATE SCHEMA IF NOT EXISTS store_schema;

--Create tables
--Create parent tables before child tables to avoid foreign key errors
CREATE TABLE IF NOT EXISTS store_schema.category (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100),
    description TEXT);
    
CREATE TABLE IF NOT EXISTS store_schema.district (
    district_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL);
    
CREATE TABLE IF NOT EXISTS store_schema.address (
    address_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    street VARCHAR(50) NOT NULL,
    house  VARCHAR(50) NOT NULL,
    apartment VARCHAR(50),
    district_id INT NOT NULL,
    FOREIGN KEY (district_id) REFERENCES store_schema.district(district_id));
    
CREATE TABLE IF NOT EXISTS store_schema.position (
    position_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(100) NOT NULL);
    
CREATE TABLE IF NOT EXISTS store_schema.supplier (
    supplier_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address_id INT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES store_schema.address(address_id));
    
CREATE TABLE IF NOT EXISTS store_schema.employee (
    employee_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    position_id INT NOT NULL,
    address_id INT NOT NULL,
    FOREIGN KEY (position_id) REFERENCES store_schema.position(position_id),
    FOREIGN KEY (address_id) REFERENCES store_schema.address(address_id));
    
CREATE TABLE IF NOT EXISTS store_schema.customer (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    address_id INT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES store_schema.address(address_id)); 

CREATE TABLE IF NOT EXISTS store_schema.product (
    product_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    model VARCHAR(100),
    price DECIMAL NOT NULL,
    stock_quantity INT NOT NULL,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES store_schema.category(category_id),
    FOREIGN KEY (supplier_id) REFERENCES store_schema.supplier(supplier_id));
    
CREATE TABLE IF NOT EXISTS store_schema.order (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES store_schema.customer(customer_id),
    FOREIGN KEY (employee_id) REFERENCES store_schema.employee(employee_id));
    
CREATE TABLE IF NOT EXISTS store_schema.order_detail (
    order_detail_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL NOT NULL,
    FOREIGN KEY (order_id) REFERENCES store_schema.order(order_id),
    FOREIGN KEY (product_id) REFERENCES store_schema.product(product_id),
    UNIQUE (order_id, product_id));
    
CREATE TABLE IF NOT EXISTS store_schema.payment (
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_amount DECIMAL NOT NULL CHECK (payment_amount > 0),
    FOREIGN KEY (order_id) REFERENCES store_schema.order(order_id));


--Apply five check constraints across the tables to restrict certain values
--Using IF EXISTS to make the script rerunnable and without errors.

--Add CHECK constraints to columns order_date(after 2024-01-01) table order
BEGIN;
ALTER TABLE store_schema.order DROP CONSTRAINT IF EXISTS chk_start_date;
ALTER TABLE store_schema.order
ADD CONSTRAINT chk_start_date CHECK (order_date > '2024-01-01'::DATE);
COMMIT;


--Add UNIQUE constraint to column email table customer
BEGIN;
ALTER TABLE store_schema.customer DROP CONSTRAINT IF EXISTS unique_email_cus;
ALTER TABLE store_schema.customer
ADD CONSTRAINT unique_email_cus UNIQUE (email);
COMMIT;

--Add NOT NULL constraint to column name table category
BEGIN;
ALTER TABLE store_schema.category
    ALTER COLUMN name SET NOT NULL;
COMMIT;

--Add CHECK constraint to column availability(specific value) table order
BEGIN;
ALTER TABLE store_schema.order DROP CONSTRAINT IF EXISTS chk_status;
ALTER TABLE store_schema.order
ADD CONSTRAINT chk_status CHECK (status IN
('Pending', 'Shipped', 'Delivered', 'Cancelled'));
COMMIT;

--Add CHECK constraints to column unit_price (>0) table order_detail
BEGIN;
ALTER TABLE store_schema.order_detail DROP CONSTRAINT IF EXISTS chk_unit_price;
ALTER TABLE store_schema.order_detail
ADD CONSTRAINT chk_unit_price CHECK (unit_price > 0);
COMMIT;

--Add CHECK constraints to columns stock_quantity (>=0) and price (>0) table product  
BEGIN;
ALTER TABLE store_schema.product DROP CONSTRAINT IF EXISTS chk_stock_quantity;
ALTER TABLE store_schema.product
ADD CONSTRAINT chk_stock_quantity CHECK (stock_quantity > 0);

ALTER TABLE store_schema.product DROP CONSTRAINT IF EXISTS chk_price;
ALTER TABLE store_schema.product
ADD CONSTRAINT chk_price CHECK (price > 0);
COMMIT;

/*The "product" table contains a "stock_quantity" column that needs to be updated when a sale occurs (quantity decreases). To implement this automatically, create a function and trigger that automatically decreases stock_quantity immediately after inserting rows into order_detail */

CREATE OR REPLACE FUNCTION decrease_stock_quantity_on_order()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE store_schema.product
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_decrease_stock_quantity
AFTER INSERT ON store_schema.order_detail
FOR EACH ROW
EXECUTE FUNCTION decrease_stock_quantity_on_order();


/*Add data into each table. Using WHERE NOT EXISTS and ON CONFLICT DO NOTHING to avoid duplicates and make the script rerunnable; 
Using SELECT and dynamic ID's to avoid hard coding;
Using RETURNING for traceability */

BEGIN;
INSERT INTO store_schema.category (name, description)
SELECT * FROM (SELECT 
		'Refrigerators' AS name,
		'Household cooling appliances' AS description
	   UNION ALL
	       SELECT 
	        'Televisions' AS name,
	        'Display devices' AS description
	   UNION ALL
	       SELECT 
		'Washing Machines' AS name,
		'Automatic laundry machines' AS description
	   UNION ALL
	       SELECT 
		'Vacuum Cleaners' AS name,
		'Devices for dust removal' AS description
	   UNION ALL
	       SELECT 
		'Microwave Ovens' AS name,
		'Devices for heating food' AS description
	   UNION ALL	       		
	       SELECT 
		'Electric Kettles' AS name,
		'Devices for boiling water' AS description
		) AS n_cat
WHERE NOT EXISTS (SELECT 1 FROM store_schema.category cat
		  WHERE LOWER (cat.name) = LOWER (n_cat.name))
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO store_schema.district (name)
SELECT * FROM (SELECT 
		'west' AS name
	   UNION ALL
	       SELECT 
	        'east' AS name
	   UNION ALL
	       SELECT 
		'central' AS name
	   UNION ALL
	       SELECT 
		'north' AS name
	   UNION ALL
	       SELECT 
		'south' AS name
	   UNION ALL	       		
	       SELECT 
		'old' AS name		
		) AS n_dis
WHERE NOT EXISTS (SELECT 1 FROM store_schema.category dis
		  WHERE LOWER (dis.name) = LOWER (n_dis.name))
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO store_schema.position (title)
SELECT * FROM (SELECT 
		'sales manager' AS title
	  UNION ALL
	       SELECT 
	        'CEO' AS title
	  UNION ALL
	       SELECT 
		'accountant' AS title
	  UNION ALL
	       SELECT 
		'lawyer' AS title
	  UNION ALL
	       SELECT 
		'marketer' AS title
	  UNION ALL	       		
	       SELECT 
		'developer' AS title		
		) AS n_pos
WHERE NOT EXISTS (SELECT 1 FROM store_schema.position pos
		  WHERE LOWER (pos.title) = LOWER (n_pos.title))
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO store_schema.address (street, house, apartment, district_id)
SELECT * FROM (SELECT 
		'Main' AS street,
		'15' AS house,
		'2' AS apartment,
		(SELECT district_id FROM store_schema.district 
		 WHERE LOWER (district.name) = LOWER ('central')) AS district_id
	UNION ALL
		SELECT 
		'Levskogo' AS street,
		'6' AS house,
		'21' AS apartment,
		(SELECT district_id FROM store_schema.district 
		 WHERE LOWER (district.name) = LOWER ('south')) AS district_id
	UNION ALL
		SELECT 
		'Serdika' AS street,
		'45b' AS house,
		'78' AS apartment,
		(SELECT district_id FROM store_schema.district 
		 WHERE LOWER (district.name) = LOWER ('north')) AS district_id
	UNION ALL
		SELECT 
		'Pushkina' AS street,
		'4' AS house,
		'18' AS apartment,
		(SELECT district_id FROM store_schema.district 
		 WHERE LOWER (district.name) = LOWER ('west')) AS district_id
	UNION ALL
		SELECT 
		'Chernomorka' AS street,
		'4' AS house,
		'9' AS apartment,
		(SELECT district_id FROM store_schema.district 
		 WHERE LOWER (district.name) = LOWER ('east')) AS district_id
	UNION ALL
		SELECT 
		'green' AS street,
		'8' AS house,
		'17' AS apartment,
		(SELECT district_id FROM store_schema.district 
		 WHERE LOWER (district.name) = LOWER ('old')) AS district_id
		 ) AS n_adr
WHERE NOT EXISTS (SELECT 1 FROM store_schema.address adr 
		  WHERE LOWER (adr.street) = LOWER (n_adr.street) AND LOWER (adr.house) = LOWER (n_adr.house) AND LOWER (adr.apartment) = LOWER (n_adr.apartment))
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO store_schema.supplier (name, email, phone, address_id)
SELECT * FROM (SELECT 
		'Janet' AS name,
		'Jane1@gmail.com' AS email,
		'375442992358' AS phone,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Pushkina') 
		AND LOWER (house) = LOWER ('4')) AS address_id
	UNION ALL
		SELECT
		'nova' AS name,
		'nova@gmail.com' AS email,
		'375294722358' AS phone,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Chernomorka') 
		AND LOWER (house) = LOWER ('4')) AS address_id
	UNION ALL
		SELECT
		'uniCo' AS name,
		'uniCo@gmail.com' AS email,
		'375444771957' AS phone,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Levskogo') 
		AND LOWER (house) = LOWER ('6')
		AND LOWER (apartment) = LOWER ('21')) AS address_id
	UNION ALL
		SELECT
		'west tech' AS name,
		'techW@gmail.com' AS email,
		'375444777757' AS phone,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('green') 
		AND LOWER (house) = LOWER ('8')
		AND LOWER (apartment) = LOWER ('17')) AS address_id
	UNION ALL
		SELECT
		'first element' AS name,
		'element@gmail.com' AS email,
		'375334117757' AS phone,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('main') 
		AND LOWER (house) = LOWER ('15')
		AND LOWER (apartment) = LOWER ('2')) AS address_id
		) AS n_sup
WHERE NOT EXISTS (SELECT 1 FROM store_schema.supplier sup 
		  WHERE LOWER (sup.name) = LOWER (n_sup.name))
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO store_schema.employee (first_name, last_name, phone, email, position_id, address_id)
SELECT * FROM (SELECT 
		'Tom' AS first_name,
		'Dill' AS last_name,
		'375442992358' AS phone,
		'Tomhj@gmail.com' AS email,
		(SELECT position_id FROM store_schema.position 
		WHERE LOWER (title) = LOWER ('sales manager')) AS position_id,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Chernomorka') 
		AND LOWER (house) = LOWER ('4')) AS address_id
	UNION ALL
		SELECT 
		'Olga' AS first_name,
		'Nikolova' AS last_name,
		'375294722358' AS phone,
		'Olga9@gmail.com' AS email,
		(SELECT position_id FROM store_schema.position 
		WHERE LOWER (title) = LOWER ('sales manager')) AS position_id,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Serdika') 
		AND LOWER (house) = LOWER ('45b')) AS address_id
	UNION ALL
		SELECT 
		'Anna' AS first_name,
		'Talanova' AS last_name,
		'375442992561' AS phone,
		'Anna99@gmail.com' AS email,
		(SELECT position_id FROM store_schema.position 
		WHERE LOWER (title) = LOWER ('lawyer')) AS position_id,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Pushkina') 
		AND LOWER (house) = LOWER ('4')) AS address_id
	UNION ALL
		SELECT 
		'Bill' AS first_name,
		'Schmid' AS last_name,
		'375297492582' AS phone,
		'Bill1@gmail.com' AS email,
		(SELECT position_id FROM store_schema.position 
		WHERE LOWER (title) = LOWER ('marketer')) AS position_id,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Levskogo') 
		AND LOWER (house) = LOWER ('6')) AS address_id
	UNION ALL
		SELECT 
		'Rokky' AS first_name,
		'Bon' AS last_name,
		'375297470280' AS phone,
		'Rokky8@gmail.com' AS email,
		(SELECT position_id FROM store_schema.position 
		WHERE LOWER (title) = LOWER ('developer')) AS position_id,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Main') 
		AND LOWER (house) = LOWER ('15')) AS address_id
	UNION ALL
		SELECT 
		'Olga' AS first_name,
		'Ivanova' AS last_name,
		'375297470999' AS phone,
		'OlgaIvanova@gmail.com' AS email,
		(SELECT position_id FROM store_schema.position 
		WHERE LOWER (title) = LOWER ('accountant')) AS position_id,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('green') 
		AND LOWER (house) = LOWER ('8')) AS address_id
		) AS n_emp				
WHERE NOT EXISTS (SELECT 1 FROM store_schema.employee emp 
		WHERE LOWER (emp.first_name) = LOWER (n_emp.first_name) AND LOWER (emp.last_name) = LOWER (n_emp.last_name))
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO store_schema.customer (first_name, last_name, phone, email, address_id)
SELECT * FROM (SELECT 
		'Fill' AS first_name,
		'Tanil' AS last_name,
		'375441496358' AS phone,
		'FillT@gmail.com' AS email,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Chernomorka') 
		AND LOWER (house) = LOWER ('4')) AS address_id
	UNION ALL
		SELECT 
		'Nina' AS first_name,
		'Nikolova' AS last_name,
		'375294724879' AS phone,
		'Nina78@gmail.com' AS email,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Serdika') 
		AND LOWER (house) = LOWER ('45b')) AS address_id
	UNION ALL
		SELECT 
		'Nikolai' AS first_name,
		'Petrov' AS last_name,
		'375442994592' AS phone,
		'Petrov1@gmail.com' AS email,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Levskogo') 
		AND LOWER (house) = LOWER ('6')) AS address_id
	UNION ALL
		SELECT 
		'Olga' AS first_name,
		'Samarina' AS last_name,
		'375297494500' AS phone,
		'Sammi@gmail.com' AS email,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Levskogo') 
		AND LOWER (house) = LOWER ('6')) AS address_id
	UNION ALL
		SELECT 
		'Andrey' AS first_name,
		'Potapov' AS last_name,
		'375297455885' AS phone,
		'Potapov1@gmail.com' AS email,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('Main') 
		AND LOWER (house) = LOWER ('15')) AS address_id
	UNION ALL
		SELECT 
		'Ivan' AS first_name,
		'Kalinin' AS last_name,
		'375297412344' AS phone,
		'IKalinin@gmail.com' AS email,
		(SELECT address_id FROM store_schema.address 
		WHERE LOWER (street) = LOWER ('green') 
		AND LOWER (house) = LOWER ('8')) AS address_id
		) AS n_cus				
WHERE NOT EXISTS (SELECT 1 FROM store_schema.customer cus 
		WHERE LOWER (cus.first_name) = LOWER (n_cus.first_name) AND LOWER (cus.last_name) = LOWER (n_cus.last_name))
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO store_schema.product (category_id, supplier_id, name, model, price, stock_quantity)
SELECT * FROM (SELECT(SELECT category_id FROM store_schema.category 
		WHERE LOWER (name) = LOWER ('Refrigerators')) AS category_id,
		(SELECT supplier_id FROM store_schema.supplier 
		WHERE LOWER (name) = LOWER ('Janet')) AS supplier_id,
		'LG NoFrost Fridge' AS name,
		'LG143232' AS model,
		580 AS price,
		5 AS stock_quantity
	UNION ALL
		SELECT
		(SELECT category_id FROM store_schema.category 
		WHERE LOWER (name) = LOWER ('Televisions')) AS category_id,
		(SELECT supplier_id FROM store_schema.supplier 
		WHERE LOWER (name) = LOWER ('Janet')) AS supplier_id,
		'Philips 4k' AS name,
		'PH125AS' AS model,
		780 AS price,
		6 AS stock_quantity
	UNION ALL
		SELECT
		(SELECT category_id FROM store_schema.category 
		WHERE LOWER (name) = LOWER ('Washing Machines')) AS category_id,
		(SELECT supplier_id FROM store_schema.supplier 
		WHERE LOWER (name) = LOWER ('nova')) AS supplier_id,
		'Bosh 7kg' AS name,
		'bosh785as6' AS model,
		500 AS price,
		3 AS stock_quantity
	UNION ALL
		SELECT
		(SELECT category_id FROM store_schema.category 
		WHERE LOWER (name) = LOWER ('Vacuum Cleaners')) AS category_id,
		(SELECT supplier_id FROM store_schema.supplier 
		WHERE LOWER (name) = LOWER ('nova')) AS supplier_id,
		'LG Vertical Vacuum' AS name,
		'LG78KJ' AS model,
		320 AS price,
		8 AS stock_quantity
	UNION ALL
		SELECT
		(SELECT category_id FROM store_schema.category 
		WHERE LOWER (name) = LOWER ('Microwave Ovens')) AS category_id,
		(SELECT supplier_id FROM store_schema.supplier 
		WHERE LOWER (name) = LOWER ('uniCo')) AS supplier_id,
		'AEG Microwave' AS name,
		'10AEG258' AS model,
		270 AS price,
		5 AS stock_quantity
	UNION ALL
		SELECT
		(SELECT category_id FROM store_schema.category 
		WHERE LOWER (name) = LOWER ('Electric Kettles')) AS category_id,
		(SELECT supplier_id FROM store_schema.supplier 
		WHERE LOWER (name) = LOWER ('uniCo')) AS supplier_id,
		'Delonghi Kettle' AS name,
		'De589A' AS model,
		150 AS price,
		5 AS stock_quantity
		) AS n_prod				
WHERE NOT EXISTS (SELECT 1 FROM store_schema.product pr 
		WHERE LOWER (pr.name) = LOWER (n_prod.name) AND LOWER (pr.model) = LOWER (n_prod.model))
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO store_schema.order (customer_id, employee_id, order_date, status)
SELECT * FROM (SELECT (SELECT customer_id FROM store_schema.customer 
		 WHERE LOWER (customer.first_name) = LOWER ('Ivan') 
		 AND LOWER (customer.last_name) = LOWER ('Kalinin')) AS customer_id,
		(SELECT employee_id FROM store_schema.employee 
		 WHERE LOWER (employee.first_name) = LOWER ('Olga') 
		 AND LOWER (employee.last_name) = LOWER ('Nikolova')) AS employee_id,
		'2025-09-02 00:00:00'::timestamp AS order_date,
		'Delivered' AS name
	UNION ALL
		SELECT(SELECT customer_id FROM store_schema.customer 
		 WHERE LOWER (customer.first_name) = LOWER ('Nina') 
		 AND LOWER (customer.last_name) = LOWER ('Nikolova')) AS customer_id,
		(SELECT employee_id FROM store_schema.employee 
		 WHERE LOWER (employee.first_name) = LOWER ('Tom') 
		 AND LOWER (employee.last_name) = LOWER ('dill')) AS employee_id,
		'2025-10-02 00:00:00'::timestamp AS order_date,
		'Delivered' AS name
	UNION ALL
		SELECT(SELECT customer_id FROM store_schema.customer
     		 ORDER BY RANDOM () LIMIT 1) AS customer_id,
		(SELECT employee_id FROM store_schema.employee 
		 WHERE LOWER (employee.first_name) = LOWER ('Olga') 
		 AND LOWER (employee.last_name) = LOWER ('Nikolova')) AS employee_id,
		'2025-11-11 00:00:00'::timestamp AS order_date,
		'Delivered' AS name
	UNION ALL
		SELECT(SELECT customer_id FROM store_schema.customer
     		 ORDER BY RANDOM () LIMIT 1) AS customer_id,
		(SELECT employee_id FROM store_schema.employee 
		 WHERE LOWER (employee.first_name) = LOWER ('Olga') 
		 AND LOWER (employee.last_name) = LOWER ('Nikolova')) AS employee_id,
		'2025-11-12 00:00:00'::timestamp AS order_date,
		'Delivered' AS name
	UNION ALL
		SELECT(SELECT customer_id FROM store_schema.customer
     		 ORDER BY RANDOM () LIMIT 1) AS customer_id,
		(SELECT employee_id FROM store_schema.employee 
		 WHERE LOWER (employee.first_name) = LOWER ('Olga') 
		 AND LOWER (employee.last_name) = LOWER ('Nikolova')) AS employee_id,
		'2025-11-22 00:00:00'::timestamp AS order_date,
		'Shipped' AS name
	UNION ALL
		SELECT(SELECT customer_id FROM store_schema.customer
     		 ORDER BY RANDOM () LIMIT 1) AS customer_id,
		(SELECT employee_id FROM store_schema.employee 
		 WHERE LOWER (employee.first_name) = LOWER ('Olga') 
		 AND LOWER (employee.last_name) = LOWER ('Nikolova')) AS employee_id,
		'2025-12-02 00:00:00'::timestamp AS order_date,
		'Shipped' AS name
		) AS n_ord				
ON CONFLICT (order_id) DO NOTHING
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO store_schema.order_detail (order_id, product_id, quantity, unit_price)
SELECT * FROM (SELECT (SELECT order_id FROM store_schema.order ord 
         		INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
			WHERE LOWER (cus.first_name) = LOWER ('Ivan') 
			AND LOWER (cus.last_name) = LOWER ('Kalinin')
			AND ord.order_date = '2025-09-02 00:00:00'::timestamp) AS order_id,
			(SELECT product_id FROM store_schema.product 
			WHERE LOWER(model) = LOWER('LG143232')) AS product_id,
			2 AS quantity,
			(SELECT price FROM store_schema.product 
			WHERE LOWER(model) = LOWER('LG143232')) AS unit_price
		UNION ALL
			SELECT
			(SELECT order_id FROM store_schema.order ord 
         		INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
			WHERE LOWER (cus.first_name) = LOWER ('Nina')
			AND LOWER (cus.last_name) = LOWER ('Nikolova')
			AND ord.order_date = '2025-10-02 00:00:00'::timestamp),
			(SELECT product_id FROM store_schema.product 
			WHERE LOWER(model) = LOWER('bosh785as6')),
			1,
			(SELECT price FROM store_schema.product 
			WHERE LOWER(model) = LOWER('bosh785as6'))
		UNION ALL
			SELECT
			(SELECT order_id FROM store_schema.order ord 
         		INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
			WHERE LOWER (cus.first_name) = LOWER ('Nikolai')
			AND LOWER (cus.last_name) = LOWER ('Petrov')
			AND ord.order_date = '2025-11-12 00:00:00'::timestamp),
			(SELECT product_id FROM store_schema.product 
			WHERE LOWER(model) = LOWER('10AEG258')),
			1,
			(SELECT price FROM store_schema.product 
			WHERE LOWER(model) = LOWER('10AEG258'))
		UNION ALL
			SELECT
			(SELECT order_id FROM store_schema.order ord 
         		INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
			WHERE LOWER (cus.first_name) = LOWER ('Nina')
			AND LOWER (cus.last_name) = LOWER ('Nikolova')
			AND ord.order_date = '2025-11-11 00:00:00'::timestamp),
			(SELECT product_id FROM store_schema.product 
			WHERE LOWER(model) = LOWER('De589A')),
			2,
			(SELECT price FROM store_schema.product 
			WHERE LOWER(model) = LOWER('De589A'))
		UNION ALL
			SELECT
			(SELECT order_id FROM store_schema.order ord 
         		INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
			WHERE LOWER (cus.first_name) = LOWER ('Andrey')
			AND LOWER (cus.last_name) = LOWER ('Potapov')
			AND ord.order_date = '2025-11-22 00:00:00'::timestamp),
			(SELECT product_id FROM store_schema.product 
			WHERE LOWER(model) = LOWER('De589A')),
			1,
			(SELECT price FROM store_schema.product 
			WHERE LOWER(model) = LOWER('De589A'))
		UNION ALL
			SELECT
			(SELECT order_id FROM store_schema.order ord 
         		INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
			WHERE LOWER (cus.first_name) = LOWER ('Fill')
			AND LOWER (cus.last_name) = LOWER ('Tanil')
			AND ord.order_date = '2025-12-02 00:00:00'::timestamp),
			(SELECT product_id FROM store_schema.product 
			WHERE LOWER(model) = LOWER('LG78KJ')),
			1,
			(SELECT price FROM store_schema.product 
			WHERE LOWER(model) = LOWER('LG78KJ'))
			) AS n_od
WHERE NOT EXISTS (SELECT 1 FROM store_schema.order_detail od WHERE od.order_id = n_od.order_id
AND od.product_id = n_od.product_id)
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO store_schema.payment (order_id, payment_date, payment_amount)
SELECT * FROM (SELECT
	      ord.order_id AS order_id,
	      CURRENT_TIMESTAMP AS payment_date,
	      COALESCE(SUM(od.quantity * od.unit_price), 0)
	      FROM store_schema.order ord
	      INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
	      INNER JOIN store_schema.order_detail od ON ord.order_id = od.order_id
	      WHERE LOWER (cus.first_name) = LOWER ('Ivan')
	      AND LOWER (cus.last_name) = LOWER ('Kalinin')
	      AND ord.order_date = '2025-09-02 00:00:00'::timestamp
	      GROUP BY ord.order_id
	      HAVING COALESCE(SUM(od.quantity * od.unit_price), 0) > 0
	UNION ALL
	      SELECT
	      ord.order_id AS order_id,
	      CURRENT_TIMESTAMP AS payment_date,
	      COALESCE(SUM(od.quantity * od.unit_price), 0)
	      FROM store_schema.order ord
	      INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
	      INNER JOIN store_schema.order_detail od ON ord.order_id = od.order_id
	      WHERE LOWER (cus.first_name) = LOWER ('Nina') 
	      AND LOWER (cus.last_name) = LOWER ('Nikolova')
	      AND ord.order_date = '2025-10-02 00:00:00'::timestamp
	      GROUP BY ord.order_id
	      HAVING COALESCE(SUM(od.quantity * od.unit_price), 0) > 0
	UNION ALL
	      SELECT
	      ord.order_id AS order_id,
	      CURRENT_TIMESTAMP AS payment_date,
	      COALESCE(SUM(od.quantity * od.unit_price), 0)
	      FROM store_schema.order ord
	      INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
	      INNER JOIN store_schema.order_detail od ON ord.order_id = od.order_id
	      WHERE LOWER (cus.first_name) = LOWER ('Nikolai') 
	      AND LOWER (cus.last_name) = LOWER ('Petrov')
	      AND ord.order_date = '2025-11-12 00:00:00'::timestamp
	      GROUP BY ord.order_id
	      HAVING COALESCE(SUM(od.quantity * od.unit_price), 0) > 0
	UNION ALL
	      SELECT
	      ord.order_id AS order_id,
	      CURRENT_TIMESTAMP AS payment_date,
	      COALESCE(SUM(od.quantity * od.unit_price), 0)
	      FROM store_schema.order ord
	      INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
	      INNER JOIN store_schema.order_detail od ON ord.order_id = od.order_id
	      WHERE LOWER (cus.first_name) = LOWER ('Nina') 
	      AND LOWER (cus.last_name) = LOWER ('Nikolova')
	      AND ord.order_date = '2025-11-11 00:00:00'::timestamp
	      GROUP BY ord.order_id
	      HAVING COALESCE(SUM(od.quantity * od.unit_price), 0) > 0
	UNION ALL
	      SELECT
	      ord.order_id AS order_id,
	      CURRENT_TIMESTAMP AS payment_date,
	      COALESCE(SUM(od.quantity * od.unit_price), 0)
	      FROM store_schema.order ord
	      INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
	      INNER JOIN store_schema.order_detail od ON ord.order_id = od.order_id
	      WHERE LOWER (cus.first_name) = LOWER ('Andrey') 
	      AND LOWER (cus.last_name) = LOWER ('Potapov')
	      AND ord.order_date = '2025-11-22 00:00:00'::timestamp
	      GROUP BY ord.order_id
	      HAVING COALESCE(SUM(od.quantity * od.unit_price), 0) > 0
	UNION ALL
	      SELECT
	      ord.order_id AS order_id,
	      CURRENT_TIMESTAMP AS payment_date,
	      COALESCE(SUM(od.quantity * od.unit_price), 0)
	      FROM store_schema.order ord
	      INNER JOIN store_schema.customer cus ON ord.customer_id = cus.customer_id
	      INNER JOIN store_schema.order_detail od ON ord.order_id = od.order_id
	      WHERE LOWER (cus.first_name) = LOWER ('Fill') 
	      AND LOWER (cus.last_name) = LOWER ('Tanil')
	      AND ord.order_date = '2025-12-02 00:00:00'::timestamp
	      GROUP BY ord.order_id
	      HAVING COALESCE(SUM(od.quantity * od.unit_price), 0) > 0
	) AS n_pay
WHERE NOT EXISTS (SELECT 1 FROM store_schema.payment pay WHERE pay.order_id = n_pay.order_id)
RETURNING *;
COMMIT;


--Task 5.1: Create a function that updates data in one of your tables. This function should take the following input arguments: 1)The primary key value of the row you want to update; 2)The name of the column you want to update; 3)The new value you want to set for the specified column

--Create an update function for the "product" table that takes three input arguments
CREATE OR REPLACE FUNCTION store_schema.update_product_column(
    product_id_value INT,           -- PK value 
    target_column_name VARCHAR,     -- column name to update 
    new_value_text TEXT             -- new value
)
RETURNS void AS $$
DECLARE
    v_sql_query TEXT;
BEGIN
    v_sql_query := FORMAT('UPDATE store_schema.product SET %I = %L WHERE product_id = %L',
        LOWER (target_column_name), 
        new_value_text,     
        product_id_value);
    EXECUTE v_sql_query;
    RAISE NOTICE 'Row with product_id = % in table product update: % set in %', 
                 product_id_value, target_column_name, new_value_text;
END;
$$ LANGUAGE plpgsql;

--For example, update the price of a product
SELECT store_schema.update_product_column(
    1,          -- product_id
    'price',    -- column name to update
    '599');     -- new value


--Сreate a more flexible function that can update any table in the schema. 
CREATE OR REPLACE FUNCTION store_schema.update_data_table(
    target_table_name VARCHAR,      -- table name to update 
    primary_key_column_name VARCHAR, -- PK column name 
    primary_key_value INT,          -- PK value 
    target_column_name VARCHAR,     -- column name to update 
    new_value_text TEXT             -- new value 
)
RETURNS void AS $$
DECLARE
    v_sql_query TEXT;
BEGIN
    v_sql_query := FORMAT('UPDATE store_schema.%I SET %I = %L WHERE %I = %L',
        LOWER (target_table_name),
        LOWER (target_column_name),
        new_value_text,
        primary_key_column_name,
        primary_key_value);
    EXECUTE v_sql_query;
    RAISE NOTICE 'Row with % = % in table % update: % set in %', 
                 primary_key_column_name, primary_key_value, target_table_name, 
                 target_column_name, new_value_text;
END;
$$ LANGUAGE plpgsql;

--For example, update the price of a product
SELECT store_schema.update_data_table(
    'ProDuct',     --table name to update    
    'product_id',  --PK column name     
    1,             --PK value     
    'price',       --column name to update
    '499');        --new value
    
    
--Task 5.2: Create a function that adds a new transaction to your transaction table. You can define the input arguments and output format. 
      
--Сreate a function for adding a new transaction to table "payment"   
CREATE OR REPLACE FUNCTION store_schema.insert_new_payment(
    p_order_date TIMESTAMP WITH TIME ZONE, -- Order date/time
    p_customer_phone VARCHAR DEFAULT NULL, -- can be NULL
    p_customer_email VARCHAR DEFAULT NULL -- can be NULL, customer email (natural key for customer)
)
RETURNS text AS $$ 
DECLARE
    v_order_id INT;
    v_customer_id INT;
    v_payment_id INT;
	v_payment_amount DECIMAL;
	v_payment_exists BOOLEAN := FALSE;
BEGIN
    -- flexible customer_id search, using a unique email and phone number
    SELECT customer_id INTO v_customer_id
    FROM store_schema.customer
    WHERE 
        -- search by phone and email (if the phone is not provided, we search by email and vise verse)
        (p_customer_email IS NOT NULL AND LOWER (email) = LOWER (p_customer_email))
        OR
        (p_customer_phone IS NOT NULL AND phone = p_customer_phone);
    IF v_customer_id IS NULL THEN
        RETURN 'Error: Client email address not found.';
    END IF;
    -- Find order_id by customer_id and order date
    SELECT order_id INTO v_order_id
    FROM store_schema.order
    WHERE customer_id = v_customer_id AND order_date = p_order_date;
    IF v_order_id IS NULL THEN
        RETURN 'Error: Order with the specified data not found.';
    END IF;
	-- Check if there is already a successful payment for this order
    SELECT TRUE INTO v_payment_exists
    FROM store_schema.payment
    WHERE order_id = v_order_id 
    LIMIT 1;
    IF v_payment_exists THEN
        RETURN 'The order #' || v_order_id || ' already has a completed payment. The duplicate transaction was rejected.';
    END IF;
	    -- payment amount
    SELECT COALESCE(SUM(quantity * unit_price), 0) INTO v_payment_amount
    FROM store_schema.order_detail
    WHERE order_id = v_order_id;
    IF v_payment_amount <= 0 THEN
        RETURN 'Error: The order amount is zero or negative, the payment cannot be created.';
    END IF;
    -- Insert a new transaction (payment)
    INSERT INTO store_schema.payment (order_id, payment_amount, payment_date)
    VALUES (v_order_id, v_payment_amount, CURRENT_TIMESTAMP)
    RETURNING payment_id INTO v_payment_id; 
    -- Confirming successful insertion
    RETURN 'Success: Transaction #' || v_payment_id || ' added to order #' || v_order_id || '.';
EXCEPTION
    WHEN others THEN
        -- Handling other possible errors
        RETURN 'An error occurred while inserting the payment: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;    

--Example query to insert a new transaction to table "payment"     
SELECT store_schema.insert_new_payment(
    '2025-09-09 00:00:00'::timestamp,
    '375297412344',
    'IKalinin@gmail.com');    
    
    
--Task 6: Create a view that presents analytics for the most recently added quarter in your database. 

--Create a VIEW that presents sales analytics
CREATE OR REPLACE VIEW store_schema.quarter_sales_analytics AS
WITH c_quarter AS (
    -- determine beginning of the current quarter
    SELECT DATE_TRUNC('quarter', CURRENT_DATE) AS current_quarter_start),
last_completed_quarter_dates AS (
    -- determine the start and the end date of the last added quarter
    SELECT 
        (SELECT current_quarter_start FROM c_quarter) - INTERVAL '3 months' AS start_date,
        (SELECT current_quarter_start FROM c_quarter) - INTERVAL '1 second' AS end_date)
SELECT
      (SELECT CONCAT(EXTRACT(YEAR FROM start_date), ' Q', EXTRACT(QUARTER FROM start_date)) from last_completed_quarter_dates) as year_quarter, 
       COUNT(DISTINCT ord.order_id) AS total_orders_count,
       SUM(OD.quantity) AS total_items_sold,
       SUM(OD.quantity * OD.unit_price) AS total_sales_amount,
       ROUND(avg(OD.quantity * OD.unit_price)) as average_order_value
FROM store_schema.order ord
INNER JOIN store_schema.order_detail od ON ord.order_id = od.order_id
INNER JOIN store_schema.product pr ON od.product_id = pr.product_id
WHERE ord.order_date >= (SELECT start_date FROM last_completed_quarter_dates)
AND ord.order_date <= (SELECT end_date FROM last_completed_quarter_dates)


--Task 7: Create a read-only role for the manager. This role should have permission to perform SELECT queries on the database tables, and also be able to log in. Please ensure that you adhere to best practices for database security when defining this role
   
--Create a new role "manager", set a password, and give them the ability to log in to the system (LOGIN).    
CREATE ROLE manager WITH LOGIN PASSWORD 'managerpass';

--Grant permission to the role to connect to the database
GRANT CONNECT ON DATABASE household_appliances_store_db TO manager;

--Grant permission to the role to use the store_schema
GRANT USAGE ON SCHEMA store_schema TO manager;

--Grant the role SELECT permission to ALL tables in the store_schema.
GRANT SELECT ON ALL TABLES IN SCHEMA store_schema TO manager;
    
    
    


