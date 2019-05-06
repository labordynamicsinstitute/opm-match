*paths
global basedir /home/ssgprojects/project0002/cdl77/opm-match/
global data "$basedir/inputs"
global work "$basedir/programs"
global outputs "$basedir/outputs"

*Section of codes to run
global merge1_switch = 1	//set to 1 if running binary FOIA 2013-FOIA2016 merge
global merge2_switch = 0	//set to 1 if running binary FOIA 2013-Fedscope merge
global merge3_switch = 0	//set to 1 if running binary FOIA 2013-Buzzfeed merge

*Carryforward
global start_date = yq(2013,1)
global end_date = yq(2016,1)

*varlists for binary FOIA 2013 merge
//merge varlist for FOIA 2013 with FOIA 2016 without masking
global bvarlist1a "q_date paylvl_common agency duty_sta age_common loslvl_common occ grade cbsa educ_c tenure posting_length tenure_occ qoq_earn_change_lvl loc occ_cat_common pay_plan appoint schedule "

//merge varlist for FOIA 2013 with FOIA 2016 with masking
global bvarlist1b "q_date paylvl_common agency age_common loslvl_common occ grade educ_c tenure posting_length tenure_occ qoq_earn_change_lvl occ_cat_common pay_plan appoint schedule "

//merge varlist for FOIA 2013 with Fedscope
global bvarlist2 "q_date adj_pay agency loc age_common sex gs occ grade occ_cat pay_plan appoint schedule "

//merge varlist for FOIA 2013 with Buzzfeed
global bvarlist3 "q_date adj_pay agency duty_sta age_common educ_c grade loslvl_common occ tenure posting_length tenure_occ qoq_earn_change occ_cat_common pay_plan appoint schedule "




*varlists
//merge varlist for FOIA 2013 with FOIA 2016
global varlist1 "q_date paylvl_common agency duty_sta age_common loslvl_common occ grade cbsa educ_c tenure posting_length tenure_occ loc occ_cat_common pay_plan appoint schedule "

//merge varlist for merge1 with Fedscope
global varlist2 "q_date adj_pay agency loc age_common sex gs occ grade occ_cat_common pay_plan appoint schedule "

//merge varlist for merge2 with Buzzfeed
global varlist3tab "q_date adj_pay agency duty_sta age_common educ_c grade loslvl_common occ tenure posting_length tenure_occ qoq_earn_change occ_cat_common pay_plan appoint schedule " //dropped name

global varlist3 "q_date name adj_pay agency duty_sta age educ_c grade loslvl occ tenure posting_length tenure_occ qoq_earn_change occ_cat pay_plan appoint schedule "


