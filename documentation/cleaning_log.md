# Cleaning Log

Raw tables are never edited. Fixes are applied in clean views.

| ID | Table.column | Issue | Found by | Rows | Proposed rule | Decision | Status |
|---|---|---|---|---|---|---|---|
| CL-001 | dim_vendor.vendor_name | Savanna Office Supplies / Savanna Office Enterprises may be one vendor | Query 7 | | Compare TIN, bank, address; merge only if confirmed | | Suspected |
| CL-002 | dim_vendor.vendor_id | Northern Research and Consulting may exist under two IDs | Query 7 (140M to 99.5M) | | Same check as CL-001 | | Suspected |
| CL-003 | fact_expenditure.amount_original | Possible mixed currencies | Raised in Query 7 review | | Check currency columns; convert or split | | Suspected |
| CL-004 | fact_expenditure.vendor_id | NULL vendor_id rows | Query 7 review | | Count and classify; keep, but report separately | | Suspected |
| CL-005 | fact_expenditure.amount_original | 531 high outliers above TZS 3,720,625 | Exploration | 531 | Flag, don't remove; finance to review | | Open |
| CL-006 | fact_expenditure.amount_original | 11 negative amounts (likely reversals) | Exploration | 11 | Confirm pairing, then keep | | Open |
| CL-007 | dim_vendor.vendor_name | 14 exact duplicate vendor names (e.g., Community Office Co, Northern Office Ltd) impacting 29 total rows | Task 3 (Duplicates Check) | 29 | Inspect underlying identifiers (TIN, registration, bank/contact) to confirm duplicates | | Open |
| CL-008 | dim_vendor.vendor_name | Exact duplicate 'Savanna Office Services' split across VND-0077 and VND-0129, alongside unstandardized lowercase entries | Task 3 (Savanna Pattern Check) | 2 | Cross-check TIN and contact details to verify independent vs. split records | | Open |
| CL-009 | dim_vendor.vendor_name | 4 exact duplicate 'Northern' vendor pairs across 8 distinct IDs (Consulting Associates, General Co, Office Ltd, Research and Consulting) | Task 3 (Northern Pattern Check) | 8 | Compare TIN and operational identifiers to verify duplicate onboarding | | Open |
| CL-010 | dim_project.project_name | Zero exact duplicate project names found; business key uniqueness holds | Task 3 (Project Check) | 0 | None required; project business keys verified clean | | Confirmed Clean |
| CL-011 | PKs and FKs across all tables | Zero NULLs detected across primary and foreign key columns | Task 3 (NULL Checks) | 0 | Structural key integrity confirmed; proceed to referential joins safely | | Confirmed Clean |