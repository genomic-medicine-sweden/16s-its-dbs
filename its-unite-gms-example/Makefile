# Database build Makefile
#
# Build scripts for 16S and ITS reference databases.

# ------------------------------------------------------------------------------
#  Misc defaults
# ------------------------------------------------------------------------------

.DEFAULT_GOAL := all

.ONESHELL:
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

.DELETE_ON_ERROR:

# Configuration
BUILD_DIR ?= build

# Database build targets
.PHONY: all its clean help

all: its

its: $(BUILD_DIR)/sh_general_release_dynamic_19.02.2025_dev.fasta

ITS_DB_DOI := 10.15156/BIO/3301229

$(BUILD_DIR)/itsdb.tgz:
	mkdir -p build
	curl -fsSLG "https://api.plutof.ut.ee/v1/public/dois/" \
	  --data-urlencode "format=vnd.api+json" \
	  --data-urlencode "identifier=$(ITS_DB_DOI)" \
	  | jq -er '.data[0].attributes.media[0].url' \
	  | xargs -r curl -fL --retry 3 -o $@

$(BUILD_DIR)/sh_general_release_dynamic_19.02.2025_dev.fasta: | $(BUILD_DIR)/itsdb.tgz
	tar -C $(BUILD_DIR) -zxvf $(word 1, $|)

define CORRECT_FASTA_SCRIPT
iter=0
while IFS=, read -r search_for search replace; do
	if [ $${iter} -gt 0 ]; then
		echo "Search for: $${search_for}, Search: $${search}, Replace: $${replace}, Iter: $${iter}.";
	fi;
	iter=$$(($${iter}+1));
done < corrections.csv
endef

%.corrected.fasta: %.fasta
	bash -c '$(CORRECT_FASTA_SCRIPT)' > $@

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

