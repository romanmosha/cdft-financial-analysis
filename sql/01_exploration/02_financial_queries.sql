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
sql
-- Finding: Monthly spend ranges from TZS 689M (July) to TZS 1.04B
-- (October). October spike warrants investigation -- likely large
-- procurement payments. June shows fewest transactions (537) but
-- highest average transaction size (TZS 1,506,618) suggesting
-- large vendor payments that month. Burn rate is broadly consistent
-- with no alarming gaps or end-of-year panic spending
-- Session Date: 04/08/2026

