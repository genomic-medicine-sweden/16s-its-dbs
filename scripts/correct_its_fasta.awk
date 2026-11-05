# Read corrections from CSV
FNR == NR {
    # Skip CSV header
    if (FNR == 1) {
        next
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
        found[accession] = 1

        old_taxonomy = corrections[accession]
        new_taxonomy = replacements[accession]

        # Check that the expected old taxonomy exists
        position = index(fields[5], old_taxonomy)
        
        if (position) {
            # Replace the taxonomy lineage
            fields[5] = substr(fields[5], 1, position -1) \
            new_taxonomy \
            substr(fields[5], position + length(old_taxonomy))

            # Update the sequence name using the new species name
            rank_count = split(new_taxonomy, ranks, ";")
            fields[1] = ranks[rank_count]
            sub(/^s__/, "", fields[1])
            fields[1] = ">" fields[1]

            applied[accession] = 1

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
    next
}

# Print all non-header lines unchanged
{
    print
}

END {
    # Report corrections whose accession IDs were not found
    for (accession in corrections) {
        if (!(accession in found)) {
            print "WARNING: Accession " accession \
            " not found in FASTA" > "/dev/stderr"
        }
    }
}