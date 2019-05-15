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

I Use Attributes attached to ID	


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
|	I Use Attributes attached to ID		|
|																				|
********************************************************************************/
//foia16_outsample.dta created in 01_format
*Separate FOIA 2016 outsample into masked and nonmasked files
use $data/foia16_outsample.dta, clear
keep if id_foia16 != "#########" & duty_sta != "#########"
save $data/foia16a_outsample.dta, replace

use $data/foia16_outsample.dta, clear
keep if id_foia16 == "#########" & duty_sta != "#########"
save $data/foia16b_outsample.dta, replace

use $data/foia16_outsample.dta, clear
keep if duty_sta == "#########"
save $data/foia16c_outsample.dta, replace

*keep only the ID and attribute information for the merge
forval yr = 2000/2012 {
    forval qr = 1/4 {
	use $outputs/binary_merge_foia16_foia13_y`yr'q`qr'.dta, clear
	keep if id_foia16 != ""
	keep q_date id_foia16 sex 
	drop if sex == ""
	save $outputs/temp_foia16_attribute_y`yr'q`qr'.dta, replace
    }
}

clear
forval yr = 2000/2012 {
    forval qr = 1/4 {
	append using $outputs/temp_foia16_attribute_y`yr'q`qr'.dta
    }
}
ren sex sexa
by id_foia (q_date), sort: keep if _n==_N
drop q_date
drop if id_foia == "#########" //drop obs without id
save $outputs/temp_foia16_attribute1.dta, replace

*keep only the important varlist and attribute information for the merge
forval yr = 2000/2012 {
    forval qr = 1/4 {
	use $outputs/binary_merge_foia16_foia13_y`yr'q`qr'.dta, clear
	keep sex $carrylista
	drop if sex == ""
	by $carrylista, sort: keep if _n ==_N 
	save $outputs/temp_foia16_attribute_y`yr'q`qr'.dta, replace
    }
}

clear
forval yr = 2000/2012 {
    forval qr = 1/4 {
        append using $outputs/temp_foia16_attribute_y`yr'q`qr'.dta
    }
}
*"Randomly" assign attribute to the varlist
by $carrylista, sort: keep if _n ==_N 
save $outputs/temp_foia16_attribute2.dta, replace

forval yr = 2000/2012 {
    forval qr = 1/4 {
    	erase $outputs/temp_foia16_attribute_y`yr'q`qr'.dta
    }
}


*keep latest attribute of an individual (has ID)
use $outputs/temp_foia16_attribute1.dta, clear

*attach attribute to out-of-scope FOIA 2016 data
noisily merge 1:m id_foia16 using $data/foia16a_outsample.dta
	ren _merge mergea
	count if mergea ==1 //2000-2012 sample
	local merge1a = `r(N)'
	count if mergea ==2 //2013-2016 sample
	local merge2a = `r(N)'
	count if mergea ==3 //Matched
	local merge3a = `r(N)'
drop if mergea == 1
save $outputs/carryforward_foia16a.dta, replace



*remerge using matching varlist without longitudinal var and location var
use $outputs/temp_foia16_attribute2.dta, clear
ren sex sexb

*attach attribute to out-of-scope FOIA 2016 data
noisily merge m:m $carrylista using $outputs/carryforward_foia16a.dta
	ren _merge mergeb
	count if mergeb ==1 //2000-2012 sample
	local merge1b = `r(N)'
	count if mergeb ==2 //2013-2016 sample
	local merge2b = `r(N)'
	count if mergeb ==3 //Matched
	local merge3b = `r(N)'

save $outputs/carryforward_foia16a.dta, replace

gen test = (sexa == sexb) if mergeb != 1 & sexa != "" & sexb != ""
tab test




/********************************************************************************
|																				|
|	I Export Merge Summary	|
|																				|
********************************************************************************/
use $data/foia16_outsample.dta, clear
local obs_foia16 = _N
count if id_foia != "#########"
local obs_foia16_nomiss = `r(N)'

clear
set obs 1
gen obs_foia16= `obs_foia16'
gen merge_insample_a= `merge1a'
gen merge_outsample_a= `merge2a'
gen merge_matched_a= `merge3a'
gen matched_rate_a = merge_matched_a/(obs_foia16)
gen merge_insample_b= `merge1b'
gen merge_outsample_b= `merge2b'
gen merge_matched_b= `merge3b'
gen matched_rate_b = merge_matched_b/(obs_foia16)

saveold $outputs/carryforward_foia16_summary.dta, replace
export delimited $outputs/carryforward_foia16_summary.csv, replace


