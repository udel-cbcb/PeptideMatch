package org.proteininformationresource.peptidematch.config;

/**
 * Elasticsearch index mapping configuration for PeptideMatch.
 *
 * Defines the index name, analyzers, and field mappings for standard UniProt FASTA headers.
 *
 * Fields are derived from the UniProt KB FASTA definition line:
 * >db|UniqueIdentifier|EntryName ProteinName OS=OrganismName OX=OrganismIdentifier GN=GeneName PE=ProteinExistence SV=SequenceVersion
 */
public class IndexConfig {

    public static final String INDEX_NAME = "peptidematch";

    /**
     * Returns the Elasticsearch index mapping as a JSON string.
     *
     * Mapping design:
     * - originalSeq / lToiSeq: text fields with custom ngram analyzer (min=3, max=3)
     *   for exact substring matching via match_phrase queries
     * - All other fields: keyword (not analyzed) for exact match filtering
     */
    public static String getIndexMapping() {
        return """
                {
                  "settings": {
                    "number_of_shards": 4,
                    "number_of_replicas": 1,
                    "analysis": {
                      "analyzer": {
                        "peptide_ngram": {
                          "tokenizer": "peptide_ngram_tokenizer",
                          "filter": ["lowercase"]
                        },
                        "peptide_ngram_ltoi": {
                          "tokenizer": "peptide_ngram_tokenizer",
                          "filter": ["lowercase"]
                        }
                      },
                      "tokenizer": {
                        "peptide_ngram_tokenizer": {
                          "type": "ngram",
                          "min_gram": 3,
                          "max_gram": 3,
                          "token_chars": ["letter"]
                        }
                      }
                    }
                  },
                  "mappings": {
                    "properties": {
                      "ac":               { "type": "keyword" },
                      "proteinID":        { "type": "keyword" },
                      "proteinName":      { "type": "keyword" },
                      "organismName":     { "type": "keyword" },
                      "organismID":       { "type": "keyword" },
                      "geneName":         { "type": "keyword" },
                      "proteinEvidence":  { "type": "keyword" },
                      "sequenceVersion":  { "type": "keyword" },
                      "sptr":             { "type": "keyword" },
                      "isoform":          { "type": "keyword" },
                      "originalSeq":      { "type": "text", "analyzer": "peptide_ngram", "store": true },
                      "lToiSeq":          { "type": "text", "analyzer": "peptide_ngram_ltoi" },
                      "length":           { "type": "integer" },
                      "boost":            { "type": "float" }
                    }
                  }
                }
                """;
    }
}
