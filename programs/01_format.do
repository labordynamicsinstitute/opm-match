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
This program formats and recodes OPM datasets - FOIA 2013, FOIA 2016, Fedscope, and Buzzfeed - to be able to merge. It also saves all datasets in annual parts to save time in merging.

The program follows the order:

I.     Format FOIA 2013
II.    Format FOIA 2016	
III.   Format Fedscope


I only keep 2000-2012 samples for merging (shared across all 4 datasets)
*/


/********************************************************************************
|																				|
|	I.   Format FOIA 2013							|
|																				|
********************************************************************************/	
capture log using foia13.log
clear
use $data/opmfoia13_all.dta, clear
gen q_date =yq(year,quarter)

*Recode to common value 
**i.Recoding age

/*
FOIA 2016 AGE LEVEL (YEARS)
  *           *-UNSPEC
  1           1-BELOW 20
  2           2-20-24
  3           3-25-29
  4           4-30-34
  5           5-35-39
  6           6-40-44
  7           7-45-49
  8           8-50-54
  9           9-55-59
  10          10-60-64
  11          11-65 OR ABOVE
*/

replace age = "1" if age == "< 20"
replace age = "2" if age == "20-24"
replace age = "3" if age == "25-29"
replace age = "4" if age == "30-34"
replace age = "5" if age == "35-39"
replace age = "6" if age == "40-44"
replace age = "7" if age == "45-49"
replace age = "8" if age == "50-54"
replace age = "9" if age == "55-59"
replace age = "10" if age == "60-64"
replace age = "11" if age == "65+"

**ii.Add service length level
/*
LENGTH OF SERVICE LEVEL (YEARS)
  *           *-UNSPEC
  1           1-BELOW 1
  2           2-1 - 2
  3           3-3 - 4
  4           4-5 - 9
  5           5-10 - 14
  6           6-15 - 19
  7           7-20 - 24
  8           8-25 - 29
  9           9-30 OR ABOVE
*/
gen loslvl = ""
replace loslvl = "1" if service < 1
replace loslvl = "2" if service >= 1 & service < 3
replace loslvl = "3" if service >= 3 & service < 5
replace loslvl = "4" if service >= 5 & service < 10
replace loslvl = "5" if service >= 10 & service < 15
replace loslvl = "6" if service >= 15 & service < 20
replace loslvl = "7" if service >= 20 & service < 25
replace loslvl = "8" if service >= 25 & service < 30
replace loslvl = "9" if service >= 30 

**iii. Add pay level
/*
SALARY LEVEL
  1           1-BELOW $20,000
  2           2-$20,000-$29,999
  3           3-$30,000-$39,999
  4           4-$40,000-$49,999
  5           5-$50,000-$59,999
  6           6-$60,000-$69,999
  7           7-$70,000-$79,999
  8           8-$80,000-$89,999
  9           9-$90,000-$99,999
  10          10-$100,000-$109,999
  11          11-$110,000-$119,999
  12          12-$120,000-$129,999
  13          13-$130,000-$139,999
  14          14-$140,000-$149,999
  15          15-$150,000-$159,999
  16          16-$160,000-$169,999
  17          17-$170,000-$179,999
  18          18-$180,000 OR MORE
*/
gen paylvl = ""
replace paylvl ="1" if adj_pay < 20000
replace paylvl ="2" if adj_pay >= 20000 & adj_pay <= 29999
replace paylvl ="3" if adj_pay >= 30000 & adj_pay <= 39999
replace paylvl ="4" if adj_pay >= 40000 & adj_pay <= 49999
replace paylvl ="5" if adj_pay >= 50000 & adj_pay <= 59999
replace paylvl ="6" if adj_pay >= 60000 & adj_pay <= 69999
replace paylvl ="7" if adj_pay >= 70000 & adj_pay <= 79999
replace paylvl ="8" if adj_pay >= 80000 & adj_pay <= 89999
replace paylvl ="9" if adj_pay >= 90000 & adj_pay <= 99999
replace paylvl ="10" if adj_pay >= 100000 & adj_pay <= 109999
replace paylvl ="11" if adj_pay >= 110000 & adj_pay <= 119999
replace paylvl ="12" if adj_pay >= 120000 & adj_pay <= 129999
replace paylvl ="13" if adj_pay >= 130000 & adj_pay <= 139999
replace paylvl ="14" if adj_pay >= 140000 & adj_pay <= 149999
replace paylvl ="15" if adj_pay >= 150000 & adj_pay <= 159999
replace paylvl ="16" if adj_pay >= 160000 & adj_pay <= 169999
replace paylvl ="17" if adj_pay >= 170000 & adj_pay <= 179999
replace paylvl ="18" if adj_pay >= 180000 
replace paylvl ="" if adj_pay ==.	

