-- Telco Churn Data Analysis --

USE telco_churn;


-- 1. Staging table 

DROP TABLE IF EXISTS telco_staging;

SELECT *
FROM telco_raw;

CREATE TABLE telco_staging
LIKE telco_raw;

INSERT INTO telco_staging
SELECT *
FROM telco_raw;


-- 2. Duplicate Check

SELECT customerID, COUNT(*) AS cnt 
FROM telco_staging
GROUP BY customerID
HAVING COUNT(*) > 1;
-- Expected: no rows (no duplicate customer IDs)


-- 3. Standardize values

SELECT *
FROM telco_staging;

SELECT *
FROM telco_staging
WHERE MultipleLines LIKE 'No %';

UPDATE telco_staging
SET MultipleLines = 'No'
WHERE MultipleLines LIKE 'No %';

SELECT SeniorCitizen
FROM telco_staging;

ALTER TABLE telco_staging
MODIFY SeniorCitizen VARCHAR(10);

UPDATE telco_staging
SET SeniorCitizen = 'No'
WHERE SeniorCitizen = '0';

UPDATE telco_staging
SET SeniorCitizen = 'Yes'
WHERE SeniorCitizen = '1';


-- 4. New columns

ALTER TABLE telco_staging
ADD COLUMN ChurnFlag TINYINT;

SELECT *
FROM telco_staging;

UPDATE telco_staging
SET ChurnFlag = 1
WHERE Churn = 'Yes';

UPDATE telco_staging
SET ChurnFlag = 0
WHERE Churn = 'No';

ALTER TABLE telco_staging
ADD COLUMN tenure_group VARCHAR(10);

ALTER TABLE telco_staging
RENAME COLUMN tenure_group TO TenureGroup;

SELECT ChurnFlag, COUNT(*) 
FROM telco_staging 
GROUP BY ChurnFlag;

UPDATE telco_staging
SET TenureGroup = CASE
	WHEN tenure <= 12 THEN '0-12'
    WHEN tenure <= 24 THEN '13-24'
    WHEN tenure <= 48 THEN '25-48'
    ELSE '49+'
END;

SELECT TenureGroup, COUNT(*), MIN(tenure), MAX(tenure)
FROM telco_staging 
GROUP BY TenureGroup;

SELECT tenure, MonthlyCharges
FROM telco_staging;


-- Range Checks --

SELECT MIN(tenure), MAX(tenure), MIN(MonthlyCharges), MAX(MonthlyCharges)
FROM telco_staging; 
-- Expected: tenure 1 to 72, MonthlyCharges 18.25 to 118.75


-- Validation

SELECT COUNT(*) AS total_rows, COUNT(DISTINCT customerID) as unique_ids
FROM telco_staging;
-- Expected: 7032 and 7032 (no duplicate IDs)

SELECT ChurnFlag, COUNT(*)
FROM telco_staging
GROUP BY ChurnFlag;
-- Expected: 0 = 5163, 1 = 1869

SELECT COUNT(*)
FROM telco_staging
WHERE ChurnFlag IS NULL OR TenureGroup IS NULL;
-- Expected: 0

SELECT SeniorCitizen, COUNT(*)
FROM telco_staging
GROUP BY SeniorCitizen;
-- Expected: No = 5890, Yes = 1142

SELECT TenureGroup, COUNT(*)
FROM telco_staging
GROUP BY TenureGroup
ORDER BY TenureGroup;
-- Expected: 0-12 = 2175, 13-24 = 1024, 25-48 = 1594, 49+ = 2239

SELECT ROUND(SUM(TotalCharges), 2)
FROM telco_staging;
-- Expected: about 16056168.70


