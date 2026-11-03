-- Telco Data Analysis -- 

USE telco_churn;


-- Revenue Impact of Churn --

-- Customers by churn status
SELECT ChurnFlag, COUNT(*)
FROM telco_staging
GROUP BY ChurnFlag;
-- Result: 0 = 5163 retained, 1 = 1869 churned (churn rate 26.58%)

-- Total monthly revenue, all customers
SELECT ROUND(SUM(MonthlyCharges), 2)
FROM telco_staging;
-- Result: 455,661.00

-- Monthly revenue from churned customers (filtered with WHERE)
SELECT ROUND(SUM(MonthlyCharges), 2)
FROM telco_staging
WHERE ChurnFlag = 1;
-- Result: 139,130.85

SELECT ROUND(SUM(MonthlyCharges * ChurnFlag), 2) AS total_churned_charges
FROM telco_staging;
-- Result: 139,130.85 (matches the WHERE version above)

-- Churned revenue as a percentage of total monthly revenue
SELECT ROUND(SUM(MonthlyCharges * ChurnFlag) / (SUM(MonthlyCharges)) * 100, 2) AS churned_revenue_pct
FROM telco_staging;
-- Result: 30.53%


-- Churn by Segment --

-- Churn by contract type
SELECT Contract, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY Contract;

-- Churn by internet service
SELECT InternetService, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY InternetService;

-- Churn by payment method
SELECT PaymentMethod, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY PaymentMethod;

-- Churn by tenure group (months)
SELECT TenureGroup, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY TenureGroup;

-- Churn by senior citizen status
SELECT SeniorCitizen, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY SeniorCitizen;

-- Churn by partner status
SELECT Partner, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY Partner;

-- Churn by dependents
SELECT Dependents, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY Dependents;

-- Churn by tech support
SELECT TechSupport, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY TechSupport;

-- Churn by online security
SELECT OnlineSecurity, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY OnlineSecurity;

-- Churn by paperless billing
SELECT PaperlessBilling, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY PaperlessBilling;

-- Churn by gender
SELECT gender, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY gender;

-- Average monthly charges: retained vs. churned customers
SELECT ChurnFlag, ROUND(AVG(MonthlyCharges), 2)
FROM telco_staging
GROUP BY ChurnFlag;
-- Result: 0 (retained) = 61.31, 1 (churned) = 74.44


-- Revenue Impact by Segment --

-- Highest-risk segment: month-to-month, fiber optic, electronic check, first year
SELECT  COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
WHERE Contract = 'Month-to-month'
AND InternetService = 'Fiber optic'
AND PaymentMethod = 'Electronic check'
AND TenureGroup = '0-12';
-- Result: 631 customers, 449 churned (71.16%)

-- Annualized revenue lost to churn in the highest-risk segment
SELECT ROUND(SUM(MonthlyCharges * ChurnFlag) * 12, 2) AS Annualized_revenue
FROM telco_staging
WHERE Contract = 'Month-to-month'
AND InternetService = 'Fiber optic'
AND PaymentMethod = 'Electronic check'
AND TenureGroup = '0-12';
-- Result: 445,992.00 (37,166.00 per month)

-- Revenue lost to churn by contract, and the share of each contract's own revenue that was lost
SELECT Contract, ROUND(SUM(MonthlyCharges * ChurnFlag), 2) AS Churned_revenue, ROUND(SUM(MonthlyCharges * ChurnFlag) / SUM(MonthlyCharges) * 100, 2) AS percentage_of_annualized_revenue_lost
FROM telco_staging
GROUP BY Contract;

-- Revenue lost to churn by contract, next to each contract's share of the company's total monthly revenue
SELECT Contract, ROUND(SUM(MonthlyCharges * ChurnFlag), 2), ROUND(SUM(MonthlyCharges) / (SELECT SUM(MonthlyCharges) FROM telco_staging) * 100, 2)
FROM telco_staging
GROUP BY Contract;


-- Advanced Analysis --

