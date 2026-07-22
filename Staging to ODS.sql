CREATE OR REPLACE SCHEMA ODS;

CREATE OR REPLACE TABLE ODS.BUSINESS (
  business_id VARCHAR PRIMARY KEY, name VARCHAR, city VARCHAR, state VARCHAR,
  latitude FLOAT, longitude FLOAT, stars FLOAT, review_count NUMBER,
  is_open BOOLEAN, categories VARCHAR
);

INSERT INTO ODS.BUSINESS
SELECT raw_data:business_id::VARCHAR, raw_data:name::VARCHAR,
       raw_data:city::VARCHAR, raw_data:state::VARCHAR,
       raw_data:latitude::FLOAT, raw_data:longitude::FLOAT,
       raw_data:stars::FLOAT, raw_data:review_count::NUMBER,
       (raw_data:is_open::NUMBER = 1)::BOOLEAN, raw_data:categories::VARCHAR
FROM STAGING.RAW_BUSINESS;

CREATE OR REPLACE TABLE ODS.CUSTOMER (
  customer_id VARCHAR PRIMARY KEY, name VARCHAR, review_count NUMBER,
  yelping_since TIMESTAMP_NTZ, average_stars FLOAT, fans NUMBER
  -- 'friends' and 'elite' excluded: irrelevant social-graph fields
);

INSERT INTO ODS.CUSTOMER
SELECT raw_data:user_id::VARCHAR, raw_data:name::VARCHAR,
       raw_data:review_count::NUMBER, raw_data:yelping_since::TIMESTAMP_NTZ,
       raw_data:average_stars::FLOAT, raw_data:fans::NUMBER
FROM STAGING.RAW_USER;


CREATE OR REPLACE TABLE ODS.REVIEW (
  review_id VARCHAR PRIMARY KEY, business_id VARCHAR, customer_id VARCHAR,
  stars NUMBER(2,1), useful NUMBER, funny NUMBER, cool NUMBER,
  review_ts TIMESTAMP_NTZ, review_date DATE
);

INSERT INTO ODS.REVIEW
SELECT raw_data:review_id::VARCHAR, raw_data:business_id::VARCHAR,
       raw_data:user_id::VARCHAR, raw_data:stars::NUMBER(2,1),
       raw_data:useful::NUMBER, raw_data:funny::NUMBER, raw_data:cool::NUMBER,
       raw_data:date::TIMESTAMP_NTZ, raw_data:date::DATE
FROM STAGING.RAW_REVIEW;


CREATE OR REPLACE TABLE ODS.TIPS (
  business_id VARCHAR, customer_id VARCHAR, tip_text VARCHAR,
  tip_ts TIMESTAMP_NTZ, tip_date DATE, compliment_count NUMBER
);

INSERT INTO ODS.TIPS
SELECT raw_data:business_id::VARCHAR, raw_data:user_id::VARCHAR,
       raw_data:text::VARCHAR, raw_data:date::TIMESTAMP_NTZ,
       raw_data:date::DATE, raw_data:compliment_count::NUMBER
FROM STAGING.RAW_TIP;


CREATE OR REPLACE TABLE ODS.CHECK_IN (
  business_id VARCHAR, checkin_ts TIMESTAMP_NTZ, checkin_date DATE
);


INSERT INTO ODS.CHECK_IN
SELECT raw_data:business_id::VARCHAR, TRIM(c.value)::TIMESTAMP_NTZ, TRIM(c.value)::DATE
FROM STAGING.RAW_CHECKIN, LATERAL SPLIT_TO_TABLE(raw_data:date::VARCHAR, ',') c;


CREATE OR REPLACE TABLE ODS.COVID (
  business_id VARCHAR PRIMARY KEY, delivery_or_takeout BOOLEAN,
  grubhub_enabled BOOLEAN, covid_banner BOOLEAN, virtual_services BOOLEAN
);

INSERT INTO ODS.COVID
SELECT raw_data:business_id::VARCHAR,
       (raw_data:"delivery or takeout"::VARCHAR = 'TRUE'),
       (raw_data:"Grubhub enabled"::VARCHAR = 'TRUE'),
       (raw_data:"Covid Banner"::VARCHAR = 'TRUE'),
       (raw_data:"Virtual Services Offered"::VARCHAR = 'TRUE')
FROM STAGING.RAW_COVID;

CREATE OR REPLACE TABLE ODS.TEMPERATURE (
  weather_date DATE PRIMARY KEY, temp_min FLOAT, temp_max FLOAT,
  normal_min FLOAT, normal_max FLOAT
);

INSERT INTO ODS.TEMPERATURE
SELECT TO_DATE(date_id, 'YYYYMMDD'),
       TRY_TO_DECIMAL(temp_min, 10, 2), TRY_TO_DECIMAL(temp_max, 10, 2),
       TRY_TO_DECIMAL(normal_min, 10, 2), TRY_TO_DECIMAL(normal_max, 10, 2)
FROM STAGING.RAW_TEMPERATURE;


CREATE OR REPLACE TABLE ODS.PRECIPITATION (
  weather_date DATE PRIMARY KEY, precipitation FLOAT,
  precipitation_normal FLOAT, is_trace_precip BOOLEAN
);


INSERT INTO ODS.PRECIPITATION
SELECT TO_DATE(date_id, 'YYYYMMDD'),
       CASE WHEN precipitation = 'T' THEN 0.005 ELSE TRY_TO_DECIMAL(precipitation, 10, 3) END,
       TRY_TO_DECIMAL(precipitation_normal, 10, 3),
       (precipitation = 'T')
