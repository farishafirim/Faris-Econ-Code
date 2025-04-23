clear
cd "C:\Users\faris\OneDrive\Documents\ECON\Conference & Competition\CIES\"

use merged_rapor_adopsirapor_clean.dta, clear

replace Percentage=total_unduh_kumulatif_per_versi_/ total_sekolah_target_adopsi

***************************************************************************
*CLEAN

foreach var of varlist A1_2022 - E7_2024{
	replace `var' = subinstr(`var',",", ".",.)
	replace `var' = subinstr(`var',"%", "",.)
	replace `var'="" if (`var'=="Tidak Tersedia (Satdik tidak mengikuti AN)") | (`var'=="Data Terbaru Belum Tersedia") | (`var'=="Angka Partisipasi Tidak Memadai") | (`var'=="Tidak Tersedia (Tidak ada data untuk indikator ini)")
	destring `var', replace
	egen z`var'=std(`var')
	replace `var'=z`var'
	drop z`var'
}

foreach var of varlist _all {
    drop if missing(`var')
}

tab nama_provinsi, gen(prov)
encode KabupatenKota, gen(KabupatenKota_num)
encode nama_provinsi, gen(provinsi)

*Reshape
reshape long A1_ A2_ A3_ B1_ B2_ B3_ D1_ D2_ D3_ D4_ D5_ D6_ D8_ D9_ D10_ D11_ E1_ E2_ E3_ E4_, i(KabupatenKota) j(Year) string
rename *_ *
destring Year, replace

foreach var in A1 A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {
    gen `var'_2022 = `var' if Year == 2022
    bysort KabupatenKota (Year): replace `var'_2022 = `var'_2022[_n-1] if missing(`var'_2022)
}

foreach var in A1 A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {
    gen `var'_2023 = `var' if Year == 2023
    bysort KabupatenKota (Year): replace `var'_2023 = `var'_2023[_n-1] if missing(`var'_2023)
	bysort KabupatenKota (Year): replace `var'_2023 = `var'_2023[_n+1] if missing(`var'_2023)
}





***************************************************************************
*BINARY TREATMENT MEDIAN
gen treat=1 if Percentage>0.258
replace treat = 0 if Percentage<=0.258

*PSM
logit treat D12_2022 A1_2022 B1_2022 D1_2022 D2_2022 D3_2022 D6_2022 D9_2022 E3_2022 , cluster(KabupatenKota) robust
vif,uncentered
predict pscore, pr

preserve
keep if Year==2022
psmatch2 treat, pscore(pscore) caliper(0.005) neighbor(1)
tab _weight
drop if _weight==.
keep KabupatenKota_num _weight

save matched_data.dta, replace

restore
drop _merge
merge n:1 KabupatenKota_num using matched_data.dta


*IPW
gen _weight2 = .
replace _weight2 = 1/pscore if treat == 1
replace _weight2 = 1/(1 - pscore) if treat == 0
replace _weight2=10 if _weight2>10

*PARALLEL TREND
preserve
drop if Year==2024
xtset KabupatenKota_num Year
gen pretrend_A1 = A1 - L.A1 if Year == 2023
reg pretrend_A1 treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov*, cluster(KabupatenKota) robust
outreg2 using paraleltrendmed.xls, replace keep(treat)

reg pretrend_A1 treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* [pweight=_weight], cluster(KabupatenKota) robust
outreg2 using paraleltrendmed.xls, append keep(treat)

reg pretrend_A1 treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* [pweight=_weight2] if _weight~=., cluster(KabupatenKota) robust
outreg2 using paraleltrendmed.xls, append keep(treat)

