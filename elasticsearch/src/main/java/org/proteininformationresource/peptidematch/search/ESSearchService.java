package org.proteininformationresource.peptidematch.search;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.SortOrder;
import co.elastic.clients.elasticsearch._types.aggregations.Aggregate;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsAggregate;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsBucket;
import co.elastic.clients.elasticsearch._types.query_dsl.BoolQuery;
import co.elastic.clients.elasticsearch.core.CountRequest;
import co.elastic.clients.elasticsearch.core.CountResponse;
import co.elastic.clients.elasticsearch.core.SearchRequest;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.elasticsearch.core.search.TotalHits;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.proteininformationresource.peptidematch.config.IndexConfig;

/**
 * Elasticsearch-based peptide search service.
 *
 * Replaces the Solr-based PeptideMatchPhraseQuery classes found in:
 * - peptidematchapi2/PeptideMatchPhraseQuery.java
 * - peptidematchws/PeptideMatchPhraseQuery.java
 * - peptidematch_web/PeptidePhraseQuery.java
 *
 * Uses match_phrase queries on ngram-tokenized fields for exact substring matching.
 */
public class ESSearchService {

    private static final Logger logger = LoggerFactory.getLogger(ESSearchService.class);

    private final co.elastic.clients.elasticsearch.ElasticsearchClient client;

    public ESSearchService(co.elastic.clients.elasticsearch.ElasticsearchClient client) {
        this.client = client;
    }

    /**
     * Build filter clauses for search parameters.
     */
    private void addFilters(BoolQuery.Builder boolBuilder, String taxonids,
                            String swissprot, String isoform, String uniref100) {
        if (taxonids != null && !taxonids.isEmpty()) {
            String[] ids = taxonids.replaceAll("\\s", "").split(",");
            if (ids.length == 1) {
                boolBuilder.filter(f -> f.term(t -> t.field("organismID").value(ids[0])));
            } else {
                List<FieldValue> fieldValues = new ArrayList<>();
                for (String id : ids) {
                    fieldValues.add(FieldValue.of(id));
                }
                boolBuilder.filter(f -> f.terms(t -> t
                        .field("organismID")
                        .terms(tv -> tv.value(fieldValues))
                ));
            }
        }
        if ("Y".equals(swissprot)) {
            boolBuilder.filter(f -> f.term(t -> t.field("sptr").value("sp")));
        }
        if ("N".equals(isoform)) {
            boolBuilder.filter(f -> f.bool(b -> b.mustNot(m -> m.term(t -> t.field("isoform").value("Y")))));
        }
        if ("Y".equals(uniref100)) {
            boolBuilder.filter(f -> f.term(t -> t.field("uniref100").value("Y")));
        }
    }

    /**
     * Search for peptides matching a query peptide sequence.
     */
    public SearchResult searchByPeptide(String peptide, String taxonids,
                                        String swissprot, String isoform, String uniref100,
                                        String leqi, int offset, int size, String sortBy) throws IOException {
        boolean leqiFlag = "Y".equals(leqi);
        String queryField = leqiFlag ? "lToiSeq" : "originalSeq";
        String queryText = leqiFlag ? peptide.replaceAll("L", "I") : peptide;

        BoolQuery.Builder boolBuilder = new BoolQuery.Builder();
        boolBuilder.must(m -> m.matchPhrase(mp -> mp
                .field(queryField)
                .query(queryText)
                .analyzer("peptide_ngram")
        ));
        addFilters(boolBuilder, taxonids, swissprot, isoform, uniref100);

        SearchRequest.Builder searchBuilder = new SearchRequest.Builder()
                .index(IndexConfig.INDEX_NAME)
                .query(q -> q.bool(boolBuilder.build()))
                .from(offset)
                .trackTotalHits(t -> t.enabled(true));

        if (size > 0) {
            searchBuilder.size(size);
        } else {
            searchBuilder.size(10000);
        }

        applySorting(searchBuilder, sortBy);

        SearchResponse<Map> response = client.search(searchBuilder.build(), Map.class);

        List<Map<String, Object>> hits = new ArrayList<>();
        for (Hit<Map> hit : response.hits().hits()) {
            Map<String, Object> source = hit.source();
            if (source != null) {
                hits.add(source);
            }
        }

        TotalHits total = response.hits().total();
        long totalFound = total != null ? total.value() : 0;

        return new SearchResult(totalFound, response.took(), hits);
    }