-- Churn rate by segment (contract + internet service), ranked from highest to lowest. The CTE builds the segment table, then RANK() orders it.
WITH segment_churn_cte AS
(
SELECT Contract, InternetService, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS Churn_percentage
FROM telco_staging
GROUP BY Contract, InternetService
)
SELECT Contract, InternetService, Customers, Churned, Churn_percentage, RANK() OVER(ORDER BY Churn_percentage DESC) AS Churn_rank
FROM segment_churn_cte
ORDER BY Churn_rank;
-- Finding: month-to-month fiber optic customers churn at 54.61%, about twice the overall 26.58%, and it is also the largest of the nine segments.

-- Number of customers at each tenure (months)
SELECT tenure, COUNT(*)
FROM telco_staging
GROUP BY tenure
ORDER BY tenure;

-- Running total of customers by tenure, using a CTE and a window function
WITH customer_tenure_cte AS
(
SELECT tenure, COUNT(*) AS Customers
FROM telco_staging
GROUP BY tenure
ORDER BY tenure
)
SELECT tenure, Customers, SUM(Customers) OVER(ORDER BY tenure) AS running_total
FROM customer_tenure_cte;

-- Same running total without a CTE: the window function sits directly on top of the grouped count. Returns the same result as the query above.
SELECT tenure, COUNT(*) AS Customers, SUM(COUNT(*)) OVER (ORDER BY tenure) AS running_total
FROM telco_staging
GROUP BY tenure
ORDER BY tenure;
-- Result: identical to the CTE version above (72 rows, ending at 7032)

-- Churn rate by contract compared with the overall churn rate. The subquery calculates the overall rate over the whole table; the last column is the contract's rate minus the overall rate (in percentage points).
SELECT Contract, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS `Churn %`, 
	(SELECT ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) FROM telco_staging) AS `Churn %`, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) - (SELECT ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) FROM telco_staging) AS Difference
FROM telco_staging
GROUP BY Contract;


-- Risk Score and Summary View --

-- Quick look at the four risk columns used in the score (exploration only)
SELECT Contract, InternetService, TechSupport, PaymentMethod
FROM telco_staging;

-- Risk score for each customer: 1 point for each of five risk traits (month-to-month contract, fiber optic internet, no tech support, electronic check payment, first-year tenure), so the score runs from 0 to 5.
SELECT ChurnFlag,
	   CASE WHEN Contract = 'Month-to-month' THEN 1 ELSE 0 END
	 + CASE WHEN InternetService = 'Fiber optic' THEN 1 ELSE 0 END
     + CASE WHEN TechSupport = 'No' THEN 1 ELSE 0 END
     + CASE WHEN PaymentMethod = 'Electronic check' THEN 1 ELSE 0 END
     + CASE WHEN TenureGroup = '0-12' THEN 1 ELSE 0 END AS Risk_score
FROM telco_staging;
-- Result: 7032 rows, each with a Risk_score between 0 and 5

-- Churn rate by risk score. The CTE calculates the score per customer, and the outer query groups by it.
WITH risk_score_cte AS
(
SELECT ChurnFlag,
	   CASE WHEN Contract = 'Month-to-month' THEN 1 ELSE 0 END
	 + CASE WHEN InternetService = 'Fiber optic' THEN 1 ELSE 0 END
     + CASE WHEN TechSupport = 'No' THEN 1 ELSE 0 END
     + CASE WHEN PaymentMethod = 'Electronic check' THEN 1 ELSE 0 END
     + CASE WHEN TenureGroup = '0-12' THEN 1 ELSE 0 END AS Risk_score
FROM telco_staging
)
SELECT Risk_score, SUM(ChurnFlag) AS Churn, COUNT(*) AS Customers, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS `Churned %`
FROM risk_score_cte
GROUP BY Risk_score
ORDER BY Risk_score;

CREATE VIEW churn_summary AS
SELECT Contract, InternetService, TenureGroup, COUNT(*) AS Customers, SUM(ChurnFlag) AS Churned, ROUND(SUM(ChurnFlag) / COUNT(*) * 100, 2) AS `Churn rate`, ROUND(SUM(MonthlyCharges), 2) AS MonthlyRevenue, ROUND(SUM(MonthlyCharges * ChurnFlag), 2) AS ChurnedRevenue
FROM telco_staging
GROUP BY Contract, InternetService, TenureGroup;

SELECT *
FROM churn_summary
