# Stockholm ITS database modifications

## Overview

This directory contains site-specific modifications to the Unite ITS
reference database used by the TRANA pipeline. The modifications
consist of corrections to existing database entries and additions
of new sequences that are not present in the original database.

The files in this directory define which corrections and additions
should be applied. The scripts used to process these files are
located in the repository's `scripts/` directory and are called
through the Makefile in this directory.

These modifications are intended to account for site-specific
requirements while keeping the underlying database preparation
workflow general and reusable.

## Dependencies

The following tools are required to run the database build:

- **GNU Make** – for running the Makefile.
- **jq** – for extracting the database download URL from the PlutoF API response.
- **Emu** – for building the final reference database.

## Usage

This Makefile is run from the repository root using:

```bash
make -C its-stockholm/ its
```

## Corrections

The `corrections.csv` file contains corrections to existing
database entries.

Corrections are identified by accession ID and specify the
original taxonomy and the replacement taxonomy. The original
taxonomy is checked before applying a correction to ensure that
the intended database entry is being modified. If the accession
is found but its existing taxonomy does not match the expected
original taxonomy, the correction is skipped and a warning is
issued.

**Corrections included and rationale:**

| Accession ID | Correction | Reason |
|---|---|---|
| MK881172 | Oligophagozyma_castellii -> Candida_tropicalis | Wrong taxonomy assigned by Unite |
| JN942635 | Oligophagozyma_castellii -> Candida_tropicalis | Wrong taxonomy assigned by Unite |
| EU594608 | Oligophagozyma_castellii -> Candida_tropicalis | Wrong taxonomy assigned by Unite |
| KJ707052 | Oligophagozyma_castellii -> Candida_tropicalis | Wrong taxonomy assigned by Unite |
| ON248033 | Oligophagozyma_castellii -> Candida_tropicalis | Wrong taxonomy assigned by Unite |
| MH918805 | Oligophagozyma_castellii -> Candida_tropicalis | Wrong taxonomy assigned by Unite |
| KJ706257 | Oligophagozyma_castellii -> Candida_tropicalis | Wrong taxonomy assigned by Unite |
| EF568042 | Oligophagozyma_castellii -> Candida_tropicalis | Wrong taxonomy assigned by Unite |

## Additions

The `additions.fa` file contains sequences that are added to the
original Unite ITS reference database.

**Additions included and rationale:**

| Identifier | Species | Reason |
|---|---|---|
| LC508728 | Trichophyton indotineae | Missing species in original database |
| Palmer_Mock_1 | Synthetic_spike_A | Synthetic spike-in species |
| Palmer_Mock_3 | Synthetic_spike_B | Synthetic spike-in species |
| Palmer_Mock_7 | Synthetic_spike_C | Synthetic spike-in species |

## Database preparation

The Makefile in this directory coordinates the site-specific
modifications and calls the scripts `prepare_unite.awk` and
`correct_its.fasta.awk` located in the repository's `scripts/`
directory.

The database preparation consists of the following steps:

1. **Apply corrections:** The original database FASTA is
   processed using `correct-its-fasta.awk`, applying the
   corrections specified in `corrections.csv`.
2. **Add sequences:** The sequences in `additions.fa` are
   appended to the corrected FASTA file to produce a combined
   FASTA file.
3. **Prepare database input:** The combined FASTA file is
   processed using `prepare_unite.awk` to generate the input
   files required by `emu build-database`.
4. **Build database:** Emu uses the generated FASTA,
   sequence-to-taxonomy mapping, and taxonomy list to build
   the final database.

The intermediate files generated during preparation include:

- `corrected.fasta` – Original database FASTA with site-specific
  corrections applied.
- `combined.fasta` – Corrected FASTA with the additional
  sequences appended.
- `emu-<database-name>-input.fa` – FASTA formatted for Emu
  database construction.
- `seq2tax.map` – Mapping between sequence IDs and taxonomy IDs.
- `tax.tsv` – Taxonomy information required by Emu.

## Maintenance

Site-specific corrections and additions should be documented
in this README when introduced, including the reason for each
modification.

When adding a correction, ensure that the accession ID and
expected original taxonomy are correct.

When adding a new sequence, ensure that its header contains the
required taxonomic information and that the sequence is
appropriately represented in the database.

The general-purpose scripts should remain independent of
site-specific modifications. Changes to those scripts should
therefore be made in the shared `scripts/` directory rather
than introducing site-specific processing logic here.

## References

The synthetic spike species included in `additions.fa` are based on
the following publication:

- Palmer, J. M., Jusino, M. A., Banik, M. T., & Lindner, D. L. (2018).
  Non-biological synthetic spike-in controls and the AMPtk software
  pipeline improve mycobiome data. *PeerJ, 6*, e4925.
  https://doi.org/10.7717/peerj.4925