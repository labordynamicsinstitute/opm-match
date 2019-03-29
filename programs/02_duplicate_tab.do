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
global data "$basedir/inputs"
global work "$basedir/programs"
global outputs "$basedir/outputs"
cd $work
set more off

//Notes
/*
This program tabulates duplicates of FOIA 2013, FOIA 2016, Fedscope, and Buzzfeed OPM datasets, by varlists used to merge in $work/02_merge_opm.do

The varlists are given in $work/config.do

The program runs iteratively in the following order:

I.   Tabulate Duplicate by varlist1: Used to merge FOIA 2013 with FOIA 2016
II.  Tabulate Duplicate by varlist2: Used to merge Merge(I) with Fedscope
III. Tabulate Duplicate by varlist3" Used to merge Merge(II) with Buzzfeed

Due to the fact that Merge(II) and Merge(III) are merged using a varlist that was shared in common after the merge. The tabulation of the varlist# can only be applied to the dataset with the most variables (FOIA 2013)

I dropped name from varlist3 for the Tabulation #3, since it doesn't exist in FOIA 2013. Only for the tabulation not the actual merge.

*/
timer on 9


capture log using merge_opm_`yr'.log, replace
/********************************************************************************
|																				|
|	I Tabulate Duplicate by varlist1					|
|																				|
********************************************************************************/	
use $data/foia13_formatted.dta, clear

duplicates tag $varlist1 , generate(dups1_foia13)
di "***************************************************************************" 
di "***************************************************************************"
di "******* THIS IS TABULATION OF DUPLICATES OF VARLIST1 FOR FOIA 2013 ********" 
di "***************************************************************************"
di "***************************************************************************"
tab dups1_foia13

use $data/foia16_formatted.dta, clear

duplicates tag $varlist1 , generate(dups1_foia16)
di "**************************************************************************" 
di "**************************************************************************"
di "******* THIS IS TABULATION OF DUPLICATES OF VARLIST1 FOR FOIA 2016 ********" 
di "**************************************************************************"
di "**************************************************************************"
tab dups1_foia16



/********************************************************************************
|																				|
|	II Tabulate Duplicate by varlist2						|
|																				|
********************************************************************************/
use $data/foia13_formatted.dta, clear

duplicates tag $varlist2 , generate(dups2_foia13)
di "***************************************************************************" 
di "***************************************************************************"
di "******* THIS IS TABULATION OF DUPLICATES OF VARLIST1 FOR FOIA 2013 ********" 
di "***************************************************************************"
di "***************************************************************************"
tab dups2_foia13

use $data/feds_formatted.dta, clear

duplicates tag $varlist2 , generate(dups2_feds)
di "**************************************************************************" 
di "**************************************************************************"
di "******* THIS IS TABULATION OF DUPLICATES OF VARLIST1 FOR FOIA 2016 ********" 
di "**************************************************************************"
di "**************************************************************************"
tab dups2_feds



/********************************************************************************
|																				|
|	III Tabulate Duplicate by varlist3				|
|																				|
********************************************************************************/
use $data/foia16_formatted.dta, clear

duplicates tag $varlist3tab , generate(dups3_foia13)
di "***************************************************************************" 
di "***************************************************************************"
di "******* THIS IS TABULATION OF DUPLICATES OF VARLIST1 FOR FOIA 2013 ********" 
di "***************************************************************************"
di "***************************************************************************"
tab dups2_foia13

use $data/feds_formatted.dta, clear

duplicates tag $varlist3tab , generate(dups3_buzz)
di "**************************************************************************" 
di "**************************************************************************"
di "******* THIS IS TABULATION OF DUPLICATES OF VARLIST1 FOR FOIA 2016 ********" 
di "**************************************************************************"
di "**************************************************************************"
tab dups2_buzz
