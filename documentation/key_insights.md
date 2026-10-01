# CDFT Analysis — Key Insights

## Pre-Cleaning Validated Findings
-- NOTE: Findings below are preliminary and based on raw uncleaned
-- data. Numbers will be validated and confirmed after the SQL
-- cleaning phase is complete. Do not use for external reporting.

## SQL Exploration Phase

### Financial Findings
- Malaria Rapid Diagnostic Testing Manyara is the highest 
  spending project at TZS 604.6M
- Health Centre Rehabilitation Moshi is lowest at TZS 409.4M
  — unusual for a construction project, warrants investigation
- Salary payments account for 36.6% of total expenditure 
  at TZS 3.6B — dominant cost category as expected for an NGO
- ICT Equipment ranks second at TZS 1.35B (13.6%) — unusually
  high, may reflect unplanned capital purchases
- October highest monthly spend at TZS 1.04B vs average TZS 824M
  — procurement clustering pattern warrants investigation
 
 ### Business question: Which vendor receive the most spend from CDFT and are they 
-- due diligence approved, meaning are we paying compitent suppliers?
- RISK: 8 vendors with PENDING due diligence status have received payments. 
  This violates standard NGO procurement policy which requires due diligence 
  clearance before first payment.
- Finance team must resolve pending checks immediately and report to relevant 
  donors if required by grant conditions <br>
- COMPLIANCE: 11 blacklisted vendors confirmed,zero payments
  made to any blacklisted vendor. Controls are working.

- SPEND DISTRIBUTION by vendor type: Suppliers receive 41% of total vendor spend,
  Consultants 29% -- consultant share warrants review against approved indirect cost rates.

- TOP VENDORS : Northern Research and Consulting leads at TZS 140M (3.2% of total spend), 
followed by Savanna Office Supplies (1.8%) and Savanna Office Enterprise (1.64%).
- NOTE: Savanna Office Supplies and Savanna Office Enterprise may be duplicate vendor 
registrations for the same entity flag for due diligence review and potential vendor merge.


### Data Quality Findings
- 531 high outliers identified above Tukey fence of TZS 3,720,625
  — 6.6% flag rate requiring finance team review before reporting
- 11 confirmed reversal transactions with negative values
  — legitimate accounting entries, no action required
- Zero value transactions: none found

## Power Query Cleaning Phase
*Pending*

