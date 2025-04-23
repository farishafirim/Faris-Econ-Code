clear 
capture log close
set more off
set logtype text
cd "G:\My Drive\Courseworks\Adv Econ Dev\PS3\" 
log using PS3log_FarisMakarim.log, replace
use ps3.dta
************************************************************************

*3. Open the dataset in Stata ("use ps3.dta"), run the "describe" command, and check that you have 7,230 observations on the variables in ps3vardesc.txt. 
describe

************************************************************************
*4. Graph a poverty profile. To construct a poverty profile, follow these steps: 
*a) Order household income from lowest to highest. 
sort incomepc

************************************************************************
*b) Plot household income (in the y-axis) vs. the household income rank (x-axis). To do this, you will need to calculate the income rank for each household in the dataset (egen incrank = rank(incomepc)). Include horizontal lines corresponding to the full poverty line and the extreme poverty line. (Hint: you may want to create new variables equal to the full and extreme poverty lines.) When drawing the poverty profile, only include households up to the 95th percentile in income per capita on the graph. (That is, leave the top 5% of households off the graph.) Eliminating the highest-income household in this way will allow you to use a sensible scale for the graph, and you will be able to see better what is happening at lower income levels. 

egen incrank = rank(incomepc)
gen expovline=1912
gen fullpovline= 4319
xtile top5 = incomepc, n(20)

graph twoway ///
    (line incomepc incrank if top5<20, lcolor(blue)) ///
    (line expovline incrank if top5<20, lcolor(red)) ///
	(line fullpovline incrank if top5<20, lcolor(green)), ///
	xtitle("Income Rank") ///
    ytitle("Income per Capita (Q)") ///
    ylabel(, nogrid angle(horizontal) format(%9.0f)) ///
	legend(order(1 "Income per capita (Q)" 2 "Extreme Poverty Line (Q)" 3 "Full Poverty Line (Q)"))
	
************************************************************************
*5. Using the full poverty line and the consumption per capita variable, calculate the poverty measures P0, P1, P2 defined in class. (Note: to sum a variable over all observations, use the command "egen newvar = total(oldvar)".) 

sort conspc
*P0
gen poor = conspc<fullpovline
egen q=total(poor)
gen p0=q/_N

*P1
gen p_minus_y1_over_p=(fullpovline-conspc)/fullpovline
replace p_minus_y1_over_p=0 if p_minus_y1_over_p<0
egen sump1 = total(p_minus_y1_over_p)
gen p1=sump1/_N

*P2
gen p_minus_y1_over_p_squared=p_minus_y1_over_p*p_minus_y1_over_p
egen sump2 = total(p_minus_y1_over_p_squared)
gen p2=sump2/_N

sum p0 p1 p2

************************************************************************
*6. Using the extreme poverty line and the consumption per capita variable, again calculate P0, P1, and P2.
*P0
gen poor2 = conspc<expovline
egen q_2=total(poor2)
gen p0_2=q_2/_N

*P1
gen p_minus_y1_over_p_2=(expovline-conspc)/expovline
replace p_minus_y1_over_p_2=0 if p_minus_y1_over_p_2<0
egen sump1_2 = total(p_minus_y1_over_p_2)
gen p1_2=sump1_2/_N

*P2
gen p_minus_y1_over_p_2_squared=p_minus_y1_over_p_2*p_minus_y1_over_p_2
egen sump2_2 = total(p_minus_y1_over_p_2_squared)
gen p2_2=sump2_2/_N

sum p0_2 p1_2 p2_2

************************************************************************
*7. Using the full poverty line and the consumption per capita variable, calculate P2 separately for urban and rural households.

local i=0

while `i'<2{
preserve
keep if urban==`i'
keep conspc fullpovline

gen p_minus_y1_over_p=(fullpovline-conspc)/fullpovline
replace p_minus_y1_over_p=0 if p_minus_y1_over_p<0
gen p_minus_y1_over_p_squared=p_minus_y1_over_p*p_minus_y1_over_p
egen sump2 = total(p_minus_y1_over_p_squared)
gen p2=sump2/_N
sum p2 
local p2_`i' = r(mean) 

restore

local i=`i'+1
}

gen p2_rural = `p2_0'
gen p2_urban = `p2_1'

sum p2_urban p2_rural

************************************************************************

*8. Using the full poverty line and the consumption per capita variable, calculate P2 separately for indigenous and non-indigenous households.

local i=0

while `i'<2{
preserve
keep if indig==`i'
keep conspc fullpovline

gen p_minus_y1_over_p=(fullpovline-conspc)/fullpovline
replace p_minus_y1_over_p=0 if p_minus_y1_over_p<0
gen p_minus_y1_over_p_squared=p_minus_y1_over_p*p_minus_y1_over_p
egen sump2 = total(p_minus_y1_over_p_squared)
gen p2=sump2/_N
sum p2 
local p2_`i' = r(mean)  // Store the value in a local macro

restore

local i=`i'+1
}

gen p2_nonindig = `p2_0'
gen p2_indig = `p2_1'

sum p2_nonindig p2_indig

************************************************************************
*9. Using the full poverty line and the consumption per capita variable, calculate P2 separately for each region. (Three bonus points for doing this in a "while" loop in Stata, like the one you used in Problem Set 1.)

local i=1

while `i'<9{
preserve
keep if region==`i'
keep conspc fullpovline

gen p_minus_y1_over_p=(fullpovline-conspc)/fullpovline
replace p_minus_y1_over_p=0 if p_minus_y1_over_p<0
gen p_minus_y1_over_p_squared=p_minus_y1_over_p*p_minus_y1_over_p
egen sump2 = total(p_minus_y1_over_p_squared)
gen p2=sump2/_N
sum p2 
local p2_`i' = r(mean) 

restore
gen p2_region`i'=`p2_`i''

