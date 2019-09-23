import delimited /Users/juju/Dropbox/data_0922.csv

gen quarter = date(date_month,"20YMD")
format quarter  %tq
xtset shareid_str quarter 

egen on_TA_group = group(on_ta)

by shareid_str: gen lag3_quality = quality[_n-3]
by shareid_str: gen lag3_review_count = num_of_reviews[_n-3]/1000
by shareid_str: gen lag3_on_TA = on_TA_group[_n-3]

by shareid_str: gen lag1_quality = quality[_n-1]
by shareid_str: gen lag1_review_count = num_of_reviews[_n-1]/1000
by shareid_str: gen lag1_on_TA = on_TA_group[_n-1]

eststo: quietly xtreg revpar i.lag3_quality i.lag3_on_TA c.lag3_review_count c.lag3_review_count#i.lag3_quality i.quarter, fe vce(robust)

estadd local individual "yes"
estadd local quarter "yes"
estadd local robust "yes"

eststo: quietly xtreg revpar i.lag1_quality i.lag1_on_TA c.lag3_review_count c.lag1_review_count#i.lag1_quality i.quarter, fe 

estadd local individual "yes"
estadd local quarter "yes"
estadd local robust "no"

eststo: quietly xtreg revpar i.lag1_quality i.lag1_on_TA c.lag3_review_count c.lag1_review_count#i.lag1_quality i.quarter, fe vce(robust)

estadd local individual "yes"
estadd local quarter "yes"
estadd local robust "yes"


esttab ,  s(fixed N, label("indivudal fixed effects" "year-quarter fixed effect" "Robust")) ar2 se noconstant star(* .10 ** .05 *** .01) drop(*quarter)
