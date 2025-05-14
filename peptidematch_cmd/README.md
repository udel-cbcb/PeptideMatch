# PeptideMatchCMD

A command line tool allows users to query the peptide sequences against their own customized protein sequence database.

The tool provides two major functionalities:

1. Given a protein sequence database in FASTA format, create the Lucene index for it.
2. Query the peptide sequences against the above index. The query can be:
- A peptide sequence or a comma-separated list of peptide sequences or
- A file in either FASTA format or a list of peptide sequences, one sequence per line.