local i=`i'+1
}

sum p2_region*

************************************************************************
*10. Using one of your comparisons from parts 7-9, compute the contribution that each subgroup makes to overall poverty. Note that if P2 is the poverty measure for the entire population (of households or of individuals), and P2 j and s j are the poverty measure and population share of sub-group j of the population, then the contribution  of each sub-group to overall poverty can be written: sj*P2j/P2. 

*RURAL-URBAN
count if urban == 0  
local num_rural = r(N)

count if urban == 1  
local num_urban = r(N)

gen cont_p2_rural=`num_rural'/_N*p2_rural/p2
gen cont_p2_urban=`num_urban'/_N*p2_urban/p2

*INDIG-NONINDIG
count if indig == 0  
local num_nonindig = r(N)

count if indig == 1  
local num_indig = r(N)

gen cont_p2_indig=`num_indig'/_N*p2_indig/p2
gen cont_p2_nonindig=`num_nonindig'/_N*p2_nonindig/p2

*Regions 1-8
local i = 1
while `i'<9{
	count if region==`i'
	local num_region`i'=r(N)
	gen cont_p2_region`i'=`num_region`i''/_N*p2_region`i'/p2
	local i = `i'+1
	}
	
sum cont*

************************************************************************
*11. Summarize your results for parts 4-10 in a paragraph, noting which calculations you find particularly interesting or important and why. 


************************************************************************
*12. In many cases, detailed consumption or income data is not available, or is available only for a subset of households, and targeting of anti-poverty programs must rely on poverty indices based on a few easy-to-observe correlates of poverty. Suppose that in addition to the ENCOVI survey, Guatemala has a population census with data on all households, but suppose also that the census contains no information on per capita consumption and only contains information on the following variables: urban, indig, spanish, n0_6, n7_24, n25_59, n60_plus, hhhfemal, hhhage, ed_1_5, ed_6, ed_7_10, ed_11, ed_m11, and dummies for each region. (In Stata, a convenient command to create dummy variables for each region is "xi i.region;".) Calculate a "consumption index" using the ENCOVI by (a) regressing log per-capita consumption on the variables available in the population census, and 

gen log_conspc= log(conspc)
reg log_conspc urban indig spanish n0_6 n7_24 n25_59 n60_plus hhhfemal hhhage ed_1_5 ed_6 ed_7_10 ed_11 ed_m11 i.region

*(b) recovering the predicted values (command: predict), 
predict y_hat

*(c) converting from log to level using the "exp( )" function in Stata. These predicted values are your consumption index. Note that an analogous consumption index could be calculated for all households in the population census, using the coefficient estimates from this regression using the ENCOVI data. Explain how. 
gen cons_idx=exp(y_hat)

************************************************************************
*13. Calculate P2 using your index (using the full poverty line) and compare to the value of P2 you calculated in question 5. 

sort cons_idx

gen p_minus_y1_over_p_idx=(fullpovline-cons_idx)/fullpovline
replace p_minus_y1_over_p_idx=0 if p_minus_y1_over_p_idx<0
gen p_minus_y1_over_p_idx_squared=p_minus_y1_over_p_idx*p_minus_y1_over_p_idx
egen sump2_idx = total(p_minus_y1_over_p_idx_squared)
gen p2_idx=sump2_idx/_N

sum p2_idx p2







summarize conspc, detail
scalar p95_conspc = r(p95)

summarize cons_idx, detail
scalar p95_considx = r(p95)

gen inrange_conspc = conspc <= p95_conspc
gen inrange_considx = cons_idx <= p95_considx

scalar povline = 4319 

twoway ///
(hist conspc if inrange_conspc, bin(40) lcolor(blue) fcolor(blue%30) legend(label(1 "Actual (conspc)"))) ///
(hist cons_idx if inrange_considx, bin(40) lcolor(red) fcolor(red%30) legend(label(2 "Predicted (cons_idx)"))) ///
(function y=0, range(0 0) lcolor(black) lpattern(dash) legend(label(3 "Full Poverty Line"))) ///
, title("Histogram: Actual vs Predicted Consumption (Bottom 95%)") ///
xline(`=povline', lcolor(black) lpattern(dash)) ///
legend(order(1 2 3)) ///
ytitle("Number of Observations")





************************************************************************
*14. Using the per-capita income variable, calculate the Gini coefficient for households (assuming that each household enters with equal weight.) Some notes: (1) Your bins will be 1/N wide, where N is the number of households. (2) The value of the Gini coefficient you calculate will not be equal to the actual Gini coefficient for Guatemala, because of the weighting issue described above. (3) To generate a cumulative sum of a variable in Stata, use the syntax "gen newvar = sum(oldvar);". Try it out. (4) If you are interested (although it is not strictly necessary in this case) you can create a difference between the value of a variable in one observation and the value of the same variable in a previous observation in Stata, use the command "gen xdiff = x - x[_n-1];". Be careful about how the data are sorted when you do this. 

sort incomepc

gen cumincomepc=sum(incomepc)
sum cumincomepc
local maxcumincomepc = r(max)
replace cumincomepc=cumincomepc/`maxcumincomepc'
gen trapezoid= (cumincomepc+cumincomepc[_n+1])/(2*_N)
replace trapezoid = 0 if trapezoid==.

egen underlorrenz=total(trapezoid)
gen gini = (0.5-underlorrenz)/(0.5-underlorrenz+underlorrenz)

sum gini
