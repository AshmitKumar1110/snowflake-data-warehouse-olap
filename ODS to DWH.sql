CREATE OR REPLACE SCHEMA DWH;


CREATE OR REPLACE TABLE DWH.DIM_DATE (
  date_key NUMBER PRIMARY KEY, full_date DATE, year NUMBER, month NUMBER,
  day_of_week NUMBER, day_name VARCHAR, is_weekend BOOLEAN
);

INSERT INTO DWH.DIM_DATE
SELECT DISTINCT TO_NUMBER(TO_CHAR(review_date, 'YYYYMMDD')), review_date,
       YEAR(review_date), MONTH(review_date), DAYOFWEEK(review_date),
       DAYNAME(review_date), DAYOFWEEK(review_date) IN (0,6)
FROM ODS.REVIEW WHERE review_date IS NOT NULL;


--business
CREATE OR REPLACE TABLE DWH.DIM_BUSINESS (
  business_key NUMBER AUTOINCREMENT PRIMARY KEY, business_id VARCHAR,
  name VARCHAR, city VARCHAR, state VARCHAR, category VARCHAR, avg_stars FLOAT
);

INSERT INTO DWH.DIM_BUSINESS (business_id, name, city, state, category, avg_stars)
SELECT business_id, name, city, state, categories, stars FROM ODS.BUSINESS;


--customer
CREATE OR REPLACE TABLE DWH.DIM_CUSTOMER (
  customer_key NUMBER AUTOINCREMENT PRIMARY KEY, customer_id VARCHAR,
  review_count NUMBER, average_stars FLOAT
);

INSERT INTO DWH.DIM_CUSTOMER (customer_id, review_count, average_stars)
SELECT customer_id, review_count, average_stars FROM ODS.CUSTOMER;


--temperature
CREATE OR REPLACE TABLE DWH.DIM_TEMPERATURE (
  temperature_key NUMBER AUTOINCREMENT PRIMARY KEY, weather_date DATE,
  temp_min FLOAT, temp_max FLOAT, temp_bucket VARCHAR
);

INSERT INTO DWH.DIM_TEMPERATURE (weather_date, temp_min, temp_max, temp_bucket)
SELECT weather_date, temp_min, temp_max,
       CASE WHEN temp_max < 50 THEN 'Cold' WHEN temp_max < 80 THEN 'Mild' ELSE 'Hot' END
FROM ODS.TEMPERATURE;


--PRECIPITATION 
CREATE OR REPLACE TABLE DWH.DIM_PRECIPITATION (
  precipitation_key NUMBER AUTOINCREMENT PRIMARY KEY, weather_date DATE,
  precipitation FLOAT, precip_bucket VARCHAR
  );

INSERT INTO DWH.DIM_PRECIPITATION (weather_date, precipitation, precip_bucket)
SELECT weather_date, precipitation,
       CASE WHEN precipitation = 0 THEN 'None' WHEN precipitation < 0.1 THEN 'Light' ELSE 'Heavy' END
FROM ODS.PRECIPITATION;


--FACT_REVIEW
CREATE OR REPLACE TABLE DWH.FACT_REVIEW (
  review_key NUMBER AUTOINCREMENT PRIMARY KEY, review_id VARCHAR,
  date_key NUMBER, business_key NUMBER, customer_key NUMBER,
  temperature_key NUMBER, precipitation_key NUMBER,
  stars NUMBER(2,1), useful NUMBER
);

INSERT INTO DWH.FACT_REVIEW (review_id, date_key, business_key, customer_key,
                              temperature_key, precipitation_key, stars, useful)
SELECT r.review_id, TO_NUMBER(TO_CHAR(r.review_date,'YYYYMMDD')),
       b.business_key, c.customer_key, t.temperature_key, p.precipitation_key,
       r.stars, r.useful
FROM ODS.REVIEW r
LEFT JOIN DWH.DIM_BUSINESS b      ON r.business_id = b.business_id
LEFT JOIN DWH.DIM_CUSTOMER c      ON r.customer_id = c.customer_id
LEFT JOIN DWH.DIM_TEMPERATURE t   ON r.review_date  = t.weather_date
LEFT JOIN DWH.DIM_PRECIPITATION p ON r.review_date  = p.weather_date;

-- C.4 — SQL QUERIES: REPORT (business name, temperature,            ##
-- ##         precipitation, ratings)  
SELECT
  b.name                AS business_name,
  t.temp_max             AS temperature_max,
  p.precipitation         AS precipitation_inches,
  AVG(f.stars)            AS avg_rating,
  COUNT(*)                 AS review_count
FROM DWH.FACT_REVIEW f
JOIN DWH.DIM_BUSINESS b      ON f.business_key = b.business_key
JOIN DWH.DIM_TEMPERATURE t   ON f.temperature_key = t.temperature_key
JOIN DWH.DIM_PRECIPITATION p ON f.precipitation_key = p.precipitation_key
GROUP BY b.name, t.temp_max, p.precipitation
ORDER BY avg_rating DESC;