foreach var of varlist A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {
    gen pretrend_`var' = `var' - L.`var' if Year == 2023
	reg pretrend_`var' treat *_2022 total_sekolah_target_adopsi 		total_login_kumulatif_per_versi prov*, cluster(KabupatenKota) robust
	outreg2 using paraleltrendmed.xls, append keep(treat)
	
	reg pretrend_`var' treat *_2022 total_sekolah_target_adopsi 		total_login_kumulatif_per_versi prov* [pweight=_weight], cluster(KabupatenKota) robust
	outreg2 using paraleltrendmed.xls, append keep(treat)

	reg pretrend_`var' treat *_2022 total_sekolah_target_adopsi 		total_login_kumulatif_per_versi prov* [pweight=_weight2] if _weight~=., cluster(KabupatenKota) robust
	outreg2 using paraleltrendmed.xls, append keep(treat)
}
restore 

*DID
gen tryear = (Year==2024)
gen treat_tryear=treat*tryear

reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year, cluster(KabupatenKota) robust
outreg2 using didresultsmed.xls, replace keep(treat_tryear tryear treat)

reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
outreg2 using didresultsmed.xls, append keep(treat_tryear tryear treat)

/*reg treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
predict residual, residuals
reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023 residual, cluster(KabupatenKota) robust
outreg2 using didresultsmed.xls, append keep(treat_tryear tryear treat)
*/

preserve
drop if _weight==.
reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023 [pweight=_weight], cluster(KabupatenKota) robust
outreg2 using didresultsmed.xls, append keep(treat_tryear tryear treat)

reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023 [pweight=_weight2], cluster(KabupatenKota) robust
outreg2 using didresultsmed.xls, append keep(treat_tryear tryear treat)
restore

foreach var of varlist A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {
reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year, cluster(KabupatenKota) robust
outreg2 using didresultsmed.xls, append keep(treat_tryear tryear treat)

reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
outreg2 using didresultsmed.xls, append keep(treat_tryear tryear treat)

/*
reg treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
capture drop residual
predict residual, residuals
reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023 residual, cluster(KabupatenKota) robust
outreg2 using didresultsmed.xls, append keep(treat_tryear tryear treat)
*/

preserve
drop if _weight==.
reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023 [pweight=_weight], cluster(KabupatenKota) robust
outreg2 using didresultsmed.xls, append keep(treat_tryear tryear treat)

reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023 [pweight=_weight2], cluster(KabupatenKota) robust
outreg2 using didresultsmed.xls, append keep(treat_tryear tryear treat)
restore
}


**************************************************************************
*HETEROGENOUS EFFECT ON HIGHER D3
*PSM
capture drop treat
capture drop pscore
capture drop _weight2
gen treat= (Percentage>0.258)
logit treat D12_2022 A1_2022 B1_2022 D1_2022 D2_2022 D3_2022 D6_2022 D9_2022 E3_2022 , cluster(KabupatenKota) robust
vif,uncentered
predict pscore, pr

preserve
keep if Year==2022
psmatch2 treat, pscore(pscore) caliper(0.005) neighbor(1)
tab _weight
drop if _weight==.
keep KabupatenKota_num _weight

save matched_data.dta, replace

restore
drop _merge
merge n:1 KabupatenKota_num using matched_data.dta


*IPW
gen _weight2 = .
replace _weight2 = 1/pscore if treat == 1
replace _weight2 = 1/(1 - pscore) if treat == 0
replace _weight2=10 if _weight2>10

capture drop tryear
capture drop treat_tryear
capture drop highlead
capture drop treat_highlead
capture drop highlead_tryear
capture drop treat_tryear_highlead


gen highlead = (D3_2022>-0.049) 
gen tryear = (Year==2024)

gen treat_tryear=treat*tryear
gen treat_highlead=treat*highlead
gen highlead_tryear=highlead*tryear

gen treat_tryear_highlead = treat*tryear*highlead

reg A1 treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
outreg2 using DDDresultsmed.xls, replace keep(treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead)

preserve
drop if _weight==.
reg A1 treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023 [pweight=_weight], cluster(KabupatenKota) robust
outreg2 using DDDresultsmed.xls, append keep(treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead)

reg A1 treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023 [pweight=_weight2], cluster(KabupatenKota) robust
outreg2 using DDDresultsmed.xls, append keep(treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead)
restore

foreach var of varlist A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {

reg `var' treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
outreg2 using DDDresultsmed.xls, append keep(treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead)

preserve
drop if _weight==.
reg `var' treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023 [pweight=_weight], cluster(KabupatenKota) robust
outreg2 using DDDresultsmed.xls, append keep(treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead)

reg `var' treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023 [pweight=_weight2], cluster(KabupatenKota) robust
outreg2 using DDDresultsmed.xls, append keep(treat_tryear_highlead treat_tryear highlead_tryear treat_highlead tryear treat highlead)
restore
}


***************************************************************************

