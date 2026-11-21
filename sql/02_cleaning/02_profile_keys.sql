-- ============================================================================
-- File:      02_profile_keys.sql
-- Phase:     02_cleaning, Step 2 (Profile structure and keys)
-- Purpose:   Review column types, confirm keys, check key uniqueness and
--            orphan references. Find and record only, no fixes.
-- Date:      2026-11-20
-- Database:  cdft_fmis
-- ============================================================================

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- Findings:
-- 1. All 18 tables show IS_NULLABLE = 'YES' on every column (including IDs) -> 
-- check NULLs, blanks, and duplicate keys in row-level queries.
-- 2. Date, boolean/flag, and several numeric/percentage columns 
-- (e.g., disposal_proceeds, knowledge_gain_pct) use varchar -> profile values/formats before casting.
-- 3. dim_vendor.bank_account is bigint -> verify leading zeros/lengths; check self-links 
-- (parent_account_id, next_status_id) and fact_training.facilitator_id.

-- ============================================================
-- KEYS (table: key column)
-- ============================================================
-- dim_account: account_id
-- dim_activity: activity_id
-- dim_asset: asset_id
-- dim_budget_line: budget_line_id
-- dim_cost_centre: cost_centre_id
-- dim_donor: donor_id
-- dim_fiscal_period: period_id
-- dim_grant: grant_id
-- dim_location: location_id
-- dim_procurement_status: status_id
-- dim_program: program_id
-- dim_project: project_id
-- dim_staff: staff_id
-- dim_vendor: vendor_id
-- fact_budget_allocation: allocation_id
-- fact_expenditure: expenditure_id
-- fact_procurement: procurement_id
-- fact_training: training_id

-- ============================================================
-- RELATIONSHIPS (child.column -> parent table)
-- ============================================================
-- dim_account.parent_account_id -> dim_account
-- dim_activity.project_id -> dim_project
-- dim_activity.responsible_staff_id -> dim_staff
-- dim_asset.grant_id -> dim_grant
-- dim_asset.project_id -> dim_project
-- dim_asset.location_id -> dim_location
-- dim_asset.custodian_id -> dim_staff
-- dim_budget_line.grant_id -> dim_grant
-- dim_cost_centre.program_id -> dim_program
-- dim_cost_centre.location_id -> dim_location
-- dim_cost_centre.manager_id -> dim_staff
-- dim_grant.donor_id -> dim_donor
-- dim_grant.grant_manager_id -> dim_staff
-- dim_procurement_status.next_status_id -> dim_procurement_status
-- dim_program.program_director_id -> dim_staff
-- dim_project.grant_id -> dim_grant
-- dim_project.program_id -> dim_program
-- dim_project.location_id -> dim_location
-- dim_project.project_manager_id -> dim_staff
-- dim_staff.cost_centre_id -> dim_cost_centre
-- dim_staff.location_id -> dim_location
-- fact_budget_allocation.grant_id -> dim_grant
-- fact_budget_allocation.project_id -> dim_project
-- fact_budget_allocation.budget_line_id -> dim_budget_line
-- fact_budget_allocation.activity_id -> dim_activity
-- fact_budget_allocation.period_id -> dim_fiscal_period
-- fact_expenditure.grant_id -> dim_grant
-- fact_expenditure.project_id -> dim_project
-- fact_expenditure.activity_id -> dim_activity
-- fact_expenditure.budget_line_id -> dim_budget_line
-- fact_expenditure.account_id -> dim_account
-- fact_expenditure.cost_centre_id -> dim_cost_centre
-- fact_expenditure.location_id -> dim_location
-- fact_expenditure.period_id -> dim_fiscal_period
-- fact_expenditure.vendor_id -> dim_vendor
-- fact_expenditure.staff_id -> dim_staff
-- fact_expenditure.procurement_id -> fact_procurement
-- fact_procurement.grant_id -> dim_grant
-- fact_procurement.project_id -> dim_project
-- fact_procurement.budget_line_id -> dim_budget_line
-- fact_procurement.vendor_id -> dim_vendor
-- fact_procurement.location_id -> dim_location
-- fact_procurement.period_id -> dim_fiscal_period
-- fact_procurement.status_id -> dim_procurement_status
-- fact_procurement.expenditure_id -> fact_expenditure
-- fact_training.grant_id -> dim_grant
-- fact_training.project_id -> dim_project
-- fact_training.activity_id -> dim_activity
-- fact_training.location_id -> dim_location
-- fact_training.period_id -> dim_fiscal_period
-- fact_training.facilitator_id -> dim_staff

