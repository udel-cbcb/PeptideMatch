package org.proteininformationresource.peptidematch;

import org.junit.jupiter.api.Test;
import org.proteininformationresource.peptidematch.config.IndexConfig;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for IndexConfig.
 * Validates the Elasticsearch index mapping JSON is well-formed and contains expected fields.
 */
class IndexConfigTest {

    @Test
    void testIndexMappingIsValidJson() {
        String mapping = IndexConfig.getIndexMapping();
        assertNotNull(mapping);
        assertFalse(mapping.isEmpty());

        // Basic JSON validation — check it starts/ends with braces
        assertTrue(mapping.trim().startsWith("{"));
        assertTrue(mapping.trim().endsWith("}"));
    }

    @Test
    void testIndexMappingContainsAnalyzers() {
        String mapping = IndexConfig.getIndexMapping();
        assertTrue(mapping.contains("peptide_ngram"));
        assertTrue(mapping.contains("peptide_ngram_tokenizer"));
        assertTrue(mapping.contains("peptide_ngram_ltoi"));
        assertTrue(mapping.contains("l_to_i_filter"));
    }

    @Test
    void testIndexMappingContainsAllFields() {
        String mapping = IndexConfig.getIndexMapping();

        String[] expectedFields = {
                "ac", "proteinID", "proteinName", "organismName", "organismID",
                "geneName", "proteinEvidence", "sequenceVersion",
                "sptr", "isoform", "originalSeq", "length", "boost"
        };

        for (String field : expectedFields) {
            assertTrue(mapping.contains("\"" + field + "\""),
                    "Mapping should contain field: " + field);
        }
    }

    @Test
    void testNgramAnalyzerConfig() {
        String mapping = IndexConfig.getIndexMapping();
        assertTrue(mapping.contains("\"min_gram\": 3"));
        assertTrue(mapping.contains("\"max_gram\": 3"));
    }

    @Test
    void testIndexName() {
        assertEquals("peptidematch", IndexConfig.INDEX_NAME);
    }
}
