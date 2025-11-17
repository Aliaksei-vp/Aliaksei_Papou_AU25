--Create database 
CREATE DATABASE political_campaign_db

--Create schema
CREATE SCHEMA IF NOT EXISTS political_campaign

--Create tables
--Create parent tables before child tables to avoid foreign key errors
CREATE TABLE IF NOT EXISTS political_campaign.campaign (
    campaign_id INT PRIMARY KEY,
    name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    description TEXT);
    
CREATE TABLE IF NOT EXISTS political_campaign.voter (
    voter_id INT PRIMARY KEY,
    campaign_id INT NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    email VARCHAR(100),
    phone VARCHAR(20),
    FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id));
    
CREATE TABLE IF NOT EXISTS political_campaign.donor (
    donor_id INT PRIMARY KEY,
    name VARCHAR(100),
    contact_info VARCHAR(200));
    
CREATE TABLE IF NOT EXISTS political_campaign.volunteer (
    volunteer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255) UNIQUE,
    availability VARCHAR(100));
    
CREATE TABLE IF NOT EXISTS political_campaign.event_type (
    event_type_id INT PRIMARY KEY,
    type_name VARCHAR(50));
    
CREATE TABLE IF NOT EXISTS political_campaign.problem_type (
    problem_type_id INT PRIMARY KEY,
    type_name VARCHAR(50)); 

CREATE TABLE IF NOT EXISTS political_campaign.volunteer_role (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(50));
    
CREATE TABLE IF NOT EXISTS political_campaign.contribution (
    contribution_id INT PRIMARY KEY,
    donor_id INT NOT NULL,
    campaign_id INT NOT NULL,
    amount DECIMAL,
    c_date date,
    FOREIGN KEY (donor_id) REFERENCES donor(donor_id),
    FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id));
    
CREATE TABLE IF NOT EXISTS political_campaign.spending (
    spending_id INT PRIMARY KEY,
    campaign_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    amount DECIMAL,
    s_date DATE,
    description TEXT,
    FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id));

CREATE TABLE IF NOT EXISTS political_campaign.event (
    event_id INT PRIMARY KEY,
    campaign_id INT NOT NULL,
    event_type_id INT NOT NULL,
    name VARCHAR(100),
    e_date TIMESTAMP,
    description TEXT,
    FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id),
    FOREIGN KEY (event_type_id) REFERENCES event_type(event_type_id));
    
CREATE TABLE IF NOT EXISTS political_campaign.survey (
    survey_id INT PRIMARY KEY,
    campaign_id INT NOT NULL,
    name VARCHAR(100),
    s_date DATE,
    FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id));

CREATE TABLE IF NOT EXISTS political_campaign.survey_response (
    response_id INT PRIMARY KEY,
    survey_id INT NOT NULL,
    voter_id INT NOT NULL,
    response_date DATE,
    response TEXT,
    FOREIGN KEY (survey_id) REFERENCES survey(survey_id),
    FOREIGN KEY (voter_id) REFERENCES voter(voter_id));
    
CREATE TABLE IF NOT EXISTS political_campaign.problem (
    problem_id INT PRIMARY KEY,
    campaign_id INT NOT NULL,
    problem_type_id INT NOT NULL,
    reported_date DATE,
    description TEXT NOT NULL,
    FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id),
    FOREIGN KEY (problem_type_id) REFERENCES problem_Type(problem_type_id),
    parent_problem_id INT REFERENCES problem(problem_id)); -- Self-referential relationship

CREATE TABLE IF NOT EXISTS political_campaign.task (
    task_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT);
    
CREATE TABLE IF NOT EXISTS political_campaign.volunteer_task (
    volunteer_task_id INT PRIMARY KEY,
    volunteer_id INT NOT NULL,
    task_id INT NOT NULL,
    assigned_date DATE,
    FOREIGN KEY (volunteer_id) REFERENCES volunteer(volunteer_id),
    FOREIGN KEY (task_id) REFERENCES task(task_id));