gen loc = substr(duty_sta,1,2)

**iv. Create Longitudinal variables
*length of attachment (tenure) to agency
by id agency (q_date), sort: egen tenure_firstyr = min(q_date) if id !="#########"
gen tenure = q_date-tenure_firstyr+1 if id !="#########"
drop tenure_firstyr

*length of attachment to duty station (posting_length)
by id duty_sta (q_date), sort: egen duty_firstyr = min(q_date) if id !="#########"
gen posting_length = q_date-duty_firstyr+1 if id !="#########"
drop duty_firstyr

*length of occupation (though that SHOULD be the same as tenure)
by id occ (q_date), sort: egen occ_firstyr = min(q_date) if id !="#########"
gen tenure_occ = q_date-occ_firstyr+1 if id !="#########"
drop occ_firstyr

*quarter-on-quarter earnings change 
//the 1st qoq earnings change will be missing, 
by id (q_date), sort: gen q_date2 = q_date - q_date[_n-1]
by id (q_date), sort: gen qoq_earn_change = adj_pay -adj_pay[_n-1] if id !="#########"
replace qoq_earn_change = . if q_date2 > 1 & q_date2 != .
/*
SALARY LEVEL CHANGE RANGE
 Range = (#-1)*10000 to (#)*10000
 A# -> Upper Range + 10000
 Z# -> Upper Range unknown
*/
*quarter-on-quarter earnings-level change
//the 1st qoq earnings change will be missing, 
destring paylvl, gen(numpaylvl)
by id (q_date), sort: gen qoq_earn_change_lvl = numpaylvl -numpaylvl[_n-1] if id !="#########"
tostring qoq_earn_change_lvl, replace
replace qoq_earn_change_lvl = "" if qoq_earn_change_lvl == "."
drop numpaylvl
replace qoq_earn_change_lvl = "A" +qoq_earn_change_lvl  if paylvl[_n-1] == "1"
replace qoq_earn_change_lvl = "Z" +qoq_earn_change_lvl  if paylvl == "18" & qoq_earn_change_lvl !=""
replace qoq_earn_change_lvl = "" if q_date2 > 1 & q_date2 != .
drop q_date2
saveold $data/foia16_formatted.dta, replace




saveold $data/foia13_formatted.dta, replace

forval yr=2000/2012 {
    preserve
    forval qr=1/4 {
	    keep if year ==`yr'& quarter == `qr'
	    saveold $data/foia13_y`yr'q`qr'.dta, replace
	    restore
    }
}    
capture log close
/********************************************************************************
|																				|
|	II.   Format FOIA 2016							|
|																				|
********************************************************************************/	
capture log using foia16.log

clear
use $data/opmfoia16_all.dta, clear
gen q_date =yq(year,quarter)

gen loc = substr(duty_sta,1,2)

**iv. Create Longitudinal variables (no qoq earn change)
*length of attachment (tenure) to agency
by id agency (q_date), sort: egen tenure_firstyr = min(q_date) if id !="#########"
gen tenure = q_date-tenure_firstyr+1 if id !="#########"
drop tenure_firstyr

*length of attachment to duty station (posting_length)
by id duty_sta (q_date), sort: egen duty_firstyr = min(q_date) if id !="#########"
gen posting_length = q_date-duty_firstyr+1 if id !="#########"
drop duty_firstyr

*length of occupation (though that SHOULD be the same as tenure)
by id occ (q_date), sort: egen occ_firstyr = min(q_date) if id !="#########"
gen tenure_occ = q_date-occ_firstyr+1 if id !="#########"
drop occ_firstyr

