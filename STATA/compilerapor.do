clear
cd "C:\Users\faris\OneDrive\Documents\ECON\Conference & Competition\CIES\Data Rapor\All"

* List all files in the directory
local files : dir . files "*.xlsx"

local cities

* Loop over each file
foreach f of local files {
    * Extract the city name (everything before the first number in the filename)
    local city = substr("`f'", 1,length("`f'")-9)
	
	local year = substr("`f'", length("`f'")-8,4)
	
	if "`year'"=="2024"{
	    local cities "`cities' `city'"
	}
	
    * Display the city name for each file (for debugging)
    display "`city'"
    
    * You can now use the `city` local macro as needed
}
display "`cities'"

local i 1
local j 2

putexcel set "C:\Users\faris\OneDrive\Documents\ECON\Conference & Competition\CIES\Compiled514_complete.xlsx", sheet("Analisis") replace
putexcel A1="Kabupaten/Kota"
putexcel B1="A1_2022"
putexcel C1="A1_2023"
putexcel D1="A1_2024"
putexcel E1="A2_2022"
putexcel F1="A2_2023"
putexcel G1="A2_2024"
putexcel H1="A3_2022"
putexcel I1="A3_2023"
putexcel J1="A3_2024"
putexcel K1="B1_2022"
putexcel L1="B1_2023"
putexcel M1="B1_2024"
putexcel N1="B2_2022"
putexcel O1="B2_2023"
putexcel P1="B2_2024"
putexcel Q1="B3_2022"
putexcel R1="B3_2023"
putexcel S1="B3_2024"
putexcel T1="B4_2022"
putexcel U1="B4_2023"
putexcel V1="B4_2024"
putexcel W1="B5_2022"
putexcel X1="B5_2023"
putexcel Y1="B5_2024"
putexcel Z1="B6_2022"
putexcel AA1="B6_2023"
putexcel AB1="B6_2024"
putexcel AC1="B13_2022"
putexcel AD1="B13_2023"
putexcel AE1="B13_2024"
putexcel AF1="B14_2022"
putexcel AG1="B14_2023"
putexcel AH1="B14_2024"
putexcel AI1="B15_2022"
putexcel AJ1="B15_2023"
putexcel AK1="B15_2024"
putexcel AL1="B16_2022"
putexcel AM1="B16_2023"
putexcel AN1="B16_2024"
putexcel AO1="C1_2022"
putexcel AP1="C1_2023"
putexcel AQ1="C1_2024"
putexcel AR1="C2_2022"
putexcel AS1="C2_2023"
putexcel AT1="C2_2024"
putexcel AU1="C3_2022"
putexcel AV1="C3_2023"
putexcel AW1="C3_2024"
putexcel AX1="C4_2022"
putexcel AY1="C4_2023"
putexcel AZ1="C4_2024"
putexcel BA1="C5_2022"
putexcel BB1="C5_2023"
putexcel BC1="C5_2024"
putexcel BD1="C6_2022"
putexcel BE1="C6_2023"
putexcel BF1="C6_2024"
putexcel BG1="C7_2022"
putexcel BH1="C7_2023"
putexcel BI1="C7_2024"
putexcel BJ1="C8_2022"
putexcel BK1="C8_2023"
putexcel BL1="C8_2024"
putexcel BM1="D1_2022"
putexcel BN1="D1_2023"
putexcel BO1="D1_2024"
putexcel BP1="D2_2022"
putexcel BQ1="D2_2023"
putexcel BR1="D2_2024"
putexcel BS1="D3_2022"
putexcel BT1="D3_2023"
putexcel BU1="D3_2024"
putexcel BV1="D4_2022"
putexcel BW1="D4_2023"
putexcel BX1="D4_2024"
putexcel BY1="D5_2022"
putexcel BZ1="D5_2023"
putexcel CA1="D5_2024"
putexcel CB1="D6_2022"
putexcel CC1="D6_2023"
putexcel CD1="D6_2024"
putexcel CE1="D7_2022"
putexcel CF1="D7_2023"
putexcel CG1="D7_2024"
putexcel CH1="D8_2022"
putexcel CI1="D8_2023"
putexcel CJ1="D8_2024"
putexcel CK1="D9_2022"
putexcel CL1="D9_2023"
putexcel CM1="D9_2024"
putexcel CN1="D10_2022"
putexcel CO1="D10_2023"
putexcel CP1="D10_2024"
putexcel CQ1="D11_2022"
putexcel CR1="D11_2023"
putexcel CS1="D11_2024"
putexcel CT1="D12_2022"
putexcel CU1="D12_2023"
putexcel CV1="D12_2024"
putexcel CW1="D13_2022"
putexcel CX1="D13_2023"
putexcel CY1="D13_2024"
putexcel CZ1="D14_2022"
putexcel DA1="D14_2023"
putexcel DB1="D14_2024"
putexcel DC1="D15_2022"
putexcel DD1="D15_2023"
putexcel DE1="D15_2024"
putexcel DF1="D16_2022"
putexcel DG1="D16_2023"
putexcel DH1="D16_2024"
putexcel DI1="D17_2022"
putexcel DJ1="D17_2023"
putexcel DK1="D17_2024"
putexcel DL1="D18_2022"
putexcel DM1="D18_2023"
putexcel DN1="D18_2024"
putexcel DO1="D19_2022"
putexcel DP1="D19_2023"
putexcel DQ1="D19_2024"
putexcel DR1="D20_2022"
putexcel DS1="D20_2023"
putexcel DT1="D20_2024"
putexcel DU1="D21_2022"
putexcel DV1="D21_2023"
putexcel DW1="D21_2024"
putexcel DX1="E1_2022"
putexcel DY1="E1_2023"
putexcel DZ1="E1_2024"
putexcel EA1="E2_2022"
putexcel EB1="E2_2023"
putexcel EC1="E2_2024"
putexcel ED1="E3_2022"
putexcel EE1="E3_2023"
putexcel EF1="E3_2024"
putexcel EG1="E4_2022"
putexcel EH1="E4_2023"
putexcel EI1="E4_2024"
putexcel EJ1="E5_2022"
putexcel EK1="E5_2023"
putexcel EL1="E5_2024"
putexcel EM1="E6_2022"
putexcel EN1="E6_2023"
putexcel EO1="E6_2024"
putexcel EP1="E7_2022"
putexcel EQ1="E7_2023"
putexcel ER1="E7_2024"


