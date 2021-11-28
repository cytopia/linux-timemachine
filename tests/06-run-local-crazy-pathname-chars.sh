#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FUNCPATH="${SCRIPTPATH}/.lib/functions.sh"
# shellcheck disable=SC1090
. "${FUNCPATH}"


###
### RSYNC ARGUMENTS
###
RSYNC_ARGS="-- --copy-links"

print_section "05 --copy-links"

### ################################################################################################
### ################################################################################################
###
### CREATE FILES AND DIRS
###
### ################################################################################################
### ################################################################################################

print_headline "Creating files and directories"

###
### Create source and target dir
###
echo "# Create SRC_DIR"
SRC_DIR="$( create_tmp_dir "1" "" " \"\\ \` \\# \$统一码-src'" )"
echo "# Create DST_DIR"
DST_DIR="$( create_tmp_dir "1" "" " '\\\" \` \\# \$统一码-dst" )"

FILE1_NAME="file 1.txt"
FILE2_NAME="file'2.txt"
FILE3_NAME="file\"3.txt"
FILE4_NAME="file\\4.txt"
FILE5_NAME="sub sub/file5\\\".txt"
FILE6_NAME="sub 'sub/file6\\'.txt"
FILE7_NAME="sub \"sub/file7.txt"
FILE8_NAME="sub \\sub/file*"

FILE1_PERM="607"
FILE2_PERM="707"
FILE3_PERM="607"
FILE4_PERM="607"
FILE5_PERM="607"
FILE6_PERM="607"
FILE7_PERM="607"
FILE8_PERM="607"

###
### Create source files
###
printf "# Create FILE1: %s/%s\\n" "${SRC_DIR}" "${FILE1_NAME}"
create_file "${SRC_DIR}" "${FILE1_NAME}" "2" "${FILE1_PERM}"

printf "# Create FILE2: %s/%s\\n" "${SRC_DIR}" "${FILE2_NAME}"
create_file "${SRC_DIR}" "${FILE2_NAME}" "5" "${FILE2_PERM}"

printf "# Create FILE3: %s/%s\\n" "${SRC_DIR}" "${FILE3_NAME}"
create_file "${SRC_DIR}" "${FILE3_NAME}" "1" "${FILE3_PERM}"

printf "# Create FILE4: %s/%s\\n" "${SRC_DIR}" "${FILE4_NAME}"
create_file "${SRC_DIR}" "${FILE4_NAME}" "1" "${FILE4_PERM}"

printf "# Create FILE5: %s/%s\\n" "${SRC_DIR}" "${FILE5_NAME}"
create_file "${SRC_DIR}" "${FILE5_NAME}" "1" "${FILE5_PERM}"

printf "# Create FILE6: %s/%s\\n" "${SRC_DIR}" "${FILE6_NAME}"
create_file "${SRC_DIR}" "${FILE6_NAME}" "1" "${FILE6_PERM}"

printf "# Create FILE7: %s/%s\\n" "${SRC_DIR}" "${FILE7_NAME}"
create_file "${SRC_DIR}" "${FILE7_NAME}" "1" "${FILE7_PERM}"

printf "# Create FILE8: %s/%s\\n" "${SRC_DIR}" "${FILE8_NAME}"
create_file "${SRC_DIR}" "${FILE8_NAME}" "1" "${FILE8_PERM}"



### ################################################################################################
### ################################################################################################
###
### DEFINE CHECKS
###
### ################################################################################################
### ################################################################################################

check_file() {
	local file="${1}"
	local destination=
	destination="${DST_DIR}/current/$(basename "${SRC_DIR}")"

	print_subline "Validate ${file}"
	check_dst_file_is_file "${file}" "${destination}"
	check_src_dst_file_equal "${file}" "${SRC_DIR}" "${destination}"
}

check_link() {
	local link="${1}"
	local destination=
	destination="${DST_DIR}/current/$(basename "${SRC_DIR}")"

	print_subline "Validate ${link}"
	check_dst_file_is_file "${link}" "${destination}"
	check_src_dst_file_equal "${link}" "${SRC_DIR}" "${destination}"
}


### ################################################################################################
### ################################################################################################
###
### Run backup (Round 1)
###
### ################################################################################################
### ################################################################################################

print_headline "Backup (Round 1)"

print_subline "Run Backup"
run_backup \
	"${SCRIPTPATH}/../timemachine" \
	"${SRC_DIR}" \
	"${DST_DIR}" \
	"${RSYNC_ARGS}" \
	"full"

check_file "${FILE1_NAME}"
check_file "${FILE2_NAME}"
check_file "${FILE3_NAME}"
check_file "${FILE4_NAME}"
check_file "${FILE5_NAME}"
check_file "${FILE6_NAME}"
check_file "${FILE7_NAME}"
check_file "${FILE8_NAME}"


### ################################################################################################
### ################################################################################################
###
### Run backup (Round 2)
###
### ################################################################################################
### ################################################################################################

print_headline "Backup (Round 2)"

print_subline "Run Backup"
run_backup \
	"${SCRIPTPATH}/../timemachine" \
	"${SRC_DIR}" \
	"${DST_DIR}" \
	"${RSYNC_ARGS}" \
	"incremental"

check_file "${FILE1_NAME}"
check_file "${FILE2_NAME}"
check_file "${FILE3_NAME}"
check_file "${FILE4_NAME}"
check_file "${FILE5_NAME}"
check_file "${FILE6_NAME}"
check_file "${FILE7_NAME}"
check_file "${FILE8_NAME}"
