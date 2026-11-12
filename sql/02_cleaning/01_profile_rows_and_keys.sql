-- ==============================================================================
-- Script Name: 01_data_profiling.sql
-- Purpose:     Initial health check (row counts, key uniqueness, NULL audit)
-- Database:    cdft_fmis
-- Author:      Roman Mosha
-- Date:        2026-11-12
-- ==============================================================================
-- displayind table name
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'cdft_fmis'
	AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- ------------------------------------------------------------------------------
-- 1. TABLE ROW COUNTS (Establish baseline volume)
-- ------------------------------------------------------------------------------
SELECT 'dim_account' AS table_name, count(*) AS row_count FROM dim_account
UNION ALL
SELECT 'dim_activity' AS table_name, count(*) AS row_count FROM dim_activity
UNION ALL
SELECT 'dim_asset' AS table_name, count(*) AS row_count FROM dim_asset
UNION ALL
SELECT 'dim_budget_line' AS table_name, count(*) AS row_count FROM dim_budget_line
UNION ALL
SELECT 'dim_cost_centre' AS table_name, count(*) AS row_count FROM dim_cost_centre
UNION ALL
SELECT 'dim_donor' AS table_name, count(*) AS row_count FROM dim_donor
UNION ALL
SELECT 'dim_fiscal_period' AS table_name, count(*) AS row_count FROM dim_fiscal_period
UNION ALL
SELECT 'dim_grant' AS table_name, count(*) AS row_count FROM dim_grant
UNION ALL
SELECT 'dim_location' AS table_name, count(*) AS row_count FROM dim_location
UNION ALL
SELECT 'dim_procurenent_status' AS table_name, count(*) AS row_count FROM dim_procurement_status
UNION ALL
SELECT 'dim_program' AS table_name, count(*) AS row_count FROM dim_program
UNION ALL
SELECT 'dim_project' AS table_name, count(*) AS row_count FROM dim_project
UNION ALL
SELECT 'dim_staff' AS table_name, count(*) AS row_count FROM dim_staff
UNION ALL
SELECT 'dim_vendor' AS table_name, count(*) AS row_count FROM dim_vendor
UNION ALL
SELECT 'fact_budget_allocation' AS table_name, count(*) AS row_count FROM fact_budget_allocation
UNION ALL
SELECT 'fact_expenditure' AS table_name, count(*) AS row_count FROM fact_expenditure
UNION ALL
SELECT 'fact_procurement' AS table_name, count(*) AS row_count FROM fact_procurement
UNION ALL
SELECT 'fact_training' AS table_name, count(*) AS row_count FROM fact_training;

-- Findings
/*
dim_account	21
dim_activity	81
dim_asset	600
dim_budget_line	229
dim_cost_centre	8
dim_donor	8
dim_fiscal_period	12
dim_grant	12
dim_location	12
dim_procurenent_status	10
dim_program	6
dim_project	20
dim_staff	120
dim_vendor	150
fact_budget_allocation	900
fact_expenditure	8000
fact_procurement	2500
fact_training	450
*/

-- ------------------------------------------------------------------------------
-- 2. PRIMARY KEY & DUPLICATE CHECKS (Verify grain of each table)
-- ------------------------------------------------------------------------------
SELECT
	t.table_name,
	kcu.column_name AS primary_key_column,
	CASE 
		WHEN kcu.column_name IS NULL THEN 'warning: no primary key'
		ELSE 'ok'
	END AS pk_status
FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints tc
	ON t.table_schema = tc.table_schema
	AND t.table_name = tc.table_name
	AND tc.constraint_type = 'PRIMARY KEY'
LEFT JOIN information_schema.key_column_usage kcu
	ON tc.constraint_schema = kcu.constraint_schema
	AND tc.constraint_name=kcu.constraint_name
	AND tc.table_name = kcu.table_name
WHERE t.table_schema = 'cdft_fmis'
	AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name;
	


-- ------------------------------------------------------------------------------
-- 3. NULL & COMPLETENESS AUDIT (Identify missing critical fields)
-- ------------------------------------------------------------------------------
-- SELECT COUNT(*) AS total, COUNT(col_a) AS non_null_a FROM table_name;


-- ------------------------------------------------------------------------------
-- 4. SUMMARY OF FINDINGS (Document anomalies before moving to S2/S3)
-- ------------------------------------------------------------------------------
-- * Finding 1: ...
-- * Finding 2: ...