-- Total: 51 relationships
-- Unconfirmed (name suggests dim_staff, test in Task 4):
--   fact_expenditure.authorised_by, fact_expenditure.posted_by,
--   fact_budget_allocation.approved_by, dim_fiscal_period.closed_by
-- =========================
-- TASK 3: KEY UNIQUENES
-- =========================

SELECT concat(
	'SELECT ''',TABLE_NAME,''' AS table_name,''',
	COLUMN_NAME,''' AS key_col, ',
	'COUNT(*) AS total_rows, ',
	'COUNT(DISTINCT ', COLUMN_NAME, ')AS distinct_non_null,',
	'SUM(CASE WHEN ',COLUMN_NAME,' IS NULL OR UPPER(TRIM(',COLUMN_NAME,'))='''' THEN 1 ELSE 0 END) AS null_or_blank ',
'FROM ', TABLE_SCHEMA,'.',TABLE_NAME, ' UNION ALL'
) AS sql_line
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME LIKE 'dim\_%'
AND COLUMN_NAME LIKE '%\_id'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT 'dim_account' AS table_name,'account_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT account_id)AS distinct_non_null,SUM(CASE WHEN account_id IS NULL OR UPPER(TRIM(account_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_account UNION ALL
SELECT 'dim_account' AS table_name,'parent_account_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT parent_account_id)AS distinct_non_null,SUM(CASE WHEN parent_account_id IS NULL OR UPPER(TRIM(parent_account_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_account UNION ALL
SELECT 'dim_activity' AS table_name,'activity_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT activity_id)AS distinct_non_null,SUM(CASE WHEN activity_id IS NULL OR UPPER(TRIM(activity_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_activity UNION ALL
SELECT 'dim_activity' AS table_name,'project_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT project_id)AS distinct_non_null,SUM(CASE WHEN project_id IS NULL OR UPPER(TRIM(project_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_activity UNION ALL
SELECT 'dim_activity' AS table_name,'responsible_staff_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT responsible_staff_id)AS distinct_non_null,SUM(CASE WHEN responsible_staff_id IS NULL OR UPPER(TRIM(responsible_staff_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_activity UNION ALL
SELECT 'dim_asset' AS table_name,'asset_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT asset_id)AS distinct_non_null,SUM(CASE WHEN asset_id IS NULL OR UPPER(TRIM(asset_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_asset UNION ALL
SELECT 'dim_asset' AS table_name,'grant_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT grant_id)AS distinct_non_null,SUM(CASE WHEN grant_id IS NULL OR UPPER(TRIM(grant_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_asset UNION ALL
SELECT 'dim_asset' AS table_name,'project_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT project_id)AS distinct_non_null,SUM(CASE WHEN project_id IS NULL OR UPPER(TRIM(project_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_asset UNION ALL
SELECT 'dim_asset' AS table_name,'location_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT location_id)AS distinct_non_null,SUM(CASE WHEN location_id IS NULL OR UPPER(TRIM(location_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_asset UNION ALL
SELECT 'dim_asset' AS table_name,'custodian_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT custodian_id)AS distinct_non_null,SUM(CASE WHEN custodian_id IS NULL OR UPPER(TRIM(custodian_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_asset UNION ALL
SELECT 'dim_budget_line' AS table_name,'budget_line_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT budget_line_id)AS distinct_non_null,SUM(CASE WHEN budget_line_id IS NULL OR UPPER(TRIM(budget_line_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_budget_line UNION ALL
SELECT 'dim_budget_line' AS table_name,'grant_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT grant_id)AS distinct_non_null,SUM(CASE WHEN grant_id IS NULL OR UPPER(TRIM(grant_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_budget_line UNION ALL
SELECT 'dim_cost_centre' AS table_name,'cost_centre_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT cost_centre_id)AS distinct_non_null,SUM(CASE WHEN cost_centre_id IS NULL OR UPPER(TRIM(cost_centre_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_cost_centre UNION ALL
SELECT 'dim_cost_centre' AS table_name,'program_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT program_id)AS distinct_non_null,SUM(CASE WHEN program_id IS NULL OR UPPER(TRIM(program_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_cost_centre UNION ALL
SELECT 'dim_cost_centre' AS table_name,'location_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT location_id)AS distinct_non_null,SUM(CASE WHEN location_id IS NULL OR UPPER(TRIM(location_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_cost_centre UNION ALL
SELECT 'dim_cost_centre' AS table_name,'manager_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT manager_id)AS distinct_non_null,SUM(CASE WHEN manager_id IS NULL OR UPPER(TRIM(manager_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_cost_centre UNION ALL
SELECT 'dim_donor' AS table_name,'donor_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT donor_id)AS distinct_non_null,SUM(CASE WHEN donor_id IS NULL OR UPPER(TRIM(donor_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_donor UNION ALL
SELECT 'dim_fiscal_period' AS table_name,'period_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT period_id)AS distinct_non_null,SUM(CASE WHEN period_id IS NULL OR UPPER(TRIM(period_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_fiscal_period UNION ALL
SELECT 'dim_grant' AS table_name,'grant_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT grant_id)AS distinct_non_null,SUM(CASE WHEN grant_id IS NULL OR UPPER(TRIM(grant_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_grant UNION ALL
SELECT 'dim_grant' AS table_name,'donor_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT donor_id)AS distinct_non_null,SUM(CASE WHEN donor_id IS NULL OR UPPER(TRIM(donor_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_grant UNION ALL
SELECT 'dim_grant' AS table_name,'grant_manager_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT grant_manager_id)AS distinct_non_null,SUM(CASE WHEN grant_manager_id IS NULL OR UPPER(TRIM(grant_manager_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_grant UNION ALL
SELECT 'dim_location' AS table_name,'location_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT location_id)AS distinct_non_null,SUM(CASE WHEN location_id IS NULL OR UPPER(TRIM(location_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_location UNION ALL
SELECT 'dim_procurement_status' AS table_name,'status_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT status_id)AS distinct_non_null,SUM(CASE WHEN status_id IS NULL OR UPPER(TRIM(status_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_procurement_status UNION ALL
SELECT 'dim_procurement_status' AS table_name,'next_status_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT next_status_id)AS distinct_non_null,SUM(CASE WHEN next_status_id IS NULL OR UPPER(TRIM(next_status_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_procurement_status UNION ALL
SELECT 'dim_program' AS table_name,'program_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT program_id)AS distinct_non_null,SUM(CASE WHEN program_id IS NULL OR UPPER(TRIM(program_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_program UNION ALL
SELECT 'dim_program' AS table_name,'program_director_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT program_director_id)AS distinct_non_null,SUM(CASE WHEN program_director_id IS NULL OR UPPER(TRIM(program_director_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_program UNION ALL
SELECT 'dim_project' AS table_name,'project_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT project_id)AS distinct_non_null,SUM(CASE WHEN project_id IS NULL OR UPPER(TRIM(project_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_project UNION ALL
SELECT 'dim_project' AS table_name,'grant_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT grant_id)AS distinct_non_null,SUM(CASE WHEN grant_id IS NULL OR UPPER(TRIM(grant_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_project UNION ALL
SELECT 'dim_project' AS table_name,'program_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT program_id)AS distinct_non_null,SUM(CASE WHEN program_id IS NULL OR UPPER(TRIM(program_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_project UNION ALL
SELECT 'dim_project' AS table_name,'location_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT location_id)AS distinct_non_null,SUM(CASE WHEN location_id IS NULL OR UPPER(TRIM(location_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_project UNION ALL
SELECT 'dim_project' AS table_name,'project_manager_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT project_manager_id)AS distinct_non_null,SUM(CASE WHEN project_manager_id IS NULL OR UPPER(TRIM(project_manager_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_project UNION ALL
SELECT 'dim_staff' AS table_name,'staff_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT staff_id)AS distinct_non_null,SUM(CASE WHEN staff_id IS NULL OR UPPER(TRIM(staff_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_staff UNION ALL
SELECT 'dim_staff' AS table_name,'cost_centre_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT cost_centre_id)AS distinct_non_null,SUM(CASE WHEN cost_centre_id IS NULL OR UPPER(TRIM(cost_centre_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_staff UNION ALL
SELECT 'dim_staff' AS table_name,'location_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT location_id)AS distinct_non_null,SUM(CASE WHEN location_id IS NULL OR UPPER(TRIM(location_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_staff UNION ALL
SELECT 'dim_staff' AS table_name,'national_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT national_id)AS distinct_non_null,SUM(CASE WHEN national_id IS NULL OR UPPER(TRIM(national_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_staff UNION ALL
SELECT 'dim_vendor' AS table_name,'vendor_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT vendor_id)AS distinct_non_null,SUM(CASE WHEN vendor_id IS NULL OR UPPER(TRIM(vendor_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_vendor UNION ALL
SELECT 'dim_vendor' AS table_name,'tax_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT tax_id)AS distinct_non_null,SUM(CASE WHEN tax_id IS NULL OR UPPER(TRIM(tax_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.dim_vendor;

