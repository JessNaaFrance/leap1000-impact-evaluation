/********************************************************************************************
PROJECT: LEAP 1000 Ghana
FILE: 03_analysis.do

PURPOSE:
    Produce descriptive statistics, Difference-in-Differences estimates,
    Lagged One-Difference models, heterogeneous treatment effects,
    robustness checks, and publication-ready tables and figures.

INPUT:
    data/analysis/analysis_pooled.dta

OUTPUT:
    output/tables/
    output/figures/

AUTHOR:
    Jessica France
********************************************************************************************/

clear all
set more off
set varabbrev off
version 16

*------------------------------------------------------------*
* Install required packages (first run only)
*------------------------------------------------------------*

capture which esttab
if _rc ssc install estout

capture which eststo
if _rc ssc install estout

capture which coefplot
if _rc ssc install coefplot

capture which outreg2
if _rc ssc install outreg2

capture which distinct
if _rc ssc install distinct

*------------------------------------------------------------*
* Project directories
*------------------------------------------------------------*

global analysis "$project/data/analysis"

global tables "$project/output/tables"

global figures "$project/output/figures"

capture mkdir "$tables"
capture mkdir "$figures"

cd "$project"

display "==============================================="
display "LEAP 1000 ANALYSIS"
display "==============================================="
display ""

*------------------------------------------------------------*
* Load analytical dataset
*------------------------------------------------------------*

use "$analysis/analysis_pooled.dta", clear

/********************************************************************************************
                              DATA VALIDATION
********************************************************************************************/

display "----------------------------------------------"
display "VALIDATING ANALYSIS DATASET"
display "----------------------------------------------"

describe

codebook

summarize

misstable summarize

distinct hhid

tab period

tab treatment

tab district

tab treatment period

tab moretwo

tab stress

summarize foodsec saving upset

display "----------------------------------------------"
display "Dataset successfully loaded."
display "----------------------------------------------"
display ""

/********************************************************************************************
                              SAMPLE SIZES
********************************************************************************************/

display "----------------------------------------------"
display "SAMPLE SIZES"
display "----------------------------------------------"

count

count if period==0

count if period==1

count if treatment==1

count if treatment==0

tab treatment period

bysort district: count

bysort district treatment: count

/********************************************************************************************
                        DESCRIPTIVE STATISTICS
********************************************************************************************/

display "----------------------------------------------"
display "DESCRIPTIVE STATISTICS"
display "----------------------------------------------"

eststo clear

estpost summarize ///
foodsec ///
moretwo ///
saving ///
stress ///
upset ///
kids ///
kidsn ///
size ///
size_ew ///
femaleheads ///
femaleheadsn ///
infants

esttab using ///
"$tables/Table_1_Descriptive_Statistics.rtf", ///
replace ///
cells("count mean sd min max") ///
label ///
title("Table 1. Descriptive Statistics") ///
nonumber ///
nomtitle

/********************************************************************************************
                  DESCRIPTIVE STATISTICS BY TREATMENT
********************************************************************************************/

estpost tabstat ///
foodsec ///
saving ///
stress ///
upset ///
kids ///
size ///
size_ew, ///
statistics(mean sd) ///
by(treatment)

esttab using ///
"$tables/Table_2_Treatment_Control_Statistics.rtf", ///
replace ///
cells("mean sd") ///
label ///
title("Table 2. Summary Statistics by Treatment Status")

/********************************************************************************************
                    EXPORT DESCRIPTIVE STATISTICS
********************************************************************************************/

preserve

collapse ///
(mean) foodsec ///
moretwo ///
saving ///
stress ///
upset ///
kids ///
kidsn ///
size ///
size_ew ///
femaleheads ///
femaleheadsn ///
infants, ///
by(treatment)

export excel using ///
"$tables/descriptive_statistics.xlsx", ///
replace ///
firstrow(variables)

restore

/********************************************************************************************
                        INITIAL DESCRIPTIVE FIGURES
********************************************************************************************/

graph bar ///
(mean) foodsec, ///
over(treatment) ///
title("Average Food Security by Treatment Status") ///
ytitle("Mean Food Security")

graph export ///
"$figures/food_security_by_treatment.png", ///
replace


graph bar ///
(mean) saving, ///
over(treatment) ///
title("Average Monthly Savings by Treatment Status")

