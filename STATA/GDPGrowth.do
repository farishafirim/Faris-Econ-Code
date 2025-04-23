
/*

   Stata program ps1starterprogram.do reads the data for Problem Set 1
   and makes two simple graphs. It is a good habit to describe your
   programs in a header like this, in addition to including extensive
   comments in the code. You will be surprised by how quickly you
   forget what your code is meant to be doing.

   SIPA Advanced Economic Development (INAF U8145), Spring 2025

    
   Prof. Nicolás de Roux
   Last modified 01/29/2025

*/

 *--------------*
 * Housekeeping *
 *--------------*

 
 
 *--- Set version
 
 *Note: tell Stata that code is written for version 17.0 (to ensure 
 * compatibility in the future)
 
 version 17.0   
 
 
 *--- Clear

 *Note: clear anything in memory left over from previous runs
 
 clear 
 
 
 *--- Close log
 
 *Note: close log from previous runs (capture prevents error if no log was open)
 
 capture log close
 
 
 *--- Set more off
 
 *Note: allow log to be outputted without requiring keypresses
 
 set more off
 
 
 *--- Set type of text for log
 
 set logtype text

 
 *--- Set working directory 
 
 *Note: you will have to change this
 
 cd "G:\My Drive\Courseworks\Adv Econ Dev\PS1\" 

 
 *--- Start log
 
 *Note: start log file -- you can rename it (for instance to ps1.log)
 
 log using PS1logfile_FarisMakarim.log, replace

 
 
 *--------------*
 * Question 1.2 *
 *--------------*
 
 *--- Load data
 
 *Note: Data must be in working directory as set above
 
 use ps1data_1.dta, clear    
 
 *--- Browse data 
 
 browse
 
 
 *--- Outputs list of variables and summary statistics
 
 summarize  
 
  
 *--- Create adult literacy (intead of illiteracy) variable
 
 gen ad_lit = 100-ad_illit 

 
 *--- Regress infant moratality on adult literacy 
 
 reg inf_mort ad_lit  

 
 *--- Create new variable with predicted values of inf_mort, given ad_lit
 
 predict yhat    

 
 *--- Simple scatterplot of infant mortality vs. adult literacy

 graph twoway scatter inf_mort ad_lit, msymbol(oh) title("infant mortality vs. adult literacy") ytitle("infant mortality (per 1000 births)") xtitle("adult literacy (%)") scheme(s1mono) xscale(titlegap(2)) yscale(titlegap(2)) saving(graph1, replace)

  
 *--- export graph1 to pdf

 graph export graph1.pdf, replace

 
 *--- Scatterplot of infant mortality vs. adult literacy with regression line

 graph twoway scatter inf_mort yhat ad_lit, msymbol(oh i) connect(i l) sort title("infant mortality vs. adult literacy, w/ regression line") ytitle("infant mortality (per 1000 births)") xtitle("adult literacy (%)") scheme(s1mono) xscale(titlegap(2)) yscale(titlegap(2)) saving(graph2, replace)

  
 *--- Export graph2 to postscript file

 graph export graph2.pdf, replace

 

*Question 1.3
gen gdp_usd = gdp_lcu/xr/pop
gen gdp_id = gdp_lcu/ppp/pop
 
*Question 1.4
graph twoway scatter gdp_id gdp_usd, msymbol(oh) title("1.4. GDP/Capita Comparison") ytitle("GDP/capita (PPP Conversion)") xtitle("GDP/capita (XR Conversion)") scheme(s1mono) xscale(titlegap(2)) yscale(titlegap(2)) saving(graph3, replace)
 
  graph export graph1_4.pdf, replace
  
*Question 1.5
gen log_gdp_usd=log(gdp_usd)
gen log_gdp_id=log(gdp_id)

graph twoway scatter log_gdp_id log_gdp_usd, msymbol(oh) title("1.5. GDP/Capita Comparison (log)") ytitle("Log GDP/capita (PPP Conversion)") xtitle("Log GDP/capita (XR Conversion)") scheme(s1mono) xscale(titlegap(2)) yscale(titlegap(2)) saving(graph1_5, replace)
 
  graph export graph1_5.pdf, replace
  
