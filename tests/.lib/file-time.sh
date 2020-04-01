#!/usr/bin/env bash

set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# PUBLIC FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Check source and destination file modification time
###
### @param rel_path  filename
### @param abs_path  source directory
### @param abs_path  destination directory
###
check_src_dst_file_mod_time() {
	local f="${1}"
	local src_dir="${2}"
	local dst_dir="${3}/current"
	local match="1"

	if [ "${#}" -gt "3" ]; then
		match="${4}"
	fi


	local src_time=
	local dst_time=
	src_time="$( get_mod_time "${src_dir}/${f}" )"
	dst_time="$( get_mod_time "${dst_dir}/${f}" )"

	# Check that they dont match
	if [ "${match}" = "0" ]; then
		if [ "${src_time}" = "${dst_time}" ]; then
			printf "[TEST] [FAIL] Mod time: (%s) src and dst match: %s != %s\\r\\n" "${f}" "${src_time}" "${dst_time}"
			exit 1
		else
			printf "[TEST] [OK]   Mod time: (%s) src and dst do not match: %s = %s\\r\\n" "${f}" "${src_time}" "${dst_time}"
		fi
	# Check that they match
	else
		if [ "${src_time}" != "${dst_time}" ]; then
			printf "[TEST] [FAIL] Mod time: (%s) src and dst don't match: %s != %s\\r\\n" "${f}" "${src_time}" "${dst_time}"
			exit 1
		else
			printf "[TEST] [OK]   Mod time: (%s) src and dst match: %s = %s\\r\\n" "${f}" "${src_time}" "${dst_time}"
		fi
	fi
}


# -------------------------------------------------------------------------------------------------
# PRIVATE FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Get modification time
###
get_mod_time() {
	local file_path="${1}"

	if [ "$(uname)" = "Linux" ]; then
		run "stat -c '%Y' '${file_path}'" "1" "stderr"
	else
		run "stat -f '%m' '${file_path}'" "1" "stderr"
	fi
}