-- Fact tables

SELECT concat(
	'SELECT ''',TABLE_NAME,''' AS table_name,''',
	COLUMN_NAME,''' AS key_col, ',
	'COUNT(*) AS total_rows, ',
	'COUNT(DISTINCT ', COLUMN_NAME, ')AS distinct_non_null,',
	'SUM(CASE WHEN ',COLUMN_NAME,' IS NULL OR UPPER(TRIM(',COLUMN_NAME,'))='''' THEN 1 ELSE 0 END) AS null_or_blank ',
'FROM ', TABLE_SCHEMA,'.',TABLE_NAME, ' UNION ALL'
) AS sql_line
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME LIKE 'fact\_%'
AND COLUMN_NAME LIKE '%\_id'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT 'fact_budget_allocation' AS table_name,'allocation_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT allocation_id)AS distinct_non_null,SUM(CASE WHEN allocation_id IS NULL OR UPPER(TRIM(allocation_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_budget_allocation UNION ALL
SELECT 'fact_budget_allocation' AS table_name,'grant_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT grant_id)AS distinct_non_null,SUM(CASE WHEN grant_id IS NULL OR UPPER(TRIM(grant_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_budget_allocation UNION ALL
SELECT 'fact_budget_allocation' AS table_name,'project_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT project_id)AS distinct_non_null,SUM(CASE WHEN project_id IS NULL OR UPPER(TRIM(project_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_budget_allocation UNION ALL
SELECT 'fact_budget_allocation' AS table_name,'budget_line_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT budget_line_id)AS distinct_non_null,SUM(CASE WHEN budget_line_id IS NULL OR UPPER(TRIM(budget_line_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_budget_allocation UNION ALL
SELECT 'fact_budget_allocation' AS table_name,'activity_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT activity_id)AS distinct_non_null,SUM(CASE WHEN activity_id IS NULL OR UPPER(TRIM(activity_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_budget_allocation UNION ALL
SELECT 'fact_budget_allocation' AS table_name,'period_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT period_id)AS distinct_non_null,SUM(CASE WHEN period_id IS NULL OR UPPER(TRIM(period_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_budget_allocation UNION ALL
SELECT 'fact_expenditure' AS table_name,'expenditure_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT expenditure_id)AS distinct_non_null,SUM(CASE WHEN expenditure_id IS NULL OR UPPER(TRIM(expenditure_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'grant_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT grant_id)AS distinct_non_null,SUM(CASE WHEN grant_id IS NULL OR UPPER(TRIM(grant_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'project_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT project_id)AS distinct_non_null,SUM(CASE WHEN project_id IS NULL OR UPPER(TRIM(project_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'activity_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT activity_id)AS distinct_non_null,SUM(CASE WHEN activity_id IS NULL OR UPPER(TRIM(activity_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'budget_line_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT budget_line_id)AS distinct_non_null,SUM(CASE WHEN budget_line_id IS NULL OR UPPER(TRIM(budget_line_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'account_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT account_id)AS distinct_non_null,SUM(CASE WHEN account_id IS NULL OR UPPER(TRIM(account_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'cost_centre_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT cost_centre_id)AS distinct_non_null,SUM(CASE WHEN cost_centre_id IS NULL OR UPPER(TRIM(cost_centre_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'location_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT location_id)AS distinct_non_null,SUM(CASE WHEN location_id IS NULL OR UPPER(TRIM(location_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'period_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT period_id)AS distinct_non_null,SUM(CASE WHEN period_id IS NULL OR UPPER(TRIM(period_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'vendor_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT vendor_id)AS distinct_non_null,SUM(CASE WHEN vendor_id IS NULL OR UPPER(TRIM(vendor_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'staff_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT staff_id)AS distinct_non_null,SUM(CASE WHEN staff_id IS NULL OR UPPER(TRIM(staff_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_expenditure' AS table_name,'procurement_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT procurement_id)AS distinct_non_null,SUM(CASE WHEN procurement_id IS NULL OR UPPER(TRIM(procurement_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_expenditure UNION ALL
SELECT 'fact_procurement' AS table_name,'procurement_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT procurement_id)AS distinct_non_null,SUM(CASE WHEN procurement_id IS NULL OR UPPER(TRIM(procurement_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_procurement UNION ALL
SELECT 'fact_procurement' AS table_name,'grant_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT grant_id)AS distinct_non_null,SUM(CASE WHEN grant_id IS NULL OR UPPER(TRIM(grant_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_procurement UNION ALL
SELECT 'fact_procurement' AS table_name,'project_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT project_id)AS distinct_non_null,SUM(CASE WHEN project_id IS NULL OR UPPER(TRIM(project_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_procurement UNION ALL
SELECT 'fact_procurement' AS table_name,'budget_line_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT budget_line_id)AS distinct_non_null,SUM(CASE WHEN budget_line_id IS NULL OR UPPER(TRIM(budget_line_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_procurement UNION ALL
SELECT 'fact_procurement' AS table_name,'vendor_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT vendor_id)AS distinct_non_null,SUM(CASE WHEN vendor_id IS NULL OR UPPER(TRIM(vendor_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_procurement UNION ALL
SELECT 'fact_procurement' AS table_name,'location_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT location_id)AS distinct_non_null,SUM(CASE WHEN location_id IS NULL OR UPPER(TRIM(location_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_procurement UNION ALL
SELECT 'fact_procurement' AS table_name,'period_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT period_id)AS distinct_non_null,SUM(CASE WHEN period_id IS NULL OR UPPER(TRIM(period_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_procurement UNION ALL
SELECT 'fact_procurement' AS table_name,'status_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT status_id)AS distinct_non_null,SUM(CASE WHEN status_id IS NULL OR UPPER(TRIM(status_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_procurement UNION ALL
SELECT 'fact_procurement' AS table_name,'expenditure_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT expenditure_id)AS distinct_non_null,SUM(CASE WHEN expenditure_id IS NULL OR UPPER(TRIM(expenditure_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_procurement UNION ALL
SELECT 'fact_training' AS table_name,'training_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT training_id)AS distinct_non_null,SUM(CASE WHEN training_id IS NULL OR UPPER(TRIM(training_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_training UNION ALL
SELECT 'fact_training' AS table_name,'grant_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT grant_id)AS distinct_non_null,SUM(CASE WHEN grant_id IS NULL OR UPPER(TRIM(grant_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_training UNION ALL
SELECT 'fact_training' AS table_name,'project_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT project_id)AS distinct_non_null,SUM(CASE WHEN project_id IS NULL OR UPPER(TRIM(project_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_training UNION ALL
SELECT 'fact_training' AS table_name,'activity_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT activity_id)AS distinct_non_null,SUM(CASE WHEN activity_id IS NULL OR UPPER(TRIM(activity_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_training UNION ALL
SELECT 'fact_training' AS table_name,'location_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT location_id)AS distinct_non_null,SUM(CASE WHEN location_id IS NULL OR UPPER(TRIM(location_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_training UNION ALL
SELECT 'fact_training' AS table_name,'period_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT period_id)AS distinct_non_null,SUM(CASE WHEN period_id IS NULL OR UPPER(TRIM(period_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_training UNION ALL
SELECT 'fact_training' AS table_name,'facilitator_id' AS key_col, COUNT(*) AS total_rows, COUNT(DISTINCT facilitator_id)AS distinct_non_null,SUM(CASE WHEN facilitator_id IS NULL OR UPPER(TRIM(facilitator_id))='' THEN 1 ELSE 0 END) AS null_or_blank FROM cdft_fmis.fact_training;

-- TASK 1: COLUMN TYPES
-- Dates, flags and some numbers stored as varchar; multi-currency data. See CL-001 to CL-006.

-- TASK 2: KEYS AND RELATIONSHIPS
-- Keys = first column of each table. 51 relationships mapped (4 unconfirmed staff references,
-- to test in Task 4).

-- TASK 3: KEY UNIQUENESS
-- Part A done: all 18 keys unique, no blank keys.
-- Blanks are stored as '' not NULL (CL-007). 6 vendors have no tax_id; non-blank tax_ids all
-- unique (CL-008). fact_expenditure: 66% of rows have no vendor, 76% no staff (CL-010).
-- Part B (double postings) and Part C (procurement/expenditure link): pending.