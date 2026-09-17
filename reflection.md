# Behind the Project: How I Built This



I started this project with a fairly simple goal: I wanted to get better at SQL by working on something that felt closer to a real business problem rather than just solving isolated query exercises.



Because of my interest in analytics, credit risk seemed like a good place to start. The original question was straightforward:



> **Can I use SQL to understand which borrowers are more likely to default, where risk is concentrated in a loan portfolio, and how a lender might use that information when making lending decisions?\*\*



What started as a SQL practice project eventually became much more about understanding how data, business rules, and risk decisions connect.



### Starting with the Data



The first challenge came before I even wrote any meaningful analysis.



I imported the CSV into PostgreSQL using DataGrip and quickly realized that automatic data type detection is not always something you should trust blindly.



Several columns that should have been numeric were imported as `TEXT`, including fields such as interest rate, loan status, loan-to-income ratio, and credit history length. At one point, the credit history field was showing values that did not match the original CSV at all.



That forced me to go back and think about something that is easy to overlook:



> Before analyzing data, do I actually understand how the data entered the database?



I started manually checking column types, comparing PostgreSQL values against the original CSV, and defining the expected schema more deliberately.



It was a useful reminder that a query can be perfectly written and still produce meaningless results if the underlying data is wrong.



---



### Cleaning Wasn't Just About Removing NULLs



Once the schema was working, I started exploring the data for unusual values.



One of the first things I found was borrower ages such as:



- 123

- 124

- 144



Rather than immediately deleting those records, I looked at the pattern and made the assumption that these were likely data-entry errors where `100` had accidentally been added to the age.



I corrected them to:



- 23

- 24

- 44



This was also where I learned to use SQL transactions with `BEGIN`, `COMMIT`, and `ROLLBACK`.



Instead of running an `UPDATE` and hoping I had written the `WHERE` clause correctly, I could make the change inside a transaction, inspect the result, and only commit it once I was comfortable with the output.



That sounds like a small thing, but it changed how I thought about SQL. I stopped treating SQL only as a language for retrieving data and started thinking more carefully about database state, reproducibility, and the consequences of modifying records.



I also found a very large income value of approximately `$6,000,000`. Unlike the age values, I did not have enough evidence to say that it was definitely incorrect.



That led to another lesson:



> **An outlier is not automatically an error.\*\*



Sometimes the correct decision is to investigate, isolate, or document a value rather than immediately changing it.



---



### Turning Raw Columns into Risk Features



The next stage was feature engineering.



The raw dataset had continuous variables such as age, income, employment length, interest rate, loan amount, credit history length, and loan-to-income ratio.



For analysis, I wanted these variables to be easier to interpret, so I created categories such as:



- Age bands

- Income bands

- Employment-length bands

- Loan-amount bands

- Affordability bands

- Credit-history bands

- Interest-rate bands

- Numeric loan-grade scores



This turned out to be more challenging than simply writing a `CASE WHEN`.



For example, if income ranged from approximately `$4,000` to `$6,000,000`, what should the income intervals actually be?



At first, it was tempting to choose arbitrary round numbers. Instead, I looked at the distribution using the median and percentiles and then selected ranges that were both understandable from a business perspective and reasonably representative of the portfolio.



That process taught me that feature engineering is partly technical and partly judgment.



A technically valid interval is not necessarily a useful one.



The categories need to be interpretable enough that someone looking at the final results can understand what they mean without needing to reverse-engineer the SQL.



---



### Understanding Default Risk



One of the most useful moments in the project came from a very simple query.



I originally wanted to answer:



> Which age group has the most defaults?



My first approach counted defaulted loans by age group.



But that does **not** necessarily tell you which age group is more likely to default.



For example:



- Group A could have 100 defaults out of 1,000 loans.

- Group B could have 50 defaults out of 100 loans.



Group A has more defaults, but Group B has a much higher **default rate**.



That distinction helped shape the rest of the analysis.



Instead of focusing only on counts, I started comparing:



- Total loans

- Defaulted loans

