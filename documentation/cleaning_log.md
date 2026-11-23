# Cleaning Log

Raw tables are never edited; fixes are applied in v_clean_ views.
Status: Open > Decided > Fixed (in view) > Verified (or Closed: no issue).

| ID | Table.column | Issue | Found by | Proposed rule | Decision | Status |
|---|---|---|---|---|---|---|
| CL-001 | 31 date columns across 11 tables (e.g. fact_expenditure.transaction_date, fact_procurement.po_date) | Dates stored as varchar | Step 2, column review | Check format in Step 3; convert to DATE in clean views; flag unparseable values | | Open |
| CL-002 | 12 flag columns (is_blacklisted, is_reversal, preferred_vendor, is_active, etc.) | Flags stored as varchar; value variants unknown | Step 2, column review | Check distinct values in Step 3; standardise in views | | Open |
| CL-003 | dim_asset.disposal_proceeds; fact_training pre_assessment_avg, post_assessment_avg, knowledge_gain_pct | Numeric values stored as varchar | Step 2, column review | Check for non-numeric entries; CAST in views | | Open |
| CL-004 | fact_expenditure.amount_original (and ~10 tables with a currency column) | Multi-currency data: amount_original is in each row's own currency | Step 2, column review | Step 3: check original_currency values and exchange_rate; choose amount_usd or amount_grant_currency for cross-currency totals | | Open |
| CL-005 | dim_vendor.bank_account (bigint), dim_budget_line.line_code (decimal) | Odd types: leading zeros lost; code stored as decimal | Step 2, column review | Low risk; keep, but note bank_account may not match across duplicate vendors if formatted differently | | Open |
| CL-006 | dim_staff.national_id, phone, email; dim_vendor.phone, email | Personal data fields | Step 2, column review | Exclude from clean views and Tableau | | Open |
| CL-007 | All tables (confirmed in dim_vendor.tax_id, dim_cost_centre.program_id, dim_procurement_status.next_status_id) | Missing values stored as empty strings, not NULL; earlier "zero NULLs" check was incomplete | Step 2, Task 3 | In views, convert '' to NULL with NULLIF; Step 3 profiles blanks in every column | | Open |
| CL-008 | dim_vendor.tax_id | 6 vendors have no tax ID; all 144 non-blank values are unique, so no shared-TIN duplicates | Step 2, Task 3 | Keep; flag missing TIN in clean view; use bank_account/registration_number for duplicate matching in Step 4 | | Open |
| CL-009 | dim_cost_centre.program_id | 2 of 8 cost centres have no program | Step 2, Task 3 | Check which ones in Task 4; likely shared/admin, keep | | Open |
| CL-010 | fact_expenditure.vendor_id, staff_id | 66% of rows have no vendor and 76% have no staff; at least 3,334 rows (42%) have neither | Step 2, Task 3 | Expected for salaries; check transaction_type of the no-payee rows in Step 3; convert '' to NULL; report vendor analysis as % of vendor-linked spend | | Open |
| CL-011 | fact_budget_allocation (grant, project, budget_line) | Covers 11/12 grants, 15/20 projects, 72/229 budget lines, while expenditure covers 12/20/229 | Step 2, Task 3 | Keep; decide at analysis stage which table holds the budget for budget-vs-actual | | Open |
| CL-012 | fact_expenditure (EXP-2025-01161, EXP-2025-01233) | Potential double posting: same project, date, amount (TZS 679,000), description; differ in activity, budget line, payment references and method; 01233 is annotated "Potential duplicate entry" in notes. Also 01233: amount_usd (61.25) does not match amount_original / exchange_rate (about 273.60) | Step 2, Task 3 Part B | Keep both rows; flag in clean view; refer to finance for confirmation. Include amount_usd mismatch in the Step 3 calculation check | | Open (referred to finance) |
## Control totals
13,139 rows across 18 tables (see sql/02_cleaning/01_baseline_counts.sql).