*BINARY TREATMENT Q1 Q3
*PARALLEL TREND
preserve
capture drop treat
gen treat=1 if Percentage>=0.46875
replace treat = 0 if Percentage<0.46875

drop if Year==2024
xtset KabupatenKota_num Year
gen pretrend_A1 = A1 - L.A1 if Year == 2023
reg pretrend_A1 treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov*, cluster(KabupatenKota) robust
outreg2 using paraleltrendq3q1.xls, replace keep(treat) 

foreach var of varlist A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {
    gen pretrend_`var' = `var' - L.`var' if Year == 2023
	reg pretrend_`var' treat *_2022 total_sekolah_target_adopsi 		total_login_kumulatif_per_versi prov*, cluster(KabupatenKota) robust
	outreg2 using paraleltrendq3q1.xls, append keep(treat) 
}
restore 

*DID
capture drop treat
capture drop tryear
capture drop treat_tryear
gen treat=1 if Percentage>=0.46875
replace treat = 0 if Percentage<0.46875
gen tryear = (Year==2024)
gen treat_tryear=treat*tryear

/*
reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year, cluster(KabupatenKota) robust
outreg2 using didresultsq3q1.xls, replace keep(treat_tryear tryear treat)
*/

reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
outreg2 using didresultsq3q1.xls, replace keep(treat_tryear tryear treat)

foreach var of varlist A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {
/*
reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year, cluster(KabupatenKota) robust
outreg2 using didresultsq3q1.xls, append keep(treat_tryear tryear treat)
*/

reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
outreg2 using didresultsq3q1.xls, append keep(treat_tryear tryear treat)
}

***************************************************************************

*BINARY TREATMENT Q1 Q3 (flipped)
*PARALLEL TREND
preserve
capture drop treat
gen treat=1 if Percentage>=0.1245136
replace treat = 0 if Percentage<0.1245136

drop if Year==2024
xtset KabupatenKota_num Year
gen pretrend_A1 = A1 - L.A1 if Year == 2023
reg pretrend_A1 treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov*, cluster(KabupatenKota) robust
outreg2 using paraleltrendq1q3.xls, replace keep(treat) 

foreach var of varlist A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {
    gen pretrend_`var' = `var' - L.`var' if Year == 2023
	reg pretrend_`var' treat *_2022 total_sekolah_target_adopsi 		total_login_kumulatif_per_versi prov*, cluster(KabupatenKota) robust
	outreg2 using paraleltrendq1q3.xls, append keep(treat) 
}
restore 

*DID
preserve
capture drop treat
capture drop tryear
capture drop treat_tryear
gen treat=1 if Percentage>=0.1245136
replace treat = 0 if Percentage<0.1245136
drop if treat==.
gen tryear = (Year==2024)
gen treat_tryear=treat*tryear
/*
reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year, cluster(KabupatenKota) robust
outreg2 using didresultsq1q3.xls, replace keep(treat_tryear tryear treat)
*/
reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
outreg2 using didresultsq1q3.xls, append keep(treat_tryear tryear treat)

foreach var of varlist A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {

/*reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year, cluster(KabupatenKota) robust
outreg2 using didresultsq1q3.xls, append keep(treat_tryear tryear treat)
*/
reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
outreg2 using didresultsq1q3.xls, append keep(treat_tryear tryear treat)
}
restore


***************************************************************************

*CONTINUOUS TREATMENT
capture drop treat
capture drop tryear
capture drop treat_tryear
gen treat = Percentage

*PARALLEL TREND
preserve
drop if Year==2024
xtset KabupatenKota_num Year
gen pretrend_A1 = A1 - L.A1 if Year == 2023
reg pretrend_A1 treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov*, cluster(KabupatenKota) robust
outreg2 using paraleltrendcont.xls, replace keep(treat)