graph export ///
"$figures/savings_by_treatment.png", ///
replace


graph bar ///
(mean) stress, ///
over(treatment) ///
title("Average Stress by Treatment Status")

graph export ///
"$figures/stress_by_treatment.png", ///
replace

display ""
display "----------------------------------------------"
display "SECTION 1 COMPLETE"
display "Proceeding to baseline balance tests..."
display "----------------------------------------------"

/********************************************************************************************
                            SECTION 2
                    BASELINE BALANCE TESTS
********************************************************************************************/

display ""
display "===================================================="
display "SECTION 2: BASELINE BALANCE TESTS"
display "===================================================="

*------------------------------------------------------------*
* Baseline observations only
*------------------------------------------------------------*

preserve

keep if period==0

display ""
display "Baseline sample size:"
count

display ""
display "Treatment allocation"
tab treatment

*------------------------------------------------------------*
* Baseline Balance Regressions
*------------------------------------------------------------*

eststo clear

reg size i.treatment, robust
eststo HHSize

reg kids i.treatment, robust
eststo Kids

reg infants i.treatment, robust
eststo Infants

reg preg i.treatment, robust
eststo Pregnancy

reg size_ew i.treatment, robust
eststo EligibleWomen

reg femaleheads i.treatment, robust
eststo FemaleHeads

*------------------------------------------------------------*
* Export Table 3
*------------------------------------------------------------*

esttab ///
HHSize ///
Kids ///
Infants ///
Pregnancy ///
EligibleWomen ///
FemaleHeads ///
using ///
"$tables/Table_3_Baseline_Balance.rtf", ///
replace ///
label ///
b(3) ///
se(3) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(N r2, ///
labels("Observations" "R-squared")) ///
title("Table 3. Baseline Balance Tests") ///
compress

*------------------------------------------------------------*
* Means by treatment group
*------------------------------------------------------------*

estpost tabstat ///
size ///
kids ///
infants ///
preg ///
size_ew ///
femaleheads, ///
by(treatment) ///
statistics(mean sd)

esttab using ///
"$tables/Table_4_Baseline_Means.rtf", ///
replace ///
cells("mean sd") ///
label ///
title("Table 4. Baseline Means by Treatment Status")

*------------------------------------------------------------*
* Export baseline summary to Excel
*------------------------------------------------------------*

collapse ///
(mean) size ///
kids ///
infants ///
preg ///
size_ew ///
femaleheads, ///
by(treatment)

export excel using ///
"$tables/baseline_balance_means.xlsx", ///
replace ///
firstrow(variables)

restore

/********************************************************************************************
                OPTIONAL VISUAL BALANCE CHECKS
********************************************************************************************/

graph bar ///
(mean) size, ///
over(treatment) ///
title("Average Household Size at Baseline")

graph export ///
"$figures/baseline_household_size.png", ///
replace


graph bar ///
(mean) kids, ///
over(treatment) ///
title("Average Number of Children")

graph export ///
"$figures/baseline_children.png", ///
replace


graph bar ///
(mean) femaleheads, ///
over(treatment) ///
title("Female-Headed Households")

graph export ///
"$figures/baseline_female_heads.png", ///
replace


display ""
display "Baseline balance tests complete."
display ""

/********************************************************************************************
                            SECTION 3
                  FOOD SECURITY ANALYSIS (DID)
********************************************************************************************/

display ""
display "===================================================="
display "SECTION 3: FOOD SECURITY ANALYSIS"
display "===================================================="

eststo clear

*------------------------------------------------------------*
* Model 1
* Food Security (Linear Regression)
*------------------------------------------------------------*

reg foodsec ///
    i.treatment##i.period ///
    i.district, ///
    vce(robust)

eststo Food_LRM

predict foodsec_hat if e(sample)

*------------------------------------------------------------*
* Model 2
* Food Security (Linear Probability Model)
*------------------------------------------------------------*

reg moretwo ///
    i.treatment##i.period ///
    i.district, ///
    vce(robust)

eststo Food_LPM

predict moretwo_hat if e(sample)

*------------------------------------------------------------*
* Export Main Food Security Table
*------------------------------------------------------------*

