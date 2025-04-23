clear matrix
capture clear
capture log close
capture program drop _all
capture macro drop _all
drop _all
set more off

*******************************************************************************
* Open the data.
*******************************************************************************
* Tell Stata where to find your data
use "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\Cash_and_Childhood_Development_Replication\macoursetal_main.dta", clear

*******************************************************************************
* Start a log file.
*******************************************************************************
log using "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\finalprojectlog.smcl", text replace

gen age_transfer1 = age_transfer+40
qui tab age_transfer1, gen(CEDAD)

gen TXhhsize = T*s1hhsize_05

gen s1hhsize_05Xed_mom_inter = s1hhsize_05*ed_mom_inter
gen s1hhsize_05Xs1age_head_05 = s1hhsize_05*s1age_head_05
gen s1hhsize_05Xs1male_head_05 = s1hhsize_05*s1male_head_05

qui tab itt_all_i,gen(itt_)
ren itt_1 itt_control
ren itt_2 itt_basico
ren itt_3 itt_training
ren itt_4 itt_grant
gen itt_basicoXs1hhsize_05=itt_basico*s1hhsize_05
gen itt_trainingXs1hhsize_05=itt_training*s1hhsize_05
gen itt_grantXs1hhsize_05=itt_grant*s1hhsize_05

mac def controls "CEDAD* male s1age_head_05 s1male_head_05 ed_mom_inter ed_mom_miss bweight_miss bweight_inter tvip_05_miss tvip_05_inter  height_05_miss height_05_inter weight_05_miss weight_05_inter MUN2 MUN3 MUN4 MUN5 MUN6 com_haz_05 com_waz_05 com_tvip_05 com_control_05 com_vit_05 com_deworm_05 com_notvip s1hhsize_05Xed_mom_inter s1hhsize_05Xs1age_head_05 s1hhsize_05Xs1male_head_05 s1hhsz_65plus_05 s4p6_vitamina_i_05 s4p7_parasite_i_05"

*************************************************************************
**************************************************************************
*Balance test 1 T and C Mean

mat results1=J(44,4,.)
local col = 1
local row = 1
sum ed_mom

**note loop, loop commands are efficient to rerun the same code many times instead of retyping**
foreach v of varlist male age_transfer1 s2mother_inhs_05 ed_mom yrsedfath tvip_05 height_05 weight_05 bweight weighted_05 s4p6_vitamina_i_05 s4p7_parasite_i_05 s1hhsize_05 s1hhsz_undr5_05 s1hhsz_5_14_05 s1hhsz_15_24_05 s1hhsz_25_64_05 s1hhsz_65plus_05 s1male_head_05 s1age_head_05 s11ownland_hh_05 s3ap23_stime_h_05 s3ap24_htime_h_05 s3ap25_hqtime_h_05 s3atoilet_hh_05 s3awater_access_hh_05 s3aelectric_hh_05 propfood_05 prstap_f_05 pranimalprot_f_05 prfruitveg_f_05 MUN1 MUN2 MUN3 MUN4 MUN5 MUN6 com_haz_05 com_control_05 com_tvip_05 com_control_05 com_vit_05 com_deworm_05 com_notvip {
	
	*ttest
	qui ttest `v', by(T)

	*store treatment mean
	mat results1[`row', `col']= r(mu_2) 
	*store control mean
	mat results1[`row', `col'+1]= r(mu_1) 
	*store difference
	mat results1[`row', `col'+2]= r(mu_2) - r(mu_1) 
	
	
	qui sum `v'
	mat results1[`row', `col'+3]= r(N) 
	
	local ++row
	} //end variable loop
	
mat list results1
putexcel set "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\balance.xlsx", sheet(Results) replace
putexcel A1=matrix(results1)
****************************************************************************
*Balance test 2 P-Value

mat results2=J(44,4,.)
local row1 = 1
	