foreach var of varlist A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {
    gen pretrend_`var' = `var' - L.`var' if Year == 2023
	reg pretrend_`var' treat *_2022 total_sekolah_target_adopsi 		total_login_kumulatif_per_versi prov*, cluster(KabupatenKota) robust
	outreg2 using paraleltrendcont.xls, append keep(treat)
}
restore 

*DID
gen tryear = (Year==2024)
gen treat_tryear=treat*tryear

/*
reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year, cluster(KabupatenKota) robust
outreg2 using didresultscont.xls, replace keep(treat_tryear tryear treat)
*/
reg A1 treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
outreg2 using didresultscont.xls, replace keep(treat_tryear tryear treat)

foreach var of varlist A2 A3 B1 B2 B3 D1 D2 D3 D4 D5 D6 D8 D9 D10 D11 E1 E2 E3 E4 {

/*reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year, cluster(KabupatenKota) robust
outreg2 using didresultscont.xls, append keep(treat_tryear tryear treat)
*/
reg `var' treat_tryear tryear treat *_2022 total_sekolah_target_adopsi total_login_kumulatif_per_versi prov* i.Year *2023, cluster(KabupatenKota) robust
outreg2 using didresultscont.xls, append keep(treat_tryear tryear treat)
}

***************************************************************************









*BINARY TREATMENT MEDIAN
gen treat=1 if Percentage>0.258
replace treat = 0 if Percentage<=0.258
*PARALLEL TREND

	local var2023 = subinstr("A1_2022", "2022", "2023", 1)
	reg `var2023' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendmed.xls, replace keep(treat)

foreach var of varlist A2_2022 A3_2022 B1_2022 B2_2022 B3_2022 D1_2022 D2_2022 D3_2022 D4_2022 D5_2022 D6_2022 D8_2022 D9_2022 D10_2022 D11_2022 E1_2022 E2_2022 E3_2022 E4_2022{
	local var2023 = subinstr("`var'", "2022", "2023", 1)
	reg `var2023' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendmed.xls, append keep(treat)
	}

*DID
	local var2024 = subinstr("A1_2023", "2023", "2024", 1)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using didresultsmed.xls, replace keep(treat)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi  A1_2023 A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023 E1_2023 E7_2023 *2023, robust
	outreg2 using didresultsmed.xls, append keep(treat)

foreach var of varlist A2_2023	A3_2023	B1_2023	B2_2023	B3_2023 D1_2023		D2_2023	D3_2023	D4_2023 D6_2023 D9_2023	D10_2023 D11_2023	E1_2023	E2_2023 E4_2023{
	local var2024 = subinstr("`var'", "2023", "2024", 1)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using didresultsmed.xls, append keep(treat)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi A1_2023 A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023 E1_2023 E7_2023 *2023, robust
	outreg2 using didresultsmed.xls, append keep(treat)
	}
	
***************************************************************************

***************************************************************************
*BINARY TREATMENT Q1 Q3
preserve
drop treat
gen treat=1 if Percentage>=0.478
replace treat = 0 if Percentage<=0.115
drop if treat==.

*PARALLEL TREND

	local var2023 = subinstr("A1_2022", "2022", "2023", 1)
	reg `var2023' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendq3q1.xls, replace keep(treat)

foreach var of varlist A2_2022 A3_2022 B1_2022 B2_2022 B3_2022 D1_2022 D2_2022 D3_2022 D4_2022 D5_2022 D6_2022 D8_2022 D9_2022 D10_2022 D11_2022 E1_2022 E2_2022 E3_2022 E4_2022{
	local var2023 = subinstr("`var'", "2022", "2023", 1)
	reg `var2023' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendq3q1.xls, append keep(treat)
	}

*DID
	local var2024 = subinstr("A1_2023", "2023", "2024", 1)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using didresultsq3q1.xls, replace keep(treat)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi  A1_2023 A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023 E1_2023 E7_2023 *2023, robust
	outreg2 using didresultsq3q1.xls, append keep(treat)

foreach var of varlist A2_2023	A3_2023	B1_2023	B2_2023	B3_2023 D1_2023		D2_2023	D3_2023	D4_2023 D6_2023 D9_2023	D10_2023 D11_2023	E1_2023	E2_2023 E4_2023{
	local var2024 = subinstr("`var'", "2023", "2024", 1)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using didresultsq3q1.xls, append keep(treat)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi A1_2023 A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023 E1_2023 E7_2023 *2023, robust
	outreg2 using didresultsq3q1.xls, append keep(treat)
	}
restore
	
***************************************************************************
***************************************************************************
*CONTINUOUS TREATMENT
drop treat
gen treat = Percentage