CREATE TABLE IF NOT EXISTS political_campaign.volunteer_assignment (
    volunteer_id INT NOT NULL,
    role_id INT NOT NULL,
    campaign_id INT NOT NULL,
    task_id INT NOT NULL,
    assignment_date DATE,
    PRIMARY KEY (volunteer_id, role_id),
    FOREIGN KEY (volunteer_id) REFERENCES volunteer(volunteer_id),
    FOREIGN KEY (role_id) REFERENCES volunteer_role(role_id),
    FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id),
    FOREIGN KEY (task_id) REFERENCES task(task_id));


--Apply five check constraints across the tables to restrict certain values
--Using idempotent script IF NOT EXISTS to avoid duplicates and make the script rerunnable
--Add CHECK constraints to columns start_date(after 2000-01-01) and end_date table campaign
DO $$
DECLARE
    _exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'campaign' AND constraint_name = 'chk_start_date'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Campaign
            ADD CONSTRAINT chk_start_date CHECK (start_date > '2000-01-01'::DATE)$q$;
    END IF;
END $$;

DO $$
DECLARE
    _exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'campaign' AND constraint_name = 'chk_end_date'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Campaign
            ADD CONSTRAINT chk_end_date CHECK (end_date >= start_date)$q$;
    END IF;
END $$;

--Add UNIQUE constraint to column email table voter
DO $$
DECLARE
    _exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'voter' AND constraint_name = 'unique_email'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Voter
            ADD CONSTRAINT unique_email UNIQUE (email)$q$;
    END IF;
END $$;

--Add NOT NULL constraint to column date_of_birth table voter
DO $$
DECLARE
    _is_not_null BOOLEAN;
BEGIN
    SELECT (is_nullable = 'NO')
    FROM information_schema.columns
    WHERE table_schema = 'political_campaign'
      AND table_name = 'voter' AND column_name = 'date_of_birth'
    INTO _is_not_null;
    IF NOT _is_not_null THEN
        EXECUTE $q$ALTER TABLE political_campaign.Voter
            ALTER COLUMN date_of_birth SET NOT NULL$q$;
    END IF;
END $$;


--Add CHECK constraint to column availability(specific value) table volunteer
DO $$
DECLARE
    _exists BOOLEAN;
BEGIN
  SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'volunteer' AND constraint_name = 'chk_availability'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Volunteer
            ADD CONSTRAINT chk_availability CHECK (availability IN
('weekdays', 'weekends', 'weekdays and weekends'))$q$;
    END IF;
END $$;

--Add CHECK constraints to columns c_date (after 2000-01-01) and amount(>0) table contribution 
DO $$
DECLARE
    _exists BOOLEAN;
BEGIN
   SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'contribution' AND constraint_name = 'chk_c_date'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Contribution
            ADD CONSTRAINT chk_c_date CHECK (c_date > '2000-01-01'::DATE)$q$;
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'contribution' AND constraint_name = 'chk_contribution_amount'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Contribution
            ADD CONSTRAINT chk_contribution_amount CHECK (amount > 0)$q$;
    END IF;
END $$;

--Add CHECK constraints to columns s_date (after 2000-01-01) and amount(>0) table spending
DO $$
DECLARE
    _exists BOOLEAN;
BEGIN
     SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'spending' AND constraint_name = 'chk_s_date'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Spending
            ADD CONSTRAINT chk_s_date CHECK (s_date > '2000-01-01'::DATE)$q$;
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'spending' AND constraint_name = 'chk_spending_amount'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Spending
            ADD CONSTRAINT chk_spending_amount CHECK (amount > 0)$q$;
    END IF;
END $$;

--Add CHECK constraint to column e_date(after 2000-01-01) table event
DO $$
DECLARE
    _exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'event' AND constraint_name = 'chk_e_date'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Event
            ADD CONSTRAINT chk_e_date CHECK (e_date > '2000-01-01'::DATE)$q$;
    END IF;
END $$;

