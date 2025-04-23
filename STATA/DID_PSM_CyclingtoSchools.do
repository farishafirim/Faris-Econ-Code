
/* Cycling to School Replication Files for AEJ: Applied by Muralidharan and Prakash */
/* Table 1: Testing the Parallel Trends Assumption */

clear
cd "C:\Users\faris\OneDrive\Documents\ECON\Adv Causal Method\Replication Paper\Cycling\APP2016-0004_data"
set more off

use "bh_enroll_data_reg.dta", clear

* Converting enrollment in logs as the population base for Bihar and Jharkhand is different *
gen lenrollment = log(enrollment)

* Generating Interactions for testing parallel trend assumption *
drop if male==1
ren treat treatedstate
gen n_year=year-2002
gen state_year = treatedstate*n_year

/* Dependent variable: Log (9th Grade Enrollment by School, Gender, and Year) */

*Testing parallel trends for DID State X Year
reg lenrollment state_year treatedstate n_year if class == 9, robust cluster(district_code)
*Parallel trend confirmed

******************************************************************************************************************************************************************

*Proceed with DID
clear
use dlhs-reg-data.dta
drop if bihar==.

*Dropping boys
drop if female==0

*Dropping cohort outside of the original paper's analysis
keep if (age>=14) & (age<=17)

gen treatedcohort=1 if age <=15
replace treatedcohort=0 if age>=16

gen bihar_treatedcohort=treatedcohort*bihar


local demographic sc st obc hindu muslim
local household hhheadschool hhheadmale land bpl media electricity
local village middle bank postoff lcurrpop
local dist busdist towndist railwaydist hqdist

reg enrollment_secschool bihar_treatedcohort treatedcohort bihar [pw = hhwt], robust cluster(village)
estimates store a1

reg enrollment_secschool bihar_treatedcohort treatedcohort bihar `demographic' [pw = hhwt], robust cluster(village)
estimates store a2

reg enrollment_secschool bihar_treatedcohort treatedcohort bihar `demographic' `household'  [pw = hhwt], robust cluster(village)
estimates store a3

reg enrollment_secschool bihar_treatedcohort treatedcohort bihar `demographic' `household' `village' `dist' [pw = hhwt], robust cluster(village)
estimates store a4


outreg2 [a*] using "C:\Users\faris\OneDrive\Documents\ECON\Adv Causal Method\Replication Paper\Cycling\APP2016-0004_data\Results\Extension-NewDID.xls", dec(3) replace

******************************************************************************************************************************************************************

*With PSM
local demographic sc st obc hindu muslim
local household hhheadschool hhheadmale land bpl media electricity
local village middle bank postoff lcurrpop
local dist busdist towndist railwaydist hqdist

*Calculate pscore of being enrolled
logit enrollment_secschool `demographic' `household' `village' `dist' [pw = hhwt], robust cluster(village)
predict pscore

*Matching
psmatch2 bihar if age>15, pscore(pscore) logit noreplacement neighbor(1) caliper(0.0001) 

hist pscore if _support==0

*Drop if not matched
keep if _support==1

*Do the same regression as before
reg enrollment_secschool bihar_treatedcohort treatedcohort bihar [pw = hhwt], robust cluster(village)
estimates store a1

reg enrollment_secschool bihar_treatedcohort treatedcohort bihar `demographic' [pw = hhwt], robust cluster(village)
estimates store a2

reg enrollment_secschool bihar_treatedcohort treatedcohort bihar `demographic' `household'  [pw = hhwt], robust cluster(village)
estimates store a3

reg enrollment_secschool bihar_treatedcohort treatedcohort bihar `demographic' `household' `village' `dist' [pw = hhwt], robust cluster(village)
estimates store a4

outreg2 [a*] using "C:\Users\faris\OneDrive\Documents\ECON\Adv Causal Method\Replication Paper\Cycling\APP2016-0004_data\Results\Extension-NewDID+PSM.xls", dec(3) replace
*****************************************************************************

clear
cd "C:\Users\faris\OneDrive\Documents\ECON\Adv Causal Method\Replication Paper\Cycling\APP2016-0004_data"
set more off
use dlhs-reg-data.dta
drop if bihar==.

local demographic sc st obc hindu muslim

* Local = Household level characteristics *

local household hhheadschool hhheadmale land bpl media electricity

* Local = Village level characteristics 

local village middle bank postoff lcurrpop

* Distance to Different Facilities

local dist busdist towndist railwaydist hqdist
*Calculate pscore of being enrolled
logit enrollment_secschool `demographic' `household' `village' `dist' [pw = hhwt], robust cluster(village)
predict pscore

drop if treat1==.

*Matching
psmatch2 bihar, pscore(pscore) logit noreplacement neighbor(1) caliper(0.0001) 

* Check if _support variable is created
tab _support
tab bihar
tab bihar if _support==0

tab bihar if _support==1

* Distribution of pscore for observations where _support = 0 and bihar = 1
summarize pscore if _support == 0 & bihar == 1

* Distribution of pscore for observations where _support = 0 and bihar = 0
summarize pscore if _support == 0 & bihar == 0


* Create kernel density plots for Bihar == 1 and _support == 1, and Bihar == 1 and _support == 0
kdensity pscore if bihar == 1 & _support == 1, color(blue) lwidth(medium) ///
    title("Bihar's Dropped girls (Red) vs Matched girls (Blue)") ///
    legend(label(1 "Bihar = 1, _support = 1")) ///
    addplot(kdensity pscore if bihar == 1 & _support == 0, color(red) lwidth(medium) ///
    legend(label(2 "Bihar = 1, _support = 0")))

kdensity pscore if bihar == 1 & _support == 1, color(blue) lwidth(medium) ///
    title("Matched Girls from Bihar (blue) and Jharkhand (green)") ///
    legend(label(1 "Bihar = 1, _support = 1")) ///
    addplot(kdensity pscore if bihar == 0 & _support == 1, color(green) lwidth(medium) ///
    legend(label(2 "Bihar = 0, _support = 1")))



* List of variables to test
local variables sc st obc hindu muslim hhheadschool hhheadmale land bpl media electricity middle bank postoff lcurrpop busdist towndist railwaydist hqdist secondarydist

* Loop through each variable to perform the t-test
foreach var of local variables {
    * Perform t-test
    ttest `var', by(bihar)
	preserve
	keep if _support==1
	ttest `var', by(bihar)
	restore
}




keep if _support==1


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

reg enrollment_secschool treat1_female_bihar treat1_female treat1_bihar female_bihar treat1 female bihar [pw = hhwt] if treat1 ~= ., robust cluster(village)
estimates store a1

reg enrollment_secschool treat1_female_bihar treat1_female treat1_bihar female_bihar treat1 female bihar `demographic' [pw = hhwt] if treat1 ~= ., robust cluster(village)
estimates store a2

reg enrollment_secschool treat1_female_bihar treat1_female treat1_bihar female_bihar treat1 female bihar `demographic' `household' [pw = hhwt] if treat1 ~= ., robust cluster(village)
estimates store a3

reg enrollment_secschool treat1_female_bihar treat1_female treat1_bihar female_bihar treat1 female bihar `demographic' `household' `village' `dist' [pw = hhwt] if treat1 ~= ., robust cluster(village)
estimates store a4

outreg2 [a*] using "C:\Users\faris\OneDrive\Documents\ECON\Adv Causal Method\Replication Paper\Cycling\APP2016-0004_data\Results\DDDPSM.xls", dec(3) replace