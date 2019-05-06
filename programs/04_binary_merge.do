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


The program runs in the following order:

From 2000q1-2012q4

I.   Merge FOIA 2013 with FOIA 2016
II.  Merge FOIA 2013 with Fedscope
III. Merge FOIA 2013 with Buzzfeed

For FOIA 2016, "security-related" agencies and occupations have blanked certain fields: id_foia16, name, duty_sta, cbsa, loc
They will be merged separately without using duty_sta, cbsa, loc
*/
timer on 9
/*
Possible program arguments
1: data1 = foia16, feds, buzz
2: data2 = foia13
3: year = 2000-2012
4: quarter = 1-4
5: varlist = bvarlist1a, bvarlist1b, bvarlist2, bvarlist3

*/
capture program drop merge_summary
capture program drop merge_append
program merge_summary
	use $data/`1'_y`3'q`4'.dta, clear
	local obs_`1' = _N
	//Use merge m:m because I want do not need a full outer join. It is fine to lose the duplicates
	merge m:m `5' using $data/`2'_y`3'q`4'.dta
	di "*** `1' `2' Y`3'Q`4'***"
	rename _merge merge_`1'_`2'
	count if merge_`1'_`2' ==1 //FOIA2016
	local merge_`1'_`3'_`4' = `r(N)'
	count if merge_`1'_`2' ==2 //FOIA2013
	local merge_`2'_`3'_`4' = `r(N)'
	count if merge_`1'_`2' ==3 //Matched
	local merge_match_`3'_`4' = `r(N)'
	saveold $outputs/binary_merge_`1'_`2'_y`3'q`4'.dta, replace
	

	clear
	set obs 1
	gen year = `3'
	gen quarter = `4'
	gen merge_`1'=.
	gen merge_`2'=.
	gen merge_matched=.
	gen obs_`1' =.
	replace year = `3' in 1
	replace quarter = `4' in 1
	replace merge_`1'= `merge_`1'_`3'_`4''  in 1
	replace merge_`2'= `merge_`2'_`3'_`4'' in 1
	replace merge_matched= `merge_match_`3'_`4'' in 1
	replace obs_`1' = `obs_`1'' in 1
	gen matched_`1'_`2' = 1 - (merge_`1'/(obs_`1'))


	saveold $outputs/temp_`1'_`2'_y`3'q`4'.dta, replace
end 

program merge_append
	clear
	forval yr=2000/2012 {
	    forval qr = 1/4 {
		append using $outputs/temp_`1'_`2'_y`yr'q`qr'.dta
	    }
	}

	saveold $outputs/merge_`1'_`2'_summary.dta, replace
	export delimited $outputs/merge_`1'_`2'_summary.csv, replace

	forval yr=2000/2012 {
	    forval qr = 1/4 {
		erase $outputs/temp_`1'_`2'_y`yr'q`qr'.dta
	    }
	}
	
end 


/********************************************************************************
|																				|
|	I Merging FOIA 2013 and FOIA 2016 and Export Summary		|
|																				|
********************************************************************************/
*Run for all quartly files
*program merge_summary 1 2 3 4 5 // 1-first dataset 2-second dataset 3-year 4-quarter 5-merge varlist

if $merge1_switch == 1 {

forval yr=2000/2012 {
    forval qr=1/4 {
	merge_summary foia16a foia13 `yr' `qr' $bvarlist1a
	merge_summary foia16b foia13 `yr' `qr' $bvarlist1b

    }
}

*Append the split merge summary files
forval yr=2000/2012 {
    forval qr = 1/4 {
	use $outputs/temp_foia16a_foia13_y`yr'q`qr'.dta, clear
	append using  $outputs/temp_foia16b_foia13_y`yr'q`qr'.dta, gen(masking) //0 = no masking, 1 = masking
	save $outputs/temp_foia16_foia13_y`yr'q`qr'.dta, replace
    }
}



*program merge_append 1 2 // 1-first dataset 2-second dataset
merge_append foia16 foia13 

}

/********************************************************************************
|																				|
|	II Merge FOIA 2013 with Fedscope and Export Summary						|
|																				|
********************************************************************************/
*Run for all quartly files
*program merge_summary 1 2 3 4 // 1-year 2-quarter 3-first dataset 4-second dataset

if $merge2_switch == 1 {

forval yr=2000/2012 {
    forval qr=1/4 {
	merge_summary feds foia13 `yr' `qr' $bvarlist2

    }
}

*program merge_append 1 2 // 1-first dataset 2-second dataset
merge_append feds foia13 

}
/********************************************************************************
|																				|
|	III Merge FOIA 2013 with Buzzfeed and Export Summary					|
|																				|
********************************************************************************/
*Run for all quartly files
*program merge_summary 1 2 3 4 // 1-year 2-quarter 3-first dataset 4-second dataset

