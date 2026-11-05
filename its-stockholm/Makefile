
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

ITS_DB_DOI := 10.15156/BIO/3301229
ITS_DB_NAME := unite-fungi

ITS_INPUT_FASTA := $(BUILD_DIR)/sh_general_release_dynamic_19.02.2025_dev.fasta
ITS_CORRECTIONS := corrections.csv
ITS_CORRECTED_FASTA := $(BUILD_DIR)/corrected.fasta

ITS_CONVERTED_FASTA := $(BUILD_DIR)/emu-$(ITS_DB_NAME)-input.fa
ITS_SEQ2TAX := $(BUILD_DIR)/seq2tax.map
ITS_TAXONOMY := $(BUILD_DIR)/tax.tsv

ITS_DB_FILES := $(ITS_CONVERTED_FASTA) $(ITS_SEQ2TAX) $(ITS_TAXONOMY)

# Final EMU database files

ITS_DB_OUTPUT := \
	$(DB_DIR)/$(ITS_DB_NAME)/species_taxid.fasta \
	$(DB_DIR)/$(ITS_DB_NAME)/taxonomy.tsv

its: $(ITS_DB_OUTPUT)

# Download database

$(BUILD_DIR)/itsdb.tgz:
	mkdir -p build
	curl -fsSLG "https://api.plutof.ut.ee/v1/public/dois/" \
	  --data-urlencode "format=vnd.api+json" \
	  --data-urlencode "identifier=$(ITS_DB_DOI)" \
	  | jq -er '.data[0].attributes.media[0].url' \
	  | xargs -r curl -fL --retry 3 -o $@

# Extract database

$(ITS_INPUT_FASTA): | $(BUILD_DIR)/itsdb.tgz
	tar -C $(BUILD_DIR) -zxvf $(word 1, $|)

# Correct species annotation based on corrections.csv

$(ITS_CORRECTED_FASTA): $(ITS_INPUT_FASTA) $(ITS_CORRECTIONS)
	awk -f ../scripts/correct_its_fasta.awk $(ITS_CORRECTIONS) $< > $@

# Convert FASTA into emu build-database input files

$(ITS_DB_FILES) &: $(ITS_INPUT_FASTA)
	mkdir -p $(BUILD_DIR)
	awk \
		-v db_name="$(ITS_DB_NAME)" \
		-v output_dir="$(BUILD_DIR)" \
		-f ../scripts/prepare_unite.awk $<

# Build EMU database

$(ITS_DB_OUTPUT) &: $(ITS_DB_FILES)
	mkdir -p $(DB_DIR)
	cd $(DB_DIR) && emu build-database $(ITS_DB_NAME) \
		--sequences ../$(ITS_CONVERTED_FASTA) \
		--seq2tax ../$(ITS_SEQ2TAX) \
		--taxonomy-list ../$(ITS_TAXONOMY)

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
