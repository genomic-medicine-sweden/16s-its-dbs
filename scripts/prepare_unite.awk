# This script converts a UNITE-styled FASTA file into the input files required
# as input for emu build-database. It extracts taxonomic lineage from the fifth
# pipe-separated field in each FASTA sequence header, assigns a unique tax_id
# to each distinct lineage, and assigns each sequence a new ID using the
# supplied database name.
#
# Three files are generated in the specified output directory:
#   emu-<db_name>-input.fa:     FASTA file with renamed sequence IDs.
#   seq2tax.map:                Mapping between equence IDs and tax IDs.
#   tax.tsv:                    Taxonomy table with ranks from species to superkingdom.
#
# Required arguments:
#   -v db_name=DB_NAME          Name used as the prefix for sequence IDs.
#   -v output_dir=OUTPUT_DIR    Directory where the output files are written.
#
# Usage:
#   awk -v db_name=DB_NAME -v output_dir=OUTPUT_DIR -f prepare_unite.awk input.fasta

BEGIN {
    if (db_name == "" || output_dir == "" ) {
        print "Usage: awk -v db_name=DB_NAME -v output_dir=OUTPUT_DIR -f prepare_unite.awk input.fasta"
        exit 1
    }

    fasta_out = output_dir "/emu-" db_name "-input.fa"
    map_out = output_dir "/seq2tax.map"
    tax_out = output_dir "/tax.tsv"

    # Write seq2tax header
    print "seq_id\ttax_id" > map_out
}

# Process FASTA headers
/^>/ {
    # Extract original sequence header and remove whitespace
    seq_header = substr($0, 2)
    sub(/[[:space:]].*/, "", seq_header)

    # Extract taxonomic lineage (fifth pipe-separated field)
    split(seq_header, fields, /\|/)
    lineage = fields[5]

    # Assign tax_id to new lineages
    if (!(lineage in tax_ids)) {
        tax_ids[lineage] = ++tax_counter # Pre-increment tax_counter and assign its value as the tax_id
        lineages[tax_counter] = lineage
    }

    # Assign new sequence ID
    seq_id = db_name "_" ++seq_counter # Pre-increment seq_counter and append its value to db_name

    # Write renamed FASTA header
    print ">" seq_id " " seq_header > fasta_out

    # Write sequence-to-taxonomy mapping
    print seq_id "\t" tax_ids[lineage] > map_out

    next # Prevent the header from being processed again by the general block below
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
        # Split the lineage by ';' and store the resulting ranks in the ranks array
        n = split(lineages[i], ranks, ";")

        # Remove rank prefixes (e.g. k__, p__, g__)
        for (j = 1; j <= n; j++) {
            sub(/^[^_]__/, "", ranks[j])
        }

        # Write ranks in reverse order
        print i "\t" ranks[7] "\t" ranks[6] "\t" ranks[5] "\t" \
            ranks[4] "\t" ranks[3] "\t" ranks[2] "\t" ranks[1] > tax_out
    }

    close(fasta_out)
    close(map_out)
    close(tax_out)
}