**note loop, loop commands are efficient to rerun the same code many times instead of retyping**
foreach v of varlist male age_transfer1 s2mother_inhs_05 ed_mom yrsedfath tvip_05 height_05 weight_05 bweight weighted_05 s4p6_vitamina_i_05 s4p7_parasite_i_05 s1hhsize_05 s1hhsz_undr5_05 s1hhsz_5_14_05 s1hhsz_15_24_05 s1hhsz_25_64_05 s1hhsz_65plus_05 s1male_head_05 s1age_head_05 s11ownland_hh_05 s3ap23_stime_h_05 s3ap24_htime_h_05 s3ap25_hqtime_h_05 s3atoilet_hh_05 s3awater_access_hh_05 s3aelectric_hh_05 propfood_05 prstap_f_05 pranimalprot_f_05 prfruitveg_f_05 MUN1 MUN2 MUN3 MUN4 MUN5 MUN6 com_haz_05 com_control_05 com_tvip_05 com_control_05 com_vit_05 com_deworm_05 com_notvip {
	
	*reg
	qui reg `v' i.itt_all_i, robust cluster (unique_05)
	mat hold=r(table)
	qui reg `v' T, robust cluster (unique_05)
	mat hold2=r(table)
	scalar pval1=hold2[4,1]
	scalar pval2=hold[4,2]
	scalar pval3=hold[4,3]
	scalar pval4=hold[4,4]
	
	mat results2[`row1',1]=pval1
	mat results2[`row1',2]=pval2
	mat results2[`row1',3]=pval3
	mat results2[`row1',4]=pval4
	local ++row1

	} //end variable loop
	
mat list results2


putexcel E1=matrix(results2)
****************************************************************************
*Retrieve variable name for balance table

putexcel set "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\balance.xlsx", sheet(varname) modify

local varnametag = 1

foreach v of varlist male age_transfer s2mother_inhs_05 ed_mom yrsedfath tvip_05 height_05 weight_05 bweight weighted_05 s4p6_vitamina_i_05 s4p7_parasite_i_05 s1hhsize_05 s1hhsz_undr5_05 s1hhsz_5_14_05 s1hhsz_15_24_05 s1hhsz_25_64_05 s1hhsz_65plus_05 s1male_head_05 s1age_head_05 s11ownland_hh_05 s3ap23_stime_h_05 s3ap24_htime_h_05 s3ap25_hqtime_h_05 s3atoilet_hh_05 s3awater_access_hh_05 s3aelectric_hh_05 propfood_05 prstap_f_05 pranimalprot_f_05 prfruitveg_f_05 MUN1 MUN2 MUN3 MUN4 MUN5 MUN6 com_haz_05 com_control_05 com_tvip_05 com_control_05 com_vit_05 com_deworm_05 com_notvip {

	local x : variable label `v'
	di "`x'"
	putexcel A`varnametag'="`x'"
	local ++varnametag
	}
	
****************************************************************************
*Without interaction
	reg z_tvip_06 T s1hhsize_05 $controls, robust cluster(unique_05) 
	vif
	estat hettest
local y : variable label z_tvip_06
twoway (function y=_b[_cons]+_b[T]*(1) +_b[s1hhsize_05]*x, range(s1hhsize_05))|| (function y=_b[_cons]+_b[T]*(0) +_b[s1hhsize_05]*x, range(s1hhsize_05)), title("`y' no intrctn") xtitle("Household size") ytitle("Z-score") legend (label(1 "Treatment")label(2 "Control")) name(z_tvip_06_T_wi, replace) graphregion(color(white)) 

foreach v of varlist z_tvip_08 z_social_06 z_social_08 z_language_06 z_language_08 z_finmotor_06 z_finmotor_08 z_memory_06 z_memory_08 z_grmotor_06 z_grmotor_08 z_legmotor_06 z_legmotor_08 z_behavior_06 z_behavior_08 z_martians_08 z_height_06 z_height_08 z_weight_06 z_weight_08 z_all_06 z_all_08 {
	qui reg `v' T s1hhsize_05 $controls, robust cluster(unique_05)

local y : variable label `v'
twoway (function y=_b[_cons]+_b[T]*(1) +_b[s1hhsize_05]*x, range(s1hhsize_05))|| (function y=_b[_cons]+_b[T]*(0) +_b[s1hhsize_05]*x, range(s1hhsize_05)), title("`y' no intrctn") xtitle("Household size") ytitle("Z-score") legend (label(1 "Treatment")label(2 "Control")) name(`v'_T_wi, replace) graphregion(color(white))
}

*Regress with T*s1hhsize_05
	qui reg z_tvip_06 T s1hhsize_05 TXhhsize $controls, robust cluster(unique_05)
test T TXhhsize

outreg2 T s1hhsize_05 using "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\results.xls", excel replace keep(T s1hhsize_05 TXhhsize) alpha(0.001,0.01,0.05,0.1,0.15) symbol(***,**,*,+,#) addstat(Prob > F, `r(p)')

local y : variable label z_tvip_06
twoway (function y=_b[_cons]+_b[T]*(1) +_b[s1hhsize_05]*x +_b[TXhhsize]*(1)*x, range(s1hhsize_05))|| (function y=_b[_cons]+_b[T]*(0) +_b[s1hhsize_05]*x +_b[TXhhsize]*(0)*x, range(s1hhsize_05)), title("`y'") xtitle("Household size") ytitle("Z-score") legend (label(1 "Treatment")label(2 "Control")) name(z_tvip_06_T, replace ) graphregion(color(white)) 


foreach v of varlist z_tvip_08 z_social_06 z_social_08 z_language_06 z_language_08 z_finmotor_06 z_finmotor_08 z_memory_06 z_memory_08 z_grmotor_06 z_grmotor_08 z_legmotor_06 z_legmotor_08 z_behavior_06 z_behavior_08 z_martians_08 z_height_06 z_height_08 z_weight_06 z_weight_08 z_all_06 z_all_08 {
	
	qui reg `v' T s1hhsize_05 TXhhsize $controls, robust cluster(unique_05)
test T TXhhsize

outreg2 T s1hhsize_05 using "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\results.xls", excel append  keep(T s1hhsize_05 TXhhsize) alpha(0.001,0.01,0.05,0.1,0.15) symbol(***,**,*,+,#) addstat(Prob > F, `r(p)')

local y : variable label `v'
twoway (function y=_b[_cons]+_b[T]*(1) +_b[s1hhsize_05]*x +_b[TXhhsize]*(1)*x, range(s1hhsize_05))|| (function y=_b[_cons]+_b[T]*(0) +_b[s1hhsize_05]*x +_b[TXhhsize]*(0)*x, range(s1hhsize_05)), title("`y'") xtitle("Household size") ytitle("Z-score") legend (label(1 "Treatment")label(2 "Control")) name(`v'_T, replace ) graphregion(color(white))

}


****************************************************************************

****************************************************************************
*Regress with itt_all_i*s1hhsize_05

	qui reg z_tvip_06 itt_basico itt_training itt_grant s1hhsize_05 itt_basicoXs1hhsize_05 itt_trainingXs1hhsize_05 itt_grantXs1hhsize_05 $controls, robust cluster(unique_05)
test itt_basico itt_basicoXs1hhsize_05

outreg2 T s1hhsize_05 using "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\results4.xls", excel replace keep(itt_basico itt_basicoXs1hhsize_05 itt_training itt_trainingXs1hhsize_05 itt_grant itt_grantXs1hhsize_05) alpha(0.001,0.01,0.05,0.1) symbol(***,**,*,+) addstat(Prob > F, `r(p)') dec(3)

 qui reg z_tvip_06 itt_basico itt_training itt_grant s1hhsize_05 itt_basicoXs1hhsize_05 itt_trainingXs1hhsize_05 itt_grantXs1hhsize_05 $controls, robust cluster(unique_05)
test itt_training itt_trainingXs1hhsize_05

outreg2 T s1hhsize_05 using "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\results4.xls", excel append keep(itt_basico itt_basicoXs1hhsize_05 itt_training itt_trainingXs1hhsize_05 itt_grant itt_grantXs1hhsize_05) alpha(0.001,0.01,0.05,0.1) symbol(***,**,*,+) addstat(Prob > F, `r(p)') dec(3)

	qui reg z_tvip_06 itt_basico itt_training itt_grant s1hhsize_05 itt_basicoXs1hhsize_05 itt_trainingXs1hhsize_05 itt_grantXs1hhsize_05 $controls, robust cluster(unique_05)
test itt_grant itt_grantXs1hhsize_05

outreg2 T s1hhsize_05 using "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\results4.xls", excel append keep(itt_basico itt_basicoXs1hhsize_05 itt_training itt_trainingXs1hhsize_05 itt_grant itt_grantXs1hhsize_05) alpha(0.001,0.01,0.05,0.1) symbol(***,**,*,+) addstat(Prob > F, `r(p)') dec(3)

local y : variable label z_tvip_06
twoway (function y=_b[_cons]+_b[itt_basico]*(1) +_b[s1hhsize_05]*x +_b[itt_basicoXs1hhsize_05]*1*x, range(s1hhsize_05))|| (function y=_b[_cons]+_b[itt_training]*(1) +_b[s1hhsize_05]*x +_b[itt_trainingXs1hhsize_05]*1*x, range(s1hhsize_05))|| (function y=_b[_cons]+_b[itt_grant]*(1) +_b[s1hhsize_05]*x +_b[itt_grantXs1hhsize_05]*1*x, range(s1hhsize_05))|| (function y=_b[_cons]+_b[s1hhsize_05]*x, range(s1hhsize_05)), title("`y'") xtitle("Household size") ytitle("Z-score") legend (label(1 "Basic")label(2 "+Training")label(3 "+Grant")label(4 "Control")) name(z_tvip_06_itt, replace) graphregion(color(white))

foreach v of varlist z_tvip_08 z_social_06 z_social_08 z_language_06 z_language_08 z_finmotor_06 z_finmotor_08 z_memory_06 z_memory_08 z_grmotor_06 z_grmotor_08 z_legmotor_06 z_legmotor_08 z_behavior_06 z_behavior_08 z_martians_08 z_height_06 z_height_08 z_weight_06 z_weight_08 z_all_06 z_all_08 {
	
	qui reg `v' itt_basico itt_training itt_grant s1hhsize_05 itt_basicoXs1hhsize_05 itt_trainingXs1hhsize_05 itt_grantXs1hhsize_05 $controls, robust cluster(unique_05)
test itt_basico itt_basicoXs1hhsize_05

outreg2 T s1hhsize_05 using "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\results4.xls", excel append  keep(itt_basico itt_basicoXs1hhsize_05 itt_training itt_trainingXs1hhsize_05 itt_grant itt_grantXs1hhsize_05) alpha(0.001,0.01,0.05,0.1) symbol(***,**,*,+) addstat(Prob > F, `r(p)') dec(3)

	qui reg `v' itt_basico itt_training itt_grant s1hhsize_05 itt_basicoXs1hhsize_05 itt_trainingXs1hhsize_05 itt_grantXs1hhsize_05 $controls, robust cluster(unique_05)
test itt_training itt_trainingXs1hhsize_05

outreg2 T s1hhsize_05 using "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\results4.xls", excel append  keep(itt_basico itt_basicoXs1hhsize_05 itt_training itt_trainingXs1hhsize_05 itt_grant itt_grantXs1hhsize_05) alpha(0.001,0.01,0.05,0.1) symbol(***,**,*,+) addstat(Prob > F, `r(p)') dec(3)

	qui reg `v' itt_basico itt_training itt_grant s1hhsize_05 itt_basicoXs1hhsize_05 itt_trainingXs1hhsize_05 itt_grantXs1hhsize_05 $controls, robust cluster(unique_05)
test itt_grant itt_grantXs1hhsize_05

outreg2 T s1hhsize_05 using "C:\Users\faris\OneDrive\Documents\ECON\! 6002\Cash_and_Childhood_Development_Replication\results4.xls", excel append  keep(itt_basico itt_basicoXs1hhsize_05 itt_training itt_trainingXs1hhsize_05 itt_grant itt_grantXs1hhsize_05) alpha(0.001,0.01,0.05,0.1) symbol(***,**,*,+) addstat(Prob > F, `r(p)') dec(3)

local y : variable label `v'
twoway (function y=_b[_cons]+_b[itt_basico]*(1) +_b[s1hhsize_05]*x +_b[itt_basicoXs1hhsize_05]*1*x, range(s1hhsize_05))|| (function y=_b[_cons]+_b[itt_training]*(1) +_b[s1hhsize_05]*x +_b[itt_trainingXs1hhsize_05]*1*x, range(s1hhsize_05))|| (function y=_b[_cons]+_b[itt_grant]*(1) +_b[s1hhsize_05]*x +_b[itt_grantXs1hhsize_05]*1*x, range(s1hhsize_05))|| (function y=_b[_cons]+_b[s1hhsize_05]*x, range(s1hhsize_05)), title("`y'") xtitle("Household size") ytitle("Z-score") legend (label(1 "Basic")label(2 "+Training")label(3 "+Grant")label(4 "Control")) name(`v'_itt, replace) graphregion(color(white))

}

****************************************************************************
*Combine graph

local numx 1
local varx "z_all_ z_tvip_ z_social_ z_language_ z_behavior_ z_memory_ z_grmotor_ z_finmotor_ z_legmotor_ z_height_ z_weight_"
foreach v of local varx {
    graph combine `v'06_T_wi `v'06_T `v'06_itt `v'08_T_wi `v'08_T `v'08_itt, name("Graphx`numx'",replace) iscale(.37) graphregion(color(white)) ycommon
local ++numx
}

	   graph combine z_martians_08_T_wi z_martians_08_T z_martians_08_itt, name("Graphx`numx'",replace) iscale(.5) graphregion(color(white)) ycommon

****************************************************************************