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
III.   Format Buzzfeed
V.     Export Observation counts of all Formatted Quarterly Datasets

I only keep 2000-2012 samples for merging (shared across all 4 datasets)
DOD agencies are dropped from formatted files: AF AR DD NV 




2 instances in FOIA 2013 where there is error in raw data.
year	quarter	test	id	agency
2011	2	5	001201539	VAT
2008	3	5	002819277	HSBã

agency > VATA
agency > HSBC
*/


/********************************************************************************
|																				|
|	I.   Format FOIA 2013							|
|																				|
********************************************************************************/	
capture log using foia13.log
clear
use $data/opmfoia13_all.dta, clear
*drop DOD agencies
gen dept = substr(agency,1,2)
drop if dept == "AF" | dept == "AR" | dept == "DD" | dept == "NV"
drop dept  

*fix agency error
replace agency = "VATA" if id == "001201539" & year == 2011 & quarter == 2
replace agency = "HSBC" if id == "002819277" & year == 2008 & quarter == 3
compress agency



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
gen age_common = ""
replace age_common = "1" if age == "< 20"
replace age_common = "2" if age == "20-24"
replace age_common = "3" if age == "25-29"
replace age_common = "4" if age == "30-34"
replace age_common = "5" if age == "35-39"
replace age_common = "6" if age == "40-44"
replace age_common = "7" if age == "45-49"
replace age_common = "8" if age == "50-54"
replace age_common = "9" if age == "55-59"
replace age_common = "10" if age == "60-64"
replace age_common = "11" if age == "65+"

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
gen loslvl_common = ""
replace loslvl_common = "1" if service < 1
replace loslvl_common = "2" if service >= 1 & service < 3
replace loslvl_common = "3" if service >= 3 & service < 5
replace loslvl_common = "4" if service >= 5 & service < 10
replace loslvl_common = "5" if service >= 10 & service < 15
replace loslvl_common = "6" if service >= 15 & service < 20
replace loslvl_common = "7" if service >= 20 & service < 25
replace loslvl_common = "8" if service >= 25 & service < 30
replace loslvl_common = "9" if service >= 30 

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
gen paylvl_common = ""
replace paylvl_common ="1" if adj_pay < 20000
replace paylvl_common ="2" if adj_pay >= 20000 & adj_pay <= 29999
replace paylvl_common ="3" if adj_pay >= 30000 & adj_pay <= 39999
replace paylvl_common ="4" if adj_pay >= 40000 & adj_pay <= 49999
replace paylvl_common ="5" if adj_pay >= 50000 & adj_pay <= 59999
replace paylvl_common ="6" if adj_pay >= 60000 & adj_pay <= 69999
replace paylvl_common ="7" if adj_pay >= 70000 & adj_pay <= 79999
replace paylvl_common ="8" if adj_pay >= 80000 & adj_pay <= 89999
replace paylvl_common ="9" if adj_pay >= 90000 & adj_pay <= 99999
replace paylvl_common ="10" if adj_pay >= 100000 & adj_pay <= 109999
replace paylvl_common ="11" if adj_pay >= 110000 & adj_pay <= 119999
replace paylvl_common ="12" if adj_pay >= 120000 & adj_pay <= 129999
replace paylvl_common ="13" if adj_pay >= 130000 & adj_pay <= 139999
replace paylvl_common ="14" if adj_pay >= 140000 & adj_pay <= 149999
replace paylvl_common ="15" if adj_pay >= 150000 & adj_pay <= 159999
replace paylvl_common ="16" if adj_pay >= 160000 & adj_pay <= 169999
replace paylvl_common ="17" if adj_pay >= 170000 & adj_pay <= 179999
replace paylvl_common ="18" if adj_pay >= 180000 
replace paylvl_common ="" if adj_pay ==.	

gen loc = substr(duty_sta,1,2)
gen occ_cat_common = occ_cat

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
destring paylvl_common, gen(numpaylvl)
by id (q_date), sort: gen qoq_earn_change_lvl = numpaylvl -numpaylvl[_n-1] if id !="#########"
tostring qoq_earn_change_lvl, replace
replace qoq_earn_change_lvl = "" if qoq_earn_change_lvl == "."
drop numpaylvl
by id (q_date), sort: replace qoq_earn_change_lvl = "A" +qoq_earn_change_lvl  if paylvl[_n-1] == "1" 
replace qoq_earn_change_lvl = "Z" +qoq_earn_change_lvl  if paylvl == "18" & qoq_earn_change_lvl !=""
replace qoq_earn_change_lvl = "" if q_date2 > 1 & q_date2 != .
by id (q_date), sort: replace qoq_earn_change_lvl = "" if _n==1 // there shouldn't be change in earning in the 1st obs of an individual
drop q_date2
drop foia13_dup
saveold $data/foia13_formatted.dta, replace

