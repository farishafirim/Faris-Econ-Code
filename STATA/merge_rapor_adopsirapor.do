clear
cd "C:\Users\faris\OneDrive\Documents\ECON\Conference & Competition\CIES\"

import excel "Adopsi Rapor (per bulan) - edit.xlsx", sheet(Analisis) firstrow clear

ren nama_kab_kota KabupatenKota
keep KabupatenKota nama_provinsi total* Percentage
order KabupatenKota
replace KabupatenKota=lower(KabupatenKota)
drop if KabupatenKota==""
replace KabupatenKota="kab. jaya wijaya" if KabupatenKota=="kab. jayawijaya"
replace KabupatenKota="kab. memberamo raya" if KabupatenKota=="kab. mamberamo raya"
replace KabupatenKota="kab. membramo tengah" if KabupatenKota=="kab. mamberamo tengah"
replace KabupatenKota="kab. nagakeo" if KabupatenKota=="kab. nagekeo"
save adopsirapor.dta,replace

import excel "Compiled514_complete.xlsx", sheet(Analisis) firstrow clear
replace KabupatenKota=lower(KabupatenKota)
merge 1:1 KabupatenKota using adopsirapor.dta

save merged_rapor_adopsirapor.dta, replace

ds  // Get a list of all variables
foreach var in `r(varlist)' {
    quietly count if missing(`var')  // Count missing values
    local num_missing = r(N)
    
    quietly count  // Get total observations
    local total_obs = r(N)

    if `num_missing' >= `total_obs' / 2 {
        drop `var'
    }
}

drop B14_2023 B15_2023 B16_2023 C1_2022 C2_2022 C3_2022 C5_2022 C6_2022 C7_2022 C8_2022 D7_2022 D14_2022 D15_2022

save merged_rapor_adopsirapor_clean.dta, replace

clear
import excel "APBD.xlsx",clear cellrange(A5) firstrow
replace Daerah = lower(Daerah)
replace Daerah = subinstr(Daerah, "pemerintah", "", .)