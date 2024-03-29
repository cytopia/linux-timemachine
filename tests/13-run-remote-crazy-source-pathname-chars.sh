#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FUNCPATH="${SCRIPTPATH}/.lib/functions.sh"
# shellcheck disable=SC1090
. "${FUNCPATH}"


###
### GLOBALS
###
#SSH_USER="root"
SSH_HOST="server"
#SSH_PORT="22"

TIMEMACHINE_ARGS=""
RSYNC_ARGS="--progress"

print_section "12 Remote (crazy pathname chars)"

### ################################################################################################
### ################################################################################################
###
### CREATE FILES AND DIRS
###
### ################################################################################################
### ################################################################################################

print_headline "Creating files and directories"

###
### Create source dir
###
SRC_DIR="$( create_tmp_dir )"
DOCKER_SRC_DIR="/$(printf "%s" ' "\ ` $统一码-$-src')"
DOCKER_DST_DIR="/backup-dst"

FILE1_NAME="file1.txt"
FILE2_NAME="file2.txt"
FILE3_NAME="sub/file3.txt"

FILE1_PERM="607"
FILE2_PERM="707"
FILE3_PERM="607"

###
### Create source files
###
create_file "${SRC_DIR}" "${FILE1_NAME}" "2" "${FILE1_PERM}"
create_file "${SRC_DIR}" "${FILE2_NAME}" "5" "${FILE2_PERM}"
create_file "${SRC_DIR}" "${FILE3_NAME}" "1" "${FILE3_PERM}"


### ################################################################################################
### ################################################################################################
###
### DEFINE CHECKS
###
### ################################################################################################
### ################################################################################################

check() {
	printf ""
}


### ################################################################################################
### ################################################################################################
###
### Start container
###
### ################################################################################################
### ################################################################################################

print_headline "Start container"

###
### Kill accidentally left artifacts
###
run "docker rm -f ssh-server || true" >/dev/null 2>&1
run "docker rm -f ssh-client || true" >/dev/null 2>&1

###
### Startup
###
run "docker run -d --rm --name ssh-server -h server cytopia/ssh-server /usr/sbin/sshd -D"
run "docker exec ssh-server mkdir $(printf "%q" "${DOCKER_DST_DIR}")"
run "docker run -d --rm --name ssh-client -h client --link ssh-server -v '${SCRIPTPATH}/../timemachine:/usr/bin/timemachine' -v ${SRC_DIR}:/$(printf "%q" "${DOCKER_SRC_DIR}") cytopia/ssh-client"
run "sleep 5"


### ################################################################################################
### ################################################################################################
###
### Run backup (Round 1)
###
### ################################################################################################
### ################################################################################################

print_headline "Backup (Round 1)"

print_subline "Run Backup"
run_remote_backup \
	"ssh-client" \
	"ssh-server" \
	"/usr/bin/timemachine" \
	"${TIMEMACHINE_ARGS}" \
	"${DOCKER_SRC_DIR}" \
	"${SSH_HOST}" \
	"${DOCKER_DST_DIR}" \
	"${RSYNC_ARGS}" \
	"full"

check "${FILE1_NAME}" "${FILE1_PERM}"
check "${FILE2_NAME}" "${FILE2_PERM}"
check "${FILE3_NAME}" "${FILE3_PERM}"


### ################################################################################################
### ################################################################################################
###
### Run backup (Round 2)
###
### ################################################################################################
### ################################################################################################

print_headline "Backup (Round 2)"

print_subline "Run Backup"
run_remote_backup \
	"ssh-client" \
	"ssh-server" \
	"/usr/bin/timemachine" \
	"${TIMEMACHINE_ARGS}" \
	"${DOCKER_SRC_DIR}" \
	"${SSH_HOST}" \
	"${DOCKER_DST_DIR}" \
	"${RSYNC_ARGS}" \
	"incremental"

check "${FILE1_NAME}" "${FILE1_PERM}"
check "${FILE2_NAME}" "${FILE2_PERM}"
check "${FILE3_NAME}" "${FILE3_PERM}"


### ################################################################################################
### ################################################################################################
###
### Cleanup
###
### ################################################################################################
### ################################################################################################

print_headline "Cleanup"

###
### Remove artifacts
###
run "docker rm -f ssh-server"
run "docker rm -f ssh-client"
