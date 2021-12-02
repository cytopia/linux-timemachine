#!/usr/bin/env bash

set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# PUBLIC FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Create file
###
create_file() {
	local src_dir="${1}"
	local file_name="${2}"
	local sub_dir=
	local file_path=
	local file_size="${3}"
	local file_perms="${4}"

	file_name="$( printf "%q" "${file_name}" )"
	sub_dir="$( printf "%q" "$( eval "dirname ${file_name}" )" )"
	file_path="${src_dir}/${file_name}"

	if ! eval "test -d ${src_dir}"; then
		printf "No such directpry: %s\\n" "${src_dir}"
		return 1
	fi
	# Create sub-directory if it doesn't exist
	if [ "${sub_dir}" != "." ]; then
		printf "# Create basedir: %s\\n" "${sub_dir}"
		run "mkdir -p ${src_dir}/${sub_dir}"
	fi
	if [ "$(uname)" = "Linux" ]; then
		run "dd if=/dev/zero of=${file_path} bs=1M count=${file_size} 2>/dev/null"
	else
		run "dd if=/dev/zero of=${file_path} bs=1m count=${file_size} 2>/dev/null"
	fi
	run "chmod ${file_perms} ${file_path}"

	if ! eval "test -f ${file_path}"; then
		echo "No file created: ${file_path}"
		return 1
	fi
}


###
### Create symlink
###
create_link() {
	local src_dir="${1}"
	local link_name="${2}"
	local sub_dir=
	local link_from="${3}"

	link_name="$( printf "%q" "${link_name}" )"
	sub_dir="$( printf "%q" "$( eval "dirname ${link_name}" )" )"

	if ! eval "test -d ${src_dir}"; then
		printf "No such directpry: %s\\n" "${src_dir}"
		return 1
	fi
	# Create sub-directory if it doesn't exist
	if [ "${sub_dir}" != "." ]; then
		printf "# Create basedir: %s\\n" "${sub_dir}"
		run "mkdir -p ${src_dir}/${sub_dir}"
	fi
	run "cd ${src_dir} && ln -s ${link_from} ${link_name}"
}
