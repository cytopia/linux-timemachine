#!/usr/bin/env bash

set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# PUBLIC FUNCTIONS
# -------------------------------------------------------------------------------------------------

check_dir_size() {
	local src=
	local dst=
	src="$( printf "%q" "${1}" )"
	dst="$( printf "%q" "${2}" )"

	src_size="$( get_dir_size_with_hardlinks "${src}" )"
	dst_size="$( get_dir_size_with_hardlinks "${dst}" )"

	if [ "${src_size}" -eq "${dst_size}" ]; then
		printf "[TEST] [OK]   src-dir(%s) and dst-dir(%s) size match\\r\\n" "${src_size}" "${dst_size}"
		return 0
	fi
	printf "[TEST] [FAIL] src-dir(%s) and dst-dir(%s) size don't match: (src: %s) (dst: %s)\\r\\n" "${src_size}" "${dst_size}" "${src}" "${dst}"
	exit 1
}


# -------------------------------------------------------------------------------------------------
# PRIVATE FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Return total size of directory in bytes.
### It also counts the size of hardlinks.
###
### @param abs_path  directory
###
get_dir_size_with_hardlinks() {
	local dir=
	local size=
	dir="$( printf "%q" "${1}" )"

	size="$( run "cd '${dir}' && du -d0 '.' | awk '{print \$1}'" "1" "stderr" )"
	echo "${size}"
}

###
### Return total size of directory in bytes.
### Subtract the size of any hardlinks.
###
### @param abs_path  directory
###
get_dir_size_without_hardlinks() {
	local dir=
	dir="$( printf "%q" "${1}" )"
	local suffix="${2:-}"
	local actual_path=
	local current_dir_name=
	local parent_dir_path=
	local size=


	# Return the actual path (in case we're in a symlink)
	actual_path="$( printf "%q" "$( run "cd ${dir} && pwd -P" "1" "stderr" )" )"

	# Get only the name of the current directory
	current_dir_name="$( printf "%q" "$( run "basename ${actual_path}" "1" "stderr" )" )"

	# Get the parent directory path
	parent_dir_path="$( printf "%q" "$( run "dirname ${actual_path}" "1" "stderr" )" )"


	size="$( run "cd ${parent_dir_path} && du -d2 2>/dev/null | grep -E '${current_dir_name}${suffix}\$' | head -1 | awk '{print \$1}'" "1" "stderr" )"
	echo "${size}"
}
