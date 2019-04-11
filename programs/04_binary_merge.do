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
do config.do

cd $work
set more off

//Notes
/*
This program merges FOIA 2013, FOIA 2016, Fedscope, and Buzzfeed OPM datasets.
It also identifies the distribution of "exact" matches.


The program runs iteratively in the following order:

From 2000-2012

I.   Merge FOIA 2013 with FOIA 2016
II.  Merge (I) with Fedscope
III. Merge (II) with Buzzfeed


*/
timer on 9

*Run for all annual files
forval yr=2000/2012 {

capture log using merge_opm_`yr'.log, replace
/********************************************************************************
|																				|
|	I Merging FOIA 2013 and FOIA 2016		|
|																				|
********************************************************************************/	
timer on 1
use $data/foia13_`yr'.dta, clear
//Use merge m:m because I want do not need a full outer join. It is fine to lose the duplicates
merge m:m $bvarlist1 using $data/foia16_`yr'.dta

di "*** FOIA16 `yr' ***"
rename _merge merge1
tab merge1
sum merge1 if merge1 ==1 //FOIA2013
local merge1_1_`yr' = `r(N)'
sum merge1 if merge1 ==2 //FOIA2016
local merge1_2_`yr' = `r(N)'
sum merge1 if merge1 ==3 //Matched
local merge1_3_`yr' = `r(N)'

timer off 1
saveold $outputs/binary_merge1_`yr'.dta, replace
/********************************************************************************
|																				|
|	II Merge FOIA 2013 with Fedscope						|
|																				|
********************************************************************************/
timer on 2
use $data/foia13_`yr'.dta, clear
//Use merge m:m because I want do not need a full outer join. It is fine to lose the duplicates
merge m:m $bvarlist2 using $data/feds_`yr'.dta

di "*** Fedscope `yr' ***"
rename _merge merge2
tab merge2
sum merge2 if merge2 ==1 //FOIA2013
local merge2_1_`yr' = `r(N)'
sum merge2 if merge2 ==2 //Fedscope
local merge2_2_`yr' = `r(N)'
sum merge2 if merge2 ==3 //Matched
local merge2_3_`yr' = `r(N)'

timer off 2
saveold $outputs/binary_merge2_`yr'.dta, replace
/********************************************************************************
|																				|
|	III Merge FOIA 2013 with Buzzfeed					|
|																				|
********************************************************************************/
timer on 3
use $data/foia13_`yr'.dta, clear
//Use merge m:m because I want do not need a full outer join. It is fine to lose the duplicates
merge m:m $bvarlist3 using $data/buzz_`yr'.dta

di "*** Buzzfeed `yr' ***"
rename _merge merge3
tab merge3
sum merge3 if merge3 ==1 //FOIA2013
local merge3_1_`yr' = `r(N)'
sum merge3 if merge3 ==2 //Buzzfeed
local merge3_2_`yr' = `r(N)'
sum merge3 if merge3 ==3 //Matched
local merge3_3_`yr' = `r(N)'

saveold $outputs/binary_merge3_`yr'.dta, replace

timer off 3
timer list

capture log close

}
/********************************************************************************
|																				|
|	IV Save merge stats to CSV					|
|																				|
********************************************************************************/
clear
set obs 13
gen year =.
gen merge1_foia13=.
gen merge1_foia16=.
gen merge1_matched=.

gen merge2_foia13=.
gen merge2_feds=.
gen merge2_matched=.

gen merge3_foia13=.
gen merge3_buzz=.
gen merge3_matched=.

local i = 1
forval yr=2000/2012 {
replace year = `yr' in `i'
replace merge1_foia13= `merge1_1_`yr''  in `i'
replace merge1_foia16= `merge1_2_`yr'' in `i'
replace merge1_matched= `merge1_3_`yr'' in `i'

replace merge2_foia13= `merge2_1_`yr'' in `i'
replace merge2_feds= `merge2_2_`yr'' in `i'
replace merge2_matched= `merge2_3_`yr'' in `i'

replace merge3_foia13= `merge3_1_`yr'' in `i'
replace merge3_buzz= `merge3_2_`yr'' in `i'
replace merge3_matched= `merge3_3_`yr'' in `i'

local i = `i' + 1
}

gen matched1 = merge1_matched/(merge1_foia13+merge1_foia16+merge1_matched)
gen matched2 = merge2_matched/(merge2_foia13+merge2_feds+merge2_matched)
gen matched3 = merge3_matched/(merge3_foia13+merge3_buzz+merge3_matched)

saveold $outputs/binary_merge_summary.dta, replace
export delimited binary_merge_summary, replace

timer off 9
timer list 9
