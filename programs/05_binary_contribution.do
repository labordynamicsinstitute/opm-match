/*
Author: Daniel Lin
Written:3/06/2019
LDI
*/
//Packages
/*
*/
//Downloads
ssc install savesome
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
forval qr=1/4 {
/********************************************************************************
|																				|
|	I Check relative contribution of variables FOIA 2013 and FOIA 2016		|
|																				|
********************************************************************************/	
if $merge1_switch == 1 {

timer on 1
use $outputs/binary_merge_foia16_foia13_y`yr'q`qr.dta, clear

gen var =""
gen contribution =.
local i = 1
foreach var in $bvarlist1 {
    local newlist = subinstr("$bvarlist1", "`var' ", "",1 )
    duplicates tag `newlist', generate(dups_old)
    duplicates tag $bvarlist1, generate(dups_new)
    count if dups_old ==0
    local old = `r(N)'
    count if dups_new ==0 
    local new = `r(N)'
    local contribution = `new' - `old'
    drop dups_old
    drop dups_new
    replace var = "`var'" in `i'
    replace contribution = `contribution' in `i'
    local i = `i' +1
}
keep var contribution
keep if var != ""
gen year = `yr'
gen quarter = `qr'

saveold $outputs/contribution_binary_merge1_y`yr'q`qr, replace


timer off 1
}
/********************************************************************************
|																				|
|	II Check relative contribution of variables FOIA 2013 with Fedscope						|
|																				|
********************************************************************************/
if $merge2_switch == 1 {
timer on 2
use $outputs/binary_merge2_y`yr'q`qr.dta, clear

gen var =""
gen contribution =.
local i = 1
foreach var in $bvarlist2 {
    local newlist = subinstr("$bvarlist2", "`var' ", "",1 )
    duplicates tag `newlist', generate(dups_old)
    duplicates tag $bvarlist2, generate(dups_new)
    count if dups_old ==0
    local old = `r(N)'
    count if dups_new ==0 
    local new = `r(N)'
    local contribution = `new' - `old'
    drop dups_old
    drop dups_new
    replace var = "`var'" in `i'
    replace contribution = `contribution' in `i'
    local i = `i' +1
}
keep var contribution
keep if var != ""
gen year = `yr'
gen quarter = `qr'

saveold $outputs/contribution_binary_merge2_y`yr'q`qr, replace


timer off 2
}
/********************************************************************************
|																				|
|	III Check relative contribution of variables  FOIA 2013 with Buzzfeed					|
|																				|
********************************************************************************/
if $merge3_switch == 1 {
timer on 3
use $outputs/binary_merge3_y`yr'q`qr, clear

gen var =""
gen contribution =.
local i = 1
foreach var in $bvarlist3 {
    local newlist = subinstr("$bvarlist3", "`var' ", "",1 )
    duplicates tag `newlist', generate(dups_old)
    duplicates tag $bvarlist3, generate(dups_new)
    count if dups_old ==0
    local old = `r(N)'
    count if dups_new ==0 
    local new = `r(N)'
    local contribution = `new' - `old'
    drop dups_old
    drop dups_new
    replace var = "`var'" in `i'
    replace contribution = `contribution' in `i'
    local i = `i' +1
}
keep var contribution
keep if var != ""
gen year = `yr'
gen quarter = `qr'

saveold $outputs/contribution_binary_merge3_y`yr'q`qr, replace

timer off 3
}

timer list
}
}

/********************************************************************************
|																				|
|	IV Combine and export to CSV					|
|																				|
********************************************************************************/

forval mm = 1/3 {
	clear
	forval yr=2000/2012 {
	    forval qr =1/4 {
		append using $outputs/contribution_binary_merge`mm'_y`yr'q`qr	
	    }		
	}
	export delimited $outputs/contribution_binary_merge`mm', replace
}
