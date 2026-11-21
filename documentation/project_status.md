# CDFT Project Status
Updated: 2026-11-19

## Plan
SQL first (exploration, cleaning, analysis, advanced), then Tableau, then decide what follows.

## Progress
- [x] 01_exploration: Queries 1-7 (preliminary findings in key_insights)
- [ ] 02_cleaning
  - [x] Step 1: backup and baseline counts
  - [ ] Step 2: profile structure and keys
  - [ ] Step 3: profile content (NULLs, blanks, ranges, categories, currency)
  - [ ] Step 4: profile duplicates
  - [ ] Step 5: complete cleaning log
  - [ ] Step 6: decisions
  - [ ] Step 7: build v_clean_ views
  - [ ] Step 8: validate raw vs clean
  - [ ] Step 9: re-run Queries 1-7 on clean data
  - [ ] Step 10: close phase
- [ ] 03_analysis
- [ ] 04_advanced
- [ ] tableau

## Decisions
- Raw tables are never edited; cleaning happens in v_clean_ views.
- Database was imported from CSV with no PK/FK constraints, so integrity is checked manually.
- Findings on raw data are preliminary until re-run on clean data.
- Backup dump is stored outside the repo.

## Control totals
13,139 rows across 18 tables (see sql/02_cleaning/01_baseline_counts.sql).

## Open issues
See documentation/cleaning_log.md (CL-001 to CL-010 so far).

## Next step
Mon Nov 23: Task 3 Part B (double postings in fact_expenditure), Part C (procurement/expenditure link), then Task 4.
Estimate: cleaning done ~Dec 1 (one day later than planned, since Step 2 took longer).