if $merge3_switch == 1 {

forval yr=2000/2012 {
    forval qr=1/4 {
	merge_summary buzz foia13 `yr' `qr' $bvarlist3

    }
}

*program merge_append 1 2 // 1-first dataset 2-second dataset
merge_append buzz foia13 

}

timer list

capture log close


/*
/********************************************************************************
|																				|
|	IV Save merge stats to CSV					|
|																				|
********************************************************************************/
clear
set obs 70
gen year =.
gen quarter =.
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
    forval qr = 1/4 {
	replace year = `yr' in `i'
	replace quarter = `qr' in `i'
	replace merge1_foia13= `merge1_1_`yr'_`qr''  in `i'
	replace merge1_foia16= `merge1_2_`yr'_`qr'' in `i'
	replace merge1_matched= `merge1_3_`yr'_`qr'' in `i'

	replace merge2_foia13= `merge2_1_`yr'_`qr'' in `i'
	replace merge2_feds= `merge2_2_`yr'_`qr'' in `i'
	replace merge2_matched= `merge2_3_`yr'_`qr'' in `i'

	replace merge3_foia13= `merge3_1_`yr'_`qr'' in `i'
	replace merge3_buzz= `merge3_2_`yr'_`qr'' in `i'
	replace merge3_matched= `merge3_3_`yr'_`qr'' in `i'

        local i = `i' + 1
    }
}

gen matched1 = merge1_matched/(merge1_foia13+merge1_foia16+merge1_matched)

gen matched2 = merge2_matched/(merge2_foia13+merge2_feds+merge2_matched)
gen matched3 = merge3_matched/(merge3_foia13+merge3_buzz+merge3_matched)

/*
saveold $outputs/binary_merge_summary.dta, replace
export delimited binary_merge_summary, replace
*/
saveold $outputs/merge_foia13_foia16_summary.dta, replace
export delimited merge_foia13_foia16_summary, replace

timer off 9
timer list 9


/*
old codes
	timer on 1
	use $data/foia13_y`yr'q`qr'.dta, clear
	//Use merge m:m because I want do not need a full outer join. It is fine to lose the duplicates
	merge m:m $bvarlist1 using $data/foia16_y`yr'q`qr'.dta

	di "*** FOIA16 `yr' ***"
	rename _merge merge1
	tab merge1
	sum merge1 if merge1 ==1 //FOIA2013
	local merge1_1_`yr'_`qr' = `r(N)'
	sum merge1 if merge1 ==2 //FOIA2016
	local merge1_2_`yr'_`qr' = `r(N)'
	sum merge1 if merge1 ==3 //Matched
	local merge1_3_`yr'_`qr' = `r(N)'

	timer off 1
	saveold $outputs/binary_merge1_y`yr'q`qr'.dta, replace

	timer on 2
	use $data/foia13_y`yr'q`qr'.dta, clear
	//Use merge m:m because I want do not need a full outer join. It is fine to lose the duplicates
	merge m:m $bvarlist2 using $data/feds_y`yr'q`qr'.dta

	di "*** Fedscope `yr' ***"
	rename _merge merge2
	tab merge2
	sum merge2 if merge2 ==1 //FOIA2013
	local merge2_1_`yr'_`qr' = `r(N)'
	sum merge2 if merge2 ==2 //Fedscope
	local merge2_2_`yr'_`qr' = `r(N)'
	sum merge2 if merge2 ==3 //Matched
	local merge2_3_`yr'_`qr' = `r(N)'

	timer off 2
	saveold $outputs/binary_merge2_y`yr'q`qr'.dta, replace

	timer on 3
	use $data/foia13_y`yr'q`qr'.dta, clear
	//Use merge m:m because I want do not need a full outer join. It is fine to lose the duplicates
	merge m:m $bvarlist3 using $data/buzz_y`yr'q`qr'.dta

	di "*** Buzzfeed `yr' ***"
	rename _merge merge3
	tab merge3
	sum merge3 if merge3 ==1 //FOIA2013
	local merge3_1_`yr'_`qr' = `r(N)'
	sum merge3 if merge3 ==2 //Buzzfeed
	local merge3_2_`yr'_`qr' = `r(N)'
	sum merge3 if merge3 ==3 //Matched
	local merge3_3_`yr'_`qr' = `r(N)'

	saveold $outputs/binary_merge3_y`yr'q`qr'.dta, replace

timer off 3
*/
