#!/bin/bash
TERM=/usr/bin/screen

# pass date as argument, in dd-mm-YYY format, e.g. 15-07-2020
function getCovidCases() {
	# 1. Ημερομ - Ημερομηνία
	# 2. ΚρΗμ - Κρούσματα Ημέρας
	# 3. ΚρΣυν - Σύνολο Κρουσμάτων
	# 4. ΤεΗ - Κλινικά Τεστ Ημέρας
	# 5. ΤεΣ - Κλινικά Τεστ Σύνολο
	# 6. ΔεΘετ - Δείκτης θετικότητας (%) επί των κλινικών τεστ\
	# 7. ΔΜ - Διασωληνωμένοι ΜΕΘ
	# 8. ΘαΗ - Θάνατοι ημέρας
	# 9. ΘαΣ - Θάνατοι σύνολο
	curl -s http://www.odigostoupoliti.eu/koronoios-krousmata-simera-$1-stin-ellada/ \
		| xmllint --html --xpath '//div[contains(@class, "entry-content")]/table//tr[2]' 2>/dev/null - \
		| sed 's/<strong>//g' \
		| sed 's/<\/strong>//g' \
		| sed 's/<tr>//g' \
		| sed 's/<\/tr>//g' \
		| sed 's/<td>//g' \
		| sed 's/<\/td>//g' \
		| tr '\r\n' ' ' \
		| awk 'BEGIN{FS=" "} {print $2,$4,$6,$7,$8}'
}

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"

today=$(date +%d-%m-%Y)
yesterday=$(date -v-1d +%d-%m-%Y)

today_cases=$(getCovidCases $today)
yesterday_cases=$(getCovidCases $yesterday)

if [[ ! -z "$today_cases" ]]
then
	echo "${GREEN}$today_cases | size=12 color=#00ff00"
else
	echo "${RED}$yesterday_cases | size=12 color=#ff3333"
fi