esttab ///
Food_LRM ///
Food_LPM ///
using ///
"$tables/Table_5_FoodSecurity_DID.rtf", ///
replace ///
label ///
b(3) ///
se(3) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(N r2, labels("Observations" "R-squared")) ///
title("Table 5. Difference-in-Differences Estimates: Food Security")

/********************************************************************************************
                    MARGINAL EFFECTS
********************************************************************************************/

display ""
display "Average Treatment Effects"

margins treatment#period

marginsplot, ///
title("Difference-in-Differences: Food Security") ///
ytitle("Predicted Food Security")

graph export ///
"$figures/FoodSecurity_DID_Margins.png", ///
replace

/********************************************************************************************
                    DISTRICT HETEROGENEITY
********************************************************************************************/

display ""
display "District Heterogeneity"

eststo clear

levelsof district, local(districts)

foreach d of local districts {

    reg foodsec ///
        i.treatment##i.period ///
        if district==`d', ///
        vce(robust)

    eststo district`d'
}

esttab district* ///
using ///
"$tables/Table_6_FoodSecurity_Districts.rtf", ///
replace ///
label ///
b(3) ///
se(3) ///
star(* 0.10 ** 0.05 *** 0.01) ///
title("Table 6. Food Security DID by District")

/********************************************************************************************
          EXTRACT DISTRICT DID COEFFICIENTS AUTOMATICALLY
********************************************************************************************/

tempname results

postfile `results' ///
district ///
coef ///
lower ///
upper ///
using ///
"$analysis/foodsecurity_district_effects.dta", ///
replace

levelsof district, local(districts)

foreach d of local districts {

    quietly reg foodsec ///
        i.treatment##i.period ///
        if district==`d', ///
        vce(robust)

    scalar b = _b[1.treatment#1.period]
    scalar se = _se[1.treatment#1.period]

    scalar lb = b - 1.96*se
    scalar ub = b + 1.96*se

    post `results' (`d') (b) (lb) (ub)
}

postclose `results'

use "$analysis/foodsecurity_district_effects.dta", clear

sort district

export excel using ///
"$tables/FoodSecurity_District_Effects.xlsx", ///
replace ///
firstrow(variables)

/********************************************************************************************
                  DISTRICT CONFIDENCE INTERVAL PLOT
********************************************************************************************/

twoway ///
(scatter coef district, ///
msymbol(O) ///
mcolor(navy) ///
msize(medium)) ///
(rcap lower upper district, ///
horizontal ///
lcolor(maroon)), ///
xtitle("Estimated DID Effect") ///
ytitle("District") ///
title("Food Security Treatment Effects by District")

graph export ///
"$figures/FoodSecurity_District_CI.png", ///
replace

/********************************************************************************************
                    OBSERVED MEANS
********************************************************************************************/

use "$analysis/analysis_pooled.dta", clear

preserve

collapse ///
(mean) foodsec ///
moretwo, ///
by(period treatment)

export excel using ///
"$tables/FoodSecurity_GroupMeans.xlsx", ///
replace ///
firstrow(variables)

restore

/********************************************************************************************
                     BAR PLOT
********************************************************************************************/

graph bar ///
(mean) foodsec, ///
over(period) ///
over(treatment) ///
title("Average Food Security by Treatment and Survey Round")

graph export ///
"$figures/FoodSecurity_BarChart.png", ///
replace

display ""
display "Food security analysis complete."
display ""

/********************************************************************************************
                            SECTION 4
                      SAVINGS ANALYSIS (DID)
********************************************************************************************/

display ""
display "===================================================="
display "SECTION 4: SAVINGS ANALYSIS"
display "===================================================="

eststo clear

*------------------------------------------------------------*
* Difference-in-Differences Model
*------------------------------------------------------------*

reg saving ///
    i.treatment##i.period ///
    i.district, ///
    vce(robust)

eststo Savings_DID

predict saving_hat if e(sample)

*------------------------------------------------------------*
* Export Main Regression Table
*------------------------------------------------------------*

esttab ///
Savings_DID ///
using ///
"$tables/Table_7_Savings_DID.rtf", ///
replace ///
label ///
b(3) ///
se(3) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(N r2, labels("Observations" "R-squared")) ///
title("Table 7. Difference-in-Differences Estimates: Savings")

/********************************************************************************************
                         MARGINAL EFFECTS
********************************************************************************************/

margins treatment#period

marginsplot, ///
title("Difference-in-Differences: Savings") ///
ytitle("Predicted Monthly Savings")

graph export ///
"$figures/Savings_DID_Margins.png", ///
replace

/********************************************************************************************
                     DISTRICT HETEROGENEITY
********************************************************************************************/

eststo clear

levelsof district, local(districts)

foreach d of local districts {

    reg saving ///
        i.treatment##i.period ///
        if district==`d', ///
        vce(robust)

    eststo district`d'
}

esttab district* ///
using ///
"$tables/Table_8_Savings_Districts.rtf", ///
replace ///
label ///
b(3) ///
se(3) ///
star(* 0.10 ** 0.05 *** 0.01) ///
title("Table 8. Savings DID by District")

/********************************************************************************************
          AUTOMATIC DISTRICT EFFECT EXTRACTION
********************************************************************************************/

tempname results

postfile `results' ///
district ///
coef ///
lower ///
upper ///
using ///
"$analysis/savings_district_effects.dta", ///
replace

levelsof district, local(districts)

foreach d of local districts {

    quietly reg saving ///
        i.treatment##i.period ///
        if district==`d', ///
        vce(robust)

    scalar b  = _b[1.treatment#1.period]
    scalar se = _se[1.treatment#1.period]

    scalar lb = b - 1.96*se
    scalar ub = b + 1.96*se

    post `results' (`d') (b) (lb) (ub)
}