*PARALLEL TREND

	local var2023 = subinstr("A1_2022", "2022", "2023", 1)
	reg `var2023' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendcont.xls, replace keep(treat)

foreach var of varlist A2_2022 A3_2022 B1_2022 B2_2022 B3_2022 D1_2022 D2_2022 D3_2022 D4_2022 D5_2022 D6_2022 D8_2022 D9_2022 D10_2022 D11_2022 E1_2022 E2_2022 E3_2022 E4_2022{
	local var2023 = subinstr("`var'", "2022", "2023", 1)
	reg `var2023' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendcont.xls, append keep(treat)
	}

*DID
	local var2024 = subinstr("A1_2023", "2023", "2024", 1)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using didresultscont.xls, replace keep(treat)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi  A1_2023 A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023 E1_2023 E7_2023 *2023, robust
	outreg2 using didresultscont.xls, append keep(treat)

foreach var of varlist A2_2023	A3_2023	B1_2023	B2_2023	B3_2023 D1_2023		D2_2023	D3_2023	D4_2023 D6_2023 D9_2023	D10_2023 D11_2023	E1_2023	E2_2023 E4_2023{
	local var2024 = subinstr("`var'", "2023", "2024", 1)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using didresultscont.xls, append keep(treat)
	reg `var2024' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi A1_2023 A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023 E1_2023 E7_2023 *2023, robust
	outreg2 using didresultscont.xls, append keep(treat)
	}
	
***************************************************************************














***************************************************************************
*BINARY TREATMENT MEDIAN
gen treat=1 if Percentage>0.258
replace treat = 0 if Percentage<=0.258
*PARALLEL TREND

	gen A1_2022_treat=A1_2022*treat
	local var2023 = subinstr("A1_2022", "2022", "2023", 1)
	reg `var2023' A1_2022_treat A1_2022 treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendmed.xls, replace keep(A1_2022_treat A1_2022 treat)

