/********************************************************************************************
PROJECT:
LEAP 1000 Ghana Impact Evaluation

AUTHOR:
Jessica Naa L. France

PURPOSE:
Master script for reproducing the analytical workflow used in the
Master's Thesis submitted to Ohio University.

DESCRIPTION:
This script executes the complete replication workflow in sequence:

    1. Data preparation
    2. Variable construction
    3. Statistical analysis

The replication package reproduces the empirical analysis examining the
effects of Ghana's Livelihood Empowerment Against Poverty (LEAP 1000)
programme on household food security, savings, and psychological stress.

Raw LEAP 1000 survey data are confidential and therefore are not included
in this repository.

********************************************************************************************/

clear all
set more off
version 16

*--------------------------------------------------------------
* SET PROJECT DIRECTORY
*--------------------------------------------------------------

* Replace the path below with the location where you saved
* the replication package and the confidential LEAP 1000 datasets.

* Example:
* global project "C:/Users/YourName/Documents/LEAP1000_Replication"

global project "PATH_TO_PROJECT_FOLDER"

cd "$project"

*--------------------------------------------------------------
* RUN REPLICATION FILES
*--------------------------------------------------------------

do "01_data_preparation.do"

do "02_variable_construction.do"

do "03_analysis.do"

display ""
display "--------------------------------------------"
display "LEAP 1000 replication completed successfully."
display "--------------------------------------------"

/********************************************************************************************
END OF FILE
********************************************************************************************/
