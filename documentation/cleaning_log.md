# Cleaning Log

| ID | Table.column | Issue | Found by | Rows | Proposed rule | Decision | Status |
|---|---|---|---|---|---|---|---|
| CL-001 | dim_vendor.vendor_name | Savanna Office Supplies / Savanna Office Enterprises may be one vendor | Query 7 | | Compare TIN, bank, address; merge only if confirmed | | Suspected |
| CL-002 | dim_vendor.vendor_id | Northern Research and Consulting may exist under two IDs | Query 7 (140M to 99.5M) | | Same check as CL-001 | | Suspected |
| CL-003 | fact_expenditure.amount_original | Possible mixed currencies | Raised in Query 7 review | | Check currency columns; convert or split | | Suspected |
| CL-004 | fact_expenditure.vendor_id | NULL vendor_id rows | Query 7 review | | Count and classify; keep, but report separately | | Suspected |
| CL-005 | fact_expenditure.amount_original | 531 high outliers above TZS 3,720,625 | Exploration | 531 | Flag, don't remove; finance to review | | Open |
| CL-006 | fact_expenditure.amount_original | 11 negative amounts (likely reversals) | Exploration | 11 | Confirm pairing, then keep | | Open |
| CL-007 | dim_vendor.vendor_name | 14 exact duplicate vendor names (impacts 29 records), including specific duplicate pairs for 'Savanna Office Services' and 4 'Northern' entities | Task 3 (Duplicates Check) | 29 | Inspect underlying identifiers (TIN, registration, bank/contact) to confirm and merge exact duplicates | | Open |
| CL-008 | dim_project.project_name | Zero exact duplicate project names found; business key uniqueness holds | Task 3 (Project Check) | 0 | None required; project business keys verified clean | | Confirmed Clean |
| CL-009 | PKs and FKs across all tables | Zero NULLs detected across primary and foreign key columns | Task 3 (NULL Checks) | 0 | Structural key integrity confirmed; proceed to referential joins safely | | Confirmed Clean |