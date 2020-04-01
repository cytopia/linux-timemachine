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
RSYNC_ARGS=""

print_section "01 Default"

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
SRC_DIR="$( create_tmp_dir )"
DST_DIR="$( create_tmp_dir )"

FILE1_NAME="file1.txt"
FILE2_NAME="file2.txt"
FILE3_NAME="sub/file3.txt"

FILE1_PERM="607"
FILE2_PERM="707"
FILE3_PERM="607"

LINK1_NAME="links/link1.txt"
LINK2_NAME="links/link2.txt"
LINK3_NAME="links/link3.txt"

LINK1_FROM="../${FILE1_NAME}"
LINK2_FROM="../${FILE2_NAME}"
LINK3_FROM="../${FILE3_NAME}"


###
### Create source files
###
create_file "${SRC_DIR}" "${FILE1_NAME}" "2" "${FILE1_PERM}"
create_file "${SRC_DIR}" "${FILE2_NAME}" "5" "${FILE2_PERM}"
create_file "${SRC_DIR}" "${FILE3_NAME}" "1" "${FILE3_PERM}"

create_link "${SRC_DIR}" "${LINK1_NAME}" "${LINK1_FROM}"
create_link "${SRC_DIR}" "${LINK2_NAME}" "${LINK2_FROM}"
create_link "${SRC_DIR}" "${LINK3_NAME}" "${LINK3_FROM}"
sleep 2


### ################################################################################################
### ################################################################################################
###
### DEFINE CHECKS
###
### ################################################################################################
### ################################################################################################

check_file() {
	local file="${1}"
	local perm="${2}"

	print_subline "Validate ${file}"

	check_dst_file_is_file "${file}" "${DST_DIR}"

	check_src_dst_file_exist "${file}" "${SRC_DIR}" "${DST_DIR}"
	check_src_dst_file_equal "${file}" "${SRC_DIR}" "${DST_DIR}"

	check_dst_file_perm         "${file}" "${perm}" "${perm}" "${DST_DIR}"
	check_src_dst_file_perm     "${file}" "${SRC_DIR}" "${DST_DIR}"
	check_src_dst_file_size     "${file}" "${SRC_DIR}" "${DST_DIR}"
	check_src_dst_file_mod_time "${file}" "${SRC_DIR}" "${DST_DIR}"
	check_src_dst_file_uid      "${file}" "${SRC_DIR}" "${DST_DIR}"
	check_src_dst_file_gid      "${file}" "${SRC_DIR}" "${DST_DIR}"
}

check_link() {
	local link="${1}"

	print_subline "Validate ${link}"
	check_src_dst_file_exist "${link}" "${SRC_DIR}" "${DST_DIR}"
	check_dst_file_is_link "${link}" "${DST_DIR}"
	check_src_dst_file_equal "${link}" "${SRC_DIR}" "${DST_DIR}"
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

# TODO: check for .inprogress
# TODO: add --append-verify (and check for rsync version >= 3)

check_file "${FILE1_NAME}" "${FILE1_PERM}"
check_file "${FILE2_NAME}" "${FILE2_PERM}"
check_file "${FILE3_NAME}" "${FILE3_PERM}"

check_link "${LINK1_NAME}"
check_link "${LINK2_NAME}"
check_link "${LINK3_NAME}"


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

check_file "${FILE1_NAME}" "${FILE1_PERM}"
check_file "${FILE2_NAME}" "${FILE2_PERM}"
check_file "${FILE3_NAME}" "${FILE3_PERM}"

check_link "${LINK1_NAME}"
check_link "${LINK2_NAME}"
check_link "${LINK3_NAME}"
