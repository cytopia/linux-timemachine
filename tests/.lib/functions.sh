#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


# shellcheck disable=SC1090
. "${SCRIPT_PATH}/.lib/create-source.sh"
# shellcheck disable=SC1090
. "${SCRIPT_PATH}/.lib/run-backup.sh"
# shellcheck disable=SC1090
. "${SCRIPT_PATH}/.lib/dir-size.sh"
# shellcheck disable=SC1090
. "${SCRIPT_PATH}/.lib/file-exist.sh"
# shellcheck disable=SC1090
. "${SCRIPT_PATH}/.lib/file-permissions.sh"
# shellcheck disable=SC1090
. "${SCRIPT_PATH}/.lib/file-size.sh"
# shellcheck disable=SC1090
. "${SCRIPT_PATH}/.lib/file-owner.sh"
# shellcheck disable=SC1090
. "${SCRIPT_PATH}/.lib/file-time.sh"
# shellcheck disable=SC1090
. "${SCRIPT_PATH}/.lib/print.sh"


# -------------------------------------------------------------------------------------------------
# WRAPPER FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Run command
###
run() {
	local cmd="${1}"
	local verbose=1
	local std_out="stdout"
	local std_err="stderr"

	# be verbose?
	if [ "${#}" -gt "1" ]; then
		verbose="${2}"
	fi
	if [ "${#}" -gt "2" ]; then
		std_out="${3}"
	fi
	if [ "${#}" -gt "3" ]; then
		std_err="${4}"
	fi

	local red="\\033[0;31m"
	local green="\\033[0;32m"
	local yellow="\\033[0;33m"
	local reset="\\033[0m"

	# Print command?
	if [ "${verbose}" -eq "1" ]; then
		# stdout
		if [ "${std_out}" = "stdout" ]; then
			printf "${yellow}%s \$${reset} %s\\n" "$(whoami)" "${cmd}"
		# stderr
		else
			>&2 printf "${yellow}%s \$${reset} %s\\n" "$(whoami)" "${cmd}"
		fi
	fi

	# Set command
	cmd="set -e && set -u && set -o pipefail && ${cmd}"

	if eval "${cmd}"; then
		if [ "${verbose}" -eq "1" ]; then
			# stdout
			if [ "${std_out}" = "stdout" ]; then
				printf "${green}[%s]${reset}\\n" "OK"
			# stderr
			else
				>&2 printf "${green}[%s]${reset}\\n" "OK"
			fi
		fi
		return 0
	fi
	if [ "${verbose}" -eq "1" ]; then
		# stderr
		if [ "${std_err}" = "stderr" ]; then
			>&2 printf "${red}[%s]${reset}\\n" "FAIL"
		# stdout
		else
			printf "${red}[%s]${reset}\\n" "FAIL"
		fi
	fi
	return 1
}


###
### Create tmp file
###
create_tmp_file() {
	local tmp_file=

	if ! command -v mktemp >/dev/null 2>&1; then
		i=0
		local prefix="/tmp/timemachine"
		while [ -f "${prefix}-${i}.txt" ]; do
			i="$(( i + 1 ))"
		done
		tmp_file="${prefix}-${i}.txt"
		mkdir "${tmp_file}"
	else
		tmp_file="$( mktemp )"
	fi

	printf "%s" "${tmp_file}" | sed 's|/*$||'
}


###
### Create tmp dir
###
create_tmp_dir() {
	local absolute="${1:-1}"
	local pwd="${2:-}"
	local suffix="${3:-}"
	local tmp_dir=

	###
	### Create relative path tmp dir
	###
	if [ "${absolute}" = "0" ]; then
		i=0
		while  [ -d "${pwd}/.tmp/${i}${suffix}" ] || [ -f "${pwd}/.tmp/${i}${suffix}" ]; do
			i="$(( i + 1 ))"
		done
		tmp_dir=".tmp/${i}${suffix}"
		run "cd '${pwd}' && mkdir -p '${tmp_dir}'" "1" "stderr" "stderr"
		echo "${tmp_dir}"
		return
	fi

	###
	### Create absolute path tmp dir
	###
	if ! command -v mktemp >/dev/null 2>&1; then
		i=0
		local prefix="/tmp/timemachine"
		while [ -d "${prefix}-${i}${suffix}" ] || [ -f "${prefix}-${i}${suffix}" ]; do
			i="$(( i + 1 ))"
		done
		tmp_dir="${prefix}-${i}${suffix}"
		mkdir -p "${tmp_dir}" >/dev/null
	else
		if [ -z "${suffix}" ]; then
			tmp_dir="$( mktemp -d )"
		else
			tmp_dir="$( mktemp -d --suffix="${suffix}" )"
		fi
	fi

	printf "%s" "${tmp_dir}" | sed 's|/*$||'
}
