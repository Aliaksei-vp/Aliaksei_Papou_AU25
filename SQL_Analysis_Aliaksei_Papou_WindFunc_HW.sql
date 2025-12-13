
--Task 1: Create a query to produce a sales report highlighting the top customers with the highest sales across different sales channels. This report should list the top 5 customers for each channel. Additionally, calculate a key performance indicator (KPI) called 'sales_percentage,' which represents the percentage of a customer's sales relative to the total sales within their respective channel. Display the total sales amount with two decimal places. Display the sales percentage with four decimal places and include the percent sign (%) at the end. Display the result for each channel in descending order of sales.

SELECT
    channel_desc,
    cust_first_name,
    cust_last_name,
    TO_CHAR(ROUND(amount_sold, 2), '999999999.90') AS "amount_sold",
    TO_CHAR(ROUND(sales_percentage, 4), '999.9990') || '%' AS "sales_percentage"
FROM (SELECT
        ch.channel_desc,
	cust.cust_first_name,
        cust.cust_last_name,
        SUM(sal.amount_sold) AS amount_sold,
        -- Calculating the percentage of sales 
        (SUM(sal.amount_sold) * 100 / SUM(SUM(sal.amount_sold)) OVER (PARTITION BY ch.channel_desc)) AS sales_percentage,
        -- Ranking customers within each channel by highest sales
        ROW_NUMBER() OVER (PARTITION BY ch.channel_desc ORDER BY SUM(sal.amount_sold) DESC
        ) AS rn
    FROM sh.sales sal
    INNER JOIN sh.customers cust ON sal.cust_id = cust.cust_id
    INNER JOIN sh.channels ch ON sal.channel_id = ch.channel_id
    GROUP BY ch.channel_desc, cust.cust_last_name, cust.cust_first_name
    ) r_sales
WHERE rn <= 5
ORDER BY r_sales.amount_sold DESC; 


--Task 2: Create a query to retrieve data for a report that displays the total sales for all products in the Photo category in the Asian region for the year 2000. Calculate the overall report total and name it 'YEAR_SUM'. Display the sales amount with two decimal places. Display the result in descending order of 'YEAR_SUM'.

--Solution using the crosstable approach
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT product_name,
    COALESCE("2000-01", 0) AS Q1,
    COALESCE("2000-02", 0) AS Q2,
    COALESCE("2000-03", 0) AS Q3,
    COALESCE("2000-04", 0) AS Q4,
    TO_CHAR(COALESCE("2000-01", 0) + COALESCE("2000-02", 0) + 
            COALESCE("2000-03", 0) + COALESCE("2000-04", 0), '999999999999.99'
    ) AS year_sum
FROM crosstab(
        'SELECT 
            pr.prod_name,
            tim.calendar_quarter_desc AS quarter,
            SUM(sal.amount_sold) AS amount_sold
        FROM sh.sales sal
        INNER JOIN sh.products pr ON sal.prod_id = pr.prod_id
        INNER JOIN sh.times tim ON sal.time_id = tim.time_id
        INNER JOIN sh.customers cust ON sal.cust_id = cust.cust_id
        INNER JOIN sh.countries ctr ON cust.country_id = ctr.country_id
        WHERE
            LOWER(pr.prod_category) = LOWER(''Photo'')
            AND LOWER(ctr.country_region) = LOWER(''Asia'')
            AND tim.calendar_year = 2000
        GROUP BY 
            pr.prod_name, 
            tim.calendar_quarter_desc
        ORDER BY 
            pr.prod_name, 
            tim.calendar_quarter_desc',
        'SELECT DISTINCT calendar_quarter_desc 
         FROM sh.times 
         WHERE calendar_year = 2000 
         ORDER BY calendar_quarter_desc'
    ) AS ct (
        product_name text,
        "2000-01" numeric,
        "2000-02" numeric,
        "2000-03" numeric,
        "2000-04" numeric)
ORDER BY 
    (COALESCE("2000-01", 0) + COALESCE("2000-02", 0) + 
     COALESCE("2000-03", 0) + COALESCE("2000-04", 0)) DESC;

--The solution using a CASE approach looks more readable
WITH year_sales AS (
    SELECT
        pr.prod_name,
        tim.calendar_quarter_desc AS quarter,
        sal.amount_sold
    FROM sh.sales sal
    INNER JOIN sh.products pr ON sal.prod_id = pr.prod_id
    INNER JOIN sh.times tim ON sal.time_id = tim.time_id
    INNER JOIN sh.customers cust ON sal.cust_id = cust.cust_id
    INNER JOIN sh.countries ctr ON cust.country_id = ctr.country_id
    WHERE
        LOWER (pr.prod_category) = LOWER ('Photo') 
        AND LOWER (ctr.country_region) = LOWER ('Asia') 
        AND tim.calendar_year = 2000 
)
SELECT
    prod_name AS product_name,
    SUM(CASE WHEN quarter = '2000-01' THEN amount_sold ELSE 0 END) AS q1,
    SUM(CASE WHEN quarter = '2000-02' THEN amount_sold ELSE 0 END) AS q2,
    SUM(CASE WHEN quarter = '2000-03' THEN amount_sold ELSE 0 END) AS q3,
    SUM(CASE WHEN quarter = '2000-04' THEN amount_sold ELSE 0 END) AS q4,
    TO_CHAR(SUM(amount_sold),'999999999999.99') AS year_sum