    /**
     * Search grouped by organism, returning match counts per organism.
     */
    public Map<String, Long> searchByPeptideWithGroup(String peptide, String uniref100,
                                                       String leqi) throws IOException {
        boolean leqiFlag = "Y".equals(leqi);
        String queryField = leqiFlag ? "lToiSeq" : "originalSeq";
        String queryText = leqiFlag ? peptide.replaceAll("L", "I") : peptide;

        BoolQuery.Builder boolBuilder = new BoolQuery.Builder();
        boolBuilder.must(m -> m.matchPhrase(mp -> mp
                .field(queryField)
                .query(queryText)
                .analyzer("peptide_ngram")
        ));
        if ("Y".equals(uniref100)) {
            boolBuilder.filter(f -> f.term(t -> t.field("uniref100").value("Y")));
        }

        SearchRequest.Builder searchBuilder = new SearchRequest.Builder()
                .index(IndexConfig.INDEX_NAME)
                .query(q -> q.bool(boolBuilder.build()))
                .size(0)
                .trackTotalHits(t -> t.enabled(true))
                .aggregations("by_organism", a -> a.terms(t -> t
                        .field("organismID")
                        .size(10000)
                ));

        SearchResponse<Map> response = client.search(searchBuilder.build(), Map.class);

        Map<String, Long> groupCounts = new LinkedHashMap<>();
        Aggregate agg = response.aggregations().get("by_organism");
        if (agg != null) {
            StringTermsAggregate termsAgg = agg.sterms();
            if (termsAgg != null) {
                for (StringTermsBucket bucket : termsAgg.buckets().array()) {
                    String orgId = bucket.key().stringValue();
                    long count = bucket.docCount();
                    groupCounts.put(orgId, count);
                }
            }
        }

        return groupCounts;
    }

    /**
     * Search by protein accession ID.
     */
    public SearchResult searchById(String ac, String uniref100) throws IOException {
        BoolQuery.Builder boolBuilder = new BoolQuery.Builder();
        boolBuilder.must(m -> m.term(t -> t.field("ac").value(ac)));
        if ("Y".equals(uniref100)) {
            boolBuilder.filter(f -> f.term(t -> t.field("uniref100").value("Y")));
        }

        SearchRequest request = new SearchRequest.Builder()
                .index(IndexConfig.INDEX_NAME)
                .query(q -> q.bool(boolBuilder.build()))
                .size(100)
                .trackTotalHits(t -> t.enabled(true))
                .build();

        SearchResponse<Map> response = client.search(request, Map.class);

        List<Map<String, Object>> hits = new ArrayList<>();
        for (Hit<Map> hit : response.hits().hits()) {
            Map<String, Object> source = hit.source();
            if (source != null) {
                hits.add(source);
            }
        }

        TotalHits total = response.hits().total();
        long totalFound = total != null ? total.value() : 0;
        return new SearchResult(totalFound, response.took(), hits);
    }

    /**
     * Count total matching documents for a peptide query.
     */
    public long countByPeptide(String peptide, String taxonids, String swissprot,
                                String isoform, String uniref100, String leqi) throws IOException {
        boolean leqiFlag = "Y".equals(leqi);
        String queryField = leqiFlag ? "lToiSeq" : "originalSeq";
        String queryText = leqiFlag ? peptide.replaceAll("L", "I") : peptide;

        BoolQuery.Builder boolBuilder = new BoolQuery.Builder();
        boolBuilder.must(m -> m.matchPhrase(mp -> mp
                .field(queryField)
                .query(queryText)
                .analyzer("peptide_ngram")
        ));
        addFilters(boolBuilder, taxonids, swissprot, isoform, uniref100);

        CountRequest request = new CountRequest.Builder()
                .index(IndexConfig.INDEX_NAME)
                .query(q -> q.bool(boolBuilder.build()))
                .build();

        CountResponse response = client.count(request);
        return response.count();
    }

    private void applySorting(SearchRequest.Builder builder, String sortBy) {
        if (sortBy == null || sortBy.isEmpty()) {
            builder.sort(s -> s.field(f -> f.field("ac").order(SortOrder.Asc)));
            return;
        }
        switch (sortBy) {
            case "ac_asc" -> builder.sort(s -> s.field(f -> f.field("ac").order(SortOrder.Asc)));
            case "ac_desc" -> builder.sort(s -> s.field(f -> f.field("ac").order(SortOrder.Desc)));
            case "proteinID_asc" -> builder.sort(s -> s.field(f -> f.field("proteinID").order(SortOrder.Asc)));
            case "proteinID_desc" -> builder.sort(s -> s.field(f -> f.field("proteinID").order(SortOrder.Desc)));
            case "proteinName_asc" -> builder.sort(s -> s.field(f -> f.field("proteinName").order(SortOrder.Asc)));
            case "proteinName_desc" -> builder.sort(s -> s.field(f -> f.field("proteinName").order(SortOrder.Desc)));
            case "organismName_asc" -> builder.sort(s -> s.field(f -> f.field("organismName").order(SortOrder.Asc)));
            case "organismName_desc" -> builder.sort(s -> s.field(f -> f.field("organismName").order(SortOrder.Desc)));
            case "length_asc" -> builder.sort(s -> s.field(f -> f.field("length").order(SortOrder.Asc)));
            case "length_desc" -> builder.sort(s -> s.field(f -> f.field("length").order(SortOrder.Desc)));
            case "proteomic_desc" -> builder.sort(s -> s.field(f -> f.field("peptideAtlas").order(SortOrder.Desc)));
            default -> builder.sort(s -> s.field(f -> f.field("ac").order(SortOrder.Asc)));
        }
    }

    /**
     * Search result container.
     */
    public record SearchResult(long totalFound, long tookMs, List<Map<String, Object>> hits) {}
}
