
# Database build Makefile
#
# Build scripts for 16S and ITS reference databases.

.DEFAULT_GOAL := all

SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c

.DELETE_ON_ERROR:

# Configuration
BUILD_DIR ?= build
DB_DIR ?= dbs

# Database build targets
.PHONY: all 16s its clean help

all: 16s its

16s:
	echo "Not yet implemented!"
	@$(MAKE) --no-print-directory -f Makefile.16s all

its:
	echo "Not yet implemented!"

clean:
	rm -rf "$(BUILD_DIR)"

help:
	@echo "Available targets:"
	@echo "  all    Build all databases (default)"
	@echo "  16s    Build 16S databases"
	@echo "  its    Build ITS databases"
	@echo "  clean  Remove build artifacts"
	@echo "  help   Show this help"

