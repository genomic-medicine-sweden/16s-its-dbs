
# Database build Makefile
#
# Build scripts for 16S and ITS reference databases.


# ------------------------------------------------------------------------------
#  Misc defaults
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
#  16S Databases
# ------------------------------------------------------------------------------

16s:
	echo "Not yet implemented!"

# ------------------------------------------------------------------------------
#  ITS Databases
# ------------------------------------------------------------------------------

its:
	echo "Not yet implemented!"

ITS_DB_DOI := 10.15156/BIO/3301229

$(BUILD_DIR)/itsdb.tgz:
	mkdir -p build
	curl -fsSLG "https://api.plutof.ut.ee/v1/public/dois/" \
	  --data-urlencode "format=vnd.api+json" \
	  --data-urlencode "identifier=$(ITS_DB_DOI)" \
	  | jq -er '.data[0].attributes.media[0].url' \
	  | xargs -r curl -fL --retry 3 -o $@

# ------------------------------------------------------------------------------
#  Misc commands
# ------------------------------------------------------------------------------

clean:
	rm -rf "$(BUILD_DIR)"

help:
	@echo "Available targets:"
	@echo "  all    Build all databases (default)"
	@echo "  16s    Build 16S databases"
	@echo "  its    Build ITS databases"
	@echo "  clean  Remove build artifacts"
	@echo "  help   Show this help"