FROM year_sales
GROUP BY prod_name
ORDER BY sum(amount_sold) DESC;


--Task 3: Create a query to generate a sales report for customers ranked in the top 300 based on total sales in the years 1998, 1999, and 2001. The report should be categorized based on sales channels, and separate calculations should be performed for each channel.

--find the top 300 clients for each of the three selected years and for each sales channel
WITH year_channel_sales AS (
    -- Aggregate total sales per customer, per channel, per year
    SELECT
        sal.cust_id,
        sal.channel_id,
        tim.calendar_year,
        SUM(sal.amount_sold) AS total_sales
    FROM sh.sales sal
    INNER JOIN sh.times tim ON sal.time_id = tim.time_id
    WHERE tim.calendar_year IN (1998, 1999, 2001)
    GROUP BY
        sal.cust_id, 
        sal.channel_id, 
        tim.calendar_year
),
customer_channel_year_ranks AS (
    -- Rank customers within each channel and year by their total sales
    SELECT
        ycs.cust_id,
        ycs.channel_id,
        ycs.calendar_year,
        ycs.total_sales,
        DENSE_RANK() OVER (PARTITION BY ycs.channel_id, ycs.calendar_year ORDER BY ycs.total_sales DESC
        ) AS sales_rank
    FROM year_channel_sales ycs
)
SELECT
    ch.channel_desc,
    cus.cust_id,
    cus.cust_first_name,
    cus.cust_last_name,
    cyr.calendar_year,
    TO_CHAR (cyr.total_sales, '9999999999.99') AS amount_sold
FROM customer_channel_year_ranks cyr
INNER JOIN sh.customers cus ON cyr.cust_id = cus.cust_id
INNER JOIN sh.channels ch ON cyr.channel_id = ch.channel_id
WHERE cyr.sales_rank <= 300 -- Top 300 per channel per year
ORDER BY cyr.sales_rank;

--find the top 300 clients for all years at once, and then break down their total sales by channel.
WITH cus_sales_rank AS (
    SELECT
        sal.cust_id,
        SUM(sal.amount_sold) AS total_sales_volume,
        DENSE_RANK() OVER (ORDER BY SUM(sal.amount_sold) DESC) as sales_rank
    FROM sh.sales sal
    INNER JOIN sh.times tim ON sal.time_id = tim.time_id
    WHERE tim.calendar_year IN (1998, 1999, 2001)
    GROUP BY sal.cust_id
),
Top300Customers AS (
    SELECT cust_id
    FROM cus_sales_rank
    WHERE sales_rank <= 300
)  
SELECT
    chn.channel_desc AS "channel_desc",
    cust.cust_id AS "cust_id",
    cust.cust_first_name AS "cust_first_name",
    cust.cust_last_name AS "cust_last_name",
    TO_CHAR(SUM(sal.amount_sold), '99999999999.99') AS "amount_sold"
FROM sh.sales sal
INNER JOIN sh.customers cust ON sal.cust_id = cust.cust_id
INNER JOIN sh.channels chn ON sal.channel_id = chn.channel_id
INNER JOIN sh.times tim ON sal.time_id = tim.time_id
WHERE sal.cust_id IN (SELECT cust_id FROM Top300Customers)
AND tim.calendar_year IN (1998, 1999, 2001)
GROUP BY
    chn.channel_desc,
    cust.cust_id,
    cust.cust_first_name,
    cust.cust_last_name
ORDER BY SUM(sal.amount_sold) DESC;


--Task 4: Create a query to generate a sales report for January 2000, February 2000, and March 2000 specifically for the Europe and Americas regions. Display the result by months and by product category in alphabetical order.

SELECT tim.calendar_month_desc, 
       pr.prod_category, 
       SUM(CASE WHEN LOWER (ctr.country_region) = LOWER ('Americas') 
       		THEN sal.amount_sold ELSE 0 END) AS Americas_sales,
       SUM(CASE WHEN LOWER (ctr.country_region) = LOWER ('Europe') 
		THEN sal.amount_sold ELSE 0 END) AS Europe_sales
FROM sh.sales sal
    INNER JOIN sh.products pr ON sal.prod_id = pr.prod_id
    INNER JOIN sh.times tim ON sal.time_id = tim.time_id
    INNER JOIN sh.customers cust ON sal.cust_id = cust.cust_id
    INNER JOIN sh.countries ctr ON cust.country_id = ctr.country_id
WHERE tim.calendar_year = 2000 
AND tim.calendar_month_number IN (1, 2, 3)
GROUP BY pr.prod_category, tim.calendar_month_desc
ORDER BY tim.calendar_month_desc, pr.prod_category






