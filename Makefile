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
# Targets
# -------------------------------------------------------------------------------------------------

install: timemachine
	install -d /usr/local/bin
	install -m 755 timemachine /usr/local/bin/timemachine


uninstall:
	rm /usr/local/bin/timemachine


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


lint-shell:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint shellcheck                                                      #"
	@echo "# -------------------------------------------------------------------- #"
	@docker run --rm -v $(PWD):/mnt koalaman/shellcheck:stable --shell=sh timemachine

test: test-old
test: test-local-default
test: test-local-incremental
test: test-local-no_perms
test: test-local-no_times
test: test-local-copy_links

test-local-default:
	./tests/01-run-local-default.sh
test-local-incremental:
	./tests/02-run-local-incremental.sh
test-local-no_perms:
	./tests/03-run-local-no_perms.sh
test-local-no_times:
	./tests/04-run-local-no_times.sh
test-local-copy_links:
	./tests/05-run-local-copy_links.sh

test-old:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# 1. Check for stderr errors/warnings                                  #"
	@echo "# -------------------------------------------------------------------- #"
	@echo
	@$(MAKE) _populate
	@if ! ./timemachine -d $(SRC) $(DST) 3>&1- 1>&2- 2>&3- | grep -E '.+'; then \
		printf "[TEST] [OK]   No warnings detected for run without rsync arguments.\r\n"; \
	else \
		printf "[TEST] [FAIL] Warnings detected in stderr for run without rsync arguments.\r\n"; \
		exit 1; \
	fi
	@sleep 2
	@if ! ./timemachine -d $(SRC) $(DST) 3>&1- 1>&2- 2>&3- | grep -E '.+'; then \
		printf "[TEST] [OK]   No warnings detected for run without rsync arguments.\r\n"; \
	else \
		printf "[TEST] [FAIL] Warnings detected in stderr for run without rsync arguments.\r\n"; \
		exit 1; \
	fi
	@echo


	@echo "# -------------------------------------------------------------------- #"
	@echo "# 2. Testing timemachine without rsync arguments                       #"
	@echo "# -------------------------------------------------------------------- #"
	@echo
	@$(MAKE) _populate
	@if ./timemachine -d $(SRC) $(DST); then \
		printf "[TEST] [OK]   Run timemachine without rsync arguments.\r\n"; \
	else \
		printf "[TEST] [FAIL] Run timemachine without rsync arguments.\r\n"; \
		exit 1; \
	fi
	@if test -L $(DST)/current; then \
		printf "[TEST] [OK]   Symlink 'current' exists.\r\n"; \
	else \
		printf "[TEST] [FAIL] Symlink 'current' does not exists.\r\n"; \
		exit 1; \
	fi
	@if test -d $(DST)/current/source; then \
		printf "[TEST] [OK]   Source directory exists in target.\r\n"; \
	else \
		printf "[TEST] [FAIL] Source directory does not exist in target.\r\n"; \
		exit 1; \
	fi
	@if test -f $(DST)/current/source/a; then \
		printf "[TEST] [OK]   File 'a' exists after backup.\r\n"; \
	else \
		printf "[TEST] [FAIL] File 'a' does not exist after backup.\r\n"; \
		exit 1; \
	fi
	@if test -f $(DST)/current/source/b; then \
		printf "[TEST] [OK]   File 'b' exists after backup.\r\n"; \
	else \
		printf "[TEST] [FAIL] File 'b' does not exist after backup.\r\n"; \
		exit 1; \
	fi
	@if test -f $(DST)/current/source/c; then \
		printf "[TEST] [OK]   File 'c' exists after backup.\r\n"; \
	else \
		printf "[TEST] [FAIL] File 'c' does not exist after backup.\r\n"; \
		exit 1; \
	fi
	@if ! test -w $(DST)/current/source/a; then \
		printf "[TEST] [OK]   File 'a' only has read permissions as expected.\r\n"; \
	else \
		printf "[TEST] [FAIL] File 'a' has write permissions which should not have happened.\r\n"; \
		exit 1; \
	fi
	@if test -x $(DST)/current/source/b; then \
		printf "[TEST] [OK]   File 'b' has execute permissions as expected.\r\n"; \
	else \
		printf "[TEST] [FAIL] File 'b' does not have execute permissions.\r\n"; \
		exit 1; \
	fi
	@echo


	@echo "# -------------------------------------------------------------------- #"
	@echo "# 3. Testing timemachine with rsync arguments                          #"
	@echo "# -------------------------------------------------------------------- #"
	@echo
	@$(MAKE) _populate
	@if ./timemachine -d $(SRC) $(DST) -- --progress; then \
		printf "[TEST] [OK]   timemachine with rsync arguments.\r\n"; \
	else \
		printf "[TEST] [FAIL] timemachine with rsync arguments.\r\n"; \
		exit 1; \
	fi
	@if test -L $(DST)/current; then \
		printf "[TEST] [OK]   Symlink 'current' exists.\r\n"; \
	else \
		printf "[TEST] [FAIL] Symlink 'current' does not exists.\r\n"; \
		exit 1; \
	fi
	@if test -d $(DST)/current/source; then \
		printf "[TEST] [OK]   Source directory exists in target.\r\n"; \
	else \
		printf "[TEST] [FAIL] Source directory does not exist in target.\r\n"; \
		exit 1; \
	fi
	@if test -f $(DST)/current/source/a; then \
		printf "[TEST] [OK]   File 'a' exists after backup.\r\n"; \
	else \
		printf "[TEST] [FAIL] File 'a' does not exist after backup.\r\n"; \
		exit 1; \
	fi
	@if test -f $(DST)/current/source/b; then \
		printf "[TEST] [OK]   File 'b' exists after backup.\r\n"; \
	else \
		printf "[TEST] [FAIL] File 'b' does not exist after backup.\r\n"; \
		exit 1; \
	fi
	@if test -f $(DST)/current/source/c; then \
		printf "[TEST] [OK]   File 'c' exists after backup.\r\n"; \
	else \
		printf "[TEST] [FAIL] File 'c' does not exist after backup.\r\n"; \
		exit 1; \
	fi
	@if ! test -w $(DST)/current/source/a; then \
		printf "[TEST] [OK]   File 'a' only has read permissions as expected.\r\n"; \
	else \
		printf "[TEST] [FAIL] File 'a' has write permissions which should not have happened.\r\n"; \
		exit 1; \
	fi
	@if test -x $(DST)/current/source/b; then \
		printf "[TEST] [OK]   File 'b' has execute permissions as expected.\r\n"; \
	else \
		printf "[TEST] [FAIL] File 'b' does not have execute permissions.\r\n"; \
		exit 1; \
	fi
	@echo


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
