-- ============================================================================
-- File:      01_baseline_counts.sql
-- Phase:     02_cleaning, Step 1 (Safety and baseline)
-- Purpose:   Record exact row counts for all 18 tables as control totals.
--            Used later to confirm no rows are lost or duplicated when the
--            clean views are built and validated.
-- Date:      2026-11-19
-- Database:  <db_name>
-- Backup:    cdft_backup_2026-11-19.sql (stored outside the repo)
-- ============================================================================
-- displayind table name

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'cdft_fmis'
	AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- ------------------------------------------------------------------------------
-- 1. TABLE ROW COUNTS (Establish baseline volume)
-- ------------------------------------------------------------------------------
SELECT CONCAT(
         'SELECT ''', table_name, ''' AS table_name, COUNT(*) AS exact_rows FROM ',
         table_schema, '.', table_name, ' UNION ALL'
       ) AS sql_line
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_type = 'BASE TABLE'
ORDER BY table_name;


SELECT 'dim_account' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_account` UNION ALL
SELECT 'dim_activity' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_activity` UNION ALL
SELECT 'dim_asset' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_asset` UNION ALL
SELECT 'dim_budget_line' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_budget_line` UNION ALL
SELECT 'dim_cost_centre' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_cost_centre` UNION ALL
SELECT 'dim_donor' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_donor` UNION ALL
SELECT 'dim_fiscal_period' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_fiscal_period` UNION ALL
SELECT 'dim_grant' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_grant` UNION ALL
SELECT 'dim_location' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_location` UNION ALL
SELECT 'dim_procurement_status' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_procurement_status` UNION ALL
SELECT 'dim_program' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_program` UNION ALL
SELECT 'dim_project' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_project` UNION ALL
SELECT 'dim_staff' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_staff` UNION ALL
SELECT 'dim_vendor' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`dim_vendor` UNION ALL
SELECT 'fact_budget_allocation' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`fact_budget_allocation` UNION ALL
SELECT 'fact_expenditure' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`fact_expenditure` UNION ALL
SELECT 'fact_procurement' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`fact_procurement` UNION ALL
SELECT 'fact_training' AS table_name, COUNT(*) AS exact_rows FROM `cdft_fmis`.`fact_training`;

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
