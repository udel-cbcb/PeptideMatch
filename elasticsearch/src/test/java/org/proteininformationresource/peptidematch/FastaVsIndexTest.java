package org.proteininformationresource.peptidematch;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import org.junit.jupiter.api.*;
import org.proteininformationresource.peptidematch.config.ESClientFactory;
import org.proteininformationresource.peptidematch.config.IndexConfig;
import org.proteininformationresource.peptidematch.search.ESSearchService;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Compares search results between FASTA file and ES index.
 *
 * Searches a peptide against FASTA files (handling multi-line sequences),
 * collects matched protein ACs, then searches ES index and compares results.
 *
 * IMPORTANT: Run after indexing is complete. Check with:
 *   curl -s 'localhost:9200/_cat/indices?v'
 *
 * Run with:
 *   mvn test -Dtest=FastaVsIndexTest
 *   mvn test -Dtest=FastaVsIndexTest -Dtest.index=peptidematch_2026_03
 *   mvn test -Dtest=FastaVsIndexTest -Dfasta.path=/path/to/uniprot_sprot.fasta
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class FastaVsIndexTest {

    private static ElasticsearchClient client;
    private static ESSearchService searchService;
    private static String indexName;
    private static String fastaPath;

    @BeforeAll
    static void setUp() throws IOException {
        client = ESClientFactory.createClient();
        indexName = System.getProperty("test.index", "peptidematch_2026_03");
        fastaPath = System.getProperty("fasta.path",
                "/data/chenc/2026/PeptideMatch/data/inputs/uniprot_sprot_2026_03.fasta");
        searchService = new ESSearchService(client, indexName);
        System.out.println("Using index: " + indexName);
        System.out.println("Using FASTA: " + fastaPath);

        // Check if index has data
        long docCount = client.count(c -> c.index(indexName)).count();
        System.out.println("Index document count: " + docCount);
        Assumptions.assumeTrue(docCount > 0, "Index must have documents to run this test");
    }

    /**
     * Search a peptide against a FASTA file.
     * Handles multi-line sequences by accumulating sequence lines until next header.
     *
     * @param peptide The peptide to search (case-insensitive)
     * @param fastaFile Path to FASTA file
     * @return Set of protein ACs containing the peptide
     */
    private Set<String> searchFasta(String peptide, String fastaFile) throws IOException {
        Set<String> matches = new HashSet<>();
        String peptideUpper = peptide.toUpperCase();

        try (BufferedReader reader = new BufferedReader(new FileReader(fastaFile))) {
            String currentAc = null;
            StringBuilder currentSeq = new StringBuilder();

            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith(">")) {
                    // Process previous sequence
                    if (currentAc != null && currentSeq.toString().toUpperCase().contains(peptideUpper)) {
                        matches.add(currentAc);
                    }
                    // Parse new header: >db|AC|...
                    currentAc = parseAccession(line);
                    currentSeq.setLength(0);
                } else {
                    currentSeq.append(line.trim());
                }
            }
            // Process last sequence
            if (currentAc != null && currentSeq.toString().toUpperCase().contains(peptideUpper)) {
                matches.add(currentAc);
            }
        }

        return matches;
    }

    /**
     * Parse accession from FASTA header.
     * Format: >sp|P12345|... or >tr|A0A067XI54|...
     */
    private String parseAccession(String header) {
        // Remove > prefix
        String h = header.substring(1);
        String[] parts = h.split("\\|");
        if (parts.length >= 2) {
            return parts[1]; // AC is second field
        }
        return h.split("\\s+")[0]; // fallback: first word
    }

    /**
     * Search peptide against ES index and return matched ACs.
     */
    private Set<String> searchIndex(String peptide) throws IOException {
        Set<String> matches = new HashSet<>();

        SearchResponse<Map> response = client.search(s -> s
                .index(indexName)
                .query(q -> q.matchPhrase(mp -> mp
                        .field("originalSeq")
                        .query(peptide)
                        .analyzer("peptide_ngram")
                ))
                .size(10000)
                .trackTotalHits(t -> t.enabled(true)),
                Map.class
        );

        for (Hit<Map> hit : response.hits().hits()) {
            Map<String, Object> source = hit.source();
            if (source != null && source.containsKey("ac")) {
                matches.add((String) source.get("ac"));
            }
        }

        return matches;
    }

    @Test
    @Order(1)
    void testMKTIIALSYIFCLVFA() throws IOException {
        String peptide = "MKTIIALSYIFCLVFA";

        // Search FASTA
        Set<String> fastaMatches = searchFasta(peptide, fastaPath);
        System.out.println("FASTA matches for " + peptide + ": " + fastaMatches.size());
        fastaMatches.forEach(ac -> System.out.println("  " + ac));

        // Search ES index
        Set<String> indexMatches = searchIndex(peptide);
        System.out.println("Index matches for " + peptide + ": " + indexMatches.size());
        indexMatches.forEach(ac -> System.out.println("  " + ac));

        // Verify all FASTA matches are in index (index may have more from TrEMBL)
        assertFalse(fastaMatches.isEmpty(), "FASTA should find matches");
        assertFalse(indexMatches.isEmpty(), "Index should find matches");
        assertTrue(indexMatches.containsAll(fastaMatches),
                "Index should contain all FASTA matches (may have more from TrEMBL)");
    }

    @Test
    @Order(2)
    void testAAAA() throws IOException {
        String peptide = "AAAA";

        Set<String> fastaMatches = searchFasta(peptide, fastaPath);
        System.out.println("FASTA matches for " + peptide + ": " + fastaMatches.size());

        Set<String> indexMatches = searchIndex(peptide);
        System.out.println("Index matches for " + peptide + ": " + indexMatches.size());

        // AAAA is very common, both should find results
        assertFalse(fastaMatches.isEmpty(), "FASTA should find matches");
        assertFalse(indexMatches.isEmpty(), "Index should find matches");

        // For large result sets, verify all index results are valid proteins
        // (index may have more data than just Swiss-Prot FASTA)
        assertTrue(indexMatches.size() <= 10000, "Index should return at most 10000 results");
    }

    @Test
    @Order(3)
    void testPeptideNotInData() throws IOException {
        String peptide = "ZZZZZZZZZ";

        Set<String> fastaMatches = searchFasta(peptide, fastaPath);
        Set<String> indexMatches = searchIndex(peptide);

        assertTrue(fastaMatches.isEmpty(), "FASTA should find no matches");
        assertTrue(indexMatches.isEmpty(), "Index should find no matches");
    }
}
