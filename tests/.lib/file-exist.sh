#!/usr/bin/env bash

set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# PUBLIC FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Check if source and destination file exist
###
### @param rel_path  filename
### @param abs_path  source directory
### @param abs_path  destination directory
###
check_src_dst_file_exist() {
	local f="${1}"
	local src_dir="${2}"
	local dst_dir="${3}"
	local src=
	local dst=

	file_name="$( printf "%q" "${f}" )"
	src="${src_dir}/${file_name}"
	dst="${dst_dir}/${file_name}"


	cmd="test -f ${src}"
	if ! eval "${cmd}"; then
		printf "[TEST] [FAIL] Source file does not exist: %s\\r\\n" "${src}"
		printf "%s" "$( ls "${src_dir}" )"
		return 1
	fi

	cmd="test -f ${dst}"
	if ! eval "${cmd}"; then
		printf "[TEST] [FAIL] Destination file does not exist: %s\\r\\n" "${dst}"
		printf "%s" "$( ls "${src_dir}" )"
		return 1
	fi
	printf "[TEST] [OK]   Source and Destination files exist\\r\\n"
}


###
### Check if destination file is a file
###
### @param rel_path  filename
### @param abs_path  destination directory
###
check_dst_file_is_file() {
	local f="${1}"
	local dst_dir="${2}"
	local dst=

	file_name="$( printf "%q" "${f}" )"
	dst="${dst_dir}/${file_name}"

	cmd="test -d ${dst}"
	if eval "${cmd}"; then
		printf "[TEST] [FAIL] Destination file is a directory: %s\\r\\n" "${dst}"
		return 1
	fi

	cmd="test -L ${dst}"
	if eval "${cmd}"; then
		printf "[TEST] [FAIL] Destination file is a symlink: %s\\r\\n" "${dst}"
		return 1
	fi

	cmd="test -f ${dst}"
	if eval "${cmd}"; then
		printf "[TEST] [OK]   Destination file is a regular file: %s\\r\\n" "${dst}"
		return 0
	fi

	printf "[TEST] [FAIL] Destination file is not a regular file: %s\\r\\n" "${dst}"
	return 1
}


###
### Check if destination file is a symlink
###
### @param rel_path  filename
### @param abs_path  destination directory
###
check_dst_file_is_link() {
	local f="${1}"
	local dst_dir="${2}"
	local dst=

	dst="$( printf "%q" "${dst_dir}/${f}" )"

	if [ -d "${dst}" ]; then
		printf "[TEST] [FAIL] Destination file is a directory: %s\\r\\n" "${dst}"
		return 1
	fi
	if [ -L "${dst}" ]; then
		printf "[TEST] [OK]   Destination file is a symlink\\r\\n"
		return
	fi
	printf "[TEST] [FAIL] Destination file is not a symlink: %s\\r\\n" "${dst}"
	return 1
}


###
### Check if source and destination file equal
###
### @param rel_path  filename
### @param abs_path  source directory
### @param abs_path  destination directory
###
check_src_dst_file_equal() {
	local f="${1}"
	local src_dir="${2}"
	local dst_dir="${3}"
	local src=
	local dst=

	src="${src_dir}/$( printf "%q" "${f}" )"
	dst="${dst_dir}/$( printf "%q" "${f}" )"

	if ! run "cmp ${src} ${dst}"; then
		printf "[TEST] [FAIL] Source (%s) and dest (%s) files differ\\r\\n" "${src}" "${dst}"
		return 1
	else
		printf "[TEST] [OK]   Source and dest files are equal\\r\\n"
	fi
}
