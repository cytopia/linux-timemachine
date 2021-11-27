ifneq (,)
.error This Makefile requires GNU Make.
endif


# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------

.PHONY: help lint lint-file lint-shell test clean _populate

SHELL := /bin/bash

TEMP = temp
SRC := $(TEMP)/source
DST := $(TEMP)/dest

FL_VERSION = 0.3
FL_IGNORES = .git/,.github/

# -------------------------------------------------------------------------------------------------
# Default targets
# -------------------------------------------------------------------------------------------------

help:
	@echo
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Linux timemachine Makefile                                           #"
	@echo "# -------------------------------------------------------------------- #"
	@echo
	@echo "install    Install to /usr/local/bin/timemachine (requires root)"
	@echo "uninstall  Remove /usr/local/bin/timemachine (requires root)"
	@echo
	@echo "help       Show this help"
	@echo "lint       Run shellcheck linting"
	@echo "test       Run integration test"
	@echo


# -------------------------------------------------------------------------------------------------
# System targets
# -------------------------------------------------------------------------------------------------

install: timemachine
	install -d /usr/local/bin
	install -m 755 timemachine /usr/local/bin/timemachine


uninstall:
	rm /usr/local/bin/timemachine


# -------------------------------------------------------------------------------------------------
# Lint targets
# -------------------------------------------------------------------------------------------------

lint: lint-file lint-shell


lint-file:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint files                                                           #"
	@echo "# -------------------------------------------------------------------- #"
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-cr --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-crlf --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-trailing-single-newline --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-trailing-space --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-utf8 --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-utf8-bom --text --ignore '$(FL_IGNORES)' --path .


# -------------------------------------------------------------------------------------------------
# Test targets
# -------------------------------------------------------------------------------------------------

lint-shell:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint shellcheck                                                      #"
	@echo "# -------------------------------------------------------------------- #"
	@docker run --rm -v $(PWD):/mnt koalaman/shellcheck:stable --shell=sh timemachine


test: test-local-default-abs-noslash-noslash
test: test-local-default-abs-noslash-slash
test: test-local-default-abs-slash-noslash
test: test-local-default-abs-slash-slash
test: test-local-default-rel-noslash-noslash
test: test-local-default-rel-noslash-slash
test: test-local-default-rel-slash-noslash
test: test-local-default-rel-slash-slash
test: test-local-no_perms
test: test-local-no_times
test: test-local-copy_links
test: test-local-crazy-filename-chars
test: test-remote-default-abs
test: test-remote-default-rel
test: test-remote-ssh_1111_port-nouser
test: test-remote-ssh_1111_port-user
test: test-remote-ssh_22_port-nouser
test: test-remote-ssh_22_port-user
test: test-remote-ssh_def_port-nouser
test: test-remote-ssh_def_port-user
test: test-remote-ssh_config-default
test: test-remote-ssh_config-port_1111
test: test-remote-ssh_config-port_overwrite


test-local-default-abs-noslash-noslash:
	./tests/01-run-local-default-abs-noslash-noslash.sh

test-local-default-abs-noslash-slash:
	./tests/01-run-local-default-abs-noslash-slash.sh

test-local-default-abs-slash-noslash:
	./tests/01-run-local-default-abs-slash-noslash.sh

test-local-default-abs-slash-slash:
	./tests/01-run-local-default-abs-slash-slash.sh

test-local-default-rel-noslash-noslash:
	./tests/02-run-local-default-rel-noslash-noslash.sh

test-local-default-rel-noslash-slash:
	./tests/02-run-local-default-rel-noslash-slash.sh

test-local-default-rel-slash-noslash:
	./tests/02-run-local-default-rel-slash-noslash.sh

test-local-default-rel-slash-slash:
	./tests/02-run-local-default-rel-slash-slash.sh

test-local-no_perms:
	./tests/03-run-local-no_perms.sh

test-local-no_times:
	./tests/04-run-local-no_times.sh

test-local-copy_links:
	./tests/05-run-local-copy_links.sh

test-local-crazy-filename-chars:
	./tests/06-run-local-crazy-filename-chars.sh

test-local-crazy-pathname-chars:
	./tests/06-run-local-crazy-pathname-chars.sh

test-remote-default-abs:
	./tests/10-run-remote-default-abs.sh

test-remote-default-rel:
	./tests/10-run-remote-default-rel.sh

test-remote-ssh_1111_port-nouser:
	./tests/11-run-remote-ssh_port_1111-nouser.sh

test-remote-ssh_1111_port-user:
	./tests/11-run-remote-ssh_port_1111-user.sh

test-remote-ssh_22_port-nouser:
	./tests/11-run-remote-ssh_port_22-nouser.sh

test-remote-ssh_22_port-user:
	./tests/11-run-remote-ssh_port_22-user.sh

test-remote-ssh_def_port-nouser:
	./tests/11-run-remote-ssh_port_def-nouser.sh

test-remote-ssh_def_port-user:
	./tests/11-run-remote-ssh_port_def-user.sh

test-remote-ssh_config-default:
	./tests/12-run-remote-ssh_config-default.sh

test-remote-ssh_config-port_1111:
	./tests/12-run-remote-ssh_config-port_1111.sh

test-remote-ssh_config-port_overwrite:
	./tests/12-run-remote-ssh_config-port_overwrite.sh


# -------------------------------------------------------------------------------------------------
# Helper targets
# -------------------------------------------------------------------------------------------------

clean:
	@rm -rf $(TEMP)

_populate: clean
	@mkdir -p "$(DST)"
	@mkdir -p "$(SRC)"
	@echo "a" > "$(SRC)/a"
	@echo "b" > "$(SRC)/b"
	@echo "c" > "$(SRC)/c"
	@chmod -w "$(SRC)/a"
	@chmod +x "$(SRC)/b"

pull-docker-lint-file:
	docker pull cytopia/file-lint:$(FL_VERSION)

pull-docker-lint-shell:
	docker pull koalaman/shellcheck:stable

pull-docker-ssh-base:
	docker pull debian:buster-slim

build-docker-ssh-server:
	docker build -t cytopia/ssh-server -f "$(PWD)/tests/docker-ssh-server/Dockerfile" "$(PWD)/tests/docker-ssh-server"

build-docker-ssh-client:
	docker build -t cytopia/ssh-client -f "$(PWD)/tests/docker-ssh-client/Dockerfile" "$(PWD)/tests/docker-ssh-client"
