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

	if [ ! -f "${src_dir}/${f}" ]; then
		printf "[TEST] [FAIL] Source file does not exist: %s\\r\\n" "${src_dir}/${f}"
		exit 1
	fi
	if [ ! -f "${dst_dir}/${f}" ]; then
		printf "[TEST] [FAIL] Destination file does not exist: %s\\r\\n" "${dst_dir}/${f}"
		exit 1
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

	if [ -d "${dst_dir}/${f}" ]; then
		printf "[TEST] [FAIL] Destination file is a directory: %s\\r\\n" "${dst_dir}/${f}"
		exit 1
	fi
	if [ -L "${dst_dir}/${f}" ]; then
		printf "[TEST] [FAIL] Destination file is a symlink: %s\\r\\n" "${dst_dir}/${f}"
		exit 1
	fi
	printf "[TEST] [OK]   Destination file is a regular file\\r\\n"
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

	if [ -d "${dst_dir}/${f}" ]; then
		printf "[TEST] [FAIL] Destination file is a directory: %s\\r\\n" "${dst_dir}/${f}"
		exit 1
	fi
	if [ -L "${dst_dir}/${f}" ]; then
		printf "[TEST] [OK]   Destination file is a symlink\\r\\n"
		return
	fi
	printf "[TEST] [FAIL] Destination file is not a symlink: %s\\r\\n" "${dst_dir}/${f}"
	exit 1
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

	if ! run "cmp -s '${src_dir}/${f}' '${dst_dir}/${f}'"; then
		printf "[TEST] [FAIL] Source (%s) and dest (%s) files differ\\r\\n" "${src_dir}/${f}" "${dst_dir}/${f}"
		exit 1
	else
		printf "[TEST] [OK]   Source and dest files are equal\\r\\n"
	fi
}
