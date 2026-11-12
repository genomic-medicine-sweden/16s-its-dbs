# This script applies taxonomy corrections to a UNITE-styled FASTA file using
# a CSV file containing accession IDs, expected original taxonomies, and
# replacement taxonomies. It checks that the expected original taxonomy
# matches before applying a correction, replaces the taxonomy lineage, and
# updates the sequence name to the new species name while preserving all
# other header fields and sequence lines.
#
# Corrections that cannot be applied are reported as warnings:
#   - Accession IDs not found in the FASTA file.
#   - Accession IDs where the expected original taxonomy does not match.
#
# Required input files:
#   corrections.csv: CSV file with three columns:
#       search_for: NCBI Accession ID to search for (second pipe-separated header field).
#       search:     Expected original taxonomy lineage.
#       replace:    Replacement taxonomy lineage.
#   input.fasta:    FASTA file to apply corrections to.
#
# Usage:
#   awk -f correct-its-fasta.awk corrections.csv input.fasta

BEGIN {
    if (ARGC != 3) {
        print "Usage: awk -f correct-its-fasta.awk corrections.csv input.fasta"
        exit 1
    }
}

# Read corrections from the first input file (CSV)
FNR == NR {
    # Skip CSV header
    if (FNR == 1) {
        next # Skip the remaining rules and read the next CSV row
    }

    # Skip empty lines
    if ($0 == "") {
        next
    }

    # Split CSV columns
    split($0, columns, ",")

    # Remove optional quotes and surrounding whitespace
    for (i = 1; i <= 3; i++) {
        gsub(/^[ \t]*"/, "", columns[i])
        gsub(/^[ \t]*$/, "", columns[i])
        gsub(/^[ \t]+|[ \t]+$/, "", columns[i])
        sub(/\r$/, "", columns[i])
    }

    search_for = columns[1]
    search = columns[2]
    replace = columns[3]

    corrections[search_for] = search
    replacements[search_for] = replace

    next
}

# Process FASTA headers
/^>/ {
    n = split($0, fields, /\|/)

    # Extract accession ID (second pipe-separated field)
    accession = fields[2]

    if (accession in corrections) {
        found[accession] = 1 # Track that the accession exists in the FASTA

        old_taxonomy = corrections[accession]
        new_taxonomy = replacements[accession]

        # Check that the expected old taxonomy exists
        position = index(fields[5], old_taxonomy)
        
        if (position) {
            # Replace the old taxonomy substring with the new one while preserving the rest of the field
            fields[5] = substr(fields[5], 1, position -1) \
            new_taxonomy \
            substr(fields[5], position + length(old_taxonomy))

            # Split the new taxonomy by ';' and store the resulting ranks in the ranks array
            rank_count = split(new_taxonomy, ranks, ";") #

            # Replace the original sequence name with the species name from the last rank
            fields[1] = ranks[rank_count]

            # Remove the species rank prefix
            sub(/^s__/, "", fields[1])

            # Restore the FASTA header marker (>) before the new sequence name
            fields[1] = ">" fields[1]

            print "Corrected " accession > "/dev/stderr"
        } else {
            print "WARNING: Skipping " accession \
            ": expected taxonomy not found" > "/dev/stderr"
        }
    }

    # Reconstruct header, preserving all other fields
    header = fields[1]

    for (i =2; i <= n; i++) {
        header = header "|" fields[i]
    }

    print header
    next # Prevent the header from being printed again by the general rule
}

# Print all non-header lines unchanged
{
    print
}

END {
    # Report corrections whose accession IDs were never found in the FASTA
    for (accession in corrections) {
        if (!(accession in found)) {
            print "WARNING: Accession " accession \
            " not found in FASTA" > "/dev/stderr"
        }
    }
}
