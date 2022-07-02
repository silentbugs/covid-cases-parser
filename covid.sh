#!/bin/bash

# pass date as argument, in dd-mm-YYY format, e.g. 15-07-2020
function getCovidCases() {
	# 1. Ημερομ - Ημερομηνία
	# 2. ΚρΗμ - Κρούσματα Ημέρας
	# 3. ΚρΣυν - Σύνολο Κρουσμάτων
	# 4. ΤεPCR - PCR τεστ ημέρας
	# 5. ΤεΣPR - PCR και RAPID τεστ σύνολο
	# 6. ΔεΘετ - Δείκτης θετικότητας (%) επί των κλινικών τεστ\
	# 7. ΔΜ - Διασωληνωμένοι ΜΕΘ
	# 8. ΘαΗ - Θάνατοι ημέρας
	# 9. ΘαΣ - Θάνατοι σύνολο
	curl -s http://www.odigostoupoliti.eu/koronoios-krousmata-simera-stin-ellada-$1/ \
		| xmllint --html --xpath '//div[contains(@class, "entry-content")]/table//tr[2]' 2>/dev/null - \
		| grep -v 'text-align' \
		| sed 's/<strong>//g' \
		| sed 's/<\/strong>//g' \
		| sed 's/<tr>//g' \
		| sed 's/<\/tr>//g' \
		| sed 's/<td>//g' \
		| sed 's/<\/td>//g' \
		| tr '\r\n' ' ' \
		| awk 'BEGIN{FS=" "} {print $1,$2,$3,$4,$5,$6,$7,$8,$9}'
}

function printResults() {
	# replace nbsp with regular whitespace
	cases=$(echo $1 | sed 's/\xc2\xa0/ /g')
	# replace multiple whitespaces with single whitespace
	cases=$(echo $cases | sed 's/ +/ /g')

	# prepare the output for xbar
	cases=$(echo $cases | awk 'BEGIN{FS=" "} {
		print "---"
		print "Daily | font=Hack"
		print "---"
		print "Date:    "$1" | font=Hack"
		print "Cases:   "$2" | font=Hack"
		print "Tests:   "$5" | font=Hack"
		print "» PCR:   "$4" | font=Hack"
		print "» Rapid: "$5-$4" | font=Hack"
		print "Rate:    "$6" | font=Hack"
		print "ICU:     "$7" | font=Hack"
		print "Deaths:  "$8" | font=Hack"
		print "---"
		print "Totals | font=Hack"
		print "---"
		print "Cases:   "$3" | font=Hack"
		print "Deaths:  "$9" | font=Hack"
	}')
	echo "covid | color=$2"
	echo "---"
	echo "$cases"
}

today=$(date +%d-%m-%Y)
today_cases=$(getCovidCases $today)


# check if input contains any numbers
# response contains weird ascii characters so we cannot test -z for an empty response

# Substitute the date as an empty string because the website creates the "date" entry without any
# data before having the actual data.
# So we test for numbers apart from the date part
today_cases_without_date=$(echo $today_cases | sed "s/$today//g")

if [[ $today_cases_without_date =~ [0-9] ]]
then
	color="#44ff44"
	printResults "$today_cases" "$color"
else
	# only fetch yesterday's cases if today's are not available
	yesterday=$(date -v-1d +%d-%m-%Y)
	yesterday_cases=$(getCovidCases $yesterday)

	color="#ff4444"
	printResults "$yesterday_cases" "$color"
fi
