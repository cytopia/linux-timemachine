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

print_section "01 Default (noslash slash)"

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
SRC_DIR="$( create_tmp_dir "0" "${SCRIPTPATH}/.." )"
DST_DIR="$( create_tmp_dir "0" "${SCRIPTPATH}/.." )"

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
create_file "${SCRIPTPATH}/../${SRC_DIR}" "${FILE1_NAME}" "2" "${FILE1_PERM}"
create_file "${SCRIPTPATH}/../${SRC_DIR}" "${FILE2_NAME}" "5" "${FILE2_PERM}"
create_file "${SCRIPTPATH}/../${SRC_DIR}" "${FILE3_NAME}" "1" "${FILE3_PERM}"

create_link "${SCRIPTPATH}/../${SRC_DIR}" "${LINK1_NAME}" "${LINK1_FROM}"
create_link "${SCRIPTPATH}/../${SRC_DIR}" "${LINK2_NAME}" "${LINK2_FROM}"
create_link "${SCRIPTPATH}/../${SRC_DIR}" "${LINK3_NAME}" "${LINK3_FROM}"
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
	local destination=
	destination="${SCRIPTPATH}/../${DST_DIR}/current/$(basename "${SRC_DIR}")"

	print_subline "Validate ${file}"

	check_dst_file_is_file "${file}" "${destination}"

	check_src_dst_file_exist "${file}" "${SCRIPTPATH}/../${SRC_DIR}" "${destination}"
	check_src_dst_file_equal "${file}" "${SCRIPTPATH}/../${SRC_DIR}" "${destination}"

	check_dst_file_perm         "${file}" "${perm}" "${perm}" "${destination}"
	check_src_dst_file_perm     "${file}" "${SCRIPTPATH}/../${SRC_DIR}" "${destination}"
	check_src_dst_file_size     "${file}" "${SCRIPTPATH}/../${SRC_DIR}" "${destination}"
	check_src_dst_file_mod_time "${file}" "${SCRIPTPATH}/../${SRC_DIR}" "${destination}"
	check_src_dst_file_uid      "${file}" "${SCRIPTPATH}/../${SRC_DIR}" "${destination}"
	check_src_dst_file_gid      "${file}" "${SCRIPTPATH}/../${SRC_DIR}" "${destination}"
}

check_link() {
	local link="${1}"
	local destination=
	destination="${SCRIPTPATH}/../${DST_DIR}/current/$(basename "${SRC_DIR}")"

	print_subline "Validate ${link}"
	check_src_dst_file_exist "${link}" "${SCRIPTPATH}/../${SRC_DIR}" "${destination}"
	check_dst_file_is_link   "${link}" "${destination}"
	check_src_dst_file_equal "${link}" "${SCRIPTPATH}/../${SRC_DIR}" "${destination}"
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
	"${DST_DIR}/" \
	"${RSYNC_ARGS}" \
	"full" \
	"${SCRIPTPATH}/.."

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
	"${DST_DIR}/" \
	"${RSYNC_ARGS}" \
	"incremental" \
	"${SCRIPTPATH}/.."

check_file "${FILE1_NAME}" "${FILE1_PERM}"
check_file "${FILE2_NAME}" "${FILE2_PERM}"
check_file "${FILE3_NAME}" "${FILE3_PERM}"

check_link "${LINK1_NAME}"
check_link "${LINK2_NAME}"
check_link "${LINK3_NAME}"
