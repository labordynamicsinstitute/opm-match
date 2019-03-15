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
/*
This program merges FOIA 2013 with FOIA 2016 and identify the distribution of "exact" matches.

This is Part I of the programs that follows the order:
I.   Merge FOIA 2013 with FOIA 2016
II.  Merge (I) with Fedscope
III. Merge (II) with Buzzfeed



Since foia 2016 has no salary, I'm going to merge it last
*/

capture log using merge_opm_2000.log
/********************************************************************************
|																				|
|	I Merging FOIA 2013 and FOIA 2016		|
|																				|
********************************************************************************/	
timer on 1

use $data/foia13_2000.dta, clear
di _N
/*
drop if duty_sta == "#########" //50,510,858 //total obs 101,048,295
merge m:1 year quarter agency duty_sta age loslvl occ occ_cat pay_plan grade paylvl appoint schedule cbsa educ_c file_date start_date end_date using $data/opmfoia16_all.dta
*/

//Since the varlist does not uniquely identify observations, I'm running a joinby command
joinby year quarter agency duty_sta age loslvl occ occ_cat pay_plan grade paylvl appoint schedule cbsa educ_c file_date start_date end_date using $data/foia16_2000.dta, unmatched(both)
//I identify duplicates created from joinby, and ignore them as "exact" matches
by foia13_dup, sort: gen unique13 = _n 
replace unique13 = 1 if foia13_dup == .
by foia16_dup, sort: gen unique16 = _n
replace unique16 = 1 if foia16_dup == .

rename _merge merge1
tab merge1
tab merge1 if (unique13 ==1 | unique16==1)

keep if (unique13 ==1 | unique16==1) //this should keep all the unique obs from foia13 and foia16 for merging with later files
drop unique13 unique16

timer off 1
saveold $outputs/merge_opm_2000.dta, replace
/********************************************************************************
|																				|
|	II Merge (I) with Fedscope						|
|																				|
********************************************************************************/
timer on 2

//Since the varlist does not uniquely identify observations, I'm running a joinby command
joinby year quarter agency loc age sex gs occ occ_cat pay_plan grade appoint schedule adj_pay using $data/feds_2000.dta, unmatched(both)
//I identify duplicates created from joinby, and ignore them as "exact" matches
by foia13_dup, sort: gen unique13 = _n 
replace unique13 = 1 if foia13_dup == .
by foia16_dup, sort: gen unique16 = _n
replace unique16 = 1 if foia16_dup == .
by feds_dup, sort: gen uniquefeds = _n 
replace uniquefeds = 1 if feds_dup == .

rename _merge merge2
tab merge2
tab merge2 if (unique13 ==1 | unique16==1 | uniquefeds== 1)

keep if (unique13 ==1 | unique16==1) //this should keep all the unique obs from foia13 and foia16 for merging with later files
drop unique13 unique16 uniquefeds

timer off 2
saveold $outputs/merge_opm_2000.dta, replace
/********************************************************************************
|																				|
|	III Merge (II) with Buzzfeed					|
|																				|
********************************************************************************/
timer on 3

//Since the varlist does not uniquely identify observations, I'm running a joinby command
joinby year quarter name agency duty_sta age educ_c pay_plan grade loslvl occ occ_cat appoint schedule adj_pay using $outputs/buzz_2000.dta, unmatched(both)
//I identify duplicates created from joinby, and ignore them as "exact" matches
by foia13_dup, sort: gen unique13 = _n 
replace unique13 = 1 if foia13_dup == .
by foia16_dup, sort: gen unique16 = _n
replace unique16 = 1 if foia16_dup == .
by feds_dup, sort: gen uniquefeds = _n 
replace uniquefeds = 1 if feds_dup == .

by buzz_dup, sort: gen uniquebuzz = _n 
replace uniquebuzz = 1 if buzz_dup == .

rename _merge merge3
tab merge3
tab merge3 if (unique13 ==1 | unique16==1 | uniquefeds== 1 | uniquebuzz== 1)

keep if (unique13 ==1 | unique16==1 | uniquefeds== 1 | uniquebuzz== 1) //this should keep all the unique obs from foia13 and foia16 for merging with later files

saveold $outputs/merge_opm_2000.dta, replace

timer off 3
timer list

capture log close