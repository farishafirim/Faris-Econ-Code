* Set the working directory for the 2023 & 2024 Kota
cd "C:\Users\faris\OneDrive\Documents\ECON\Conference & Competition\CIES\Data Rapor\2023_2024\Kota"

* List all files in the directory
local files : dir . files "*.xlsx"

foreach f of local files{
    * Extract the year
	local year = substr("`f'", length("`f'")-8,4)
	
    * Extract the city name
    local city = substr("`f'", 12,length("`f'")-21)
	
	* Replace hyphens with spaces to convert "tanjung-balai" into "Tanjung Balai"
    local city = subinstr("`city'", "-", "", .)
	

local cities "bandung banjar bogor bima blitar cirebon gorontalo jayapura kediri kupang magelang malang madiun mojokerto pasuruan pekalongan probolinggo semarang serang solok sorong sukabumi tangerang tasikmalaya tegal"

if regexm("`cities'", "`city'") {
    local city = "k`city'"
}

	local newname = "`city'`year'"
	display ("`newname'")
	shell rename "`f'" "`newname'.xlsx"
}
*****************************************************************************

* Set the working directory for the 2023 & 2024 Kab
cd "C:\Users\faris\OneDrive\Documents\ECON\Conference & Competition\CIES\Data Rapor\2023_2024\Kab"

* List all files in the directory
local files : dir . files "*.xlsx"

foreach f of local files{
    * Extract the year
	local year = substr("`f'", length("`f'")-8,4)
	
    * Extract the city name
    local city = substr("`f'", 10,length("`f'")-19)
	
	* Replace hyphens with spaces to convert "tanjung-balai" into "Tanjung Balai"
    local city = subinstr("`city'", "-", "", .)
	
	local newname = "`city'`year'"
	display ("`newname'")
	shell rename "`f'" "`newname'.xlsx"
}

*****************************************************************************

* Set the working directory for the 2022
*Have to change the name of the "Kota" version of  
/*
Bandung
Bima
Cirebon
Gorontalo
Jayapura
Kediri
Probolinggo
Serang
Sorong
Sukabumi
Tangerang
Tasikmalaya
Tegal
*/

cd "C:\Users\faris\OneDrive\Documents\ECON\Conference & Competition\CIES\Data Rapor\2022"

* List all files in the directory
local files : dir . files "*.xlsx"

foreach f of local files{
    	
    * Extract the city name
    local city = substr("`f'", 26,length("`f'")-35)
	
	* Replace hyphens with spaces to convert "tanjung-balai" into "Tanjung Balai"
    local city = subinstr("`city'", "-", "", .)
	
	local newname = "`city'2022"
	display ("`newname'")
	shell rename "`f'" "`newname'.xlsx"
}