-- ===================================================================================
--	Project:		Financial Management Information System
-- File:		01_database_overview.sql
-- Stage:		Database Exploration
-- Author:		Roman Mosha
-- Date:		28/07/2026
-- Description:	Initial exploration queries to understand the structure and content of 
--				the CDFT database
-- ==================================================================================== 
-- Query 1: Row counts across all tables
-- Purpose: Verify all 18 tables imported correctly
-- Business question: How many records exist in each table?

SELECT table_name, table_rows
FROM information_schema.tables
WHERE table_schema = 'cdft_fmis'
ORDER BY table_name;

-- ── Query 2: Total expenditure by project ─────────────────────
-- Business question: How much has been spent on each project?

SELECT 
    pr.project_name,
    SUM(e.amount_original) AS total_spent,
    ROW_NUMBER() OVER(ORDER BY SUM(e.amount_original) DESC) AS Rank
FROM fact_expenditure e
JOIN dim_project pr ON e.project_id = pr.project_id
GROUP BY pr.project_name
ORDER BY total_spent DESC;

-- Finding: Malaria Rapid Diagnostic Testing Manyara is the 
-- highest spending project at TZS 604,576,000 Tsh.
-- Health Centre Rehabilitation Moshi is lowest at TZS 409,416,000
-- which is unusual for a construction project and warrants
-- further investigation.
-- CORRECTION NOTE: Initial version of Query 1 used amount_usd 
-- instead of amount_original (TZS). Corrected to amount_original
-- for accurate local currency reporting. Date corrected: 03/08/2026