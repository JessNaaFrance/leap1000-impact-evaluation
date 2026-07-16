/********************************************************************************************
   PROJECT: LEAP 1000 Ghana
   FILE: 01_data_preparation.do
   PURPOSE: Import raw baseline and endline household modules, verify merge structure,
            clean/standardize IDs and key variables, and save cleaned intermediate files.
   AUTHOR: Jessica France
********************************************************************************************/

clear all
set more off
set varabbrev off


*------------------------------------------------------------*
* Project directories
*------------------------------------------------------------*
global project   "PATH_TO_PROJECT_FOLDER"
global baseline "$project/LEAP 1000 Baseline/Household"
global endline  "$project/LEAP 1000 Endline/Household"
global clean "$project/data/clean"

cd "$project"

cap mkdir "$project/data"
cap mkdir "$project/data/clean"
cap mkdir "$project/output"
cap mkdir "$project/output/tables"
cap mkdir "$project/output/figures"

*============================================================*
* 1. BASELINE: HH ROSTER
*============================================================*
use "$baseline/SEC0 - HH LEV.dta", clear

capture isid hhid
if _rc {
    di as error "hhid is not unique in baseline HH level file"
}

merge 1:m hhid using "$baseline/SEC1 - HH ROSTER.dta", gen(roster_merge)
tab roster_merge

* Household roster variables
egen kids        = mean(s1_5a < 18), by(hhid)
egen kidsn       = total(s1_5a < 18), by(hhid)
egen size        = max(pid), by(hhid)
egen size_ew     = max(pid_ew), by(hhid)
egen femaleheads  = mean((s1_4 == 1) & (s1_3 == 2)), by(hhid)
egen femaleheadsn = total((s1_4 == 1) & (s1_3 == 2)), by(hhid)
egen infants     = mean(s1_5a < 1), by(hhid)

keep hhid TAC district kids kidsn size size_ew femaleheads femaleheadsn infants
bysort hhid: keep if _n == 1

save "$clean/baseline_roster_clean.dta", replace

*============================================================*
* 2. BASELINE: REPRODUCTIVE HEALTH
*============================================================*
use "$baseline/SEC0 - HH LEV.dta", clear

capture isid hhid
if _rc {
    di as error "hhid is not unique in baseline HH level file"
}

merge 1:m hhid using "$baseline/SEC5A - REPRODUCTIVE HEALTH.dta", gen(reprod_merge)
tab reprod_merge

egen preg = mean(s5a_1 == 1), by(hhid)

keep hhid TAC district preg
bysort hhid: keep if _n == 1

save "$clean/baseline_reprod_clean.dta", replace

*============================================================*
* 3. BASELINE: FOOD SECURITY
*============================================================*
use "$baseline/SEC0 - HH LEV.dta", clear

capture isid hhid
if _rc {
    di as error "hhid is not unique in baseline HH level file"
}

merge 1:m hhid using "$baseline/SEC4B - FOOD SECURITY.dta", gen(food_merge)
tab food_merge

egen foodsecb = mean(inlist(s4b_1,3,4)), by(hhid)

keep hhid TAC district s4b_1 foodsecb
bysort hhid: keep if _n == 1

save "$clean/baseline_food_clean.dta", replace

*============================================================*
* 4. ENDLINE: FOOD SECURITY
*============================================================*
use "$endline/SEC0 - HH LEV.dta", clear

capture isid hhid
if _rc {
    di as error "hhid is not unique in endline HH level file"
}

merge 1:m hhid using "$endline/SEC4B - FOOD SECURITY.dta", gen(efood_merge)
tab efood_merge

egen foodsece = mean(inlist(s4b_1,3,4)), by(hhid)

keep hhid TAC district s4b_1 foodsece
bysort hhid: keep if _n == 1

save "$clean/endline_food_clean.dta", replace

*============================================================*
* 5. BASELINE: SAVINGS AND STRESS
*============================================================*
use "$baseline/SEC0 - HH LEV.dta", clear

capture isid hhid
if _rc {
    di as error "hhid is not unique in baseline HH level file"
}

merge 1:m hhid using "$baseline/SEC12 - WOMEN'S EMPOWERMENT, STRESS AND PREFERENCES.dta", gen(stress_merge)
tab stress_merge

gen saveb   = cond(s12_1 == 2, 0, s12_2)
gen stressb = (s12_7c > 2)

summarize s12_7c if !missing(s12_7c)
scalar sd_stressb = r(sd)
scalar mean_stressb = r(mean)
gen bupset = (s12_7c - mean_stressb) / sd_stressb

keep hhid TAC district saveb stressb bupset s12_1 s12_2 s12_7c
bysort hhid: keep if _n == 1

save "$clean/baseline_savings_stress_clean.dta", replace

*============================================================*
* 6. ENDLINE: SAVINGS AND STRESS
*============================================================*
use "$endline/SEC0 - HH LEV.dta", clear

capture isid hhid
if _rc {
    di as error "hhid is not unique in endline HH level file"
}

merge 1:m hhid using "$endline/SEC12 - WOMEN'S EMPOWERMENT, STRESS AND PREFERENCES.dta", gen(estress_merge)
tab estress_merge

gen savee   = cond(s12_1 == 2, 0, s12_2)
gen stresse = (s12_7c > 2)

summarize s12_7c if !missing(s12_7c)
scalar sd_stresse = r(sd)
scalar mean_stresse = r(mean)
gen eupset = (s12_7c - mean_stresse) / sd_stresse

keep hhid TAC district savee stresse eupset s12_1 s12_2 s12_7c
bysort hhid: keep if _n == 1

save "$clean/endline_savings_stress_clean.dta", replace

di as text "Data preparation complete."