/*
SALARY LEVEL CHANGE RANGE
 Range = (#-1)*10000 to (#)*10000
 A# -> Upper Range + 10000
 Z# -> Upper Range unknown
*/
*quarter-on-quarter earnings-level change
//the 1st qoq earnings change will be missing, 
by id (q_date), sort: gen q_date2 = q_date - q_date[_n-1]
destring paylvl, gen(numpaylvl)
by id (q_date), sort: gen qoq_earn_change_lvl = numpaylvl -numpaylvl[_n-1] if id !="#########"
tostring qoq_earn_change_lvl, replace
replace qoq_earn_change_lvl = "" if qoq_earn_change_lvl == "."
drop numpaylvl
replace qoq_earn_change_lvl = "A" +qoq_earn_change_lvl  if paylvl[_n-1] == "1"
replace qoq_earn_change_lvl = "Z" +qoq_earn_change_lvl  if paylvl == "18" & qoq_earn_change_lvl !=""
replace qoq_earn_change_lvl = "" if q_date2 > 1 & q_date2 != .
drop q_date2
saveold $data/foia16_formatted.dta, replace

forval yr=2000/2012 {    
    forval qr=1/4 {
	    preserve
	    keep if year ==`yr' & quarter == `qr'
	    saveold $data/foia16_y`yr'q`qr'.dta, replace
	    restore
    }  
}    
capture log close
/********************************************************************************
|																				|
|	III.   Format Fedscope							|
|																				|
********************************************************************************/	
capture log using feds.log
clear
use $data/opmfeds_all.dta, clear
gen q_date =yq(year,quarter)

*Rename and Split Fedscope vars 
gen pay_plan = substr(ppgrd,1,2)
gen grade = substr(ppgrd,4,2)
ren avg_pay adj_pay
drop service

**dropping redundant/unused fields to save memory
drop ppgrd
drop sallvl
drop employment
drop dept_subcode
drop loc2
drop loctyp
drop educ_c //doesn't start until after 2014, outside of our comparable time
drop stemocc
drop supervise
drop workstat
/*
Fedscope Data Definition https://www.fedscope.opm.gov/datadefn/
An employee's age.  Age is displayed in five-year intervals, except for an initial interval of less than 20 years and a final interval of 65 years or more.
*/
**i.Recoding age
replace age = "1" if age == "A"
replace age = "2" if age == "B"
replace age = "3" if age == "C"
replace age = "4" if age == "D"
replace age = "5" if age == "E"
replace age = "6" if age == "F"
replace age = "7" if age == "G"
replace age = "8" if age == "H"
replace age = "9" if age == "I"
replace age = "10" if age == "J"
replace age = "11" if age == "K"
replace age = "" if age == "Z"

**ii.Recoding loslvl
*no need to recode loslvl since, Fedscope has los and I will merge using that
drop loslvl
/*
LENGTH OF SERVICE LEVEL (YEARS)
  *           *-UNSPEC
  A           BELOW 1
  B           1 - 2
  C           3 - 4  D           5 - 9
  E           10 - 14
  F           15 - 19
  G           20 - 24
  H           25 - 29  I           30 - 34
  J           35 OR ABOVE
  Z           unavailable
replace loslvl = "1" if service < 1
replace loslvl = "2" if service >= 1 & service < 3
replace loslvl = "3" if service >= 3 & service < 5
replace loslvl = "4" if service >= 5 & service < 10
replace loslvl = "5" if service >= 10 & service < 15
replace loslvl = "6" if service >= 15 & service < 20
replace loslvl = "7" if service >= 20 & service < 25
replace loslvl = "8" if service >= 25 & service < 30
replace loslvl = "9" if service >= 30 
*/


**ii.Recoding occ_cat
/*
A=2
B=6
C=4
O=5
P=1
T=3
*=9
*/
replace occ_cat = "A" if occ_cat == "2"
replace occ_cat = "B" if occ_cat == "6"
replace occ_cat = "C" if occ_cat == "4"
replace occ_cat = "O" if occ_cat == "5"
replace occ_cat = "P" if occ_cat == "1"
replace occ_cat = "T" if occ_cat == "3"
replace occ_cat = "*" if occ_cat == "9"

**iii. Create Longitudinal variables (no id to identify individuals)

