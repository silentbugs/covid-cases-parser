#!/bin/bash
TERM=/usr/bin/screen

# pass date as argument, in YYYYmmdd format, e.g. 20200715
function getCovidCases() {
	curl -s https://eody.gov.gr/$1_briefing_covid19/?print=print | grep 'Σήμερα ανακοινώνουμε' | tr " " "\n" | grep strong | tr -d "</strong>,"
}

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"

today=$(date +%Y%m%d)
yesterday=$(date -v-1d +%Y%m%d)

today_cases=$(getCovidCases $today | tr "\n" " ")
yesterday_cases=$(getCovidCases $yesterday | tr "\n" " ")

if [[ ! -z "$today_cases" ]]
then
	echo "${GREEN}$today_cases | size=12 color=#00ff00"
else
	echo "${RED}$yesterday_cases | size=12 color=#ff3333"
fi
