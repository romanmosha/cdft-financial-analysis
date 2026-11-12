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