package org.proteininformationresource.peptidematch.config;

/**
 * Elasticsearch index mapping configuration for PeptideMatch.
 *
 * Defines the index name, analyzers, and field mappings that mirror
 * the original Solr schema used by PeptideMatch.
 */
public class IndexConfig {

    public static final String INDEX_NAME = "peptidematch";

    /**
     * Returns the Elasticsearch index mapping as a JSON string.
     *
     * Mapping design:
     * - originalSeq / lToiSeq: text fields with custom ngram analyzer (min=3, max=3)
     *   for exact substring matching via match_phrase queries
     * - fullLineage / shortLineage: text fields with standard analyzer for taxonomy search
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
                        },
                        "lineage_analyzer": {
                          "tokenizer": "whitespace",
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
                      "taxongroupName":   { "type": "keyword" },
                      "taxongroupID":     { "type": "keyword" },
                      "nist":             { "type": "keyword" },
                      "peptideAtlas":     { "type": "keyword" },
                      "pride":            { "type": "keyword" },
                      "iedb":             { "type": "keyword" },
                      "fullLineage":      { "type": "text", "analyzer": "lineage_analyzer" },
                      "shortLineage":     { "type": "text", "analyzer": "lineage_analyzer" },
                      "uniref100":        { "type": "keyword" },
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
