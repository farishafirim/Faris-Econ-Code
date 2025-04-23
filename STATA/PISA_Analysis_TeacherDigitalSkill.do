clear matrix
capture clear
capture log close
capture program drop _all
capture macro drop _all
drop _all
set more off

cd "C:\Users\faris\OneDrive\Documents\ECON\Conference & Competition\FELT 2024"
log using "FELT2024.smcl", text replace

*********************************************************************
/*
import sas "C:\Users\faris\OneDrive\Documents\ECON\PISA\SCH_QQQ_SAS\cy08msp_sch_qqq.sas7bdat"

keep if CNT=="IDN"

save "IDNschoolDataPISA2022.dta", replace

use "C:\Users\faris\OneDrive\Documents\ECON\PISA\STU_QQQ_SAS\PISAIDNSTUDENTcleaned.dta", replace

use "C:\Users\faris\OneDrive\Documents\ECON\PISA\STU_QQQ_SAS\IDNcogPISA.dat", replace

collapse (first) STRATUM (mean) PV*MATH PV*READ, by(CNTSCHID)

egen MATH = rowmean(PV*MATH)
egen READ = rowmean(PV*READ)

save "IDNstdDataPISA2022.dta", replace

merge 1:1 CNTSCHID using "IDNschoolDataPISA2022.dta"

gen KABKOTA = 1 if STRATUM=="IDN01"
replace KABKOTA = 2 if STRATUM=="IDN02"
replace KABKOTA = 3 if STRATUM=="IDN03"
replace KABKOTA = 4 if STRATUM=="IDN04"

order CNTSCHID KABKOTA MATH READ SC211Q03JA DIGPREP
save "MergedSTDSCHPISA2022.dta", replace

*/
*******************************************************************
use "MergedSTDSCHPISA2022.dta"

gen PRIVATE = 1 if PRIVATESCH=="private" & PRIVATESCH!="."
replace PRIVATE = 0 if PRIVATESCH=="public" & PRIVATESCH!="."

gen kaya = SC211Q03JA<30
gen miskin = SC211Q03JA>70

pca SC155Q06HA SC155Q08HA SC155Q07HA, means
predict comp1, score

center comp1
gen xxxk = c_comp1*kaya
gen xxxm = c_comp1*miskin

reg MATH comp1, robust
reg MATH comp1 kaya miskin, robust
reg MATH comp1 kaya miskin xxxk xxxm, robust
reg MATH comp1 kaya miskin xxxk xxxm PRIVATE NEGSCLIM, robust
predict yhatzmath, xb
predict residzmath, residuals
hist residzmath, normal freq name(histn,replace) ytitle("Frekuensi") xtitle("Residual Numerasi") graphregion(color(white)) bgcolor(white)
qnorm residzmath, msize(vtiny) name(nqpn, replace) ytitle("Residual Numerasi") xtitle("Invers Normal") graphregion(color(white)) bgcolor(white)
swilk residzmath

reg READ comp1, robust
reg READ comp1 kaya miskin, robust
reg READ comp1 kaya miskin xxxk xxxm, robust
reg READ comp1 kaya miskin xxxk xxxm PRIVATE NEGSCLIM, robust
predict yhatzread, xb
predict residzread, residuals
hist residzread, normal freq name(histl,replace) ytitle("Frekuensi") xtitle("Residual Literasi") graphregion(color(white)) bgcolor(white)
qnorm residzread, msize(vtiny) name(nqpl, replace) ytitle("Residual Literasi") xtitle("Invers Normal") graphregion(color(white)) bgcolor(white)
swilk residzread

graph combine histn nqpn histl nqpl

sum MATH READ SC155Q06HA SC155Q08HA SC155Q07HA SC211Q03JA kaya miskin PRIVATE NEGSCLIM

sum comp1 xxxk xxxm

reg READ comp1 kaya miskin xxxk xxxm PRIVATE NEGSCLIM
hettest