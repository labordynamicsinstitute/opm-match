*paths

global basedir /home/ssgprojects/project0002/cdl77/opm-match/
global data "$basedir/inputs"
global work "$basedir/programs"
global outputs "$basedir/outputs"

*varlists
*merge varlist for FOIA 2013 with FOIA 2016
global varlist1 "year quarter agency duty_sta loc age loslvl occ occ_cat pay_plan grade paylvl appoint schedule cbsa educ_c tenure posting_length tenure_occ"

*merge varlist for merge1 with Fedscope
global varlist2 "year quarter agency loc age sex gs occ occ_cat pay_plan grade appoint schedule adj_pay "

*merge varlist for merge2 with Buzzfeed
global varlist3tab "year quarter agency duty_sta age educ_c pay_plan grade loslvl occ occ_cat appoint schedule adj_pay tenure posting_length tenure_occ qoq_earn_change" //dropped name

global varlist3 "year quarter name agency duty_sta age educ_c pay_plan grade loslvl occ occ_cat appoint schedule adj_pay tenure posting_length tenure_occ qoq_earn_change"

*varlists for binary FOIA 2013 merge
*merge bvarlist for FOIA 2013 with FOIA 2016
global varlist1 "year quarter agency duty_sta loc age loslvl occ occ_cat pay_plan grade paylvl appoint schedule cbsa educ_c tenure posting_length tenure_occ qoq_earn_change_lvl"

*merge bvarlist for FOIA 2013 with Fedscope
global varlist2 "year quarter agency loc age sex gs occ occ_cat pay_plan grade appoint schedule adj_pay"

*merge bvarlist for FOIA 2013 with Buzzfeed
global varlist3 "year quarter agency duty_sta age educ_c pay_plan grade loslvl occ occ_cat appoint schedule adj_pay tenure posting_length tenure_occ qoq_earn_change"
