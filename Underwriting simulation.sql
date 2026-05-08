-- Simulation

/*
   07_underwriting_simulation.sql

   Project: Credit Risk Portfolio Analysis
   Purpose:
   Simulate underwriting policy rules to classify loans into:
   - Approve
   - Manual Review
   - Reject

   The goal is to evaluate whether simple risk-based rules can
   separate higher-risk loans from lower-risk loans.
 */

-- 1. Create underwriting policy view with decision and reason

CREATE OR REPLACE VIEW public.credit_risk_underwriting AS
SELECT
    *,

    CASE
        /* Reject rules: high-risk applications */
        WHEN affordability_band = 'Severe Burden'
            THEN 'Severe Affordability Burden'

        WHEN loan_grade IN ('F', 'G')
            THEN 'Very Weak Loan Grade'

        WHEN loan_grade IN ('D', 'E')
             AND affordability_band IN ('High Burden', 'Severe Burden')
            THEN 'Weak Grade + High Burden'

        /* Manual review rules: moderate-risk applications */
        WHEN cb_person_default_on_file = 'Y'
             AND loan_grade IN ('C', 'D', 'E', 'F', 'G')
            THEN 'Prior Default + Weak Grade'

        WHEN credit_history_band = 'Thin File'
             AND employment_band IN ('<1 year', '1-2 years')
            THEN 'Thin Credit File + Short Employment'

        WHEN affordability_band = 'High Burden'
             AND income_band IN ('<30k', '30k-50k')
            THEN 'High Burden + Lower Income'

        /* Otherwise no risk trigger */
        ELSE 'No Risk Trigger'
    END AS underwriting_reason,


    CASE
        /* Reject rules */
        WHEN affordability_band = 'Severe Burden'
            THEN 'Reject'

        WHEN loan_grade IN ('F', 'G')
            THEN 'Reject'

        WHEN loan_grade IN ('D', 'E')
             AND affordability_band IN ('High Burden', 'Severe Burden')
            THEN 'Reject'

        /* Manual review rules */
        WHEN cb_person_default_on_file = 'Y'
             AND loan_grade IN ('C', 'D', 'E', 'F', 'G')
            THEN 'Manual Review'

        WHEN credit_history_band = 'Thin File'
             AND employment_band IN ('<1 year', '1-2 years')
            THEN 'Manual Review'

        WHEN affordability_band = 'High Burden'
             AND income_band IN ('<30k', '30k-50k')
            THEN 'Manual Review'

        /* Otherwise approve */
        ELSE 'Approve'
    END AS underwriting_decision

FROM public.credit_risk_features;


-- 2. Main underwriting simulation summary

SELECT
    underwriting_decision,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS portfolio_share_pct,

    ROUND(
        100.0 * AVG(loan_status),
        2
    ) AS default_rate_pct,

    SUM(loan_amnt) AS total_exposure,

    SUM(
        CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END
    ) AS defaulted_exposure,

    ROUND(AVG(loan_int_rate), 2) AS avg_interest_rate,
    ROUND(AVG(loan_grade_score), 2) AS avg_loan_grade_score

FROM public.credit_risk_underwriting
GROUP BY underwriting_decision
ORDER BY default_rate_pct DESC;


-- 3. Underwriting reason summary. Shows which specific rule captured the most risk

SELECT
    underwriting_decision,
    underwriting_reason,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS portfolio_share_pct,

    ROUND(
        100.0 * AVG(loan_status),
        2
    ) AS default_rate_pct,

    SUM(loan_amnt) AS total_exposure,

    SUM(
        CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END
    ) AS defaulted_exposure

FROM public.credit_risk_underwriting
GROUP BY underwriting_decision, underwriting_reason
ORDER BY default_rate_pct DESC;


-- 4. Share of defaulted exposure captured by decision group

WITH total_default_exposure AS (
    SELECT
        SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS portfolio_defaulted_exposure
    FROM public.credit_risk_underwriting
)

SELECT
    underwriting_decision,

    SUM(
        CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END
    ) AS defaulted_exposure,

    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END)
        / NULLIF((SELECT portfolio_defaulted_exposure FROM total_default_exposure), 0),
        2
    ) AS share_of_defaulted_exposure_pct

FROM public.credit_risk_underwriting
GROUP BY underwriting_decision
ORDER BY defaulted_exposure DESC;


