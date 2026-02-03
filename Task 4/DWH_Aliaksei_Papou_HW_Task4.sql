--Create schema
CREATE SCHEMA IF NOT EXISTS BL_DM;


--Сreate the DIM_DATES table.
--Since this is a static dimension, we omit the source fields (SRC_ID), but add the technical INSERT_DT for consistency.

CREATE TABLE IF NOT EXISTS BL_DM.DIM_DATES (
    DATE_ID      BIGINT NOT NULL,           
    FULL_DATE    DATE NOT NULL,          
    DAY_OF_WEEK  VARCHAR(15) NOT NULL,   
    DAY_NUMBER   INT NOT NULL,           
    MONTH_NUMBER INT NOT NULL,           
    MONTH_NAME   VARCHAR(15) NOT NULL,   
    QUARTER      INT NOT NULL,           
    YEAR         INT NOT NULL,           
    INSERT_DT    TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    
    CONSTRAINT PK_DIM_DATES PRIMARY KEY (DATE_ID)
);



--Fill the table with data. I chose the range from 2022 to 2026.
BEGIN;
INSERT INTO BL_DM.DIM_DATES (DATE_ID, FULL_DATE, DAY_OF_WEEK, DAY_NUMBER, MONTH_NUMBER, MONTH_NAME, QUARTER, YEAR)
SELECT 
    TO_CHAR(datum, 'YYYYMMDD')::BIGINT AS DATE_ID,
    datum AS FULL_DATE,
    TO_CHAR(datum, 'TMDay') AS DAY_OF_WEEK, 
    EXTRACT(DAY FROM datum) AS DAY_NUMBER,
    EXTRACT(MONTH FROM datum) AS MONTH_NUMBER,
    TO_CHAR(datum, 'TMMonth') AS MONTH_NAME,
    EXTRACT(QUARTER FROM datum) AS QUARTER,
    EXTRACT(YEAR FROM datum) AS YEAR
FROM (
    SELECT '2022-01-01'::DATE + sequence.day AS datum
    FROM generate_series(0, (DATE '2026-12-31' - DATE '2022-01-01')) AS sequence(day)
) AS d
ON CONFLICT (DATE_ID) DO NOTHING;
COMMIT;