*The graph in 1.5 is easier to interpret because the relationship between x axis and y axis is clearly linear, while the relationship in 1.4 is linear at first but as x goes up, the value increase of y is decreasing. It is more like a log curve. That is why changing the variables to log curve make them linear.

*Question 1.6
graph twoway (scatter log_gdp_id log_gdp_usd, msymbol(oh) connect(i l)) ///
(function y=x, range(4 12) lcolor(red) lwidth(medium)), ///
title("GDP/Capita Comparison (log)") ytitle("Log GDP/capita (PPP Conversion)") xtitle("Log GDP/capita (XR Conversion)") scheme(s1mono) xscale(titlegap(2)) yscale(titlegap(2)) saving(graph5, replace)

graph twoway (scatter log_gdp_id log_gdp_usd, msymbol(i i) mlabel(cty_cod1) mlabsize(tiny) mlabposition(0) connect(i l)) ///
(function y=x, range(4 12) lcolor(red) lwidth(medium)), ///
title("1.6. GDP/Capita Comparison (log)") ytitle("Log GDP/capita (PPP Conversion)") xtitle("Log GDP/capita (XR Conversion)") scheme(s1mono) xscale(titlegap(2)) yscale(titlegap(2)) saving(graph5, replace)

graph export graph1_6.pdf, replace

*Question 1.7
gen ratio = gdp_id/gdp_usd
egen ratio_rank=rank(-ratio)
sort ratio_rank
*PPP conversion larger than XR conversion -> the further away above the x=y line:
* Kyrgyzstan, Ghana, Ethiopia, Congo, Dem. Rep. of the, Tajikistan
 
*PPP conversion smaller than XR conversion -> under the x=y line:
* Sweden, Congo, Switzerland, Norway, Japan

*Question 1.8
*The general trend is that as countries become wealthier, the GDP per capita with PPP (Purchasing Power Parity) conversion tends to be smaller relative to GDP per capita with exchange rate (XR) conversion. In other words, while poorer countries have a significantly higher GDP per capita using PPP conversion compared to XR conversion, this disparity shrinks in wealthier countries. In fact, in richer nations, the GDP per capita using PPP conversion is often nearly the same as or slightly lower than the XR conversion.

*The economic reason behind this pattern lies in the differences in the cost of living. In poorer countries, the cost of living is usually much lower than in wealthier countries, which makes the purchasing power of the people higher relative to the exchange rate. As a result, GDP per capita with PPP conversion is inflated compared to XR conversion. However, in wealthier countries, the higher cost of living reduces the relative advantage of PPP adjustments, as goods and services are more expensive, and people's income is spent on higher-priced items. Consequently, the gap between GDP per capita using PPP and XR conversion narrows or even reverses slightly in richer countries.

 *--------------*
 * Question 2   *
 *--------------*
*Question 2.1
graph twoway scatter inf_mort log_gdp_id, title("2.1. Infant Mortality vs GDP") ytitle("Infant Mortality") xtitle("Log GDP/capita (PPP Conversion)") saving(graph2_1, replace)
 
  graph export graph2_1.pdf, replace

  *Question 2.2
  reg inf_mort log_gdp_id
  predict yhat1

graph twoway scatter inf_mort yhat1 log_gdp_id, msymbol(oh i) scheme(s1mono) connect(i l) title("2.2. Infant Mortality vs GDP") ytitle("Infant Mortality") xtitle("Log GDP/capita (PPP Conversion)") saving(graph2_2, replace)
graph export graph2_2.pdf, replace
  
  
  *Question 2.3
  reg ad_lit log_gdp_id
  predict yhat2

