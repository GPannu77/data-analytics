# World Layoffs: SQL Data Cleaning & Exploratory Data Analysis

A two-stage SQL project that takes a raw global tech layoffs dataset, cleans it, and then explores it to find out which companies, industries, and countries were hit hardest.

## Project Overview

The raw data had duplicate rows, inconsistent category names, text-formatted dates, and a lot of missing values. This project covers:

1. **Data cleaning:** turning the raw table into a reliable, analysis-ready one
2. **Exploratory data analysis (EDA):** querying the cleaned data for trends and insights

**Tools used:** MySQL, MySQL Workbench, Git/GitHub

## Dataset

- **Source:** [add link, e.g. Kaggle]
- **Time period:** March 11, 2020 to March 6, 2023
- **Size:** 2,361 raw rows, 9 columns

| Column | Description |
|---|---|
| `company` | Company that conducted the layoffs |
| `location` | City / region of the company |
| `industry` | Industry the company operates in |
| `total_laid_off` | Number of employees laid off |
| `percentage_laid_off` | Share of the workforce laid off (0 to 1) |
| `date` | Date of the layoff announcement (stored as text, e.g. `3/6/2023`) |
| `stage` | Funding stage of the company |
| `country` | Country of the company |
| `funds_raised_millions` | Total funds raised (millions USD) |

### Data quality issues found in the raw data

| Issue | Detail |
|---|---|
| Duplicate rows | 5 exact duplicates |
| Inconsistent industry names | `Crypto`, `Crypto Currency`, and `CryptoCurrency` all meant the same thing |
| Inconsistent country names | `United States.` (trailing period) alongside `United States` |
| Extra whitespace | 11 company names had leading or trailing spaces |
| Dates stored as text | Format `M/D/YYYY`, not a real `DATE` type, plus 1 missing date |
| Missing industry | 4 rows (3 can be recovered from other rows of the same company) |
| Missing layoff figures | 740 rows missing `total_laid_off`, 785 missing `percentage_laid_off`, and 362 rows missing both |
| Missing funding / stage | 209 rows missing `funds_raised_millions`, 6 missing `stage` |

## Repository Structure

```
world-layoffs-sql-project/
├── README.md
├── data/
│   ├── raw/layoffs.csv
│   └── cleaned/layoffs_cleaned.csv
├── sql/
│   ├── 01_data_cleaning.sql
│   └── 02_exploratory_analysis.sql
└── images/
```

## Part 1: Data Cleaning

Script: [`sql/01_data_cleaning.sql`](sql/01_data_cleaning.sql)

All cleaning was done on a staging copy so the raw table was never modified.

| Step | What I did | Why |
|---|---|---|
| 1. Staging table | Created `layoffs_staging` as a copy of the raw table | Keeps the raw data safe |
| 2. Remove duplicates | Used `ROW_NUMBER() OVER (PARTITION BY ...)` in a CTE to flag duplicates, then deleted the extras | Duplicates inflate totals |
| 3. Standardize data | Trimmed company names, merged the three crypto spellings into `Crypto`, removed the trailing period from `United States.` | Stops one category being split into several |
| 4. Fix dates | Converted `date` from text with `STR_TO_DATE(date, '%m/%d/%Y')`, then changed the column type to `DATE` | Enables time-based analysis |
| 5. Handle nulls | Turned blanks into `NULL`, filled missing industries by self-joining on company, and deleted rows where both `total_laid_off` and `percentage_laid_off` were `NULL` | Rows with no layoff data cannot be analyzed |
| 6. Drop helper column | Removed `row_num` | Keeps the final table clean |

### Before and after

| | Rows |
|---|---|
| Raw data | 2,361 |
| After removing 5 duplicates | 2,356 |
| After removing rows with no layoff data | **1,995** |

## Part 2: Exploratory Data Analysis

Script: [`sql/02_exploratory_analysis.sql`](sql/02_exploratory_analysis.sql)

Questions explored:

- Which companies had the largest layoffs, in a single event and in total?
- Which industries and countries were hit hardest?
- How did layoffs change by year and by month? (rolling totals)
- Which companies laid off 100% of their workforce, and at what funding stage?
- Who were the top 5 companies by layoffs in each year?

## Key Findings

> These were calculated from the cleaned data. Check them against your own query results before publishing.

- **383,659 employees** were laid off across the 1,995 cleaned records.
- **Amazon had the most layoffs overall** (18,150 across its events). **Google had the largest single event** (12,000 on Jan 20, 2023), followed by Meta (11,000) and Amazon and Microsoft (10,000 each).
- **Consumer (44,782) and Retail (43,613)** were the hardest-hit industries, followed by Other (36,289).
- **The United States accounted for about 67%** of all layoffs (256,559), followed by India (35,993) and the Netherlands (17,220).
- **2022 and early 2023 dominate.** 2022 had 160,661 layoffs and Q1 2023 already had 125,677. January 2023 was the worst month on record at 84,714, followed by November 2022 at 53,451.
- **116 companies laid off 100% of their workforce**, most often startups at the Unknown, Seed, and Series B stages.

## SQL Concepts Demonstrated

- Common Table Expressions (CTEs)
- Window functions (`ROW_NUMBER()`, `DENSE_RANK()`, rolling `SUM() OVER`)
- Aggregations and `GROUP BY`
- Self joins
- Data type conversion and date functions (`STR_TO_DATE`, `SUBSTRING`)
- `ALTER`, `UPDATE`, and `DELETE` for data modification

## How to Run

1. Clone the repo:
   ```
   git clone https://github.com/YOUR-USERNAME/world-layoffs-sql-project.git
   ```
2. Create a database (e.g. `world_layoffs`) and import `data/raw/layoffs.csv` into a table called `layoffs`.
3. Run `sql/01_data_cleaning.sql` to build the cleaned table.
4. Run `sql/02_exploratory_analysis.sql` to reproduce the analysis.

## What I Learned

- Always work on a staging copy instead of the raw table
- Window functions make duplicate detection and ranking much easier
- A large share of real-world data work is cleaning before analysis can start

## Next Steps

- Build a dashboard in Tableau or Power BI from the cleaned data
- Recreate the analysis in Python (pandas) for comparison

## Contact

[Gurnoor Pannu] | [linkedin.com/in/gurnoorpannu77] | [gurnoor4771@gmail.com]
