# leap1000-impact-evaluation
Reproducible Stata code and documentation for my M.A. thesis evaluating Ghana’s LEAP 1000 cash transfer program using difference-in-differences and robustness checks.

# LEAP1000-Cash-Transfer-Evaluation

This repository contains the empirical analysis workflow for my M.A. thesis in Applied Economics, which evaluates the impact of Ghana’s LEAP 1000 cash transfer program on household welfare outcomes.[file:70] The analysis uses baseline and endline survey data from the LEAP 1000 Impact Evaluation and implements difference-in-differences and lagged one-difference models in Stata to study food security, savings, and stress.[file:68][file:70]

## Thesis title

**The Ghana LEAP 1000 Cash Transfer Program and Household Welfare**.[file:70]

## Project overview

The project studies whether participation in Ghana’s LEAP 1000 cash transfer program improved welfare among poor households with pregnant women, lactating mothers, and/or infants under 12 months.[file:70] LEAP 1000 was introduced in 2015 as an expansion of Ghana’s Livelihood Empowerment Against Poverty program and targeted vulnerable households in the Northern and Upper East regions.[file:70]

This repository translates the thesis into a reproducible research workflow by separating data preparation, variable construction, descriptive analysis, causal estimation, robustness checks, and output production into modular Stata scripts.[file:68][file:70]

## Research question

Does participation in the LEAP 1000 cash transfer program improve household welfare among poor households in Ghana?[file:70]

## Outcomes studied

The empirical analysis focuses on three welfare dimensions:[file:68][file:70]

- Food security, measured using both the number of meals consumed per day and an indicator for consuming three or more meals per day.[file:68][file:70]
- Savings, measured as the amount of cash savings reported in the last month.[file:68][file:70]
- Stress, measured using responses to the question on how often the respondent felt nervous and stressed in the past four weeks, operationalized both as a binary indicator and as a standardized outcome.[file:68][file:70]

## Data

The analysis uses the LEAP 1000 Impact Evaluation dataset collected in 2015 and 2017 through the Carolina Population Center / Transfer Project evaluation of Ghana’s LEAP 1000 program.[file:70] The baseline sample includes 2,497 households, and the endline sample includes 2,331 households, implying an attrition rate of 6.65 percent.[file:70]

The evaluation focused on five districts: Bongo, East Mamprusi, Garu-Tempane, Karaga, and Yendi.[file:70] The underlying evaluation design compared households around a proxy means test eligibility cutoff, which supported comparability between treatment and comparison groups.[file:70]

Because the original survey data are restricted, they are not included in this repository.[file:70]

## Empirical strategy

The primary identification strategy is Difference-in-Differences (DiD), implemented with district fixed effects and robust standard errors.[file:68][file:70] The main specification follows the thesis framework in which outcomes are regressed on treatment status, post-treatment period, their interaction, and district controls, with the interaction term interpreted as the program effect.[file:68][file:70]

The repository also includes lagged one-difference robustness checks that control for the baseline value of each outcome rather than using period fixed effects alone.[file:68][file:70] Heterogeneous effects by district are estimated separately for selected outcomes.[file:68][file:70]

## Main findings

The thesis finds that LEAP 1000 increased the probability that beneficiary households consumed three or more meals per day by about 6 percentage points.[file:70] It also finds an average increase in savings of roughly GH₵5 to GH₵5.5 per month, while showing no statistically significant effect on stress-related welfare outcomes.[file:70]

These results suggest that the program improved some resilience-related welfare measures, particularly food security and savings, but did not measurably reduce stress among eligible women in the study period.[file:70]

## Repository structure

```text
code/
  00_master.do
  01_data_preparation.do
  02_variable_construction.do
  03_descriptive_statistics.do
  04_difference_in_differences.do
  05_robustness_checks.do
  06_tables_and_figures.do

docs/
  Jessica_France_LEAP1000_Thesis.pdf
  Project_Overview.pdf
  Variable_Definitions.pdf

output/
  tables/
  figures/
  regression_output/
```

- `code/` contains the Stata workflow split into modular scripts.[file:68]
- `docs/` contains the thesis and short project documentation for readers.[file:70]
- `output/` stores tables, figures, and exported regression results.[file:68]

## Software

- Stata.[file:68][file:70]
- Microsoft Excel, for limited spreadsheet handling associated with research workflow documentation.[file:70]

## Reproducibility

The raw LEAP 1000 evaluation data are not publicly redistributed in this repository because they are subject to data-use restrictions.[file:70] The repository is intended to document the analytical workflow, coding practices, and econometric structure used in the thesis.[file:68][file:70]

To reproduce the analysis, place the restricted raw files in the expected project folders, update the file paths in the do-files, and run `00_master.do`.[file:68]

## Author

Jessica Naa L. France.[file:68][file:70]