graph twoway scatter ad_lit yhat2 log_gdp_id, msymbol(oh i) scheme(s1mono) connect(i l) title("2.3. Adult Literacy vs GDP") ytitle("Adult Literacy") xtitle("Log GDP/capita (PPP Conversion)") saving(graph2_3, replace)
graph export graph2_3.pdf, replace

*Question 2.4
*Graphs 2.2 and 2.3 show that GDP per capita is associated with other key development indicators, such as infant mortality and adult literacy, which are often considered important by people. This suggests that GDP per capita can serve as a good measure of development, as it appears to summarize many other preferred indicators.

*However, in this analysis, we have not yet fully explored the relationship between GDP and other variables to verify the generalization made earlier. Additionally, I observed that the predictive power of GDP varies across different variables: for example, the deviation in the adult literacy vs. GDP graph is larger than in the infant mortality graph, suggesting that adult literacy cannot be predicted solely by GDP.

*While it is reasonable to consider GDP as a "main" indicator of development due to its ability to predict other variables, I believe it would be more effective to aggregate additional indicators in the analysis. GDP alone is not a perfect predictor, and including other factors would provide a more comprehensive view of development.

 *--------------*
 * Question 3   *
 *--------------*
 *Question 3.1
 use ps1data_2.dta, clear
 replace life_exp=85 if life_exp>85 & life_exp~=.
 replace life_exp=20 if life_exp<20 & life_exp~=.
 replace exp_sch_child =18 if exp_sch_child>18 & exp_sch_child~=.
 replace exp_sch_child =0 if exp_sch_child<0 & exp_sch_child~=.
 replace sch_adult =15 if sch_adult>15 & sch_adult~=.
 replace sch_adult =0 if sch_adult<0 & sch_adult~=.
 replace gnipc =75000 if gnipc>75000 & gnipc~=.
 replace gnipc =100 if gnipc<100 & gnipc~=.
 
 gen hi=(life_exp-20)/(85-20)
 gen eysi=(exp_sch_child-0)/(18-0)
 gen mysi=(sch_adult-0)/(15-0)
 gen ei=(eysi+mysi)/2
 gen ii=(log(gnipc)-ln(100))/(ln(75000)-ln(100))
 gen hdi=(hi*ei*ii)^(1/3)
 
 *Question 3.2.
 egen gdp_rank=rank(-gdppc)
 egen hdi_rank=rank(-hdi)
 
 gen diff_hdi_gdp=hdi_rank-gdp_rank
 
 sort(diff_hdi_gdp)
 
 gen average=(gdp_rank+hdi_rank)/2
 sort(average)
 
 graph twoway scatter hdi_rank gdp_rank
 
 *3.3.
 /*

 Countries with HDI ranks that are particularly poor relative to their GDP/capita ranks:
Kuwait: .7767124
Gabon: .6454703
Botswana: .6283521
Angola: .403403
Equatorial Guinea: .5353691
Countries with HDI ranks that are particularly good relative to their GDP/capita ranks:
Timor-Leste: .5297477
New Zealand: .8911425
Tonga: .6847103
Georgia: .7064959
Ukraine: .7205315

Countries that have poor ranks for both HDI and GDP/capita, and list their values of the HDI:
Guinea-Bissau: .3275769
Niger: .2854061
Burundi: .3214741
Congo (Democratic Republic of the): .2814336
Zimbabwe: .2382953

3.4. Countries with a large positive difference between HDI rank and GDP per capita rank tend to have low GDP (except New Zealand), while countries with a large negative difference between HDI rank and GDP per capita rank tend to have higher GDP per capita.
*/
 *--------------*
 * Question 4.3 *
 *--------------*
 
 clear

 use ps1data_3.dta
 
 
 *--- Sort: put in ascending order by country code and year 
 
 sort country_code year 

  
 *--- Make variable to hold income in 1960
  
 gen rgdp_cap_1960_tmp = rgdp_cap if year==1960
 
 bysort country_code: egen rgdp_cap_1960 = max(rgdp_cap_1960_tmp)
 
 drop rgdp_cap_1960_tmp
 

 *Note: it is good practice to constantly check the data. 'br' is an
 * abbreviation of the command 'browse'

 
 
 *--- Get rgdp_cap in logs

 *Note: so we can use a linear regression to calculate a growth rate like in
 * Lecture 1.
 
 gen lrgdp_cap = log(rgdp_cap)

 
 *--- Define counter local
  
 local i=1 
 
 
 *--- Define matrix to hold coefficient estimates
 
 matrix gr19601999=J(109, 1, 0) 

 
 *--- Make loop which will run regressions separately for each country

 *Note: there are many other ways to do a loop. The following example is just
 * one of them
 
 while `i'<=109 { 
 
  *- Run regression country i in year>=1960 & year<=1999
 
  reg lrgdp_cap year if country_code==`i' & year>=1960 & year<=1999
 
 
 *- Store coefficient estimate on year variable in gr19601999 matrix
 
  matrix gr19601999[`i',1] = _b[year]
  
 *- Increment counter local

  local i=`i'+1 

  }
  
  
 *- See the resulting matrix
 
 matrix list gr19601999
  
  
 *--- Keep just one observation per country 
 
 *Note: you had to be careful here to make sure that you retained variables
 * containing the levels of income in 1960 and 2000

 sort country_code year
 by country_code: keep if _n==1


 
 *--- convert gr19601999 matrix into a variable
 
 *Note: the matrix which will be called gr196019991 (the 1 is not important)
 * in this case, variable represents average growth rate from 1960-1999
 
 svmat gr19601999, name(gr19601999)

 rename gr196019991 gr19601999
 
 br

 
 *Question 4.3
 graph twoway scatter gr19601999 rgdp_cap_1960, msymbol(oh i) scheme(s1mono) connect(i l) title("4.3. Growth vs GDP (1960-1999)") ytitle("GDP Growth 1960-1999") xtitle("GDP/capita (PPP Conversion)") saving(graph4_3, replace)
