-- Feature Engineering
SELECT * FROM credit_risk_dataset
LIMIT 1;

SELECT MIN(person_income) as min_income,
       PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY person_income) AS p25,
       PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY person_income) AS median,
       PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY person_income) AS p75,
       PERCENTILE_CONT(0.9) WITHIN GROUP(ORDER BY person_income) AS p90,
       MAX(person_income) as max_income
FROM credit_risk_dataset;

SELECT MIN(loan_amnt) as min_loan,
       PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY loan_amnt) AS p25,
       PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY loan_amnt) AS median,
       PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY loan_amnt) AS p75,
       PERCENTILE_CONT(0.9) WITHIN GROUP(ORDER BY loan_amnt) AS p90,
       MAX(loan_amnt) as max_loan
FROM credit_risk_dataset;

SELECT min(cb_person_cred_hist_length) AS min_hist,
       PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY cb_person_cred_hist_length) AS p25,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cb_person_cred_hist_length) AS median,
       PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cb_person_cred_hist_length) AS p75,
       PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY cb_person_cred_hist_length) AS p90,
       MAX(cb_person_cred_hist_length) AS max_hist
FROM credit_risk_dataset;

SELECT DISTINCT loan_int_rate FROM credit_risk_dataset ORDER BY loan_int_rate DESC;


-- Create View
CREATE OR REPLACE VIEW public.credit_risk_features AS
    SELECT
        *,
        CASE
            WHEN person_age < 25 THEN '18-24'
            WHEN person_age < 35 THEN '25-34'
            WHEN person_age < 45 THEN '35-44'
            WHEN person_age < 55 THEN '45-54'
            ELSE '55+'
        END AS age_band,

        CASE
            WHEN person_income < 30000 THEN '<30k'
            WHEN person_income < 50000 THEN '30k-50k'
            WHEN person_income < 80000 THEN '50k-80k'
            WHEN person_income < 120000 THEN '80k-120k'
            ELSE '>120k'
        END AS income_band,

        CASE
            WHEN person_emp_length IS NULL THEN 'Unknown'
            WHEN person_emp_length < 2 THEN '1-2 years'
            WHEN person_emp_length < 3 THEN '2-3 years'
            WHEN person_emp_length < 5 THEN '3-5 years'
            WHEN person_emp_length < 12 THEN '5-12 years'
            ELSE '>12 years'
        END AS employment_band,

        CASE
            WHEN loan_amnt < 5000 THEN '<5k'
            WHEN loan_amnt < 8000 THEN '5k-8k'
            WHEN loan_amnt < 12000 THEN '8k-12k'
            WHEN loan_amnt < 15000 THEN '12k-15k'
            ELSE '>15k'
        END AS loan_band,

        CASE
            WHEN loan_percent_income < 0.1 THEN 'Very Low Burden'
            WHEN loan_percent_income < 0.2 THEN 'Low Burden'
            WHEN loan_percent_income < 0.3 THEN 'Medium Burden'
            WHEN loan_percent_income < 0.5 THEN 'High Burden'
            ELSE 'Severe Burden'
        END AS affordability_band,

        CASE
            WHEN cb_person_cred_hist_length < 3 THEN 'Thin File'
            WHEN cb_person_cred_hist_length < 7 THEN 'Moderate history'
            ELSE 'Established history'
        END AS credit_history_band,

        CASE
            WHEN loan_int_rate IS NULL THEN 'Unknown'
            WHEN loan_int_rate < 8 THEN 'Low Rate'
            WHEN loan_int_rate < 13 THEN 'Medium Rate'
            WHEN loan_int_rate < 18 THEN 'High Rate'
            ELSE 'Very High Rate'
        END AS interest_band,

        CASE
            WHEN loan_grade = 'A' THEN 1
            WHEN loan_grade = 'B' THEN 2
            WHEN loan_grade = 'C' THEN 3
            WHEN loan_grade = 'D' THEN 4
            WHEN loan_grade = 'E' THEN 5
            WHEN loan_grade = 'F' THEN 6
            WHEN loan_grade = 'G' THEN 7
            ELSE NULL
        END AS loan_grade_score

FROM credit_risk_dataset;

-- validate
SELECT *
FROM credit_risk_features
LIMIT 20;