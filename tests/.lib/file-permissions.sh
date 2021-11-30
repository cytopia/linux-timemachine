#!/usr/bin/env bash

set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# PUBLIC FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Check destination file permission.
###
### @param rel_path  filename
### @param octal     source file permission
### @param octal     expected file permission
### @param abs_path  destination directory
###
check_dst_file_perm() {
	local f="${1}"
	local src_perm="${2}"
	local exp_perm="${3}"
	local dst_perm=
	local dst_dir="${4}"

	dst_perm="$( get_file_perm "${dst_dir}/${f}" )"

	if [ "${exp_perm}" != "${dst_perm}" ]; then
		printf "[TEST] [FAIL] Permissions: %s: (src: %s) (exp: %s) (dst: %s}\\r\\n" "${f}" "${src_perm}" "${exp_perm}" "${dst_perm}"
		return 1
	else
		printf "[TEST] [OK]   Permissions: %s: (src: %s) (exp: %s) (dst: %s}\\r\\n" "${f}" "${src_perm}" "${exp_perm}" "${dst_perm}"
	fi
}


###
### Check source against destination file permission
###
### @param rel_path  filename
### @param abs_path  source directory
### @param abs_path  destination directory
###
check_src_dst_file_perm() {
	local f="${1}"
	local src_dir="${2}"
	local dst_dir="${3}"

	local src_perm=
	local dst_perm=
	src_perm="$( get_file_perm "${src_dir}/${f}" )"
	dst_perm="$( get_file_perm "${dst_dir}/${f}" )"

	if [ "${src_perm}" != "${dst_perm}" ]; then
		printf "[TEST] [FAIL] Permissions: (%s) src and dst don't match: %s != %s\\r\\n" "${f}" "${src_perm}" "${dst_perm}"
		return 1
	else
		printf "[TEST] [OK]   Permissions: (%s) src and dst match: %s = %s\\r\\n" "${f}" "${src_perm}" "${dst_perm}"
	fi
}


# -------------------------------------------------------------------------------------------------
# PRIVATE FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Convert one oct digit into rwx format
###
oct_to_rwx() {
	oct="${1}"
	case "${oct}" in
		1) echo "--x";;
		2) echo "-w-";;
		3) echo "-wx";;
		4) echo "r--";;
		5) echo "r-x";;
		6) echo "rw-";;
		7) echo "rwx";;
	esac
}


###
### Convert rwx to one oct digit
###
rwx_to_oct() {
	rwx="${1}"
	case "${rwx}" in
		--x) echo "1";;
		-w-) echo "2";;
		-wx) echo "3";;
		r--) echo "4";;
		r-x) echo "5";;
		rw-) echo "6";;
		rwx) echo "7";;
	esac
}


###
### Get intersection (least one) between to rwx values
###
get_rwx_intersect() {
	rwx_1="${1}"
	rwx_2="${2}"

	r="r"
	if [ "$( echo "${rwx_1}" | cut -c1 )" == "-" ]; then
		r="-"
	fi
	if [ "$( echo "${rwx_2}" | cut -c1 )" == "-" ]; then
		r="-"
	fi

	w="w"
	if [ "$( echo "${rwx_1}" | cut -c2 )" == "-" ]; then
		w="-"
	fi
	if [ "$( echo "${rwx_2}" | cut -c2 )" == "-" ]; then
		w="-"
	fi

	x="x"
	if [ "$( echo "${rwx_1}" | cut -c3 )" == "-" ]; then
		x="-"
	fi
	if [ "$( echo "${rwx_2}" | cut -c3 )" == "-" ]; then
		x="-"
	fi

	echo "${r}${w}${x}"
}


###
### Get default directory permission based on umask
###
get_default_dir_perm() {
	local mask
	mask="$( umask | sed 's/^0*//g' )"
	echo "$(( 777 - mask ))"
}


###
### Calculate the target file permission if using --no-perms for rsync
###
### This is done by masking the current file permission with default directory umask
###
get_default_dest_file_perm() {
	# Retrieve desired file permission in rwx
	file_perm="${1}"
	file_perm_1="$( oct_to_rwx "$(echo "${file_perm}" | cut -c1)" )"
	file_perm_2="$( oct_to_rwx "$(echo "${file_perm}" | cut -c2)" )"
	file_perm_3="$( oct_to_rwx "$(echo "${file_perm}" | cut -c3)" )"

	# Retrieve default directory permission in rwx
	dir_perm="$( get_default_dir_perm )"
	dir_perm_1="$( oct_to_rwx "$(echo "${dir_perm}" | cut -c1)" )"
	dir_perm_2="$( oct_to_rwx "$(echo "${dir_perm}" | cut -c2)" )"
	dir_perm_3="$( oct_to_rwx "$(echo "${dir_perm}" | cut -c3)" )"

	# Intersect permissions
	final_perm_1="$( get_rwx_intersect "${file_perm_1}" "${dir_perm_1}" )"
	final_perm_2="$( get_rwx_intersect "${file_perm_2}" "${dir_perm_2}" )"
	final_perm_3="$( get_rwx_intersect "${file_perm_3}" "${dir_perm_3}" )"

	# Revert to oct
	final_perm_1="$( rwx_to_oct "${final_perm_1}" )"
	final_perm_2="$( rwx_to_oct "${final_perm_2}" )"
	final_perm_3="$( rwx_to_oct "${final_perm_3}" )"

	echo "${final_perm_1}${final_perm_2}${final_perm_3}"
}


###
### Get three digit octal file permissions
###
get_file_perm() {
	local file_path="${1}"
	local out
	file_path="$( printf "%q" "${file_path}" )"

	if [ "$(uname)" = "Linux" ]; then
		out="$( run "stat -c '%a' ${file_path}" "1" "stderr" )"
	else
		out="$( run "stat -f '%A' ${file_path}" "1" "stderr" )"
	fi
	out="${out//\"/}"
	>&2 echo "${out}"
	echo "${out}"
}