--Add CHECK constraint to column s_date(after 2000-01-01) table survey
DO $$
DECLARE
    _exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'survey' AND constraint_name = 'chk_s_date'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Survey
            ADD CONSTRAINT chk_s_date CHECK (s_date > '2000-01-01'::DATE)$q$;
    END IF;
END $$;

--Add CHECK constraint to column response_date(after 2000-01-01) table survey_response
DO $$
DECLARE
    _exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'survey_response' AND constraint_name = 'chk_response_date'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Survey_Response
            ADD CONSTRAINT chk_response_date CHECK (response_date >
'2000-01-01'::DATE)$q$;
    END IF;
END $$;

--Add CHECK constraint to column reported_date(after 2000-01-01) table problem
DO $$
DECLARE
    _exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'political_campaign' 
        AND table_name = 'problem' AND constraint_name = 'chk_reported_date'
    ) INTO _exists;
    IF NOT _exists THEN
        EXECUTE $q$ALTER TABLE political_campaign.Problem
            ADD CONSTRAINT chk_reported_date CHECK (reported_date >
'2000-01-01'::DATE)$q$;
    END IF;
END $$;


/*Add data into each table. Using WHERE NOT EXISTS and ON CONFLICT DO NOTHING to avoid duplicates and make the script rerunnable; 
Using SELECT and dynamic ID's to avoid hard coding;
Using RETURNING for traceability */

BEGIN;
INSERT INTO political_campaign.Campaign (campaign_id, name, start_date, end_date, description)
SELECT * FROM (SELECT 1 AS campaign_id,
		'City mayor' AS name,
		'2025-10-01'::date AS start_date,
		'2025-12-01'::date AS end_date,
		'mayoral campaign' AS description) AS n_cam
WHERE NOT EXISTS (SELECT 1 FROM political_campaign.Campaign cam 
		  WHERE cam.name = n_cam.name)
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.voter (voter_id, campaign_id, first_name, last_name, date_of_birth, email, phone)
SELECT * FROM (SELECT 1 AS voter_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE campaign.name = 'City mayor') AS campaign_id,
		'Ivan' AS first_name,
		'Ivanov' AS last_name,
		'1988-09-11'::date AS date_of_birth,
		'Ivanov@gmail.com' AS email,
		'375293332415' AS phone
		UNION ALL
		SELECT 2 AS voter_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE campaign.name = 'City mayor') AS campaign_id,
		'Petr' AS first_name,
		'Petrov' AS last_name,
		'1994-05-12'::date AS date_of_birth,
		'petrov@gmail.com' AS email,
		'375442232358' AS phone) AS n_vot
WHERE NOT EXISTS (SELECT 1 FROM political_campaign.voter vot 
		  WHERE vot.voter_id = n_vot.voter_id 
		  AND vot.first_name = n_vot.first_name AND vot.last_name = n_vot.last_name)
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.donor (donor_id, name, contact_info)
SELECT * FROM (SELECT 1 AS donor_id,
		'Jane' AS name,
		'Jane1@gmail.com' AS contact_info
		UNION ALL
		SELECT 2 AS donor_id,
		'Bill' AS name,
		'Bill1@gmail.com' AS contact_info
		UNION ALL
		SELECT 3 AS donor_id,
		'Garry' AS name,
		'Garry2@gmail.com' AS contact_info) AS n_don
ON CONFLICT (donor_id) DO NOTHING
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.volunteer (volunteer_id, first_name, last_name, phone, email, availability)
SELECT * FROM (SELECT 1 AS volunteer_id,
		'Tom' AS first_name,
		'Dill' AS last_name,
		'375442992358' AS phone,
		'Tomhj@gmail.com' AS email,
		'weekends' AS availability
		UNION ALL
		SELECT 2 AS volunteer_id,
		'Olga' AS first_name,
		'Nikolova' AS last_name,
		'375294722358' AS phone,
		'Olga9@gmail.com' AS email,
		'weekdays' AS availability
		UNION ALL
		SELECT 3 AS volunteer_id,
		'Anna' AS first_name,
		'Talanova' AS last_name,
		'375442992561' AS phone,
		'Anna99@gmail.com' AS email,
		'weekdays and weekends' AS availability) AS n_vol
