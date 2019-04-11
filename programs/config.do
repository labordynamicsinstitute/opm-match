*paths

global basedir /home/ssgprojects/project0002/cdl77/opm-match/
global data "$basedir/inputs"
global work "$basedir/programs"
global outputs "$basedir/outputs"

*varlists
*merge varlist for FOIA 2013 with FOIA 2016
global varlist1 "year quarter paylvl agency duty_sta age loslvl occ grade cbsa educ_c tenure posting_length tenure_occ loc occ_cat pay_plan appoint schedule "

*merge varlist for merge1 with Fedscope
global varlist2 "year quarter adj_pay agency loc age sex gs occ grade occ_cat pay_plan appoint schedule "

*merge varlist for merge2 with Buzzfeed
global varlist3tab "year quarter adj_pay agency duty_sta age educ_c grade loslvl occ tenure posting_length tenure_occ qoq_earn_change occ_cat pay_plan appoint schedule " //dropped name

global varlist3 "year quarter name adj_pay agency duty_sta age educ_c grade loslvl occ tenure posting_length tenure_occ qoq_earn_change occ_cat pay_plan appoint schedule "

*varlists for binary FOIA 2013 merge
*merge varlist for FOIA 2013 with FOIA 2016
global bvarlist1 "year quarter paylvl agency duty_sta age loslvl occ grade cbsa educ_c tenure posting_length tenure_occ qoq_earn_change_lvl loc occ_cat pay_plan appoint schedule "

*merge varlist for FOIA 2013 with Fedscope
global bvarlist2 "year quarter adj_pay agency loc age sex gs occ grade occ_cat pay_plan appoint schedule "

*merge varlist for FOIA 2013 with Buzzfeed
global bvarlist3 "year quarter adj_pay agency duty_sta age educ_c grade loslvl occ tenure posting_length tenure_occ qoq_earn_change occ_cat pay_plan appoint schedule "
