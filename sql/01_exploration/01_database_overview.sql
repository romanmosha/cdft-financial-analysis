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
    SUM(e.amount_original) AS total_spent
FROM fact_expenditure e
JOIN dim_project pr ON e.project_id = pr.project_id
GROUP BY pr.project_name
ORDER BY total_spent DESC;

-- Finding: Malaria Rapid Diagnostic Testing Manyara is the 
-- highest spending project at TZS 604,576,000 Tsh.
-- Health Centre Rehabilitation Moshi is lowest at TZS 409,416,000
-- which is unusual for a construction project and warrants
-- further investigation.