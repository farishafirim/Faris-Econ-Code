
/* Cycling to School Replication Files for AEJ: Applied by Muralidharan and Prakash */

clear
cd "C:\Users\faris\OneDrive\Documents\ECON\Adv Causal Method\Replication Paper\Cycling\APP2016-0004_data"
set more off

*The main data used in the DID
use dlhs-reg-data.dta
drop if bihar==.

*We want to use DD, not triple difference. So, dropping Jharkhand
drop if bihar==0

*We know that age 14/15 is treatment and age 16/17 is control. So we drop the others
keep if (age >= 14) & (age<=17)

*MADE UP Synthetic DID
*replace enrollment_secschool = enrollment_secschool *0.19075820916 if female==0

reg enrollment_secschool age if age>=16 & female==1
reg enrollment_secschool age if age>=16 & female==0

reg enrollment_secschool age if age<=15 & female==1
reg enrollment_secschool age if age<=15 & female==0

*SDID
gen year=-1*(age-16)

bysort dist: gen pop = _N
bysort dist: egen female_count = total(female==1)
gen female_percent = (female_count / pop) * 100

gen treatdist=female_percent>45


local demographic sc st obc hindu muslim
local household hhheadschool hhheadmale land bpl media electricity
local village middle bank postoff lcurrpop
local dist busdist towndist railwaydist hqdist


collapse treatdist enrollment_secschool `demographic' `household' `village' `dist', by(dist year)
gen treatx=1 if (treatdist==1) & (year>0)
replace treatx=0 if treatx==.

*sdid enrollment_secschool dist year treatx, vce(bootstrap)


sdid enrollment_secschool dist year treatx, covariates(`demographic' `household' `village' `dist') vce(bootstrap)






* Defining locals *

* Local = Demographics *

local demographic sc st obc hindu muslim

* Local = Household level characteristics *

local household hhheadschool hhheadmale land bpl media electricity

* Local = Village level characteristics 

local village middle bank postoff lcurrpop

* Distance to Different Facilities

local dist busdist towndist railwaydist hqdist

* Triple Difference (w.r.t. Jharkhand) *
* Regression Results - Table 2 *
* Treatment = Age 14-15 vs. Control = Age 16-17 *