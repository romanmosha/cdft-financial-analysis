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

-- Findings 
-- no pk course we imported csv without constraints

-- DUPLICATES
-- duplicate vendors name
SELECT
	vendor_name,
	count(*) AS record_count
FROM dim_vendor
GROUP BY vendor_name 
HAVING count(*)>1
ORDER BY record_count DESC;

-- Findings
/*
FINDINGS - DUPLICATE VENDOR NAMES (dim_vendor):
- Identified 14 exact duplicate vendor names (29 total rows impacted; max 3 duplicates for 'Community Office Co').
- Note: Multiple distinct 'Northern' entities (e.g., General Co, Office Ltd) and 'Savanna Office Services' 
  each show exact name duplication across separate vendor_ids, while also warranting a secondary check for related-party 
  overlap across similar regional names.
- Impact: Exact duplicates fragment vendor spend across multiple IDs, risking understated exposure and bypassed procurement
  thresholds.
- Action: Inspect underlying identifiers (TIN, registration, bank/contact details) to confirm whether exact matches are 
  duplicate entries to merge, and whether similar regional names share ownership.
*/

-- Target check for Savanna variatiy

SELECT 
	lower(trim(vendor_name))AS normalized_vendor_name,
	count(*) AS occurance_count,
	GROUP_CONCAT(vendor_id ORDER BY vendor_id) AS matching_vendor_id,
	group_concat(vendor_name ORDER BY vendor_id) AS recorded_name_variaties
FROM dim_vendor
WHERE vendor_name LIKE '%Savanna%'
GROUP BY lower(trim(vendor_name))
HAVING count(*)>1;

/*
FINDINGS - SAVANNA VENDOR PATTERN CHECK (dim_vendor):
- Retrieved 17 vendor records matching '%Savanna%' across distinct vendor_ids.
- Exact duplicate confirmed: 'Savanna Office Services' appears twice (VND-0077, VND-0129).
- Data hygiene & related-party flags:
  1. Inconsistent casing detected on 3 records (e.g., 'savanna office enterprises', 'savanna consulting enterprises', 'savanna construction enterprises'), indicating unstandardized CSV ingestion.
  2. High density of near-identical naming permutations across similar sectors (e.g., Medical Services vs. Medical Co; Office Services, Office Supplies, Office Associates, office enterprises; Trade Services, Trade Ltd, Trade International).
- Action: Cross-check TIN, bank details, and contact info across these 17 IDs to verify whether they are independent entities or split/related-party vendors used to fragment procurement thresholds.
*/

-- Check for duplicate project names
SELECT 
	project_name,
	count(*) AS record_count
FROM dim_project
GROUP BY project_name 
HAVING count(*)>1
ORDER BY count(*) DESC;

/*
FINDINGS - DUPLICATE PROJECT NAMES (dim_project):
- Zero exact duplicate project names found. Business key uniqueness holds for dim_project.
*/

-- Target check on northen variant
SELECT 
	vendor_name,
	count(*) AS appearence,
	GROUP_CONCAT(vendor_id ORDER BY  vendor_id) AS matching_vendor_id
FROM dim_vendor
WHERE vendor_name LIKE '%Northern%'
GROUP BY  vendor_name
HAVING count(*)>1
ORDER BY appearence DESC;

/*
FINDINGS - NORTHERN VENDOR DUPLICATES (dim_vendor):
- Confirmed 4 exact duplicate 'Northern' vendor entities, each appearing twice under separate vendor_ids:
  1. Northern Consulting Associates (VND-0058, VND-0144)
  2. Northern General Co (VND-0097, VND-0125)
  3. Northern Office Ltd (VND-0104, VND-0132)
  4. Northern Research and Consulting (VND-0017, VND-0142)
- Action: Inspect underlying identifiers (TIN, bank/contact details) across these paired IDs to verify duplicate onboarding and consolidate spend.
*/

-- Check for Nulls in Dimension Primar keys
SELECT 
	(SELECT count(*) FROM dim_vendor WHERE vendor_id IS NULL ) AS null_vendor_pk,
	(SELECT count(*) FROM dim_project WHERE project_id IS NULL) AS null_project_pk,
	(SELECT count(*) FROM dim_account WHERE account_id IS NULL) AS null_account_pk,
	(SELECT count(*) FROM dim_donor WHERE donor_id IS NULL ) AS null_donor_pk;

-- Check for Nulls in fact table foreign keys

SELECT 
	count(*) AS total_expenditure_rows,
	sum(CASE WHEN vendor_id IS NULL THEN 1 ELSE 0 end)AS null_vendor_fk,
	sum(CASE WHEN project_id IS NULL THEN 1 ELSE 0 end) AS null_project_fk,
	sum(CASE WHEN account_id IS NULL THEN 1 ELSE 0 end) AS null_account_fk,
	sum(CASE WHEN period_id IS NULL THEN 1 ELSE 0 end) AS null_period_fk
FROM fact_expenditure;

-- findings 
-- no null primary key or foreign key
	
-- ------------------------------------------------------------------------------
-- 3. NULL & COMPLETENESS AUDIT (Identify missing critical fields)
-- ------------------------------------------------------------------------------
-- SELECT COUNT(*) AS total, COUNT(col_a) AS non_null_a FROM table_name;


-- ------------------------------------------------------------------------------
-- 4. SUMMARY OF FINDINGS (Document anomalies before moving to S2/S3)
-- ------------------------------------------------------------------------------
-- * Finding 1: ...
-- * Finding 2: ...