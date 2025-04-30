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