//getting disk overflow problem, got rid of preserve and recall the full file instead
forval yr=2000/2012 {  
    forval qr=1/4 {
	    use $data/foia13_formatted.dta, clear 
	    keep if year ==`yr'& quarter == `qr'
	    saveold $data/foia13_y`yr'q`qr'.dta, replace
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
*drop DOD agencies
gen dept = substr(agency,1,2)
drop if dept == "AF" | dept == "AR" | dept == "DD" | dept == "NV"
drop dept  


gen q_date =yq(year,quarter)

gen loc = substr(duty_sta,1,2)

**i.Recoding age
gen age_common = age

**ii.Add service length level
gen loslvl_common = loslvl

**iii. Add pay level
gen paylvl_common = paylvl
gen occ_cat_common = occ_cat

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
destring paylvl_common, gen(numpaylvl)
by id (q_date), sort: gen qoq_earn_change_lvl = numpaylvl -numpaylvl[_n-1] if id !="#########"
tostring qoq_earn_change_lvl, replace
replace qoq_earn_change_lvl = "" if qoq_earn_change_lvl == "."
drop numpaylvl
by id (q_date), sort: replace qoq_earn_change_lvl = "A" +qoq_earn_change_lvl  if paylvl[_n-1] == "1" 
replace qoq_earn_change_lvl = "Z" +qoq_earn_change_lvl  if paylvl == "18" & qoq_earn_change_lvl !=""
replace qoq_earn_change_lvl = "" if q_date2 > 1 & q_date2 != .
by id (q_date), sort: replace qoq_earn_change_lvl = "" if _n==1 // there shouldn't be change in earning in the 1st obs of an individual
drop q_date2
ren id id_foia16
drop paylvl occ_cat loslvl age foia16_dup
saveold $data/foia16_formatted.dta, replace

//getting disk overflow problem, got rid of preserve and recall the full file instead
forval yr=2000/2012 {    
    forval qr=1/4 {
	    use $data/foia16_formatted.dta, clear
	    keep if year ==`yr' & quarter == `qr'
            save $data/foia16_y`yr'q`qr'.dta , replace
    }  
}    

*Separate FOIA 2016 in masked and nonmasked files
forval yr=2000/2012 {
    forval qr = 1/4 {
	use $data/foia16_y`yr'q`qr'.dta, clear
	keep if duty_sta != "#########"
	save $data/foia16ab_y`yr'q`qr'.dta, replace

	use $data/foia16ab_y`yr'q`qr'.dta, clear
	keep if id_foia16 != "#########"
	save $data/foia16a_y`yr'q`qr'.dta, replace

	use $data/foia16ab_y`yr'q`qr'.dta, clear
	keep if id_foia16 == "#########"
	save $data/foia16b_y`yr'q`qr'.dta, replace

	erase $data/foia16ab_y`yr'q`qr'.dta

	use $data/foia16_y`yr'q`qr'.dta, clear
	keep if duty_sta == "#########"
	save $data/foia16c_y`yr'q`qr'.dta, replace

    }
}




*save the out-of-scope FOIA 2016 data
use $data/foia16_formatted.dta, clear
keep if q_date >= $start_date
save $data/foia16_outsample.dta, replace


capture log close


/********************************************************************************
|																				|
|	III.   Format Fedscope							|
|																				|
********************************************************************************/	
capture log using feds.log
clear
use $data/opmfeds_all.dta, clear
*drop DOD agencies
gen dept = substr(agency,1,2)
drop if dept == "AF" | dept == "AR" | dept == "DD" | dept == "NV"
drop dept  

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
gen age_common = ""
replace age_common = "1" if age == "A"
replace age_common = "2" if age == "B"
replace age_common = "3" if age == "C"
replace age_common = "4" if age == "D"
replace age_common = "5" if age == "E"
replace age_common = "6" if age == "F"
replace age_common = "7" if age == "G"
replace age_common = "8" if age == "H"
replace age_common = "9" if age == "I"
replace age_common = "10" if age == "J"
replace age_common = "11" if age == "K"
replace age_common = "" if age == "Z"

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
gen occ_cat_common = ""
/*
A=2
B=6
C=4
O=5
P=1
T=3
*=9
*/
replace occ_cat_common = "A" if occ_cat == "2"
replace occ_cat_common = "B" if occ_cat == "6"
replace occ_cat_common = "C" if occ_cat == "4"
replace occ_cat_common = "O" if occ_cat == "5"
replace occ_cat_common = "P" if occ_cat == "1"
replace occ_cat_common = "T" if occ_cat == "3"
replace occ_cat_common = "*" if occ_cat == "9"

**iii. Create Longitudinal variables (no id to identify individuals)
drop feds_dup
saveold $data/feds_formatted.dta, replace

//getting disk overflow problem, got rid of preserve and recall the full file instead
forval yr=2000/2012 {
    
    forval qr=1/4 {
	    use $data/feds_formatted.dta, clear
	    keep if year ==`yr' & quarter == `qr'
	    saveold $data/feds_y`yr'q`qr'.dta, replace
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
*drop DOD agencies
gen dept = substr(agency,1,2)
drop if dept == "AF" | dept == "AR" | dept == "DD" | dept == "NV"
drop dept  


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
gen age_common = ""
replace age_common = "1" if age == "< 20"
replace age_common = "2" if age == "20-24"
replace age_common = "3" if age == "25-29"
replace age_common = "4" if age == "30-34"
replace age_common = "5" if age == "35-39"
replace age_common = "6" if age == "40-44"
replace age_common = "7" if age == "45-49"
replace age_common = "8" if age == "50-54"
replace age_common = "9" if age == "55-59"
replace age_common = "10" if age == "60-64"
replace age_common = "11" if age == "65-69" | age == "70-74" | age == "75+"
replace age_common = "" if age == "UNSP"


**ii.Recoding service length level
gen loslvl_common = ""
replace loslvl_common = "1" if loslvl == "< 1"
replace loslvl_common = "2" if loslvl == "1-2"
replace loslvl_common = "3" if loslvl == "3-4"
replace loslvl_common = "4" if loslvl == "5-9"
replace loslvl_common = "5" if loslvl == "10-14"
replace loslvl_common = "6" if loslvl == "15-19"
replace loslvl_common = "7" if loslvl == "20-24"
replace loslvl_common = "8" if loslvl == "25-29"
replace loslvl_common = "9" if loslvl == "30-34" | loslvl == "35+"
replace loslvl_common = "" if loslvl == "UNSP"

gen occ_cat_common = occ_cat

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
by name (q_date), sort: gen q_date2 = q_date - q_date[_n-1]
//the 1st qoq earnings change will be missing, 
by name (q_date), sort: gen qoq_earn_change = adj_pay -adj_pay[_n-1] if (strmatch(name, "NAME WITHHELD*") == 0 & strmatch(name, "NAME UNKNOWN") == 0)
replace qoq_earn_change = . if q_date2 > 1 & q_date2 != .
drop q_date2
drop buzz_dup
saveold $data/buzz_formatted.dta, replace

//getting disk overflow problem, got rid of preserve and recall the full file instead
forval yr=2000/2012 {
    forval qr=1/4 {
	    use $data/buzz_formatted.dta, clear
	    keep if year ==`yr' & quarter == `qr'
	    saveold $data/buzz_y`yr'q`qr'.dta, replace
    }
}  

capture log close 


/********************************************************************************
|																				|
|	V.   Export Observation counts of all Formatted Quarterly Datasets						|
|																				|
********************************************************************************/	
foreach dat in "foia13" "foia16" "feds" "buzz" {
    forval yr=2000/2012 {
        forval qr=1/4 {
	    use $data/`dat'_y`yr'q`qr'.dta, clear
	    local obs_`dat'_y`yr'q`qr' = _N
	    di "`obs_`dat'_y`yr'q`qr''"
	}
    }
} 
clear
set obs 60
gen year = .
gen quarter = .
gen obs_foia13=.
gen obs_foia16=.
gen obs_feds=.
gen obs_buzz=.

local i = 1
forval yr=2000/2012 {
    forval qr=1/4 {
	replace year = `yr' in `i'
	replace quarter = `qr' in `i'
	replace obs_foia13 = `obs_foia13_y`yr'q`qr'' in `i'
	replace obs_foia16 = `obs_foia16_y`yr'q`qr'' in `i'
	replace obs_feds = `obs_feds_y`yr'q`qr'' in `i'
	replace obs_buzz = `obs_buzz_y`yr'q`qr'' in `i'
	local i = `i'+1
    }
}
 

saveold $outputs/opm_quarter_obs_count.dta, replace
export delimited $outputs/opm_quarter_obs_count.csv, replace


