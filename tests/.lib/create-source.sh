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
	local file_size="${3}"
	local file_perms="${4}"

	local file_path="${src_dir}/${file_name}"

	# Create directory if it doesn't exist
	if [ ! -d "$( dirname "${file_path}" )" ]; then
		run "mkdir -p $( dirname "${file_path}" )"
	fi

	if [ "$(uname)" = "Linux" ]; then
		run "dd if=/dev/zero of=${file_path} bs=1M count=${file_size} 2>/dev/null"
	else
		run "dd if=/dev/zero of=${file_path} bs=1m count=${file_size} 2>/dev/null"
	fi
	run "chmod ${file_perms} '${file_path}'"
}


###
### Create symlink
###
create_link() {
	local src_dir="${1}"
	local link_name="${2}"
	local link_from="${3}"
	local link_path="${src_dir}/${link_name}"

	# Create directory if it doesn't exist
	if [ ! -d "$( dirname "${link_path}" )" ]; then
		run "mkdir -p $( dirname "${link_path}" )"
	fi

	run "cd '${src_dir}' && ln -s '${link_from}' '${link_name}'"
}