foreach var of varlist A2_2022 A3_2022 B1_2022 B2_2022 B3_2022 D1_2022 D2_2022 D3_2022 D4_2022 D5_2022 D6_2022 D8_2022 D9_2022 D10_2022 D11_2022 E1_2022 E2_2022 E3_2022 E4_2022{
	gen `var'_treat=`var'*treat
	local var2023 = subinstr("`var'", "2022", "2023", 1)
	reg `var2023' `var'_treat treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendmed.xls, append keep(`var'_treat `var' treat)
	}

*DID
	gen A1_2023_treat=A1_2023*treat
	local var2024 = subinstr("A1_2023", "2023", "2024", 1)
	reg `var2024' A1_2023_treat A1_2023 treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using didresultsmed.xls, replace keep(A1_2023_treat A1_2023 treat)
	reg `var2024' A1_2023_treat A1_2023 treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023, robust
	outreg2 using didresultsmed.xls, append keep(A1_2023_treat A1_2023 treat)
	reg `var2024' A1_2023_treat A1_2023 treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023 E1_2023 E7_2023, robust
	outreg2 using didresultsmed.xls, append keep(A1_2023_treat A1_2023 treat)
	reg `var2024' A1_2023_treat A1_2023 treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 *2023, robust
	outreg2 using didresultsmed.xls, append keep(A1_2023_treat A1_2023 treat)

foreach var of varlist A2_2023	A3_2023	B1_2023	B2_2023	B3_2023 D1_2023		D2_2023	D3_2023	D4_2023 D6_2023 D9_2023	D10_2023 D11_2023	E1_2023	E2_2023 E4_2023{
	gen `var'_treat=`var'*treat
	local var2024 = subinstr("`var'", "2023", "2024", 1)
	reg `var2024' `var'_treat treat `var' *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using didresultsmed.xls, append keep(`var'_treat `var' treat)
	reg `var2024' `var'_treat treat `var' *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi A1_2023 A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023, robust
	outreg2 using didresultsmed.xls, append keep(`var'_treat `var' treat)
	reg `var2024' `var'_treat treat `var' *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi A1_2023 A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023 E1_2023 E7_2023, robust
	outreg2 using didresultsmed.xls, append keep(`var'_treat `var' treat)
	reg `var2024' `var'_treat treat `var' *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi A1_2023 A2_2023 A3_2023 B1_2023 B2_2023 B3_2023 D1_2023 D2_2023 D3_2023 D4_2023 D5_2023 E1_2023 E7_2023 *2023, robust
	outreg2 using didresultsmed.xls, append keep(`var'_treat `var' treat)
	}
	
***************************************************************************
*BINARY TREATMENT Q1 Q3
drop treat
drop *_treat
gen treat=1 if Percentage>=0.478
replace treat = 0 if Percentage<=0.115
drop if treat==.

*PARALLEL TREND

	gen A1_2022_treat=A1_2022*treat
	local var2023 = subinstr("A1_2022", "2022", "2023", 1)
	reg `var2023' A1_2022_treat A1_2022 treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendq3q1.xls, replace keep(A1_2022_treat A1_2022 treat)

foreach var of varlist A2_2022 A3_2022 B1_2022 B2_2022 B3_2022 D1_2022 D2_2022 D3_2022 D4_2022 D5_2022 D6_2022 D8_2022 D9_2022 D10_2022 D11_2022 E1_2022 E2_2022 E3_2022 E4_2022{
	gen `var'_treat=`var'*treat
	local var2023 = subinstr("`var'", "2022", "2023", 1)
	reg `var2023' `var' `var'_treat treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendq3q1.xls, append keep(`var'_treat `var' treat)
	}

*DID
	gen A1_2023_treat=A1_2023*treat
	local var2024 = subinstr("A1_2023", "2023", "2024", 1)
	reg `var2024' A1_2023_treat `var' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi *2023, robust
	outreg2 using didresultsq3q1.xls, replace keep(A1_2023_treat A1_2023 treat)

foreach var of varlist A2_2023	A3_2023	B1_2023	B2_2023	B3_2023 D1_2023		D2_2023	D3_2023	D4_2023 D6_2023 D9_2023	D10_2023 D11_2023	E1_2023	E2_2023 E4_2023{
	gen `var'_treat=`var'*treat
	local var2024 = subinstr("`var'", "2023", "2024", 1)
	reg `var2024' `var'_treat `var' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using didresultsq3q1.xls, append keep(`var'_treat `var' treat)
	}
	***************************************************************************
*CONTINUOUS TREATMENT
drop treat
drop *_treat
gen treat = Percentage


*PARALLEL TREND

	gen A1_2022_treat=A1_2022*treat
	local var2023 = subinstr("A1_2022", "2022", "2023", 1)
	reg `var2023' A1_2022_treat A1_2022 treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendcont.xls, replace keep(A1_2022_treat A1_2022 treat)

foreach var of varlist A2_2022 A3_2022 B1_2022 B2_2022 B3_2022 D1_2022 D2_2022 D3_2022 D4_2022 D5_2022 D6_2022 D8_2022 D9_2022 D10_2022 D11_2022 E1_2022 E2_2022 E3_2022 E4_2022{
	gen `var'_treat=`var'*treat
	local var2023 = subinstr("`var'", "2022", "2023", 1)
	reg `var2023' `var' `var'_treat treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using paraleltrendcont.xls, append keep(`var'_treat `var' treat)
	}

*DID
	gen A1_2023_treat=A1_2023*treat
	local var2024 = subinstr("A1_2023", "2023", "2024", 1)
	reg `var2024' A1_2023_treat `var' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi *2023, robust
	outreg2 using didresultscont.xls, replace keep(A1_2023_treat A1_2023 treat)

foreach var of varlist A2_2023	A3_2023	B1_2023	B2_2023	B3_2023 D1_2023		D2_2023	D3_2023	D4_2023 D6_2023 D9_2023	D10_2023 D11_2023	E1_2023	E2_2023 E4_2023{
	gen `var'_treat=`var'*treat
	local var2024 = subinstr("`var'", "2023", "2024", 1)
	reg `var2024' `var'_treat `var' treat *2022 prov* total_login_kumulatif_per_versi_ total_sekolah_target_adopsi, robust
	outreg2 using didresultscont.xls, append keep(`var'_treat `var' treat)
	}















/*
gen A1_2022_treat=A1_2022*treat
gen A2_2022_treat=A2_2022*treat
gen A3_2022_treat=A3_2022*treat
reg A1_2023 A1_2022_treat treat *_2022
reg A2_2023 A2_2022_treat treat *_2022
reg A3_2023 A3_2022_treat treat *_2022






foreach var of varlist A1_2022 - E7_2024{
	replace `var'="" if (`var'=="Tidak Tersedia (Satdik tidak mengikuti AN)") | (`var'=="Data Terbaru Belum Tersedia") | (`var'=="Angka Partisipasi Tidak Memadai")
	replace `var' = subinstr(`var',"%", "",.)
	replace `var' = subinstr(`var',",", ".",.)
	destring `var', replace
	egen Z`var'=std(`var')
}

drop if Percentage==.

reshape long ZA1_ ZA2_ ZB1_ ZB2_ ZD1_ ZD2_ A1_ A2_ B1_ B2_ D1_ D2_, i(KabupatenKota nama_provinsi total_sekolah_target_adopsi total_login_kumulatif_per_versi_ total_unduh_kumulatif_per_versi_ Percentage _merge treat) j(year)

drop _merge
rename *_ *

foreach var of varlist A1 A2 D1 D2{
	replace `var'=`var'/3*100 if year==2022
}

encode KabupatenKota, gen(KabupatenKota_num)
encode nama_provinsi, gen(nama_provinsi_num)

gen treatedyear=1 if year==2024
replace treatedyear=0 if year<2024

gen treat_treatedyear=treat*treatedyear

gen n_year=year-2021
gen treat_year=treat*n_year

sum A1 A2 B1 B2 D1 D2 year treat Percentage

reg A1 treat_year n_year treat if year<2024
estimates store a1
reg A2 treat_year n_year treat if year<2024
estimates store a2
reg B1 treat_year n_year treat if year<2024
estimates store a3
reg B2 treat_year n_year treat if year<2024
estimates store a4
reg D1 treat_year n_year treat if year<2024
estimates store a5
reg D2 treat_year n_year treat if year<2024
estimates store a6

outreg2 [a*] using "C:\Users\faris\OneDrive\Documents\ECON\Conference & Competition\CIES\Paralleltrend", dec(3) replace


sum A2 if year==2022 & treat==1
sum A2 if year==2023 & treat==1
sum A2 if year==2022 & treat==0
sum A2 if year==2023 & treat==0

/*gsort -treat
gen id=_n

tsset id year
synth A1 A1(2022) A1(2023) A1(2024), trunit(9) trperiod(2023) fig
*/


sdid A1 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(40(5)65) ytitle("Literacy Score") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sc) returnweights g1on seed(4) reps(10000)
graph export A1.png, replace

sdid A2 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(40(5)65) ytitle("Numeracy Score") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sc) returnweights g1on seed(4) reps(10000)
graph export A2.png, replace

sdid B1 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(1(1)4) ytitle("Literacy Inequality") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sc) returnweights g1on seed(4) reps(10000)
graph export B1.png, replace

sdid B2 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(1(1)4) ytitle("Literacy Inequality") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sc) returnweights g1on  seed(4) reps(10000)
graph export B2.png, replace

sdid D1 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(50(5)75) ytitle("Learning Quality") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sc) returnweights g1on  seed(4) reps(10000)
graph export D1.png, replace

sdid D2 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(50(5)75) ytitle("Teacher Learning & Reflection") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sc) returnweights g1on seed(4) reps(10000)
graph export D2.png, replace



