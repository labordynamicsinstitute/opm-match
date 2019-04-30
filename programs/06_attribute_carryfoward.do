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
save $data/foia16_outsample.dta, replace

*keep only the important attribute information of the merge
forval yr = 2000/2012 {
forval qr = 1/4 {
use $outputs/binary_merge_foia13_foia16_y`yr'q`qr'.dta, clear
keep if id_foia16 != ""
keep q_date year quarter id_foia16 name sex adj_pay 
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
merge 1:m using $data/foia16_outsample.dta


forval yr = 2000/2012 {
forval qr = 1/4 {
erase $outputs/temp_foia16_attribute_y`yr'q`qr'.dta
}
}




