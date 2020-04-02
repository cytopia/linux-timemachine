#!/usr/bin/env bash

set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# PUBLIC FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Print main section
###
print_section() {
	local text="${1}"
	printf "\\r\\n"
	printf '@%.0s' {1..110};
	printf "\\r\\n"
	printf '@%.0s' {1..110};
	printf "\\r\\n"

	printf "@@@@@@\\r\\n"
	printf "@@@@@@ %s\\r\\n" "${text}"
	printf "@@@@@@\\r\\n"

	printf '@%.0s' {1..110};
	printf "\\r\\n"
	printf '@%.0s' {1..110};
	printf "\\r\\n"
	printf "\\r\\n"
}


###
### Print headline
###
print_headline() {
	local text="${1}"

	printf "\\r\\n"
	printf '### '
	printf '#%.0s' {1..96};
	printf "\\r\\n"

	printf "###\\r\\n"
	printf "### %s\\r\\n" "${text}"
	printf "###\\r\\n"

	printf '### '
	printf '#%.0s' {1..96};
	printf "\\r\\n"
	printf "\\r\\n"
}


###
### Print sub headline
###
print_subline() {
	local text="${1}"

	printf -- '-%.0s' {1..80};
	printf "\\r\\n"
	printf " %s\\r\\n" "${text}"
	printf -- '-%.0s' {1..80};
	printf "\\r\\n"
}