-- 5. Approval volume vs risk trade-off, Shows business impact of each underwriting decision group

SELECT
    underwriting_decision,
    COUNT(*) AS total_loans,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS loan_count_share_pct,

    SUM(loan_amnt) AS total_exposure,

    ROUND(
        100.0 * SUM(loan_amnt) / SUM(SUM(loan_amnt)) OVER (),
        2
    ) AS exposure_share_pct,

    ROUND(
        100.0 * AVG(loan_status),
        2
    ) AS default_rate_pct,

    SUM(
        CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END
    ) AS defaulted_exposure

FROM public.credit_risk_underwriting
GROUP BY underwriting_decision
ORDER BY
    CASE
        WHEN underwriting_decision = 'Reject' THEN 1
        WHEN underwriting_decision = 'Manual Review' THEN 2
        WHEN underwriting_decision = 'Approve' THEN 3
        ELSE 4
    END;


/* 6. Policy scenario simulation
   Creates three policy options:
   - Lenient Policy
   - Balanced Policy
   - Strict Policy
 */

CREATE OR REPLACE VIEW public.credit_risk_policy_scenarios AS
SELECT
    *,
    CASE
        WHEN affordability_band = 'Severe Burden'
          OR loan_grade IN ('F', 'G')
        THEN 'Reject'
        ELSE 'Approve'
    END AS lenient_policy,


    CASE
        WHEN affordability_band = 'Severe Burden'
          OR loan_grade IN ('F', 'G')
          OR (
                loan_grade IN ('D', 'E')
                AND affordability_band = 'High Burden'
             )
        THEN 'Reject'

        WHEN cb_person_default_on_file = 'Y'
          OR (
                credit_history_band = 'Thin File'
                AND employment_band IN ('<1 year', '1-2 years')
             )
        THEN 'Manual Review'

        ELSE 'Approve'
    END AS balanced_policy,


    CASE
        WHEN affordability_band IN ('High Burden', 'Severe Burden')
          OR loan_grade IN ('E', 'F', 'G')
          OR cb_person_default_on_file = 'Y'
        THEN 'Reject'

        WHEN loan_grade = 'D'
          OR credit_history_band = 'Thin File'
        THEN 'Manual Review'

        ELSE 'Approve'
    END AS strict_policy

FROM public.credit_risk_features;


/* 7. Final policy comparison table
   Compares lenient, balanced, and strict policies
 */

WITH policy_results AS (

    SELECT
        'Lenient Policy' AS policy_name,
        lenient_policy AS decision,
        COUNT(*) AS total_loans,
        SUM(loan_amnt) AS total_exposure,
        SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
        SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure,
        AVG(loan_status) AS default_rate
    FROM public.credit_risk_policy_scenarios
    GROUP BY lenient_policy

    UNION ALL

    SELECT
        'Balanced Policy' AS policy_name,
        balanced_policy AS decision,
        COUNT(*) AS total_loans,
        SUM(loan_amnt) AS total_exposure,
        SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
        SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure,
        AVG(loan_status) AS default_rate
    FROM public.credit_risk_policy_scenarios
    GROUP BY balanced_policy

    UNION ALL

    SELECT
        'Strict Policy' AS policy_name,
        strict_policy AS decision,
        COUNT(*) AS total_loans,
        SUM(loan_amnt) AS total_exposure,
        SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
        SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS defaulted_exposure,
        AVG(loan_status) AS default_rate
    FROM public.credit_risk_policy_scenarios
    GROUP BY strict_policy
)

SELECT
    policy_name,
    decision,
    total_loans,

    ROUND(
        100.0 * total_loans / SUM(total_loans) OVER (PARTITION BY policy_name),
        2
    ) AS loan_share_pct,

    total_exposure,

    ROUND(
        100.0 * total_exposure / SUM(total_exposure) OVER (PARTITION BY policy_name),
        2
    ) AS exposure_share_pct,

    defaulted_loans,

    ROUND(
        100.0 * default_rate,
        2
    ) AS default_rate_pct,

    defaulted_exposure

FROM policy_results
ORDER BY
    policy_name,
    CASE
        WHEN decision = 'Reject' THEN 1
        WHEN decision = 'Manual Review' THEN 2
        WHEN decision = 'Approve' THEN 3
        ELSE 4
    END;