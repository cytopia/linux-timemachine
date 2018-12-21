TEMP = temp
SRC := $(TEMP)/source
DST := $(TEMP)/dest

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


lint:
	shellcheck --version
	shellcheck --shell=sh timemachine


test:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# 1. Testing timemachine without rsync arguments                       #"
	@echo "# -------------------------------------------------------------------- #"
	@echo
	@$(MAKE) _populate
	@if ./timemachine -v $(SRC) $(DST); then \
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
	@echo "# 2. Testing timemachine with rsync arguments                          #"
	@echo "# -------------------------------------------------------------------- #"
	@echo
	@$(MAKE) _populate
	@if ./timemachine -v $(SRC) $(DST) -- --progress; then \
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


clean:
	@rm -rf $(TEMP)



# -------------------------------------------------------------------------------------------------
# Helper targets
# -------------------------------------------------------------------------------------------------
_populate: clean
	@mkdir -p "$(DST)"
	@mkdir -p "$(SRC)"
	@echo "a" > "$(SRC)/a"
	@echo "b" > "$(SRC)/b"
	@echo "c" > "$(SRC)/c"
	@chmod -w "$(SRC)/a"
	@chmod +x "$(SRC)/b"