sdid A1 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(40(5)65) ytitle("Literacy Score") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sdid) returnweights g1on seed(4) reps(500)
graph export A1did.png, replace

sdid A2 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(40(5)65) ytitle("Numeracy Score") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sdid) returnweights g1on seed(4) reps(500)
graph export A2did.png, replace

sdid B1 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(1(1)4) ytitle("Literacy Inequality") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sdid) returnweights g1on seed(4) reps(500)
graph export B1did.png, replace

sdid B2 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(1(1)4) ytitle("Literacy Inequality") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sdid) returnweights g1on  seed(4) reps(500)
graph export B2did.png, replace

sdid D1 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(50(5)75) ytitle("Learning Quality") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sdid) returnweights g1on  seed(4) reps(500)
graph export D1did.png, replace

sdid D2 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(50(5)75) ytitle("Teacher Learning & Reflection") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(sdid) returnweights g1on seed(4) reps(500)
graph export D2did.png, replace



sdid A1 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(40(5)65) ytitle("Literacy Score") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(did) returnweights g1on seed(4) reps(500)
graph export A1odid.png, replace

sdid A2 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(40(5)65) ytitle("Numeracy Score") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(did) returnweights g1on seed(4) reps(500)
graph export A2odid.png, replace

sdid B1 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(1(1)4) ytitle("Literacy Inequality") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(did) returnweights g1on seed(4) reps(500)
graph export B1odid.png, replace

