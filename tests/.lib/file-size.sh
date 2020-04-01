#!/usr/bin/env bash

set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# PUBLIC FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Check source and destination file size
###
### @param rel_path  filename
### @param abs_path  source directory
### @param abs_path  destination directory
###
check_src_dst_file_size() {
	local f="${1}"
	local src_dir="${2}"
	local dst_dir="${3}/current"

	local src_size=
	local dst_size=
	src_size="$( get_file_size "${src_dir}/${f}" )"
	dst_size="$( get_file_size "${dst_dir}/${f}" )"

	if [ "${src_size}" != "${dst_size}" ]; then
		printf "[TEST] [FAIL] File size: (%s) src and dst don't match: %s != %s\\r\\n" "${f}" "${src_size}" "${dst_size}"
		exit 1
	else
		printf "[TEST] [OK]   File size: (%s) src and dst match: %s = %s\\r\\n" "${f}" "${src_size}" "${dst_size}"
	fi
}


# -------------------------------------------------------------------------------------------------
# PRIVATE FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Get size in bytes of a file
###
get_file_size() {
	local file_path="${1}"

	if [ "$(uname)" = "Linux" ]; then
		run "stat -c '%s' '${file_path}'" "1" "stderr"
	else
		run "stat -f '%z' '${file_path}'" "1" "stderr"
	fi
}
