package org.proteininformationresource.peptidematch.indexer;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.Map;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.BulkRequest;
import co.elastic.clients.elasticsearch.core.BulkResponse;
import co.elastic.clients.elasticsearch.core.bulk.BulkResponseItem;
import co.elastic.clients.elasticsearch.indices.CreateIndexRequest;
import co.elastic.clients.elasticsearch.indices.DeleteIndexRequest;
import co.elastic.clients.elasticsearch.indices.ExistsRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.proteininformationresource.peptidematch.config.ESClientFactory;
import org.proteininformationresource.peptidematch.config.IndexConfig;

/**
 * Elasticsearch indexer for PeptideMatch.
 *
 * Replaces NGramIndexer.java from index_data/javaprogram/.
 * Reads the enriched FASTA-format input (output of create_data pipeline)
 * and indexes documents into Elasticsearch.
 *
 * Key differences from the Solr indexer:
 * - Uses ES BulkProcessor instead of Lucene IndexWriter
 * - NGram tokenization is handled by ES analyzer (no custom Java analyzer needed at index time)
 * - Document boost is stored as a field (ES handles scoring via function_score if needed)
 * - L→I substitution happens at field-value level (same as before)
 */
public class ESIndexer {

    private static final Logger logger = LoggerFactory.getLogger(ESIndexer.class);
    private static final int BULK_BATCH_SIZE = 5000;
    private static final DecimalFormat formatter = new DecimalFormat("0000000000");

    private final ElasticsearchClient client;
    private long indexedCount = 0;

    public ESIndexer(ElasticsearchClient client) {
        this.client = client;
    }

    /**
     * Create or recreate the ES index.
     */
    public void createIndex(boolean deleteExisting) throws IOException {
        boolean exists = client.indices().exists(ExistsRequest.of(e -> e.index(IndexConfig.INDEX_NAME))).value();
        if (exists) {
            if (deleteExisting) {
                logger.info("Deleting existing index '{}'...", IndexConfig.INDEX_NAME);
                client.indices().delete(DeleteIndexRequest.of(d -> d.index(IndexConfig.INDEX_NAME)));
            } else {
                logger.info("Index '{}' already exists, skipping creation.", IndexConfig.INDEX_NAME);
                return;
            }
        }

        logger.info("Creating index '{}'...", IndexConfig.INDEX_NAME);
        String mappingJson = IndexConfig.getIndexMapping();
        client.indices().create(CreateIndexRequest.of(c -> c
                .index(IndexConfig.INDEX_NAME)
                .withJson(new java.io.StringReader(mappingJson))
        ));
        logger.info("Index '{}' created successfully.", IndexConfig.INDEX_NAME);
    }

    /**
     * Index data from an enriched FASTA file.
     *
     * Expected format:
     * >AC PROTEIN_ID^|^^|^PROTEIN_NAME^|^^|^^|^ORGANISM_NAME^|^TAXON_ID^|^TAXGROUP_NAME^|^TAXGROUP_ID^|^NIST^|^ATLAS^|^PRIDE^|^IEDB^|^FULL_LINEAGE^|^SHORT_LINEAGE^|^UNIREF100_AC
     * SEQUENCE
     */
    public void indexDataFile(File dataFile) throws IOException {
        if (!dataFile.exists()) {
            throw new IOException("Data file does not exist: " + dataFile);
        }

        long startTime = System.currentTimeMillis();
        logger.info("Starting indexing from '{}'...", dataFile.getName());

        try (BufferedReader br = new BufferedReader(new FileReader(dataFile))) {
            BulkRequest.Builder bulkBuilder = new BulkRequest.Builder();
            int batchCount = 0;

            StringBuilder record = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                if (line.startsWith(">")) {
                    if (record.length() > 0) {
                        Map<String, Object> doc = parseRecord(record.toString());
                        if (doc != null) {
                            addBulkDoc(bulkBuilder, doc);
                            batchCount++;
                            indexedCount++;

                            if (batchCount >= BULK_BATCH_SIZE) {
                                executeBulk(bulkBuilder);
                                bulkBuilder = new BulkRequest.Builder();
                                batchCount = 0;
                            }
                        }
                        record.setLength(0);
                    }
                    record.append(line).append("\n");
                } else {
                    record.append(line);
                }
            }
            // Process last record
            if (record.length() > 0) {
                Map<String, Object> doc = parseRecord(record.toString());
                if (doc != null) {
                    addBulkDoc(bulkBuilder, doc);
                    batchCount++;
                    indexedCount++;
                }
            }
            // Execute remaining
            if (batchCount > 0) {
                executeBulk(bulkBuilder);
            }
        }