saveold $data/feds_formatted.dta, replace


forval yr=2000/2012 {
    
    forval qr=1/4 {
	    preserve
	    keep if year ==`yr' & quarter == `qr'
	    saveold $data/feds_y`yr'q`qr'.dta, replace
	    restore
    } 
}   
capture log close 

/********************************************************************************
|																				|
|	IV.   Format Buzzfeed						|
|																				|
********************************************************************************/	
capture log using feds.log
clear
use $data/opmbuzz99_all.dta, clear
gen q_date =yq(year,quarter)

**dropping redundant/unused fields to save memory
drop id
drop supervise
drop file_date //same as year quarter
/*
Fedscope Data Definition https://www.fedscope.opm.gov/datadefn/
An employee's age.  Age is displayed in five-year intervals, except for an initial interval of less than 20 years and a final interval of 65 years or more.
*/
**i.Recoding age
replace age = "1" if age == "< 20"
replace age = "2" if age == "20-24"
replace age = "3" if age == "25-29"
replace age = "4" if age == "30-34"
replace age = "5" if age == "35-39"
replace age = "6" if age == "40-44"
replace age = "7" if age == "45-49"
replace age = "8" if age == "50-54"
replace age = "9" if age == "55-59"
replace age = "10" if age == "60-64"
replace age = "11" if age == "65-69" | age == "70-74" | age == "75+"
replace age = "" if age == "UNSP"


**ii.Recoding service length level
replace loslvl = "1" if loslvl == "< 1"
replace loslvl = "2" if loslvl == "1-2"
replace loslvl = "3" if loslvl == "3-4"
replace loslvl = "4" if loslvl == "5-9"
replace loslvl = "5" if loslvl == "10-14"
replace loslvl = "6" if loslvl == "15-19"
replace loslvl = "7" if loslvl == "20-24"
replace loslvl = "8" if loslvl == "25-29"
replace loslvl = "9" if loslvl == "30-34" | loslvl == "35+"
replace loslvl = "" if loslvl == "UNSP"

**iv. Create Longitudinal variables
*length of attachment (tenure) to agency
by name agency (q_date), sort: egen tenure_firstyr = min(q_date) if (strmatch(name, "NAME WITHHELD*") == 0 & strmatch(name, "NAME UNKNOWN") == 0)
gen tenure = q_date-tenure_firstyr+1 if (strmatch(name, "NAME WITHHELD*") == 0 & strmatch(name, "NAME UNKNOWN") == 0)
drop tenure_firstyr

*length of attachment to duty station (posting_length)
by name duty_sta (q_date), sort: egen duty_firstyr = min(q_date) if (strmatch(name, "NAME WITHHELD*") == 0 & strmatch(name, "NAME UNKNOWN") == 0)
gen posting_length = q_date-duty_firstyr+1 if (strmatch(name, "NAME WITHHELD*") == 0 & strmatch(name, "NAME UNKNOWN") == 0)
drop duty_firstyr

*length of occupation (though that SHOULD be the same as tenure)
by name occ (q_date), sort: egen occ_firstyr = min(q_date) if (strmatch(name, "NAME WITHHELD*") == 0 & strmatch(name, "NAME UNKNOWN") == 0)
gen tenure_occ = q_date-occ_firstyr+1 if (strmatch(name, "NAME WITHHELD*") == 0 & strmatch(name, "NAME UNKNOWN") == 0)
drop occ_firstyr

*quarter-on-quarter earnings change (or earnings-level change)
by id (q_date), sort: gen q_date2 = q_date - q_date[_n-1]
//the 1st qoq earnings change will be missing, 
by name (q_date), sort: gen qoq_earn_change = adj_pay -adj_pay[_n-1] if (strmatch(name, "NAME WITHHELD*") == 0 & strmatch(name, "NAME UNKNOWN") == 0)
replace qoq_earn_change = . if q_date2 > 1 & q_date2 != .
drop q_date2
saveold $data/buzz_formatted.dta, replace


forval yr=2000/2012 {
    forval qr=1/4 {
	    preserve
	    keep if year ==`yr' & quarter == `qr'
	    saveold $data/buzz_`y`yr'q`qr'.dta, replace
	    restore
    }
}   
capture log close 


