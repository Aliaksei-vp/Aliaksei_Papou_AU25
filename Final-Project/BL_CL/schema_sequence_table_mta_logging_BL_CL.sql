
--Create a BL_CL schema
CREATE SCHEMA IF NOT EXISTS BL_CL;

--Create a sequence for BL_CL.MTA_LOGGING table
CREATE SEQUENCE IF NOT EXISTS BL_CL.SEQ_MTA_LOGGING START 1;

--Create a table BL_CL.MTA_LOGGING
CREATE TABLE IF NOT EXISTS BL_CL.MTA_LOGGING (
    log_id           BIGINT PRIMARY KEY DEFAULT nextval('BL_CL.SEQ_MTA_LOGGING'),
    log_dt           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    procedure_name   VARCHAR(100),
    rows_affected    INT,
    log_status       VARCHAR(20), -- SUCCESS or ERROR
    log_message      TEXT
);