- Default rate

- Portfolio share

- Total loan exposure

- Defaulted exposure



This made the analysis much more useful.



A borrower segment can have a very high default rate but represent only a tiny portion of the portfolio. Another segment may have a lower default rate but account for a much larger amount of defaulted loan exposure.



From a portfolio-management perspective, both matter for different reasons.



---



### From Demographics to Portfolio Risk



I then analyzed default behavior across several borrower characteristics:



- Age

- Income

- Employment history

- Home ownership

- Credit history

- Previous default history

- Affordability burden



I also started combining characteristics rather than looking at everything independently.



For example, instead of simply asking whether lower-income borrowers default more often, a more useful question became:



> Does income still matter when we consider how large the loan is relative to the borrower's income?



That made `loan\_percent\_income` and the affordability bands particularly interesting.



It helped move the project away from simply describing borrowers and toward thinking about **repayment capacity**.



---



### Simulating Underwriting Decisions



The final part of the project was my favorite because it connected the SQL analysis back to an actual business decision.



I created a simple underwriting simulation that classified loans into:



- **Approve**

- **Manual Review**

- **Reject**



The rules considered factors such as:



- Severe affordability burden

- Weak loan grades

- Previous defaults

- Thin credit history

- Short employment history

- Combinations of multiple risk factors



I then created three hypothetical underwriting strategies:



**Lenient Policy**  

Maintains more loan volume but only rejects the clearest high-risk cases.



**Balanced Policy**  

Uses a combination of rejection and manual review to reduce risk while preserving lending opportunities.



**Strict Policy**  

Applies tighter criteria and removes more high-risk exposure, but at the cost of rejecting more potential borrowers.



The important part was not simply labeling loans as "good" or "bad."



The real question became:



> **How much risk can we reduce, and what amount of business volume do we give up to achieve that reduction?**



That trade-off made the project feel much closer to an actual business analytics problem.



---



## How I Used AI During the Project



AI was useful throughout this project, but mostly as a **learning and reasoning partner rather than a replacement for the analysis**.



I used AI to help me understand concepts when I encountered something I had not worked with before.



For example, AI helped me work through:



- Why `BEGIN`, `COMMIT`, and `ROLLBACK` matter when updating a database

- How PostgreSQL data types affect calculations

- The difference between default count and default rate

- Ways to select reasonable feature-engineering intervals
- How affordability can be interpreted in a credit-risk context

- How default exposure differs from default probability

- How an underwriting policy simulation could be structured

- How concepts such as Probability of Default, Exposure at Default, and Loss Given Default could extend the project later



I would often start with a question, understand the concept, write or modify the SQL myself, run it against the database, and then inspect whether the output actually made sense.



This was especially useful because credit risk was relatively new to me. AI helped shorten the gap between knowing how to write SQL and understanding \*\*why a financial institution might care about the output of that SQL\*\*.



At the same time, the project also reinforced that AI suggestions still need to be validated.



A suggested threshold, cleaning rule, or underwriting condition is not automatically correct just because it sounds reasonable. I still needed to compare it with the actual dataset, understand the assumptions, and decide whether I could defend the decision.



---



## What I Learned



The biggest lesson from this project was that SQL analysis is not mainly about writing complicated queries.



The harder questions were things like:



- Is this value actually an error?

- Should I remove this outlier or preserve it?

- What denominator should I use for this KPI?

- Are my feature bands meaningful?

- Does a high default rate actually represent significant portfolio risk?

- Is the underwriting rule reducing risk, or simply rejecting a large portion of the portfolio?

- Can I explain why I made this assumption?



I also became much more comfortable structuring a SQL project into separate stages rather than keeping everything inside one large query file.



The final workflow became:



```text

Raw Dataset

&#x20;    ↓

Data Cleaning

&#x20;    ↓

Feature Engineering

&#x20;    ↓

Portfolio KPIs

&#x20;    ↓

Demographic / Risk Analysis

&#x20;    ↓

Underwriting Simulation

&#x20;    ↓

Business Interpretation

