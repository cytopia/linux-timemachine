#!/usr/bin/env bash

set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# PUBLIC FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Run backup
###
run_backup() {
	local timemachine_path="${1}"
	local src_dir="${2}"
	local dst_dir="${3}"
	local rsync_args="${4}"
	local backup_type="${5}"

	local out
	local err

	out="$( create_tmp_file )"
	err="$( create_tmp_file )"

	###
	### Give 2 seconds time for a new unique directory name (second based) to be created
	###
	sleep 2

	###
	### Run and check for failure
	###
	if ! run "\"${timemachine_path}\" -d \"${src_dir}\" \"${dst_dir}\" ${rsync_args} > \"${out}\" 2> \"${err}\""; then
		printf "[TEST] [FAIL] Run failed.\\r\\n"
		cat "${out}"
		cat "${err}"
		rm "${out}"
		rm "${err}"
		exit 1
	fi
	cat "${out}"

	###
	### Check for warnings
	###
	if [ -s "${err}" ]; then
		printf "[TEST] [FAIL] Warnings detected.\\r\\n"
		printf "Warnings:\\r\\n----------\\r\\n%s\\r\\n" "$( cat "${err}" )"
		rm "${out}"
		rm "${err}"
		exit 1
	fi
	printf "[TEST] [OK]   No warnings detected.\\r\\n"

	###
	### Check for backup type
	###
	if ! grep "Starting ${backup_type} backup" "${out}" >/dev/null; then
		printf "[TEST] [FAIL] Not a '%s' backup\\r\\n" "${backup_type}"
		rm "${out}"
		rm "${err}"
		exit 1
	fi
	printf "[TEST] [OK]   Backup type: '%s' backup.\\r\\n" "${backup_type}"

	###
	### Check for existing latest symlink
	###
	if [ ! -L "${dst_dir}/current" ]; then
		printf "[TEST] [FAIL] No latest symlink available: %s\\r\\n" "${dst_dir}/current"
		rm "${out}"
		rm "${err}"
		exit 1
	fi
	printf "[TEST] [OK]   Latest symlink available: %s\\r\\n" "${dst_dir}/current"

	###
	### Check partial backup .inprogress directory
	###
	if [ -d "${dst_dir}/current/.inprogress" ]; then
		printf "[TEST] [FAIL] Undeleted '.inprogress' directory found: %s\\r\\n" "${dst_dir}/current/.inprogress"
		rm "${out}"
		rm "${err}"
		exit 1
	fi
	printf "[TEST] [OK]   No '.inprogress' directory found\\r\\n"

	###
	### Remove artifacts
	###
	rm "${out}"
	rm "${err}"
}
