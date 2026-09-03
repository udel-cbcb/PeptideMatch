package org.proteininformationresource.peptidematch;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.GetResponse;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import org.junit.jupiter.api.*;
import org.proteininformationresource.peptidematch.config.ESClientFactory;
import org.proteininformationresource.peptidematch.config.IndexConfig;
import org.proteininformationresource.peptidematch.indexer.ESIndexer;
import org.proteininformationresource.peptidematch.search.ESSearchService;
import org.proteininformationresource.peptidematch.search.ESSearchService.SearchResult;
import org.proteininformationresource.peptidematch.search.MatchPositionFinder;

import java.io.IOException;
import java.io.StringReader;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration tests against a real Elasticsearch instance.
 * Requires ES running on localhost:9200 (or set ES_HOST/ES_PORT).
 *
 * Run with: mvn test -Dtest=ESSearchIntegrationTest -DfailIfNoTests=false
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class ESSearchIntegrationTest {

    private static ElasticsearchClient client;
    private static ESSearchService searchService;
    private static final String INDEX_NAME = IndexConfig.INDEX_NAME;
    private static final String TEST_AC = "P12345";
    private static final String TEST_SEQ = "MKTIIALSYIFCLVFA";

    @BeforeAll
    static void setUp() throws IOException {
        client = ESClientFactory.createClient();
        searchService = new ESSearchService(client);

        // Delete index if exists
        try {
            client.indices().delete(d -> d.index(INDEX_NAME));
        } catch (Exception e) {
            // index didn't exist, fine
        }

        // Create index with mapping
        String mappingJson = IndexConfig.getIndexMapping();
        client.indices().create(c -> c.index(INDEX_NAME).withJson(new StringReader(mappingJson)));
    }

    @AfterAll
    static void tearDown() throws IOException {
        if (client != null) {
            try {
                client.indices().delete(d -> d.index(INDEX_NAME));
            } catch (Exception e) {
                // ignore
            }
            client._transport().close();
        }
    }

    private Map<String, Object> buildTestDoc(String ac, String seq, String sptr) {
        Map<String, Object> doc = new LinkedHashMap<>();
        doc.put("ac", ac);
        doc.put("proteinID", ac + "_HUMAN");
        doc.put("proteinName", "Test protein " + ac);
        doc.put("originalSeq", seq);
        doc.put("lToiSeq", seq.replaceAll("L", "I"));
        doc.put("length", seq.length());
        doc.put("organismName", "Homo sapiens");
        doc.put("organismID", "9606");
        doc.put("taxongroupName", "Mammalia");
        doc.put("taxongroupID", "40674");
        doc.put("sptr", sptr);
        doc.put("isoform", "N");
        doc.put("nist", "Z");
        doc.put("peptideAtlas", "Z");
        doc.put("pride", "Z");
        doc.put("iedb", "Z");
        doc.put("fullLineage", "1, 33208, 9606");
        doc.put("shortLineage", "1, 33208, 9606");
        doc.put("uniref100", "Y");
        doc.put("boost", 1.0f);
        return doc;
    }

    @Test
    @Order(1)
    void testIndexAndRetrieveDocument() throws IOException {
        Map<String, Object> doc = buildTestDoc(TEST_AC, TEST_SEQ, "sp");

        client.index(i -> i
            .index(INDEX_NAME)
            .id(TEST_AC)
            .document(doc)
        );

        client.indices().refresh(r -> r.index(INDEX_NAME));

        GetResponse<Map> response = client.get(g -> g
            .index(INDEX_NAME)
            .id(TEST_AC),
            Map.class
        );

        assertTrue(response.found());
        Map<String, Object> source = response.source();
        assertEquals(TEST_AC, source.get("ac"));
        assertEquals(TEST_SEQ, source.get("originalSeq"));
        assertEquals("MKTIIAISYIFCIVFA", source.get("lToiSeq")); // L→I
    }

    @Test
    @Order(2)
    void testNGramSearch() throws IOException {
        // "IALS" should match MKTIIALSYIFCLVFA via trigram matching
        SearchResult result = searchService.searchByPeptide(
            "IALS", "", "", "", "", "N", 0, 10, "ac_asc");

        assertTrue(result.totalFound() > 0,
            "Should find at least one match for peptide IALS");

        boolean found = result.hits().stream()
            .anyMatch(h -> TEST_AC.equals(h.get("ac")));
        assertTrue(found, "Should find P12345 in search results");
    }

    @Test
    @Order(3)
    void testNGramSearchNoMatch() throws IOException {
        SearchResult result = searchService.searchByPeptide(
            "ZZZZZ", "", "", "", "", "N", 0, 10, "ac_asc");

        assertEquals(0, result.totalFound(),
            "Should not find any match for ZZZZZ");
    }

    @Test
    @Order(4)
    void testLeqiSearch() throws IOException {
        // Index a document with L at specific positions
        Map<String, Object> doc2 = buildTestDoc("Q99999", "AAALLLAA", "sp");

        client.index(i -> i.index(INDEX_NAME).id("Q99999").document(doc2));
        client.indices().refresh(r -> r.index(INDEX_NAME));

        // Search for "III" with L/I equivalence — should match AAALLLAA via lToiSeq
        SearchResult result = searchService.searchByPeptide(
            "III", "", "", "", "", "Y", 0, 10, "ac_asc");

        assertTrue(result.totalFound() > 0,
            "Should find Q99999 when searching III with L/I equivalence");

        boolean found = result.hits().stream()
            .anyMatch(h -> "Q99999".equals(h.get("ac")));
        assertTrue(found, "Q99999 should be in results for III with leqi=Y");
    }

    @Test
    @Order(5)
    void testMatchPositionFinderWithIndexedData() throws IOException {
        SearchResult result = searchService.searchByPeptide(
            "IALS", "", "", "", "", "N", 0, 10, "ac_asc");

        assertTrue(result.totalFound() > 0);

        for (Map<String, Object> hit : result.hits()) {
            if (TEST_AC.equals(hit.get("ac"))) {
                String seq = (String) hit.get("originalSeq");
                List<MatchPositionFinder.MatchRange> matches =
                    MatchPositionFinder.findMatches("IALS", seq, false);

                assertFalse(matches.isEmpty(), "Should find match positions");
                assertEquals(5, matches.get(0).start(), "IALS starts at position 5 in MKTIIALSYIFCLVFA");
                assertEquals(8, matches.get(0).end());
                break;
            }
        }
    }

    @Test
    @Order(6)
    void testIndexerWithRealFASTAFormat() throws IOException {
        ESIndexer indexer = new ESIndexer(client);

        String record = ">inttest INTTEST_TEST^|^^|^Integration test protein^|^^|^^|^Homo sapiens^|^9606^|^Mammalia^|^40674^|^Z^|^Z^|^Z^|^Z^|^1, 9606^|^1, 9606^|\nMKTIIALSYIFCLVFA";

        Map<String, Object> doc = indexer.parseRecord(record);
        assertNotNull(doc);

        client.index(i -> i
            .index(INDEX_NAME)
            .id((String) doc.get("ac"))
            .document(doc)
        );
        client.indices().refresh(r -> r.index(INDEX_NAME));

        SearchResult result = searchService.searchByPeptide(
            "SYIFCL", "", "", "", "", "N", 0, 10, "ac_asc");

        assertTrue(result.totalFound() > 0,
            "Should find the indexed FASTA record");
    }

    @Test
    @Order(7)
    void testSearchByAc() throws IOException {
        SearchResult result = searchService.searchById(TEST_AC, "");

        assertTrue(result.totalFound() > 0);
        assertEquals(TEST_AC, result.hits().get(0).get("ac"));
    }

    @Test
    @Order(8)
    void testCountByPeptide() throws IOException {
        long count = searchService.countByPeptide(
            "IALS", "", "", "", "", "N");

        assertTrue(count > 0, "Count should be > 0 for IALS");
    }

    @Test
    @Order(9)
    void testSearchWithOrganismFilter() throws IOException {
        SearchResult result = searchService.searchByPeptide(
            "IALS", "9606", "", "", "", "N", 0, 10, "ac_asc");

        assertTrue(result.totalFound() > 0);
        // All results should have organismID = 9606
        for (Map<String, Object> hit : result.hits()) {
            assertEquals("9606", hit.get("organismID"));
        }
    }

    @Test
    @Order(10)
    void testSearchWithSwissProtFilter() throws IOException {
        // All our test docs have sptr="sp", so filtering for SwissProt should return them
        SearchResult result = searchService.searchByPeptide(
            "IALS", "", "Y", "", "", "N", 0, 10, "ac_asc");

        assertTrue(result.totalFound() > 0);
        for (Map<String, Object> hit : result.hits()) {
            assertEquals("sp", hit.get("sptr"));
        }
    }
}