postclose `results'

use "$analysis/savings_district_effects.dta", clear

sort district

export excel using ///
"$tables/Savings_District_Effects.xlsx", ///
replace ///
firstrow(variables)

/********************************************************************************************
                 DISTRICT CONFIDENCE INTERVAL PLOT
********************************************************************************************/

twoway ///
(scatter coef district, ///
msymbol(O) ///
mcolor(navy) ///
msize(medium)) ///
(rcap lower upper district, ///
horizontal ///
lcolor(maroon)), ///
xtitle("Estimated DID Effect") ///
ytitle("District") ///
title("Savings Treatment Effects by District")

graph export ///
"$figures/Savings_District_CI.png", ///
replace

/********************************************************************************************
                    GROUP MEANS
********************************************************************************************/

use "$analysis/analysis_pooled.dta", clear

preserve
collapse (mean) saving, by(period treatment)
export excel using "$tables/Savings_GroupMeans.xlsx", replace firstrow(variables)
restore

/********************************************************************************************
                      BAR CHART
********************************************************************************************/

graph bar ///
(mean) saving, ///
over(period) ///
over(treatment) ///
title("Average Monthly Savings by Treatment and Survey Round") ///
ytitle("Average Savings")

graph export ///
"$figures/Savings_BarChart.png", ///
replace

display ""
display "Savings analysis complete."
display ""

/********************************************************************************************
                            SECTION 5
                      STRESS ANALYSIS (DID)
********************************************************************************************/

display ""
display "===================================================="
display "SECTION 5: STRESS ANALYSIS"
display "===================================================="

eststo clear

*------------------------------------------------------------*
* Model 1
* Binary Stress Indicator (LPM)
*------------------------------------------------------------*

reg stress ///
    i.treatment##i.period ///
    i.district, ///
    vce(robust)

eststo Stress_LPM

predict stress_hat if e(sample)

*------------------------------------------------------------*
* Model 2
* Standardized Stress Score
*------------------------------------------------------------*

reg upset ///
    i.treatment##i.period ///
    i.district, ///
    vce(robust)

eststo Stress_STD

predict upset_hat if e(sample)

*------------------------------------------------------------*
* Export Main Regression Table
*------------------------------------------------------------*

esttab ///
Stress_LPM ///
Stress_STD ///
using ///
"$tables/Table_9_Stress_DID.rtf", ///
replace ///
label ///
b(3) ///
se(3) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(N r2, ///
labels("Observations" "R-squared")) ///
title("Table 9. Difference-in-Differences Estimates: Stress")

/********************************************************************************************
                         MARGINAL EFFECTS
********************************************************************************************/

margins treatment#period

marginsplot, ///
title("Difference-in-Differences: Stress") ///
ytitle("Predicted Stress")

graph export ///
"$figures/Stress_DID_Margins.png", ///
replace

/********************************************************************************************
                     DISTRICT HETEROGENEITY
********************************************************************************************/

eststo clear

levelsof district, local(districts)

foreach d of local districts {

    reg stress ///
        i.treatment##i.period ///
        if district==`d', ///
        vce(robust)

    eststo district`d'
}

esttab district* ///
using ///
"$tables/Table_10_Stress_Districts.rtf", ///
replace ///
label ///
b(3) ///
se(3) ///
star(* 0.10 ** 0.05 *** 0.01) ///
title("Table 10. Stress DID by District")

/********************************************************************************************
        AUTOMATIC DISTRICT EFFECT EXTRACTION
********************************************************************************************/

tempname results

postfile `results' ///
district ///
coef ///
lower ///
upper ///
using ///
"$analysis/stress_district_effects.dta", ///
replace

