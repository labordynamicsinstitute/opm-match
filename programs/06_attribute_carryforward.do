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
This program carrys forward the matched attributes in the FOIA 2013-FOIA 2016 merges to later FOIA 2016 files



The program runs for FOIA 2016 2013q1-2016q1

*/

timer on 9
/*
Possible program arguments
1: data1 = foia13
2: data2 = foia16, feds, buzz
3: year = 2000-2012
4: quarter = 1-4

*/

/********************************************************************************
|																				|
|	I Use Attributes attached to 		|
|																				|
********************************************************************************/
clear 
*save the out-of-scope FOIA 2016 data
use $data/foia16_formatted.dta, clear
keep if q_date >= $start_date
local obs_foia16 = _N
di `obs_foia16'
save $data/foia16_outsample.dta, replace

*keep only the important attribute information of the merge
forval yr = 2000/2012 {
forval qr = 1/4 {
use $outputs/binary_merge_foia16_foia13_y`yr'q`qr'.dta, clear
keep if id_foia16 != ""
keep q_date id_foia16 sex 
save $outputs/temp_foia16_attribute_y`yr'q`qr'.dta, replace
}
}

clear
forval yr = 2000/2012 {
forval qr = 1/4 {
append using $outputs/temp_foia16_attribute_y`yr'q`qr'.dta
}
}
save $outputs/temp_foia16_attribute.dta, replace

*keep latest attribute of an individual
by id_foia (q_date), sort: keep if _n==_N
 
*attach attribute to out-of-scope FOIA 2016 data
merge 1:m id_foia16 using $data/foia16_outsample.dta

	rename _merge merge_`1'_`2'
	count if _merge ==1 //2000-2012 sample
	local merge1 = `r(N)'
	count if _merge ==2 //2013-2016 sample
	local merge2 = `r(N)'
	count if _merge ==3 //Matched
	local merge3 = `r(N)'

forval yr = 2000/2012 {
forval qr = 1/4 {
erase $outputs/temp_foia16_attribute_y`yr'q`qr'.dta
}
}

save $outputs/carryforward_foia16.dta, replace

/********************************************************************************
|																				|
|	I Export Merge Summary	|
|																				|
********************************************************************************/
clear
set obs 1
gen obs_foia16= `obs_foia16'
gen merge_insample= `merge1'
gen merge_outsample= `merge2'
gen merge_matched= `merge3'
gen matched_rate = merge_matched/(obs_foia16)

saveold $outputs/carryforward_foia16_summary.dta, replace
export delimited $outputs/carryforward_foia16_summary.csv, replace