WHERE NOT EXISTS (SELECT 1 FROM political_campaign.volunteer vol 
		  WHERE vol.volunteer_id = n_vol.volunteer_id 
		  AND vol.first_name = n_vol.first_name AND vol.last_name = n_vol.last_name)
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.event_type (event_type_id, type_name)
SELECT * FROM (SELECT 1 AS event_type_id,
		'City hall' AS type_name
		UNION ALL
		SELECT 2 AS event_type_id,
		'Rally' AS type_name
		) AS n_event_type
WHERE NOT EXISTS (SELECT 1 FROM political_campaign.event_type ev_tp 
		  WHERE ev_tp.event_type_id = n_event_type.event_type_id 
		  AND ev_tp.type_name = n_event_type.type_name)
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.problem_type (problem_type_id, type_name)
SELECT * FROM (SELECT 1 AS problem_type_id,
		'Logistics' AS type_name
		UNION ALL
		SELECT 2 AS problem_type_id,
		'Technical' AS type_name
		) AS n_pr_type
WHERE NOT EXISTS (SELECT 1 FROM political_campaign.problem_type pr_tp 
		  WHERE pr_tp.problem_type_id = n_pr_type.problem_type_id 
		  AND pr_tp.type_name = n_pr_type.type_name)
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.volunteer_role (role_id, role_name)
SELECT * FROM (SELECT 1 AS role_id,
		'Canvasser' AS role_name
		UNION ALL
		SELECT 2 AS problem_type_id,
		'Event Organizer' AS type_name
		) AS n_v_rol
WHERE NOT EXISTS (SELECT 1 FROM political_campaign.volunteer_role vol_r 
		  WHERE vol_r.role_id = n_v_rol.role_id 
		  AND vol_r.role_name = n_v_rol.role_name)
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.contribution (contribution_id, donor_id, campaign_id, amount, c_date)
SELECT * FROM (SELECT 1 AS contribution_id,
		(SELECT donor_id FROM political_campaign.donor 
		 WHERE LOWER (donor.name) = LOWER ('Jane')) AS donor_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		 500 AS amount,
		'2025-10-11'::date AS c_date
		 UNION ALL
		 SELECT 2 AS contribution_id,
		(SELECT donor_id FROM political_campaign.donor 
		 WHERE LOWER (donor.name) = LOWER ('Bill')) AS donor_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		 1500 AS amount,
		'2025-10-17'::date AS c_date
		 UNION ALL
		 SELECT 3 AS contribution_id,
		(SELECT donor_id FROM political_campaign.donor 
		 WHERE LOWER (donor.name) = LOWER ('Garry')) AS donor_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		 500 AS amount,
		'2025-10-18'::date AS c_date) AS n_contr
ON CONFLICT (contribution_id) DO NOTHING
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.spending (spending_id, campaign_id, type, amount, s_date, description)
SELECT * FROM (SELECT 1 AS spending_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		 'Office rent' AS type,
		 530 AS amount,
		'2025-10-03'::date AS s_date,
		'Monthly rent' AS description
		 UNION ALL
		 SELECT 2 AS spending_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		 'Advertising' AS type,
		 325 AS amount,
		'2025-10-04'::date AS s_date,
		'Flyer printing' AS description
		 UNION ALL
		 SELECT 3 AS spending_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		 'Website Hosting' AS type,
		 120 AS amount,
		'2025-10-04'::date AS s_date,
		'Monthly hosting' AS description) AS n_spend