        long elapsed = System.currentTimeMillis() - startTime;
        logger.info("Indexing complete. Total documents indexed: {} in {} seconds",
                indexedCount, elapsed / 1000.0);
    }

    private void addBulkDoc(BulkRequest.Builder bulkBuilder, Map<String, Object> doc) {
        bulkBuilder.operations(op -> op
                .index(idx -> idx
                        .index(IndexConfig.INDEX_NAME)
                        .document(doc)
                )
        );
    }

    private void executeBulk(BulkRequest.Builder bulkBuilder) throws IOException {
        BulkResponse response = client.bulk(bulkBuilder.build());
        if (response.errors()) {
            for (BulkResponseItem item : response.items()) {
                if (item.error() != null) {
                    logger.error("Bulk index error for doc {}: {}", item.id(), item.error().reason());
                }
            }
        }
        if (indexedCount % 50000 == 0) {
            logger.info("Indexed {} documents...", indexedCount);
        }
    }

    /**
     * Parse a FASTA record into a document map.
     */
    public Map<String, Object> parseRecord(String record) {
        String[] lines = record.split("\n");
        if (lines.length < 2) return null;

        String header = lines[0].trim();
        StringBuilder seqBuilder = new StringBuilder();
        for (int i = 1; i < lines.length; i++) {
            seqBuilder.append(lines[i].trim());
        }
        String sequence = seqBuilder.toString();
        if (sequence.isEmpty()) return null;

        // Parse defline: >AC PROTEIN_ID^|...^|FIELD14^|FIELD15^|FIELD16
        String[] fields = header.split("\\^\\|\\^");
        if (fields.length < 15) return null;

        String headerContent = fields[0].substring(1).trim(); // remove '>'
        String[] headerParts = headerContent.split("\\s+", 2);
        String ac = headerParts[0];
        String proteinID = headerParts.length > 1 ? headerParts[1] : ac;
        String proteinName = fields.length > 2 ? fields[2].trim() : "";
        String organismName = fields.length > 5 ? fields[5].trim() : "";
        String organismID = fields.length > 6 ? fields[6].trim() : "";
        String taxongroupName = fields.length > 7 && !fields[7].trim().isEmpty() ? fields[7].trim() : "other";
        String taxongroupID = fields.length > 8 && !fields[8].trim().isEmpty() ? fields[8].trim() : "null";
        String nist = fields.length > 9 && !fields[9].trim().isEmpty() && !fields[9].trim().equals("Z") ? fields[9].trim() : "Z";
        String atlas = fields.length > 10 && !fields[10].trim().isEmpty() && !fields[10].trim().equals("Z") ? "Y" : "Z";
        String pride = fields.length > 11 && !fields[11].trim().isEmpty() && !fields[11].trim().equals("Z") ? "Y" : "Z";
        String iedb = fields.length > 12 && !fields[12].trim().isEmpty() && !fields[12].trim().equals("Z") ? fields[12].trim() : "Z";
        String fullLineage = fields.length > 13 ? fields[13].trim() : "";
        String shortLineage = fields.length > 14 ? fields[14].trim() : "";
        String uniref100 = fields.length > 15 && !fields[15].trim().isEmpty() ? "Y" : "";

        String sptr = ac.length() < 6 ? "sp" : "tr";
        String isoform = ac.contains("-") ? "Y" : "N";

        if (organismID.isEmpty()) organismID = "N/A";

        // Calculate boost based on annotations (for function_score or stored field)
        float boost = 1.0f;
        if (!"Z".equals(nist)) boost = 10.0f;
        else if (!"Z".equals(atlas)) boost = 9.0f;
        else if (!"Z".equals(pride)) boost = 8.0f;
        else if (!"Z".equals(iedb)) boost = 7.0f;

        Map<String, Object> doc = new HashMap<>();
        doc.put("ac", ac);
        doc.put("proteinID", proteinID);
        doc.put("proteinName", proteinName);
        doc.put("organismName", organismName);
        doc.put("organismID", organismID);
        doc.put("taxongroupName", taxongroupName);
        doc.put("taxongroupID", taxongroupID);
        doc.put("nist", nist);
        doc.put("peptideAtlas", atlas);
        doc.put("pride", pride);
        doc.put("iedb", iedb);
        doc.put("fullLineage", fullLineage);
        doc.put("shortLineage", shortLineage);
        doc.put("uniref100", uniref100);
        doc.put("sptr", sptr);
        doc.put("isoform", isoform);
        doc.put("originalSeq", sequence.toUpperCase());
        doc.put("lToiSeq", sequence.toUpperCase().replaceAll("L", "I"));
        doc.put("length", sequence.length());
        doc.put("boost", boost);

        return doc;
    }

    public long getIndexedCount() {
        return indexedCount;
    }

    /**
     * CLI entry point.
     */
    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: ESIndexer <data-file> [--delete-existing]");
            System.exit(1);
        }

        String dataFilePath = args[0];
        boolean deleteExisting = args.length > 1 && "--delete-existing".equals(args[1]);

        ElasticsearchClient client = ESClientFactory.createClient();
        ESIndexer indexer = new ESIndexer(client);
        indexer.createIndex(deleteExisting);
        indexer.indexDataFile(new File(dataFilePath));
    }
}
