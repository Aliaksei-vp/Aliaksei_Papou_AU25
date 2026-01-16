/*
Task 1:Create a query for analyzing the annual sales data for the years 1999 to 2001, focusing on different sales channels and regions: 'Americas,' 'Asia,' and 'Europe.' 
The resulting report should contain the following columns:
AMOUNT_SOLD: This column should show the total sales amount for each sales channel
% BY CHANNELS: In this column, we should display the percentage of total sales for each channel (e.g. 100% - total sales for Americas in 1999, 63.64% - percentage of sales for the channel “Direct Sales”)
% PREVIOUS PERIOD: This column should display the same percentage values as in the '% BY CHANNELS' column but for the previous year
% DIFF: This column should show the difference between the '% BY CHANNELS' and '% PREVIOUS PERIOD' columns, indicating the change in sales percentage from the previous year.
The final result should be sorted in ascending order based on three criteria: first by 'country_region,' then by 'calendar_year,' and finally by 'channel_desc'
*/

WITH a_sold AS (
    SELECT 
        co.country_region,
        t.calendar_year,
        ch.channel_desc,
        SUM(s.amount_sold) AS amount_sold
    FROM sh.sales s
    JOIN sh.times t ON s.time_id = t.time_id
    JOIN sh.customers cu ON s.cust_id = cu.cust_id
    JOIN sh.countries co ON cu.country_id = co.country_id
    JOIN sh.channels ch ON s.channel_id = ch.channel_id
    WHERE co.country_region IN ('Americas', 'Asia', 'Europe')
      AND t.calendar_year BETWEEN 1998 AND 2001 
    GROUP BY co.country_region, t.calendar_year, ch.channel_desc
),
c_percentage AS (
    SELECT 
        country_region,
        calendar_year,
        channel_desc,
        amount_sold,
        ROUND((amount_sold / SUM(amount_sold) OVER (
        PARTITION BY country_region, calendar_year)) * 100, 2) AS pct_by_channels
    FROM a_sold
)
SELECT * FROM (
    SELECT 
        country_region,
        calendar_year,
        channel_desc,
        amount_sold,
        pct_by_channels || '%' AS "% BY CHANNELS",
        COALESCE(MAX(pct_by_channels) OVER (
                PARTITION BY country_region, channel_desc 
                ORDER BY calendar_year
                ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING)::text || '%', 'N/A') AS "% PREVIOUS PERIOD",
        (pct_by_channels - COALESCE(MAX(pct_by_channels) OVER (
                PARTITION BY country_region, channel_desc 
                ORDER BY calendar_year
                ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING), 0)) || '%' AS "% DIFF"
    FROM c_percentage
) final_result
--Cut off the year 1998 from the output, but its values ​​remained in the calculations for 1999
WHERE calendar_year BETWEEN 1999 AND 2001
ORDER BY country_region, calendar_year, channel_desc;


/*
Task 2: create a query that meets the following requirements:
Generate a sales report for the 49th, 50th, and 51st weeks of 1999.
Include a column named CUM_SUM to display the amounts accumulated during each week.
Include a column named CENTERED_3_DAY_AVG to show the average sales for the previous, current, and following days using a centered moving average.
For Monday, calculate the average sales based on the weekend sales (Saturday and Sunday) as well as Monday and Tuesday.
For Friday, calculate the average sales on Thursday, Friday, and the weekend.
Ensure that your calculations are accurate for the beginning of week 49 and the end of week 51.
*/

WITH dailys_sales AS (
    SELECT 
        t.calendar_week_number,
        t.time_id,
        t.day_name,
        SUM(s.amount_sold) AS sales
    FROM sh.sales s
    JOIN sh.times t ON s.time_id = t.time_id
    WHERE t.calendar_year = 1999
      AND t.calendar_week_number BETWEEN 48 AND 52
    GROUP BY t.calendar_week_number, t.time_id, t.day_name
),
w_calc AS (
    SELECT 
        calendar_week_number,
        time_id,
        day_name,
        sales,
        SUM(sales) OVER (ORDER BY time_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sum,
        CASE 
            WHEN day_name = 'Monday' THEN
                AVG(sales) OVER (ORDER BY time_id ROWS BETWEEN 2 PRECEDING AND 1 FOLLOWING)
            WHEN day_name = 'Friday' THEN
                AVG(sales) OVER (ORDER BY time_id ROWS BETWEEN 1 PRECEDING AND 2 FOLLOWING)
            ELSE
                AVG(sales) OVER (ORDER BY time_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
        END AS centered_3_day_avg
    FROM dailys_sales
)
SELECT 
    calendar_week_number,
    time_id,
    day_name,
    sales,
    cum_sum,
    ROUND(centered_3_day_avg, 2) as centered_3_day_avg
FROM w_calc
WHERE calendar_week_number BETWEEN 49 AND 51
ORDER BY time_id;


/*Task 3: Provide 3 instances of utilizing window functions that include a frame clause, using RANGE, ROWS, and GROUPS modes. 
Additionally, explain the reason for choosing a specific frame type for each example. 
This can be presented as a single query or as three distinct queries.
*/


SELECT 
    t.time_id,
    SUM(s.amount_sold) as daily_sales,
    
    -- 1. ROWS MODE: Moving average of 3 physical records
    -- ROWS MODE is suitable when we need to average the current day's values ​​with its immediate neighbors in the table.
    ROUND(AVG(SUM(s.amount_sold)) OVER (
        ORDER BY t.time_id 
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ),2) as rows_moving_avg,

    -- 2. RANGE MODE: Amount for a time interval (last 7 days)
    --RANGE allows you to use the INTERVAL type when working with dates. This is critical if there are gaps in the data (for example, a store closed on holidays). ROWS 6 PRECEDING in case of gaps will issue the amount for 7 actual working days, which can extend to 10 calendar days.
    SUM(SUM(s.amount_sold)) OVER (
        ORDER BY t.time_id 
        RANGE BETWEEN INTERVAL '6' DAY PRECEDING AND CURRENT ROW
    ) as range_weekly_sum,

    -- 3. GROUPS MODE: Cumulative total by calendar week
    --GROUPS Mode is selected for cumulative totals by week, where one week contains many rows.
    --GROUPS treats all rows with the same calendar week number as a single, indivisible object.
    --If we use ROWS, the amount will grow daily within a week.
    SUM(SUM(s.amount_sold)) OVER (
        ORDER BY t.calendar_week_number 
        GROUPS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as groups_cumulative_sum
FROM sh.sales s
JOIN sh.times t ON s.time_id = t.time_id
WHERE t.calendar_year = 1999 AND t.calendar_month_number = 1
GROUP BY t.time_id, t.calendar_week_number
ORDER BY t.time_id;