FROM STAGING.RAW_PRECIPITATION;

-- ##  B.4 — SQL QUERIES USING JSON FUNCTIONS ##

SELECT
  PARSE_JSON(raw_data):business_id::VARCHAR  AS business_id,
  PARSE_JSON(raw_data):name::VARCHAR          AS name,
  PARSE_JSON(raw_data):city::VARCHAR          AS city,
  PARSE_JSON(raw_data):attributes:"ByAppointmentOnly"::VARCHAR AS by_appointment_only, -- nested object path
  f.value::VARCHAR                              AS category                              -- FLATTEN explodes comma list
FROM STAGING.RAW_BUSINESS,
     LATERAL FLATTEN(INPUT => SPLIT(raw_data:categories::VARCHAR, ', ')) f
LIMIT 100;


CREATE OR REPLACE VIEW ODS.REVIEW_WEATHER_INTEGRATED AS
SELECT
  r.review_id, r.business_id, r.customer_id, r.stars, r.review_date,
  t.temp_min, t.temp_max, p.precipitation
FROM ODS.REVIEW r
JOIN ODS.TEMPERATURE t   ON r.review_date = t.weather_date
JOIN ODS.PRECIPITATION p ON r.review_date = p.weather_date;
 
SELECT * FROM ODS.REVIEW_WEATHER_INTEGRATED LIMIT 100;

-- Raw / staging / ODS size comparison (for the 3-column screenshot)

SELECT table_schema, table_name, row_count,
       ROUND(bytes / POWER(1024,2), 2) AS size_mb
FROM INFORMATION_SCHEMA.TABLES
WHERE table_catalog = 'UDACITYPROJECT'
  AND table_schema IN ('STAGING', 'ODS')
ORDER BY table_schema, table_name;


INSERT INTO ODS.BUSINESS
SELECT raw_data:business_id::VARCHAR, raw_data:name::VARCHAR,
       raw_data:city::VARCHAR, raw_data:state::VARCHAR,
       raw_data:latitude::FLOAT, raw_data:longitude::FLOAT,
       raw_data:stars::FLOAT, raw_data:review_count::NUMBER,
       (raw_data:is_open::NUMBER = 1)::BOOLEAN, raw_data:categories::VARCHAR
FROM STAGING.RAW_BUSINESS;
 
INSERT INTO ODS.CUSTOMER
SELECT raw_data:user_id::VARCHAR, raw_data:name::VARCHAR,
       raw_data:review_count::NUMBER, raw_data:yelping_since::TIMESTAMP_NTZ,
       raw_data:average_stars::FLOAT, raw_data:fans::NUMBER
FROM STAGING.RAW_USER;
 
INSERT INTO ODS.REVIEW
SELECT raw_data:review_id::VARCHAR, raw_data:business_id::VARCHAR,
       raw_data:user_id::VARCHAR, raw_data:stars::NUMBER(2,1),
       raw_data:useful::NUMBER, raw_data:funny::NUMBER, raw_data:cool::NUMBER,
       raw_data:date::TIMESTAMP_NTZ, raw_data:date::DATE
FROM STAGING.RAW_REVIEW;
 
INSERT INTO ODS.TIPS
SELECT raw_data:business_id::VARCHAR, raw_data:user_id::VARCHAR,
       raw_data:text::VARCHAR, raw_data:date::TIMESTAMP_NTZ,
       raw_data:date::DATE, raw_data:compliment_count::NUMBER
FROM STAGING.RAW_TIP;
 
-- explode the comma-delimited checkin timestamp list into one row per event
INSERT INTO ODS.CHECK_IN
SELECT raw_data:business_id::VARCHAR, TRIM(c.value)::TIMESTAMP_NTZ, TRIM(c.value)::DATE
FROM STAGING.RAW_CHECKIN, LATERAL SPLIT_TO_TABLE(raw_data:date::VARCHAR, ',') c;
 
-- COVID fields use spaces in their JSON keys and string "TRUE"/"FALSE" values
INSERT INTO ODS.COVID
SELECT raw_data:business_id::VARCHAR,
       (raw_data:"delivery or takeout"::VARCHAR = 'TRUE'),
       (raw_data:"Grubhub enabled"::VARCHAR = 'TRUE'),
       (raw_data:"Covid Banner"::VARCHAR = 'TRUE'),
       (raw_data:"Virtual Services Offered"::VARCHAR = 'TRUE')
FROM STAGING.RAW_COVID;
 
INSERT INTO ODS.TEMPERATURE
SELECT TO_DATE(date_id, 'YYYYMMDD'),
       TRY_TO_DECIMAL(temp_min, 10, 2), TRY_TO_DECIMAL(temp_max, 10, 2),
       TRY_TO_DECIMAL(normal_min, 10, 2), TRY_TO_DECIMAL(normal_max, 10, 2)
FROM STAGING.RAW_TEMPERATURE;
 
INSERT INTO ODS.PRECIPITATION
SELECT TO_DATE(date_id, 'YYYYMMDD'),
       CASE WHEN precipitation = 'T' THEN 0.005 ELSE TRY_TO_DECIMAL(precipitation, 10, 3) END,
       TRY_TO_DECIMAL(precipitation_normal, 10, 3),
       (precipitation = 'T')
FROM STAGING.RAW_PRECIPITATION;
