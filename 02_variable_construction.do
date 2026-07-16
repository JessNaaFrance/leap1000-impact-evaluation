/********************************************************************************************
   PROJECT: LEAP 1000 Ghana
   FILE: 02_variable_construction.do
   PURPOSE: Append baseline and endline cleaned files, construct pooled analysis variables,
            and save an analysis-ready dataset.
   AUTHOR: Jessica France
********************************************************************************************/

clear all
set more off
set varabbrev off

*------------------------------------------------------------*
* Project directories
*------------------------------------------------------------*
global project   "PATH_TO_PROJECT_FOLDER"
global clean   "$project/data/clean"
global analysis "$project/data/analysis"

cd "$project"

cap mkdir "$project/data/analysis"

*============================================================*
* 1. FOOD SECURITY
*============================================================*

use "$clean/baseline_food_clean.dta", clear

gen period = 0
gen foodsec = s4b_1
gen moretwo = (foodsec >= 3) if !missing(foodsec)

keep hhid TAC district period foodsec moretwo

save "$analysis/food_baseline.dta", replace


use "$clean/endline_food_clean.dta", clear

gen period = 1
gen foodsec = s4b_1
gen moretwo = (foodsec >= 3) if !missing(foodsec)

keep hhid TAC district period foodsec moretwo

save "$analysis/food_endline.dta", replace


use "$analysis/food_baseline.dta", clear
append using "$analysis/food_endline.dta"

sort hhid period

save "$analysis/food_pooled.dta", replace

*============================================================*
* 2. SAVINGS AND STRESS 
*============================================================*

use "$clean/baseline_savings_stress_clean.dta", clear

gen period = 0

gen saving = saveb
gen stress = stressb
gen upset  = bupset

keep hhid TAC district period saving stress upset

save "$analysis/stress_baseline.dta", replace


use "$clean/endline_savings_stress_clean.dta", clear

gen period = 1

gen saving = savee
gen stress = stresse
gen upset  = eupset

keep hhid TAC district period saving stress upset

save "$analysis/stress_endline.dta", replace


use "$analysis/stress_baseline.dta", clear
append using "$analysis/stress_endline.dta"

sort hhid period

save "$analysis/stress_pooled.dta", replace

*============================================================*
* 3. HOUSEHOLD CHARACTERISTICS
*============================================================*
use "$clean/baseline_roster_clean.dta", clear

keep hhid TAC district ///
     kids kidsn ///
     size size_ew ///
     femaleheads femaleheadsn ///
     infants

duplicates drop hhid, force

save "$analysis/household_characteristics.dta", replace

*============================================================*
* 4. MERGE FINAL ANALYSIS VARIABLES
*============================================================*

use "$analysis/food_pooled.dta", clear

merge 1:1 hhid period using ///
"$analysis/stress_pooled.dta", ///
gen(stress_merge)

drop if stress_merge==2


merge m:1 hhid using ///
"$analysis/household_characteristics.dta", ///
gen(hh_merge)

drop if hh_merge==2

*============================================================*
* 5. FINAL ANALYSIS VARIABLES
*============================================================*
gen treatment = TAC

gen did = treatment*period

gen female_treat = treatment*femaleheads

label variable treatment      "Treatment assignment"
label variable period         "Endline indicator"
label variable did            "Treatment × Endline"

label variable foodsec        "Food security category"

label variable moretwo        "Consumed three or more meals"

label variable saving         "Monthly savings"

label variable stress         "Stress indicator"

label variable upset          "Standardized stress score"

label variable kids           "Share of children"

label variable kidsn          "Number of children"

label variable size           "Household size"

label variable size_ew        "Eligible women"

label variable femaleheads    "Female-headed household"

label variable femaleheadsn   "Number of female heads"

label variable infants        "Share of infants"

label variable female_treat   "Treatment × Female head"

*============================================================*
* 6. SAVE MASTER DATASET
*============================================================*
order hhid ///
      treatment ///
      period ///
      did ///
      district ///
      foodsec ///
      moretwo ///
      saving ///
      stress ///
      upset

sort hhid period

compress

save "$analysis/analysis_pooled.dta", replace

display "========================================="
display "Analysis dataset created successfully."
display "========================================="

describe

summarize

tab period

tab treatment

/********************************************************************************************
END OF FILE
********************************************************************************************/
