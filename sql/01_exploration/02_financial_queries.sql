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

-- Query 3 Spending by activity category --
-- What categories of spending consume most of CDFT's budget?--
SELECT COALESCE(da.activity_name, 'Unallocated/Unknown'), COUNT(*) AS No_Transc, SUM(fe.amount_original) AS Total_Expanditure, ROUND(AVG(fe.amount_original),0) AS Avg_expanditure,
ROUND(SUM(fe.amount_original)/SUM(SUM(fe.amount_original)) OVER()*100,2) AS Percentage_of_total_expanditure
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


