
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
.PHONY: all its clean help

all: its

its: $(BUILD_DIR)/sh_general_release_dynamic_19.02.2025.fasta

ITS_DB_DOI := 10.15156/BIO/3301229

$(BUILD_DIR)/itsdb.tgz:
	mkdir -p build
	curl -fsSLG "https://api.plutof.ut.ee/v1/public/dois/" \
	  --data-urlencode "format=vnd.api+json" \
	  --data-urlencode "identifier=$(ITS_DB_DOI)" \
	  | jq -er '.data[0].attributes.media[0].url' \
	  | xargs -r curl -fL --retry 3 -o $@

$(BUILD_DIR)/sh_general_release_dynamic_19.02.2025.fasta: | $(BUILD_DIR)/itsdb.tgz
	tar -C $(BUILD_DIR) -zxvf $(word 1, $|)

# ...

# ------------------------------------------------------------------------------
#  Misc commands
# ------------------------------------------------------------------------------

clean:
	rm -rf "$(BUILD_DIR)"

help:
	@echo "Available targets:"
	@echo "  all    Build all databases (default)"
	@echo "  its    Build ITS databases"
	@echo "  clean  Remove build artifacts"
	@echo "  help   Show this help"

