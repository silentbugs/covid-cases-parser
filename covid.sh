#!/bin/bash

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
		| grep -v 'text-align' \
		| sed 's/<strong>//g' \
		| sed 's/<\/strong>//g' \
		| sed 's/<tr>//g' \
		| sed 's/<\/tr>//g' \
		| sed 's/<td>//g' \
		| sed 's/<\/td>//g' \
		| tr '\r\n' ' ' \
		| awk 'BEGIN{FS=" "} {print $2,$4,$6,$7,$8}'
}

today=$(date +%d-%m-%Y)
today_cases=$(getCovidCases $today)

# check if input contains any numbers
# response contains weird ascii characters so we cannot test -z for an empty response
if [[ $today_cases =~ [0-9] ]]
then
	echo "$today_cases | size=12 color=#00ff00"
else
	# only fetch yesterday's cases if today's are not available
	yesterday=$(date -v-1d +%d-%m-%Y)
	yesterday_cases=$(getCovidCases $yesterday)

	echo "$yesterday_cases | size=12 color=#ff3333"
fi
