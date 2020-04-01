#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FUNCPATH="${SCRIPTPATH}/.lib/functions.sh"
# shellcheck disable=SC1090
. "${FUNCPATH}"


###
### Kill accidentally left artifacts
###
run "docker rm -f ssh-server || true" >/dev/null 2>&1
run "docker rm -f ssh-client || true" >/dev/null 2>&1


###
### Startup
###
run "docker run -d --rm --name ssh-server -h server cytopia/ssh-server"
run "docker run -d --rm --name ssh-client -h client --link ssh-server -v '${SCRIPTPATH}/../timemachine:/usr/bin/timemachine' -v '${SCRIPTPATH}/../tests:/tests' cytopia/ssh-client"


###
### Run 1
###
run "sleep 5"
if ! ERR="$( run "docker exec ssh-client /usr/bin/timemachine -d /tests root@server:/backup2" 3>&1 1>&2 2>&3 )"; then
	run "docker rm -f ssh-server"
	run "docker rm -f ssh-client"
	exit 1
fi
if [ -n "${ERR}" ]; then
	printf "[TEST] [FAIL] Warnings detected.\\r\\n"
	printf "Warnings:\\r\\n----------\\r\\n%s\\r\\n" "${ERR}"
	run "docker rm -f ssh-server || true" >/dev/null 2>&1
	run "docker rm -f ssh-client || true" >/dev/null 2>&1
	exit 1
fi


###
### Run 2
###
run "sleep 5"
if ! ERR="$( run "docker exec ssh-client /usr/bin/timemachine -d /tests root@server:/backup2" 3>&1 1>&2 2>&3 )"; then
	run "docker rm -f ssh-server"
	run "docker rm -f ssh-client"
	exit 1
fi
if [ -n "${ERR}" ]; then
	printf "[TEST] [FAIL] Warnings detected.\\r\\n"
	printf "Warnings:\\r\\n----------\\r\\n%s\\r\\n" "${ERR}"
	run "docker rm -f ssh-server || true" >/dev/null 2>&1
	run "docker rm -f ssh-client || true" >/dev/null 2>&1
	exit 1
fi


###
### Remove artifacts
###
run "docker rm -f ssh-server"
run "docker rm -f ssh-client"
