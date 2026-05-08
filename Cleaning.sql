-- Create Table
CREATE TABLE public.credit_risk_dataset(
    person_age INTEGER,
    person_income NUMERIC,
    person_home_ownership TEXT,
    person_emp_length NUMERIC,
    loan_intent TEXT,
    loan_grade TEXT,
    loan_amnt NUMERIC,
    loan_int_rate NUMERIC,
    loan_status INTEGER,
    loan_percent_income NUMERIC,
    cb_person_default_on_file TEXT,
    cb_person_cred_hist_length INTEGER
);

-- Check data types
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'credit_risk_dataset';

SELECT * FROM credit_risk_dataset
LIMIT 10;

/*
-- Changing data type
ALTER TABLE credit_risk_dataset
ALTER COLUMN person_income TYPE NUMERIC
USING person_income::numeric;

ALTER TABLE credit_risk_dataset
ALTER COLUMN loan_int_rate TYPE NUMERIC
USING loan_int_rate::numeric;

ALTER TABLE credit_risk_dataset
ALTER COLUMN loan_status TYPE INTEGER
USING loan_status::integer;

ALTER TABLE credit_risk_dataset
ALTER COLUMN loan_percent_income TYPE NUMERIC
USING loan_status::numeric;

ALTER TABLE credit_risk_dataset
ALTER COLUMN cb_person_cred_hist_length TYPE INTEGER
USING loan_status::integer;

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'credit_risk_dataset';

 */

-- checking missing data

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(person_age) AS missing_age,
    COUNT(*) - COUNT(person_income) AS missing_income,
    COUNT(*) - COUNT(person_home_ownership) AS person_home_ownership,
    COUNT(*) - COUNT(person_emp_length) AS missing_emp_length,
    COUNT(*) - COUNT(loan_intent) AS missing_intent,
    COUNT(*) - COUNT(loan_grade) AS missing_grade,
    COUNT(*) - COUNT(loan_amnt) AS missing_loan_amnt,
    COUNT(*) - COUNT(loan_int_rate) AS missing_int_rate,
    COUNT(*) - COUNT(loan_status) AS missing_loan_status,
    COUNT(*) - COUNT(loan_percent_income) AS missing_loan_percent,
    COUNT(*) - COUNT(cb_person_default_on_file) AS missing_default,
    COUNT(*) - COUNT(cb_person_cred_hist_length) AS missing_cred_hist
FROM credit_risk_dataset;

-- checking bad values
SELECT * FROM credit_risk_dataset
WHERE person_age <= 0
OR person_income <= 0
OR loan_amnt <= 0
OR loan_int_rate <= 0
OR loan_percent_income <= 0;

-- age
SELECT * FROM credit_risk_dataset
WHERE person_age >=80;

SELECT MIN(person_age) AS min_age,
MAX(person_age) AS max_age,
AVG(person_age) AS avg_age
FROM credit_risk_dataset;

-- changing the age of people > 100
BEGIN;

UPDATE credit_risk_dataset
SET person_age = person_age - 100
WHERE person_age > 100;

SELECT *
FROM credit_risk_dataset
WHERE person_age >= 100;

COMMIT;

-- Emp_length
SELECT MAX(person_emp_length),
       MIN(person_emp_length),
       AVG(person_emp_length)
FROM credit_risk_dataset;

SELECT DISTINCT person_emp_length
FROM credit_risk_dataset;

-- Imputing emp length

BEGIN;

UPDATE credit_risk_dataset
SET person_emp_length = 5
WHERE person_emp_length = 123;

COMMIT;