foreach x of local cities {
import excel "`x'2022.xlsx", sheet("Satpen - SD & SMP - Dimensi A") firstrow clear
local kabkot KabupatenKota[2]
disp `kabkot'
putexcel A`j'=`kabkot'

import excel "`x'2022.xlsx", sheet("Kabupaten Kota - SD Sederajat") firstrow clear

local `i'A12022 NilaiKabupatenkotaAnda[2]
disp ``i'A12022'
putexcel B`j'=``i'A12022'

local `i'A22022 NilaiKabupatenkotaAnda[12]
disp ``i'A22022'
putexcel E`j'=``i'A22022'

local `i'A32022 NilaiKabupatenkotaAnda[24]
disp ``i'A32022'
putexcel H`j'=``i'A32022'

local `i'B12022 NilaiKabupatenkotaAnda[31]
disp ``i'B12022'
putexcel K`j'=``i'B12022'

local `i'B22022 NilaiKabupatenkotaAnda[35]
disp ``i'B22022'
putexcel N`j'=``i'B22022'

local `i'B32022 NilaiKabupatenkotaAnda[39]
disp ``i'B32022'
putexcel Q`j'=``i'B32022'

local `i'B42022 NilaiKabupatenkotaAnda[43]
disp ``i'B42022'
putexcel T`j'=``i'B42022'

local `i'B52022 NilaiKabupatenkotaAnda[47]
disp ``i'B52022'
putexcel W`j'=``i'B52022'

local `i'B62022 NilaiKabupatenkotaAnda[51]
disp ``i'B62022'
putexcel Z`j'=``i'B62022'



local `i'C12022 NilaiKabupatenkotaAnda[55]
disp ``i'C12022'
putexcel AO`j'=``i'C12022'

local `i'C22022 NilaiKabupatenkotaAnda[56]
disp ``i'C22022'
putexcel AR`j'=``i'C22022'

local `i'C32022 NilaiKabupatenkotaAnda[60]
disp ``i'C32022'
putexcel AU`j'=``i'C32022'

local `i'C52022 NilaiKabupatenkotaAnda[64]
disp ``i'C52022'
putexcel BA`j'=``i'C52022'

local `i'C62022 NilaiKabupatenkotaAnda[67]
disp ``i'C62022'
putexcel BD`j'=``i'C62022'

local `i'C72022 NilaiKabupatenkotaAnda[70]
disp ``i'C72022'
putexcel BG`j'=``i'C72022'

local `i'C82022 NilaiKabupatenkotaAnda[71]
disp ``i'C82022'
putexcel BJ`j'=``i'C82022'




local `i'D12022 NilaiKabupatenkotaAnda[72]
disp ``i'D12022'
putexcel BM`j'=``i'D12022'

local `i'D22022 NilaiKabupatenkotaAnda[76]
disp ``i'D22022'
putexcel BP`j'=``i'D22022'

local `i'D32022 NilaiKabupatenkotaAnda[80]
disp ``i'D32022'
putexcel BS`j'=``i'D32022'

local `i'D42022 NilaiKabupatenkotaAnda[84]
disp ``i'D42022'
putexcel BV`j'=``i'D42022'

local `i'D52022 NilaiKabupatenkotaAnda[91]
disp ``i'D52022'
putexcel BY`j'=``i'D52022'

local `i'D62022 NilaiKabupatenkotaAnda[95]
disp ``i'D62022'
putexcel CB`j'=``i'D62022'

local `i'D72022 NilaiKabupatenkotaAnda[97]
disp ``i'D72022'
putexcel CE`j'=``i'D72022'

local `i'D82022 NilaiKabupatenkotaAnda[100]
disp ``i'D82022'
putexcel CH`j'=``i'D82022'

local `i'D92022 NilaiKabupatenkotaAnda[105]
disp ``i'D92022'
putexcel CK`j'=``i'D92022'

local `i'D102022 NilaiKabupatenkotaAnda[109]
disp ``i'D102022'
putexcel CN`j'=``i'D102022'

local `i'D112022 NilaiKabupatenkotaAnda[114]
disp ``i'D112022'
putexcel CQ`j'=``i'D112022'

local `i'D122022 NilaiKabupatenkotaAnda[118]
disp ``i'D122022'
putexcel CT`j'=``i'D122022'

local `i'D132022 NilaiKabupatenkotaAnda[119]
disp ``i'D132022'
putexcel CW`j'=``i'D132022'

local `i'D142022 NilaiKabupatenkotaAnda[120]
disp ``i'D142022'
putexcel CZ`j'=``i'D142022'

local `i'D152022 NilaiKabupatenkotaAnda[123]
disp ``i'D152022'
putexcel DC`j'=``i'D152022'



local `i'E12022 NilaiKabupatenkotaAnda[126]
disp ``i'E12022'
putexcel DX`j'=``i'E12022'

local `i'E22022 NilaiKabupatenkotaAnda[129]
disp ``i'E22022'
putexcel EA`j'=``i'E22022'

local `i'E32022 NilaiKabupatenkotaAnda[132]
disp ``i'E32022'
putexcel ED`j'=``i'E32022'

local `i'E42022 NilaiKabupatenkotaAnda[135]
disp ``i'E42022'
putexcel EG`j'=``i'E42022'


*****************************************************************************

import excel "`x'2023.xlsx", sheet("2. CAPAIAN KABKOT") clear cellrange(A4:F7332) firstrow
local `i'A12023 SkorRapor2023[4692]
disp ``i'A12023'
putexcel C`j'=``i'A12023'

local `i'A22023 SkorRapor2023[4704]
disp ``i'A22023'
putexcel F`j'=``i'A22023'

local `i'A32023 SkorRapor2023[4718]
disp ``i'A32023'
putexcel I`j'=``i'A32023'

local `i'B12023 SkorRapor2023[4726]
disp ``i'B12023'
putexcel L`j'=``i'B12023'

local `i'B22023 SkorRapor2023[4731]
disp ``i'B22023'
putexcel O`j'=``i'B22023'

local `i'B32023 SkorRapor2023[4736]
disp ``i'B32023'
putexcel R`j'=``i'B32023'

local `i'B42023 SkorRapor2023[4741]
disp ``i'B42023'
putexcel U`j'=``i'B42023'

local `i'B52023 SkorRapor2023[4745]
disp ``i'B52023'
putexcel X`j'=``i'B52023'

local `i'B62023 SkorRapor2023[4751]
disp ``i'B62023'
putexcel AA`j'=``i'B62023'

local `i'B132023 SkorRapor2023[4756]
disp ``i'B132023'
putexcel AD`j'=``i'B132023'

local `i'B142023 SkorRapor2023[4758]
disp ``i'B142023'
putexcel AG`j'=``i'B142023'

local `i'B152023 SkorRapor2023[4760]
disp ``i'B152023'
putexcel AJ`j'=``i'B152023'

local `i'B162023 SkorRapor2023[4762]
disp ``i'B162023'
putexcel AM`j'=``i'B162023'

local `i'C12023 SkorRapor2023[4764]
disp ``i'C12023'
putexcel AP`j'=``i'C12023'

local `i'C22023 SkorRapor2023[4766]
disp ``i'C22023'
putexcel AS`j'=``i'C22023'

local `i'C32023 SkorRapor2023[4771]
disp ``i'C32023'
putexcel AV`j'=``i'C32023'

local `i'C72023 SkorRapor2023[4775]
disp ``i'C72023'
putexcel BH`j'=``i'C72023'

local `i'C82023 SkorRapor2023[4777]
disp ``i'C82023'
putexcel BK`j'=``i'C82023'


local `i'D12023 SkorRapor2023[4779]
disp ``i'D12023'
putexcel BN`j'=``i'D12023'

local `i'D22023 SkorRapor2023[4784]
disp ``i'D22023'
putexcel BQ`j'=``i'D22023'

local `i'D32023 SkorRapor2023[4789]
disp ``i'D32023'
putexcel BT`j'=``i'D32023'

local `i'D42023 SkorRapor2023[4794]
disp ``i'D42023'
putexcel BW`j'=``i'D42023'

local `i'D52023 SkorRapor2023[4806]
disp ``i'D52023'
putexcel BZ`j'=``i'D52023'

local `i'D62023 SkorRapor2023[4810]
disp ``i'D62023'
putexcel CC`j'=``i'D62023'

local `i'D72023 SkorRapor2023[4814]
disp ``i'D72023'
putexcel CF`j'=``i'D72023'

local `i'D82023 SkorRapor2023[4818]
disp ``i'D82023'
putexcel CI`j'=``i'D82023'

local `i'D92023 SkorRapor2023[4823]
disp ``i'D92023'
putexcel CL`j'=``i'D92023'

local `i'D102023 SkorRapor2023[4827]
disp ``i'D102023'
putexcel CO`j'=``i'D102023'

local `i'D112023 SkorRapor2023[4832]
disp ``i'D112023'
putexcel CR`j'=``i'D112023'

local `i'D142023 SkorRapor2023[4836]
disp ``i'D142023'
putexcel DA`j'=``i'D142023'

local `i'D212023 SkorRapor2023[4840]
disp ``i'D212023'
putexcel DV`j'=``i'D212023'

local `i'E12023 SkorRapor2023[4846]
disp ``i'E12023'
putexcel DY`j'=``i'E12023'

local `i'E22023 SkorRapor2023[4850]
disp ``i'E22023'
putexcel EB`j'=``i'E22023'

local `i'E32023 SkorRapor2023[4854]
disp ``i'E32023'
putexcel EE`j'=``i'E32023'

local `i'E42023 SkorRapor2023[4858]
disp ``i'E42023'
putexcel EH`j'=``i'E42023'

local `i'E52023 SkorRapor2023[4860]
disp ``i'E52023'
putexcel EK`j'=``i'E52023'

local `i'E72023 SkorRapor2023[4872]
disp ``i'E72023'
putexcel EQ`j'=``i'E72023'


*****************************************************************************

import excel "`x'2024.xlsx", sheet("2. CAPAIAN KABKOT") clear cellrange(A4:F7332) firstrow
local `i'A12024 NilaiCapaian2024[4195]
disp ``i'A12024'
putexcel D`j'=``i'A12024'

local `i'A22024 NilaiCapaian2024[4207]
disp ``i'A22024'
putexcel G`j'=``i'A22024'

local `i'A32024 NilaiCapaian2024[4221]
disp ``i'A32024'
putexcel J`j'=``i'A32024'

local `i'B12024 NilaiCapaian2024[4229]
disp ``i'B12024'
putexcel M`j'=``i'B12024'

local `i'B22024 NilaiCapaian2024[4234]
disp ``i'B22024'
putexcel P`j'=``i'B22024'

local `i'B32024 NilaiCapaian2024[4239]
disp ``i'B32024'
putexcel S`j'=``i'B32024'

local `i'C12024 NilaiCapaian2024[4244]
disp ``i'C12024'
putexcel AQ`j'=``i'C12024'

local `i'C72024 NilaiCapaian2024[4246]
disp ``i'C72024'
putexcel BI`j'=``i'C72024'

local `i'C82024 NilaiCapaian2024[4248]
disp ``i'C82024'
putexcel BL`j'=``i'C82024'

local `i'D12024 NilaiCapaian2024[4250]
disp ``i'D12024'
putexcel BO`j'=``i'D12024'

local `i'D22024 NilaiCapaian2024[4255]
disp ``i'D22024'
putexcel BR`j'=``i'D22024'

local `i'D32024 NilaiCapaian2024[4260]
disp ``i'D32024'
putexcel BU`j'=``i'D32024'

local `i'D42024 NilaiCapaian2024[4265]
disp ``i'D42024'
putexcel BX`j'=``i'D42024'

local `i'D52024 NilaiCapaian2024[4277]
disp ``i'D52024'
putexcel CA`j'=``i'D52024'

local `i'D62024 NilaiCapaian2024[4281]
disp ``i'D62024'
putexcel CD`j'=``i'D62024'

local `i'D72024 NilaiCapaian2024[4285]
disp ``i'D72024'
putexcel CG`j'=``i'D72024'

local `i'D82024 NilaiCapaian2024[4289]
disp ``i'D82024'
putexcel CJ`j'=``i'D82024'

local `i'D92024 NilaiCapaian2024[4294]
disp ``i'D92024'
putexcel CM`j'=``i'D92024'

local `i'D102024 NilaiCapaian2024[4298]
disp ``i'D102024'
putexcel CP`j'=``i'D102024'

local `i'D112024 NilaiCapaian2024[4304]
disp ``i'D112024'
putexcel CS`j'=``i'D112024'

local `i'D142024 NilaiCapaian2024[4307]
disp ``i'D142024'
putexcel DB`j'=``i'D142024'

local `i'D212024 NilaiCapaian2024[4311]
disp ``i'D212024'
putexcel DW`j'=``i'D212024'

local `i'E12024 NilaiCapaian2024[4316]
disp ``i'E12024'
putexcel DZ`j'=``i'E12024'

local `i'E22024 NilaiCapaian2024[4320]
disp ``i'E22024'
putexcel EC`j'=``i'E22024'

local `i'E32024 NilaiCapaian2024[4324]
disp ``i'E32024'
putexcel EF`j'=``i'E32024'

local `i'E42024 NilaiCapaian2024[4328]
disp ``i'E42024'
putexcel EI`j'=``i'E42024'

local `i'E52024 NilaiCapaian2024[4330]
disp ``i'E52024'
putexcel EL`j'=``i'E52024'

local `i'E72024 NilaiCapaian2024[4338]
disp ``i'E72024'
putexcel ER`j'=``i'E72024'



local ++i
local ++j
}

***************************************************************************

import excel "Kompilasi", sheet("Analisis") firstrow clear

drop if No==.

foreach var of varlist Literasi2022-RefleksiGuru2024{
	replace `var' = subinstr(`var',",", ".",.)
	destring `var', replace
}

foreach var of varlist Literasi2022 Numerasi2022 RefleksiGuru2022{
	replace `var'=`var'/3*100
}

save kompilasi_clean.dta,replace