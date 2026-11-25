# create_data

Perl scripts that prepare the input files for each Peptide Match data release from UniProtKB: protein sequences with isoforms, sequence description lines, organism names and taxonomy IDs, taxonomic groups and lineages, and cross-references to proteomics resources (PeptideAtlas, PRIDE, NIST and IEDB) and to UniRef100.

The scripts were run with each UniProtKB release on the production servers. They read release files from local paths, which must be changed for another environment.

**Legacy:** these inputs were used by the original Lucene/Solr index (see [index_data](../index_data/)). The current Elasticsearch indexer reads UniProtKB FASTA files directly; see the top-level [README](../README.md).
