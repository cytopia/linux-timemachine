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
