-- Summary KPI

/* How many loans are in the portfolio
- What is the total loan amount?
- What is the average loan amount?
- What is the average loan interest rate?
- How many loans defaulted?
- What is the overall default rate
- How much loan amount is tied to defaulted loans?
*/
SELECT * FROM credit_risk_features
LIMIT 3;

SELECT
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_amnt,
    AVG(loan_amnt) AS avg_amnt,
    AVG(loan_int_rate) AS avg_int_rate,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100 * AVG(loan_status), 2) AS default_rate_pct,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_amnt
FROM credit_risk_features;