sdid B2 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(1(1)4) ytitle("Literacy Inequality") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(did) returnweights g1on  seed(4) reps(500)
graph export B2odid.png, replace

sdid D1 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(50(5)75) ytitle("Learning Quality") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(did) returnweights g1on  seed(4) reps(500)
graph export D1odid.png, replace

sdid D2 KabupatenKota_num year treat_treatedyear, vce(bootstrap) graph g1_opt() g2_opt(ylabel(50(5)75) ytitle("Teacher Learning & Reflection") xlabel(2022 "2021" 2023 "2022" 2024 "2023") xline(2023, lcolor(red) lwidth(medium) lpattern(dash)) xline(2024, lcolor(white) lwidth(thick)) legend(order(1 2) label(1 "Low download") label(2 "High download")) graphregion(color(white)) plotregion(margin(0 0 0 0))) method(did) returnweights g1on seed(4) reps(500)
graph export D2odid.png, replace


* SC Graph
* Step 1: Input the data
clear
input str30 variable estimate se
"Literacy Score" 0.167 0.067
"Numeracy Score" 0.138 0.159
"Literacy Inequality" 0.272 0.303
"Numeracy Inequality" 0.713 0.746
"Learning Quality" 0.498 0.289
"Teacher Learning & Reflection" 0.249 0.108
end

* Step 2: Calculate the confidence intervals (using 10% CI, z-value = 1.645)
gen ci_lower = estimate - 1.645 * se
gen ci_upper = estimate + 1.645 * se

* Step 3: Create a numeric variable for the variable names
gen variable_id = _n

* Step 4: Reverse the order of the labels (inverting the y-axis)
gen variable_id_reversed = _N - variable_id + 1

* Step 5: Add labels to the y-axis
label define variable_id_label 1 "Teacher Learning" 2 "Learning Quality" 3 "Numeracy Inequality" 4 "Literacy Inequality" 5 "Numeracy Score" 6 "Literacy Score"
label values variable_id_reversed variable_id_label

* Step 6: Create the plot with error bars
twoway (rcap ci_lower ci_upper variable_id_reversed, horizontal) ///
(scatter variable_id_reversed estimate , msize(medium) mcolor(black)) ///
       , ytitle(" ") xtitle("Impact of Program (Standard Deviation)") ///
         xline(0, lcolor(gray) lpattern(dash)) ///
         title("SC+DID Estimates of Program Impact") ///
		 subtitle("10% Confidence Interval") ///
         ylabel(, valuelabel angle(0) labsize(small)) /// Rotate y-axis labels by 45 degrees
         legend(off) graphregion(color(white))



* SDID Graph
* Step 1: Input the data
clear
input str30 variable estimate se
"Literacy Score" 0.213 0.029
"Numeracy Score" 0.156 0.032
"Literacy Inequality" -0.148 0.092
"Numeracy Inequality" 0.106 0.080
"Learning Quality" 0.098 0.047
"Teacher Learning & Reflection" 0.078 0.026
end

* Step 2: Calculate the confidence intervals (using 10% CI, z-value = 1.645)
gen ci_lower = estimate - 1.645 * se
gen ci_upper = estimate + 1.645 * se

* Step 3: Create a numeric variable for the variable names
gen variable_id = _n

* Step 4: Reverse the order of the labels (inverting the y-axis)
gen variable_id_reversed = _N - variable_id + 1

* Step 5: Add labels to the y-axis
label define variable_id_label 1 "Teacher Learning" 2 "Learning Quality" 3 "Numeracy Inequality" 4 "Literacy Inequality" 5 "Numeracy Score" 6 "Literacy Score"
label values variable_id_reversed variable_id_label

* Step 6: Create the plot with error bars
twoway (rcap ci_lower ci_upper variable_id_reversed, horizontal) ///
(scatter variable_id_reversed estimate , msize(medium) mcolor(black)) ///
       , ytitle(" ") xtitle("Impact of Program (Standard Deviation)") ///
         xline(0, lcolor(gray) lpattern(dash)) ///
         title("SDID Estimates of Program Impact") ///
		 subtitle("10% Confidence Interval") ///
         ylabel(, valuelabel angle(0) labsize(small)) /// Rotate y-axis labels by 45 degrees
         legend(off) graphregion(color(white))

		 
*/