ON CONFLICT (spending_id) DO NOTHING
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.event (event_id, campaign_id, event_type_id, name, e_date, description)
SELECT * FROM (SELECT 1 AS event_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		 (SELECT event_type_id FROM political_campaign.event_type
		 WHERE LOWER (type_name) = LOWER ('City hall')) AS event_type_id,
		'Q&A city hall' AS name,
		'2025-10-10'::date AS e_date,
		'Q&A with voters' AS description
		 UNION ALL
		 SELECT 2 AS event_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		 (SELECT event_type_id FROM political_campaign.event_type
		 WHERE LOWER (type_name) = LOWER ('Rally')) AS event_type_id,
		'Opening Rally' AS name,
		'2025-10-15'::date AS e_date,
		'Rally in central park' AS description) AS n_event
ON CONFLICT (event_id) DO NOTHING
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.survey (survey_id, campaign_id, name, s_date)
SELECT * FROM (SELECT 1 AS survey_id,
		 (SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		'Voter Issues' AS name,
		'2025-10-07'::date AS s_date
		 UNION ALL
		 SELECT 2 AS survey_id,
		 (SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		'Policy Feedback Survey' AS name,
		'2025-10-25'::date AS s_date
		) AS n_sur
ON CONFLICT (survey_id) DO NOTHING
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.survey_response (response_id, survey_id, voter_id, response_date, response)
SELECT * FROM (SELECT 1 AS response_id,
		 (SELECT survey_id FROM political_campaign.survey 
		 WHERE LOWER (survey.name) = LOWER ('Voter Issues')) AS survey_id,
		 (SELECT voter_id FROM political_campaign.voter 
		 WHERE LOWER (voter.first_name) = LOWER ('Ivan') 
		 AND LOWER (voter.last_name) = LOWER ('Ivanov')) AS voter_id,
		'2025-10-05'::date AS response_date,
		'Support policy' AS response
		 UNION ALL
		 SELECT 2 AS response_id,
		 (SELECT survey_id FROM political_campaign.survey 
		 WHERE LOWER (survey.name) = LOWER ('Voter Issues')) AS survey_id,
		 (SELECT voter_id FROM political_campaign.voter 
		 WHERE LOWER (voter.first_name) = LOWER ('Petr') 
		 AND LOWER (voter.last_name) = LOWER ('Petrov')) AS voter_id,
		'2025-10-05'::date AS response_date,
		'Support policy' AS response
		) AS n_sresp
WHERE NOT EXISTS (SELECT 1 FROM political_campaign.survey_response serr 
		  WHERE serr.voter_id = n_sresp.voter_id 
		  and serr.survey_id = n_sresp.survey_id)
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.task (task_id, name, description)
SELECT * FROM (SELECT 1 AS task_id,
		'Distribute flyers' AS name,
		'Hand out flyers' AS description
		 UNION ALL
		 SELECT 2 AS task_id,
		'Recruit' AS name,
		'Recruit 10 more volunteers' AS description
		 UNION ALL
		 SELECT 3 AS task_id,
		'Organization' AS name,
		'Ensures communication' AS description
		) AS n_sur
ON CONFLICT (task_id) DO NOTHING
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.problem (problem_id, campaign_id, problem_type_id, reported_date, description)
SELECT * FROM (SELECT 1 AS problem_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		(SELECT problem_type_id FROM political_campaign.problem_type 
		 WHERE LOWER (problem_type.type_name) = LOWER ('Logistics')) AS problem_type_id,
		 '2025-10-17'::date AS reported_date,
		 'Venue issue' AS description) AS n_pr
		 ON CONFLICT (problem_id) DO NOTHING;
INSERT INTO political_campaign.problem (problem_id, campaign_id, problem_type_id, reported_date, description, parent_problem_id)
SELECT * FROM (SELECT 2 AS problem_id,
		(SELECT campaign_id FROM political_campaign.campaign 
		 WHERE LOWER (campaign.name) = LOWER ('City mayor')) AS campaign_id,
		(SELECT problem_type_id FROM political_campaign.problem_type 
		 WHERE LOWER (problem_type.type_name) = LOWER ('Technical')) AS problem_type_id,
		 '2025-10-21'::date AS reported_date,
		 'Microphone failure' AS description,
		 (SELECT problem_id FROM political_campaign.problem 
		 WHERE LOWER (problem.description) = LOWER ('Venue issue')) AS parent_problem_id
		) AS n_prob
ON CONFLICT (problem_id) DO NOTHING
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO political_campaign.volunteer_task (volunteer_task_id, volunteer_id, task_id, assigned_date)
SELECT * FROM (SELECT 1 AS volunteer_task_id,
		 (SELECT volunteer_id FROM political_campaign.volunteer 
		 WHERE LOWER (volunteer.first_name) = LOWER ('Olga') 
		 AND LOWER (volunteer.last_name) = LOWER ('Nikolova')) AS volunteer_id,
		 (SELECT task_id FROM political_campaign.task 
		 WHERE LOWER (task.name) = LOWER ('Distribute flyers')) AS task_id,
		'2025-10-05'::date AS assigned_date
		 UNION ALL
		 SELECT 2 AS volunteer_task_id,
		 (SELECT volunteer_id FROM political_campaign.volunteer 
		 WHERE LOWER (volunteer.first_name) = LOWER ('Anna') 
		 AND LOWER (volunteer.last_name) = LOWER ('Talanova')) AS volunteer_id,
		 (SELECT task_id FROM political_campaign.task 
		 WHERE LOWER (task.name) = LOWER ('Recruit')) AS task_id,
		'2025-10-06'::date AS assigned_date
		) AS n_vt
WHERE NOT EXISTS (SELECT 1 FROM political_campaign.volunteer_task vt 
		  WHERE vt.volunteer_id = n_vt.volunteer_id 
		  and vt.task_id = n_vt.task_id)
RETURNING *;
COMMIT;


--Add a not null 'record_ts' field to each table using ALTER TABLE statements, set the default value to current_date
--Using idempotent script IF NOT EXISTS to avoid duplicates and make the script rerunnable

--Add to table campaign
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'campaign'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE campaign ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table campaign';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table campaign';
    END IF;
END $$;

--Add to table voter
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'voter'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE voter ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table voter';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table voter';
    END IF;
END $$;

--Add to table donor
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'donor'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE donor ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table donor';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table donor';
    END IF;
END $$;

--Add to table volunteer
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'volunteer'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE volunteer ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table volunteer';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table volunteer';
    END IF;
END $$;

--Add to table event_type
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'event_type'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE event_type ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table event_type';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table event_type';
    END IF;
END $$;

--Add to table problem_type
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'problem_type'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE problem_type ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table problem_type';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table problem_type';
    END IF;
END $$;

--Add to table volunteer_role
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'volunteer_role'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE volunteer_role ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table volunteer_role';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table volunteer_role';
    END IF;
END $$;

--Add to table contribution
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'contribution'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE contribution ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table contribution';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table contribution';
    END IF;
END $$;

--Add to table spending
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'spending'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE spending ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table spending';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table spending';
    END IF;
END $$;

--Add to table event
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'event'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE event ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table event';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table event';
    END IF;
END $$;

--Add to table survey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'survey'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE survey ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table survey';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table survey';
    END IF;
END $$; 

--Add to table survey_response
 DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'survey_response'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE survey_response ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table survey_response';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table survey_response';
    END IF;
END $$;

--Add to table problem
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'problem'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE problem ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table problem';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table problem';
    END IF;
END $$;

--Add to table task
    DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'task'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE task ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table task';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table task';
    END IF;
END $$;

--Add to table volunteer_task
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'volunteer_task'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE volunteer_task ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table volunteer_task';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table volunteer_task';
    END IF;
END $$; 

--Add to table volunteer_assignment
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema() 
          AND table_name = 'volunteer_assignment'
          AND column_name = 'record_ts'
    ) THEN
        ALTER TABLE volunteer_assignment ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Column record_ts added to table volunteer_assignment';
    ELSE
        RAISE NOTICE 'Column record_ts already exists in table volunteer_assignment';
    END IF;
END $$;