graph export graph4_3.pdf, replace

*Question 4.5.a

reg gr19601999 lrgdp_cap

*Question 4.4
use ps1data_3.dta,clear
 
 sort country_code year 
  
 gen rgdp_cap_2000_tmp = rgdp_cap if year==2000
 
 bysort country_code: egen rgdp_cap_2000 = max(rgdp_cap_2000_tmp)
 
 drop rgdp_cap_2000_tmp
 
 gen lrgdp_cap = log(rgdp_cap)

 local i=1 
 
 matrix gr20002019=J(109, 1, 0) 

 while `i'<=109 { 
 
  *- Run regression country i in year>=1960 & year<=1999
 
  reg lrgdp_cap year if country_code==`i' & year>=2000 & year<=2019
 
 
 *- Store coefficient estimate on year variable in gr19601999 matrix
 
  matrix gr20002019[`i',1] = _b[year]
  
 *- Increment counter local

  local i=`i'+1 

  }
  

 matrix list gr20002016
  

 sort country_code year
 by country_code: keep if _n==41
 
 svmat gr20002019, name(gr20002019)
 
 graph twoway scatter gr20002019 rgdp_cap_2000, msymbol(oh i) scheme(s1mono) connect(i l) title("4.4. Growth vs GDP (2000-2019") ytitle("GDP Growth 2000-2019") xtitle("GDP/capita (PPP Conversion)") saving(graph4_4, replace)
graph export graph4_4.pdf, replace

*Question 4.5b
reg gr20002019 lrgdp_cap

log close

*Question 4.6.
*From the regression in 4.5, we found that in 1960-1999, GDP in 1960 does not have a significant association with GDP growth between 1960-1999 (p>.05). However, GDP in 2000 has a significant relationship with GDP growth. Specifically, countries with bigger starting GDP in 2000 experienced less growth (p<.05). In the case of absolute convergence, we would expect poorer countries to grow faster than richer ones, leading to a reduction in income disparities across countries. This is the case in the 2000-2019 where poorer countries experienced bigger growth, but not the case for our results in 1960-1999. 