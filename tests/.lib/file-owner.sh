#!/usr/bin/env bash

set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# PUBLIC FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Check src and dest file uid
###
### @param rel_path  filename
### @param abs_path  source directory
### @param abs_path  destination directory
###
check_src_dst_file_uid() {
	local f="${1}"
	local src_dir="${2}"
	local dst_dir="${3}"

	local src_uid=
	local dst_uid=
	src_uid="$( get_file_uid "${src_dir}/${f}" )"
	dst_uid="$( get_file_uid "${dst_dir}/${f}" )"

	if [ "${src_uid}" != "${dst_uid}" ]; then
		printf "[TEST] [FAIL] Owner uid: (%s) src and dst don't match: %s != %s\\r\\n" "${f}" "${src_uid}" "${dst_uid}"
		return 1
	else
		printf "[TEST] [OK]   Owner uid: (%s) src and dst match: %s = %s\\r\\n" "${f}" "${src_uid}" "${dst_uid}"
	fi
}


###
### Check src and dest file gid
###
### @param rel_path  filename
### @param abs_path  source directory
### @param abs_path  destination directory
###
check_src_dst_file_gid() {
	local f="${1}"
	local src_dir="${2}"
	local dst_dir="${3}"

	local src_gid=
	local dst_gid=
	src_gid="$( get_file_gid "${src_dir}/${f}" )"
	dst_gid="$( get_file_gid "${dst_dir}/${f}" )"

	if [ "${src_gid}" != "${dst_gid}" ]; then
		printf "[TEST] [FAIL] Owner gid: (%s) src and dst don't match: %s != %s\\r\\n" "${f}" "${src_gid}" "${dst_gid}"
		return 1
	else
		printf "[TEST] [OK]   Owner gid: (%s) src and dst match: %s = %s\\r\\n" "${f}" "${src_gid}" "${dst_gid}"
	fi
}


# -------------------------------------------------------------------------------------------------
# PRIVATE FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Get uid
###
get_file_uid() {
	local file_path="${1}"

	if [ "$(uname)" = "Linux" ]; then
		run "stat -c '%u' '${file_path}'" "1" "stderr"
	else
		run "stat -f '%u' '${file_path}'" "1" "stderr"
	fi
}


###
### Get gid
###
get_file_gid() {
	local file_path="${1}"

	if [ "$(uname)" = "Linux" ]; then
		run "stat -c '%g' '${file_path}'" "1" "stderr"
	else
		run "stat -f '%g' '${file_path}'" "1" "stderr"
	fi
}
