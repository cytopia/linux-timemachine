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

print_section "01 Default (slash slash)"

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
	local destination=
	destination="${DST_DIR}/current"

	print_subline "Validate ${file}"

	check_dst_file_is_file "${file}" "${destination}"

	check_src_dst_file_exist "${file}" "${SRC_DIR}" "${destination}"
	check_src_dst_file_equal "${file}" "${SRC_DIR}" "${destination}"

	check_dst_file_perm         "${file}" "${perm}" "${perm}" "${destination}"
	check_src_dst_file_perm     "${file}" "${SRC_DIR}" "${destination}"
	check_src_dst_file_size     "${file}" "${SRC_DIR}" "${destination}"
	check_src_dst_file_mod_time "${file}" "${SRC_DIR}" "${destination}"
	check_src_dst_file_uid      "${file}" "${SRC_DIR}" "${destination}"
	check_src_dst_file_gid      "${file}" "${SRC_DIR}" "${destination}"
}

check_link() {
	local link="${1}"
	local destination=
	destination="${DST_DIR}/current"

	print_subline "Validate ${link}"
	check_src_dst_file_exist "${link}" "${SRC_DIR}" "${destination}"
	check_dst_file_is_link "${link}" "${destination}"
	check_src_dst_file_equal "${link}" "${SRC_DIR}" "${destination}"
}

check_dir() {
	local src="${1}"
	local dst="${2}"
	local destination=
	destination="${dst}/current"

	check_dir_size "${src}" "${destination}"
}

check_backup() {
	local src="${1}"
	local dst="${2}"
	local backup1="${3}"
	local backup2="${4}"

	local src_actual_size
	local dst_actual_size
	local backup1_actual_size
	local backup2_actual_size

	print_subline "Check incremental Backup"

	backup1_actual_size="$( get_dir_size_without_hardlinks "${backup1}" )"
	backup2_actual_size="$( get_dir_size_without_hardlinks "${backup2}" )"
	if [ "${backup1_actual_size}" -eq "${backup2_actual_size}" ]; then
		printf "[TEST] [FAIL] Incremental: inital backup (%s) and incremental backup (%s) disk sizes are equal\\r\\n" "${backup1_actual_size}" "${backup2_actual_size}"
		exit 1
	fi
	printf "[TEST] [OK]   Incremental: inital backup (%s) and incremental backup (%s) disk sizes differ\\r\\n" "${backup1_actual_size}" "${backup2_actual_size}"


	print_subline "Check incremental Backup after deleting initial full backup"

	run "rm -rf '${backup1}'"
	src_actual_size="$( get_dir_size_with_hardlinks "${src}" )"
	dst_actual_size="$( get_dir_size_without_hardlinks "${dst}/current/" )"

	if [ "${src_actual_size}" -ne "${dst_actual_size}" ]; then
		printf "[TEST] [FAIL] Incremental Backup: src-dir(%s) size is not equal to dst-dir(%s)\\r\\n" "${src_actual_size}" "${dst_actual_size}"
		exit 1
	fi
	printf "[TEST] [OK]   Incremental Backup: src-dir(%s) size is equal to dst-dir(%s)\\r\\n" "${src_actual_size}" "${dst_actual_size}"
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
	"${SRC_DIR}/" \
	"${DST_DIR}/" \
	"${RSYNC_ARGS}" \
	"full"

check_file "${FILE1_NAME}" "${FILE1_PERM}"
check_file "${FILE2_NAME}" "${FILE2_PERM}"
check_file "${FILE3_NAME}" "${FILE3_PERM}"

check_link "${LINK1_NAME}"
check_link "${LINK2_NAME}"
check_link "${LINK3_NAME}"

check_dir "${SRC_DIR}" "${DST_DIR}"

BACKUP_PATH_1="$( cd "${DST_DIR}/current/" && pwd -P )"


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
	"${SRC_DIR}/" \
	"${DST_DIR}/" \
	"${RSYNC_ARGS}" \
	"incremental"

check_file "${FILE1_NAME}" "${FILE1_PERM}"
check_file "${FILE2_NAME}" "${FILE2_PERM}"
check_file "${FILE3_NAME}" "${FILE3_PERM}"

check_link "${LINK1_NAME}"
check_link "${LINK2_NAME}"
check_link "${LINK3_NAME}"

check_dir "${SRC_DIR}" "${DST_DIR}"

BACKUP_PATH_2="$( cd "${DST_DIR}/current/" && pwd -P )"


### ################################################################################################
### ################################################################################################
###
### Validate Backups
###
### ################################################################################################
### ################################################################################################

print_headline "Validate Backups"

check_backup \
	"${SRC_DIR}" \
	"${DST_DIR}" \
	"${BACKUP_PATH_1}" \
	"${BACKUP_PATH_2}"
