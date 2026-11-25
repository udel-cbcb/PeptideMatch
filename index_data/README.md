# index_data

**Legacy:** Java programs (`javaprogram/`) that built the n-gram Lucene index used by the original Solr-based Peptide Match service, for example `NGramIndexer`, which indexes the sequence file prepared by [create_data](../create_data/) with 3-grams.

The current service uses Elasticsearch; to build its index, follow the top-level [README](../README.md) (`update-index.sh` and the `elasticsearch` module).
