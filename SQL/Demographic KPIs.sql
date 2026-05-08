-- Demographic KPIs

/*
- Which age band is the most likely to default
- Default risk by affordability burden
- Highest default rate segment
- Highest default exposure segment
- Most meaningful borrower risk driver
 */

-- Overall portfolio default benchmark
SELECT
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * AVG(loan_status), 2) AS portfolio_default_rate_pct,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features;

-- Default risk by age band
SELECT
    age_band,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS portfolio_share_pct,
    ROUND(100.0 * AVG(loan_status), 2) AS default_rate_pct,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features
GROUP BY age_band
ORDER BY default_rate_pct DESC;

-- Default risk by affordability burden
SELECT
    affordability_band,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS portfolio_share_pct,
    ROUND(AVG(loan_percent_income), 3) AS avg_loan_percent_income,
    ROUND(100.0 * AVG(loan_status), 2) AS default_rate_pct,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features
GROUP BY affordability_band
ORDER BY default_rate_pct DESC;

-- Default risk by home ownership
SELECT
    person_home_ownership,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS portfolio_share_pct,
    ROUND(AVG(person_income), 2) AS avg_income,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount,
    ROUND(100.0 * AVG(loan_status), 2) AS default_rate_pct,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features
GROUP BY person_home_ownership
ORDER BY default_rate_pct DESC;

-- Default risk by income band
SELECT
    income_band,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS portfolio_share_pct,
    ROUND(AVG(person_income), 2) AS avg_income,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount,
    ROUND(AVG(loan_percent_income), 3) AS avg_loan_percent_income,
    ROUND(100.0 * AVG(loan_status), 2) AS default_rate_pct,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features
GROUP BY income_band
ORDER BY default_rate_pct DESC;

-- Default risk by employment length band
SELECT
    employment_band,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS portfolio_share_pct,
    ROUND(AVG(person_emp_length), 2) AS avg_employment_length,
    ROUND(AVG(person_income), 2) AS avg_income,
    ROUND(100.0 * AVG(loan_status), 2) AS default_rate_pct,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features
GROUP BY employment_band
ORDER BY default_rate_pct DESC;

-- Default risk by credit history length
SELECT
    credit_history_band,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS portfolio_share_pct,
    ROUND(AVG(cb_person_cred_hist_length), 2) AS avg_credit_history_length,
    ROUND(100.0 * AVG(loan_status), 2) AS default_rate_pct,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features
GROUP BY credit_history_band
ORDER BY default_rate_pct DESC;

-- Default risk by previous default history
SELECT
    cb_person_default_on_file,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS portfolio_share_pct,
    ROUND(AVG(loan_int_rate), 2) AS avg_interest_rate,
    ROUND(100.0 * AVG(loan_status), 2) AS default_rate_pct,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features
GROUP BY cb_person_default_on_file
ORDER BY default_rate_pct DESC;

-- Default risk by age and income band
SELECT
    age_band,
    income_band,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * AVG(loan_status), 2) AS default_rate_pct,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features
GROUP BY age_band, income_band
HAVING COUNT(*) >= 50
ORDER BY default_rate_pct DESC;



-- Highest-risk borrower segments
SELECT
    age_band,
    income_band,
    employment_band,
    person_home_ownership,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * AVG(loan_status), 2) AS default_rate_pct,
    ROUND(AVG(loan_percent_income), 3) AS avg_loan_percent_income,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features
GROUP BY
    age_band,
    income_band,
    employment_band,
    person_home_ownership
HAVING COUNT(*) >= 50
ORDER BY default_rate_pct DESC
LIMIT 20;

-- Segments contributing the most defaulted exposure
SELECT
    age_band,
    income_band,
    affordability_band,
    person_home_ownership,
    COUNT(*) AS total_loans,
    ROUND(100.0 * AVG(loan_status), 2) AS default_rate_pct,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure
FROM public.credit_risk_features
GROUP BY
    age_band,
    income_band,
    affordability_band,
    person_home_ownership
HAVING COUNT(*) >= 50
ORDER BY defaulted_exposure DESC
LIMIT 20;