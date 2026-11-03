
BEGIN {
    fasta_out = output_dir "/emu-" db_name "-input.fa"
    map_out = output_dir "/seq2tax.map"
    tax_out = output_dir "/tax.tsv"

    # Write seq2tax header
    print "seq_id\ttax_id" > map_out
}

# Process FASTA headers
/^>/ {
    # Extract original sequence ID
    rid = substr($0, 2)
    sub(/[[:space:]].*/, "", rid)

    # Extract taxonomic lineage (fifth pipe-separated field)
    split(rid, fields, /\|/)
    lineage = fields[5]

    # Assign tax_id to new lineages
    if (!(lineage in tax_ids)) {
        tax_ids[lineage] = ++tax_counter
        lineages[tax_counter] = lineage
    }

    # Assign new sequence ID
    seq_id = db_name "_" ++seq_counter

    # Write renamed FASTA header
    print ">" seq_id " " rid > fasta_out

    # Write sequence-to-taxonomy mapping
    print seq_id "\t" tax_ids[lineage] > map_out

    next
}

# Write FASTA sequence lines unchanged
{
    print > fasta_out
}

END {
    # Write taxonomy header
    print "tax_id\tspecies\tgenus\tfamily\torder\tclass\tphylum\tsuperkingdom" > tax_out

    # Write one row per unique lineage
    for (i = 1; i <= tax_counter; i++) {
        n = split(lineages[i], ranks, ";")

        # Remove rank prefixes (e.g. k__, p__, g__)
        for (j = 1; j <= n; j++) {
            sub(/^[^_]*__/, "", ranks[j])
        }

        # Write ranks in reverse order
        print i "\t" ranks[7] "\t" ranks[6] "\t" ranks[5] "\t" \
            ranks[4] "\t" ranks[3] "\t" ranks[2] "\t" ranks[1] > tax_out
    }

    close(fasta_out)
    close(map_out)
    close(tax_out)
}