levelsof district, local(districts)

foreach d of local districts {

    quietly reg stress ///
        i.treatment##i.period ///
        if district==`d', ///
        vce(robust)

    scalar b  = _b[1.treatment#1.period]
    scalar se = _se[1.treatment#1.period]

    scalar lb = b - 1.96*se
    scalar ub = b + 1.96*se

    post `results' (`d') (b) (lb) (ub)
}

postclose `results'

use "$analysis/stress_district_effects.dta", clear

sort district

export excel using ///
"$tables/Stress_District_Effects.xlsx", ///
replace ///
firstrow(variables)

/********************************************************************************************
                 DISTRICT CONFIDENCE INTERVAL PLOT
********************************************************************************************/

twoway ///
(scatter coef district, ///
msymbol(O) ///
mcolor(navy) ///
msize(medium)) ///
(rcap lower upper district, ///
horizontal ///
lcolor(maroon)), ///
xtitle("Estimated DID Effect") ///
ytitle("District") ///
title("Stress Treatment Effects by District")

graph export ///
"$figures/Stress_District_CI.png", ///
replace

/********************************************************************************************
                    GROUP MEANS
********************************************************************************************/

use "$analysis/analysis_pooled.dta", clear

preserve

collapse ///
(mean) stress ///
upset, ///
by(period treatment)

export excel using ///
"$tables/Stress_GroupMeans.xlsx", ///
replace ///
firstrow(variables)

restore

/********************************************************************************************
                      BAR CHART
********************************************************************************************/

graph bar ///
(mean) stress, ///
over(period) ///
over(treatment) ///
title("Average Stress by Treatment and Survey Round") ///
ytitle("Mean Stress Indicator")

graph export ///
"$figures/Stress_BarChart.png", ///
replace

/********************************************************************************************
                  HISTOGRAM OF STANDARDIZED STRESS
********************************************************************************************/

histogram upset, ///
normal ///
title("Distribution of Standardized Stress Score") ///
xtitle("Standardized Stress")

graph export ///
"$figures/Stress_Distribution.png", ///
replace

display ""
display "Stress analysis complete."
display ""

/********************************************************************************************
                            SECTION 6
                    LAGGED ONE-DIFFERENCE MODELS
********************************************************************************************/

display ""
display "===================================================="
display "SECTION 6: LAGGED ONE-DIFFERENCE (ANCOVA) MODELS"
display "===================================================="

eststo clear

/********************************************************************************************
                    FOOD SECURITY
********************************************************************************************/

display ""
display "Preparing Food Security ANCOVA dataset..."

use "$clean/baseline_food_vars.dta", clear

rename foodsec  b_foodsec
rename moretwo  b_moretwo

keep hhid district TAC ///
     b_foodsec ///
     b_moretwo

merge 1:1 hhid using ///
"$clean/endline_food_vars.dta", ///
keep(match) ///
nogen

rename foodsec e_foodsec
rename moretwo e_moretwo

display ""
display "Food Security ANCOVA"

reg e_foodsec ///
    b_foodsec ///
    i.district ///
    TAC, ///
    vce(robust)

eststo ANCOVA_Food_LRM

reg e_moretwo ///
    b_moretwo ///
    i.district ///
    TAC, ///
    vce(robust)

eststo ANCOVA_Food_LPM

/********************************************************************************************
                        SAVINGS
********************************************************************************************/

display ""
display "Preparing Savings ANCOVA dataset..."

use "$clean/baseline_savings_stress_vars.dta", clear

rename saving        b_saving
rename stressb       b_stress
rename bupset        b_upset

keep hhid district TAC ///
     b_saving ///
     b_stress ///
     b_upset

merge 1:1 hhid using ///
"$clean/endline_savings_stress_vars.dta", ///
keep(match) ///
nogen

rename saving       e_saving
rename stresse       e_stress
rename eupset        e_upset

display ""
display "Savings ANCOVA"

reg e_saving ///
    b_saving ///
    i.district ///
    TAC, ///
    vce(robust)

eststo ANCOVA_Savings

/********************************************************************************************
                          STRESS
********************************************************************************************/

display ""
display "Stress ANCOVA"

reg e_stress ///
    b_stress ///
    i.district ///
    TAC, ///
    vce(robust)

eststo ANCOVA_Stress_LPM

reg e_upset ///
    b_upset ///
    i.district ///
    TAC, ///
    vce(robust)

eststo ANCOVA_Stress_STD

/********************************************************************************************
                    EXPORT ANCOVA TABLE
********************************************************************************************/

esttab ///
ANCOVA_Food_LRM ///
ANCOVA_Food_LPM ///
ANCOVA_Savings ///
ANCOVA_Stress_LPM ///
ANCOVA_Stress_STD ///
using ///
"$tables/Table_11_ANCOVA_Models.rtf", ///
replace ///
label ///
b(3) ///
se(3) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(N r2, ///
labels("Observations" "R-squared")) ///
title("Table 11. Lagged One-Difference (ANCOVA) Estimates")

/********************************************************************************************
                            SECTION 7
                        ROBUSTNESS CHECKS
********************************************************************************************/

display ""
display "===================================================="
display "SECTION 7: ROBUSTNESS CHECKS"
display "===================================================="

eststo clear

/********************************************************************************************
                ROBUSTNESS 1: FEMALE-HEADED HOUSEHOLDS
********************************************************************************************/

display ""
display "Female-headed households only"

use "$analysis/analysis_pooled.dta", clear

preserve

keep if femaleheads > 0

reg foodsec ///
    i.treatment##i.period ///
    i.district, robust

eststo Food_FemaleHH

reg saving ///
    i.treatment##i.period ///
    i.district, robust

eststo Saving_FemaleHH

reg stress ///
    i.treatment##i.period ///
    i.district, robust

eststo Stress_FemaleHH

restore

/********************************************************************************************
                ROBUSTNESS 2: HOUSEHOLDS WITH CHILDREN
********************************************************************************************/

display ""
display "Households with children"

preserve

keep if kidsn>0

reg foodsec ///
    i.treatment##i.period ///
    i.district, robust

eststo Food_Children

reg saving ///
    i.treatment##i.period ///
    i.district, robust

eststo Saving_Children

reg stress ///
    i.treatment##i.period ///
    i.district, robust

eststo Stress_Children

restore

/********************************************************************************************
                ROBUSTNESS 3: DISTRICT FIXED EFFECTS ONLY
********************************************************************************************/

reg foodsec ///
    treatment ///
    period ///
    i.district, robust

eststo FE_Food

reg saving ///
    treatment ///
    period ///
    i.district, robust

eststo FE_Saving

reg stress ///
    treatment ///
    period ///
    i.district, robust

eststo FE_Stress

/********************************************************************************************
                    EXPORT ROBUSTNESS TABLE
********************************************************************************************/

esttab ///
Food_FemaleHH ///
Saving_FemaleHH ///
Stress_FemaleHH ///
Food_Children ///
Saving_Children ///
Stress_Children ///
FE_Food ///
FE_Saving ///
FE_Stress ///
using ///
"$tables/Table_12_Robustness_Checks.rtf", ///
replace ///
label ///
b(3) ///
se(3) ///
star(* 0.10 ** 0.05 *** 0.01) ///
title("Table 12. Robustness Checks")

display ""
display "Robustness checks complete."

/********************************************************************************************
                            REPLICATION COMPLETE
********************************************************************************************/

display ""
display "==========================================================="
display " LEAP 1000 REPLICATION COMPLETED SUCCESSFULLY"
display "==========================================================="
display ""

display "Output folders created:"
display "   output/tables/"
display "   output/figures/"

display ""
display "Replication package finished."
display "==========================================================="
