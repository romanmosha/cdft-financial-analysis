-- ============================================================
-- Project:     CDFT Financial Management Information System
-- File:        02_financial_queries.sql
-- Stage:       Financial Analysis Queries
-- Author:      Roman Mosha
-- Date:        03/08/2026
-- Description: Budget, expenditure, procurement and vendor
--              queries answering key financial business questions
-- ============================================================

-- ── Query 2: Monthly spending trend ─────────────────────────
-- Business question: Is CDFT spending evenly across 2025 or
-- are there concerning spikes or gaps in burn rate?

SELECT dfp.month_name,dfp.month_number , COUNT(fe.expenditure_id)AS total_transacton,SUM(fe.amount_original) AS total_exp,
ROUND(AVG(fe.amount_original))AS avg_transaction_size
FROM fact_expenditure fe 
LEFT JOIN dim_fiscal_period dfp ON fe.period_id = dfp.period_id
WHERE dfp.calendar_year = 2025
GROUP BY dfp.period_id ,dfp.month_name ,dfp.month_number 
ORDER BY dfp.month_number;
-- Finding: Monthly spend ranges from TZS 689M (July) to TZS 1.04B
-- (October). October spike warrants investigation -- likely large
-- procurement payments. June shows fewest transactions (537) but
-- highest average transaction size (TZS 1,506,618) suggesting
-- large vendor payments that month. Burn rate is broadly consistent
-- with no alarming gaps or end-of-year panic spending
-- Session Date: 04/08/2026

-- Query 3: Spending by activity category --
-- Which programme activities consume most of CDFT's budget?--
SELECT COALESCE(da.activity_name, 'Unallocated/Unknown'), COUNT(*) AS No_Transc, SUM(fe.amount_original) AS Total_Expenditure, ROUND(AVG(fe.amount_original),0) AS Avg_expenditure,
ROUND(SUM(fe.amount_original)/SUM(SUM(fe.amount_original)) OVER()*100,2) AS Percentage_of_total_expenditure
FROM dim_activity da 
LEFT JOIN fact_expenditure fe ON da.activity_id = fe.activity_id 
GROUP BY da.activity_name
ORDER BY SUM(fe.amount_original ) DESC;

-- Finding: Medical Supplies Procurement is the largest spending
-- category at TZS 730.2M (7.38% of total expenditure), followed
-- by Facilitator Training Workshop at TZS 709.3M (7.17%) and
-- Training of Community Health Workers at TZS 662.3M (6.69%).
-- Policy Dialogue Sessions also accounts for a significant
-- TZS 658.2M (6.65%). The results indicate that CDFT's expenditure
-- is distributed across multiple programme activities, with no
-- single category accounting for a dominant share of the budget.
-- Session Date: 02/09/2026

-- Query 4: Expenditure by transaction type
-- Business question: What categories of spending consume most of CDFT's budget?
SELECT transaction_type, COUNT(*) AS Transactions,SUM(amount_original) AS Total_transactions,AVG(amount_original ) 
AS avg_transactions, ROUND((SUM(amount_original) / SUM(SUM(amount_original))OVER())*100,2) AS pct_of_total_expenditure
FROM fact_expenditure
GROUP BY transaction_type 
ORDER BY Total_transactions DESC;
-- SUMMARY FINDINGS:
-- 1. Heavy Top-End Concentration: Salary (36.63%) & ICT (13.64%) constitute >50% of total spend.
-- 2. Fixed Overhead vs Field Activity: Overhead (Payroll, Rent, ICT, Consultancy)
-- 	  = ~66.7% vs Direct Program Spend = <20%.
-- 3. High Unit Cost: Consultancy fees average 3.4x the unit cost of Facilitator fees despite similar 
--    transaction volume (~450-490 count).
-- 4. Transaction Clustering: Operational categories average ~470 transactions each, signaling structured 
--    periodic disbursement cycles.
 

-- Query 5: Negative values and data quality check

-- Business question: "Does the expenditure data contain impossible or suspicious values that could 
-- distort financial analysis — negative amounts, zero amounts, or extreme outliers?"

WITH stats AS (
    SELECT *,
        -- Calculate Q1 and Q3 inline for every row
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_original) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_original) OVER () AS q3
    FROM fact_expenditure
),
flagged AS ( SELECT expenditure_id, project_id, transaction_type, amount_original,transaction_date, posted_date,is_reversal,
    CASE 
        WHEN amount_original < 0 THEN 'Negative / Credit'
        WHEN amount_original = 0 THEN 'Zero / Void'
        WHEN amount_original > (q3 + (1.5 * (q3 - q1))) THEN 'High Outlier'
        WHEN amount_original < (q1 - (1.5 * (q3 - q1))) THEN 'Low Outlier'
    END AS flag_type
FROM stats
)
-- SELECT flag_type,COUNT(*)
-- FROM flagged
-- GROUP BY flag_type
-- ORDER BY COUNT(*) DESC
SELECT * FROM flagged
WHERE flag_type IS NOT NULL;

SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_original) OVER () AS q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_original) OVER () AS q3,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_original) OVER () 
        - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_original) OVER () AS iqr,
    (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_original) OVER () 
        + 1.5 * (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_original) OVER () 
        - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_original) OVER ())) AS upper_fence,
    (PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_original) OVER () 
        - 1.5 * (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_original) OVER () 
        - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_original) OVER ())) AS lower_fence
FROM fact_expenditure
LIMIT 1;

SELECT AVG(amount_original)
FROM fact_expenditure

-- Finding: 6.6% of transactions (542/8,000) flagged.
--
-- High Outliers (531): Transactions above Tukey fence of
-- TZS 3,720,625. Highest is TZS 110.3M salary payment on
-- PRJ-2024-005 -- 30x the Q3 value. Verify against approved
-- staff cost schedules before donor reporting.
--
-- Negative Values (11): Confirmed legitimate reversals via
-- is_reversal = TRUE. No action required beyond netting in
-- cumulative totals.
--
-- Zero Transactions: None found. Clean on this dimension.
--
-- Recommendation: Finance team to review and approve treatment
-- of 531 outliers before any financial KPI is published.