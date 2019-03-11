/*
Author: Daniel Lin
Written:3/06/2019
LDI
*/
//Packages
/*
*/
//Downloads

//Globals
global initials "DL"
global date: display %tdCCYYNNDD date(c(current_date), "DMY")
global data /home/ssgprojects/project0002/cdl77/opm-match/inputs
global work /home/ssgprojects/project0002/cdl77/opm-match/programs
global outputs /home/ssgprojects/project0002/cdl77/opm-match/outputs
cd $work
set more off

//Notes
/*Order is as follows:
1. Merge with Buzzfeed to FOIA 2013
2. Merge (1) with FOIA 2016
3. Merge (2) with Fedscope

*/

capture log using merge_buzz_foia13.log
/********************************************************************************
|																				|
|	Merging and comparing distribution of each merge							|
|																				|
********************************************************************************/	
clear
use $data/opmbuzz99_all.dta, clear

merge 1:1 year quarter agency duty_sta age educ_c pay_plan grade occ occ_cat appoint schedule adj_pay using $data/opmfoia13_all.dta 


tab _merge

saveold $outputs/merge_buzz_foia13.dta, replace

log close
