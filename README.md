# Credit Risk Portfolio Analysis Using SQL

## Project Overview

This project analyzes a consumer lending portfolio using PostgreSQL to identify borrower and loan characteristics associated with higher default risk. The analysis focuses on portfolio-level KPIs, borrower segmentation, default-rate comparisons, risk concentration, and underwriting policy simulation.

The goal of this project is to answer three core business questions:

1. Which borrower and loan segments are most likely to default?
2. Where is default exposure concentrated in the portfolio?
3. How can simple underwriting rules help reduce risky loan approvals while preserving business volume?

This project was built as a SQL-based credit risk portfolio analysis, with emphasis on data cleaning, feature engineering, risk segmentation, and business interpretation.

---

## Business Problem

Lenders need to manage default risk while continuing to approve profitable and responsible loans. A loan portfolio may contain thousands of borrowers with different income levels, credit histories, employment backgrounds, loan purposes, interest rates, and affordability levels.

The business objective is to analyze the portfolio and identify patterns that may help improve underwriting decisions. Specifically, the analysis investigates whether factors such as loan grade, affordability burden, income band, home ownership, employment length, and previous default history are associated with higher default risk.

---

## Dataset

The dataset contains borrower-level and loan-level information for a consumer lending portfolio.

Key fields include:

| Column | Description |
|---|---|
| `person_age` | Borrower age |
| `person_income` | Borrower annual income |
| `person_home_ownership` | Borrower home ownership status |
| `person_emp_length` | Employment length in years |
| `loan_intent` | Purpose of the loan |
| `loan_grade` | Credit grade assigned to the loan |
| `loan_amnt` | Loan amount |
| `loan_int_rate` | Loan interest rate |
| `loan_status` | Loan outcome, where 1 indicates default and 0 indicates non-default |
| `loan_percent_income` | Loan amount as a percentage of borrower income |
| `cb_person_default_on_file` | Whether the borrower has previous default history |
| `cb_person_cred_hist_length` | Borrower credit history length |

---

## Tools Used

- PostgreSQL
- DataGrip
- SQL
- GitHub

---

## Project Structure

```text
credit-risk-portfolio-analysis/
│
├── data/
│   └── credit_risk_dataset.csv
│
├── sql/
│   ├── 01_cleaning.sql
│   ├── 02_feature_engineering.sql
│   ├── 03_portfolio_kpis.sql
│   ├── 04_demographic_kpis.sql
│   └── 05_underwriting_simulation.sql
│
└── README.md
