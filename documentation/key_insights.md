# CDFT Analysis: Key Insights

> **Status:** Section 1 is PRELIMINARY, based on raw uncleaned data. Do not use for external reporting.
> Section 2 is filled in after the cleaning phase, when key queries are re-run on clean data.
> Percentages for vendors are share of vendor-linked spend, not total CDFT spend.

## 1. Preliminary findings (raw data)

### 1.1 Financial
- Malaria Rapid Diagnostic Testing Manyara is the highest spending project at TZS 604.6M.
- Health Centre Rehabilitation Moshi is the lowest at TZS 409.4M. Lead: low for a construction project, investigate.
- Salary payments are 36.6% of total expenditure (TZS 3.6B), the dominant cost category.
- ICT Equipment ranks second at TZS 1.35B (13.6%). Lead: unusually high, check for capital purchases outside plan.
- October has the highest monthly spend at TZS 1.04B vs a monthly average of TZS 824M. Lead: check for procurement clustering.

### 1.2 Vendors: who receives spend, and are they due-diligence approved?
- 8 vendors with PENDING due diligence status have received payments. Status is a current snapshot, so status at payment time is unconfirmed. Quantify post-cleaning.
- 11 vendors are blacklisted, with no payments recorded against their IDs. Re-test after duplicates are resolved.
- Suppliers receive 41% of vendor spend and Consultants 29%. Review the consultant share against indirect cost limits after cleaning.
- Top vendors: Northern Research and Consulting TZS 99.5M (2.30%), Savanna Office Supplies (1.77%), Savanna Office Enterprises (1.65%).
- Lead: the two Savanna records may be one vendor (combined 3.42%, which would make them the largest). See cleaning log CL-001.
- Lead: grouping by vendor_id reduced Northern from TZS 140M to 99.5M. Check whether one name is registered under two IDs. See CL-002.

### 1.3 Data quality
- 531 high outliers above the Tukey fence of TZS 3,720,625 (6.6% flag rate). Finance review needed before reporting. See CL-005.
- 11 negative transactions that appear to be reversals. Confirm each matches an original transaction. See CL-006.
- No zero-value transactions found.

## 2. Validated findings (post-cleaning)
*To be completed after the cleaning phase.*

| Metric | Preliminary (raw) | Validated (clean) | Change and reason |
|---|---|---|---|
| Top vendor spend | | | |
| PENDING vendors paid | 8 | | |
| Outlier count | 531 | | |