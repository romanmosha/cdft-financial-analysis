# cdft-financial-analysis
End to end NGO financial analysis — MySQL, Excel Power Query, Power Pivot, DAX, Tableau
## 📊 About the Data
> **Data Privacy Note:** All data utilized in this project is **AI-synthesized mock data** generated specifically to simulate enterprise workloads, test edge cases, and showcase analytical workflows. No real-world proprietary or sensitive business data is exposed in this repository.

*This project is actively in progress. 
Expected completion: October 2026*

## Overview
Community Development Foundation Tanzania (CDFT) is a fictional NGO 
operating Health, Education, Women's Economic Empowerment, Climate 
Resilience, Agriculture and Child Protection programmes across 
Kilimanjaro, Arusha and Manyara regions.

This project analyses CDFT's financial management data covering 
12 active grants, 20 projects, 8,000 expenditure transactions and 
2,500 procurement records across 2025.

The analysis supports executive financial reporting, donor 
utilisation tracking, procurement compliance monitoring and 
programme M&E reporting — the same outputs required by real NGOs 
funded by USAID, UNICEF, FCDO and the EU.

## Business Questions Answered

**Financial Management**
- Which projects are overspending or underspending against budget?
- What is the monthly burn rate and is it on track?
- Which transaction types consume the largest share of expenditure?

**Procurement and Compliance**
- Which vendors receive the most spend and are they due-diligence approved?
- What is the average procurement cycle time from PO to payment?
- Are procurement thresholds being respected — correct number of quotations obtained?

**Donor Reporting**
- What is the grant utilisation rate per donor?
- Which grants are at risk of underspend before the end date?

**Programme M&E**
- How many beneficiaries have been reached per programme?
- What is the cost per beneficiary across projects?
- What is the training reach disaggregated by sex, age and disability?

**Data Quality**
- Does the financial data contain impossible values, outliers or 
  duplicates that could distort reporting?

## Dataset
A synthetic relational database designed to mirror a real NGO 
Financial Management Information System (FMIS).

| Table | Type | Rows | Description |
|---|---|---|---|
| dim_donor | Dimension | 8 | Funding organisations |
| dim_grant | Dimension | 12 | Grant agreements |
| dim_project | Dimension | 20 | Implementation projects |
| dim_staff | Dimension | 120 | Personnel records |
| dim_vendor | Dimension | 150 | Supplier register |
| fact_expenditure | Fact | 8,000 | All financial transactions |
| fact_procurement | Fact | 2,500 | Purchase orders |
| fact_training | Fact | 450 | Training activities |
| ... | ... | ... | ... |

**Data quality issues intentionally introduced** for cleaning practice:
- Mixed date formats across procurement and expenditure
- Negative expenditure outliers
- Duplicate vendor names and invoice references
- Missing document references and payment dates
- Inconsistent district name spellings

*Note: All data is synthetic and generated for portfolio purposes. 
No real organisation or individual is represented.*

## Tools and Methodology

**MySQL (XAMPP)** — Database setup, data import and SQL-based 
exploration. Queries progress from basic aggregations through 
subqueries, CTEs and window functions as complexity increases.


*This project is actively in progress. 
Expected completion: October 2026*

## Author
Roman Mosha 
**LinkedIn :** www.linkedin.com/in/roman-mosha-264255a7
**Github:** https://github.com/romanmosha