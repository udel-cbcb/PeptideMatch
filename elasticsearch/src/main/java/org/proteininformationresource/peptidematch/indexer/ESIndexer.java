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
    private static final int DEFAULT_BULK_BATCH_SIZE = 5000;

    private final ElasticsearchClient client;
    private final int bulkBatchSize;
    private String sourceType = "tr"; // default to TrEMBL
    private long indexedCount = 0;
    private long errorCount = 0;

    public ESIndexer(ElasticsearchClient client) {
        this(client, DEFAULT_BULK_BATCH_SIZE);
    }

    public ESIndexer(ElasticsearchClient client, int bulkBatchSize) {
        this.client = client;
        this.bulkBatchSize = bulkBatchSize;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
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
     * Index data from a FASTA file.
     *
     * Supports two formats:
     * 1. Standard UniProt FASTA:
     *    >sp|Q9Y5Q8|TF3C5_HUMAN General transcription factor 3C polypeptide 5 OS=Homo sapiens OX=9606 GN=GTF3C5 PE=1 SV=2
     *    SEQUENCE
     *
     * 2. Enriched FASTA format (^|^ delimited, from create_data pipeline):
     *    >AC PROTEIN_ID^|^^|^PROTEIN_NAME^|^^|^^|^ORGANISM_NAME^|^TAXON_ID^|^TAXGROUP_NAME^|^TAXGROUP_ID^|^NIST^|^ATLAS^|^PRIDE^|^IEDB^|^FULL_LINEAGE^|^SHORT_LINEAGE^|^UNIREF100_AC
     *    SEQUENCE
     */
    public void indexDataFile(File dataFile, String sourceType) throws IOException {
        if (!dataFile.exists()) {
            throw new IOException("Data file does not exist: " + dataFile);
        }
        this.sourceType = sourceType;

        long startTime = System.currentTimeMillis();
        long lastReportTime = startTime;
        logger.info("Starting indexing from '{}' (source={}, batch size={})...", dataFile.getName(), sourceType, bulkBatchSize);

        try (BufferedReader br = new BufferedReader(new FileReader(dataFile))) {
            BulkRequest.Builder bulkBuilder = new BulkRequest.Builder();
            int batchCount = 0;

            StringBuilder record = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                if (line.startsWith(">")) {
                    if (record.length() > 0) {
                        indexRecord(bulkBuilder, record.toString());
                        batchCount++;

                        if (batchCount >= bulkBatchSize) {
                            executeBulk(bulkBuilder);
                            bulkBuilder = new BulkRequest.Builder();
                            batchCount = 0;
                            reportProgress(startTime, lastReportTime);
                            lastReportTime = System.currentTimeMillis();
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
                indexRecord(bulkBuilder, record.toString());
                batchCount++;
            }
            // Execute remaining
            if (batchCount > 0) {
                executeBulk(bulkBuilder);
            }
        }

        long elapsed = System.currentTimeMillis() - startTime;
        logger.info("Indexing complete. Total: {} indexed, {} errors, in {} seconds ({}/sec)",
                indexedCount, errorCount, String.format("%.1f", elapsed / 1000.0),
                indexedCount > 0 ? (indexedCount * 1000 / elapsed) : 0);
    }

    private void indexRecord(BulkRequest.Builder bulkBuilder, String record) {
        Map<String, Object> doc = parseRecord(record, sourceType);
        if (doc != null) {
            addBulkDoc(bulkBuilder, doc);
            indexedCount++;
        }
    }

    private void reportProgress(long startTime, long lastReportTime) {
        long elapsed = (System.currentTimeMillis() - startTime) / 1000;
        double rate = indexedCount > 0 ? (indexedCount * 1000.0 / (System.currentTimeMillis() - startTime)) : 0;
        logger.info("Progress: {} documents indexed ({} errors) | {}s elapsed | {} docs/sec",
                indexedCount, errorCount, elapsed, String.format("%.0f", rate));
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
                    errorCount++;
                    if (errorCount <= 10) {
                        logger.error("Bulk index error for doc {}: {}", item.id(), item.error().reason());
                    }
                }
            }
            if (errorCount == 11) {
                logger.error("Suppressing further error messages (>10 errors)");
            }
        }
    }

    /**
     * Parse a FASTA record into a document map.
     * Supports both enriched format (^|^ delimited) and standard UniProt format.
     */
    public Map<String, Object> parseRecord(String record, String sourceType) {
        String[] lines = record.split("\n");
        if (lines.length < 2) return null;

        String header = lines[0].trim();
        StringBuilder seqBuilder = new StringBuilder();
        for (int i = 1; i < lines.length; i++) {
            seqBuilder.append(lines[i].trim());
        }
        String sequence = seqBuilder.toString();
        if (sequence.isEmpty()) return null;

        // Try enriched format first: ^|^ delimited
        if (header.contains("^|^")) {
            return parseEnrichedRecord(header, sequence, sourceType);
        }

        // Standard UniProt FASTA: >sp|AC|EntryName ProteinName OS=... OX=... GN=... PE=... SV=...
        // or tr|AC|EntryName ProteinName OS=... OX=... GN=... PE=... SV=...
        String headerContent = header.substring(1).trim(); // remove '>'
        String[] headerParts = headerContent.split("\\s+", 2);

        // Extract AC and EntryName from the first part: "sp|AC|EntryName"
        String ac = "";
        String proteinID = "";
        if (headerParts[0].contains("|")) {
            String[] acParts = headerParts[0].split("\\|");
            if (acParts.length > 1) ac = acParts[1];
            if (acParts.length > 2) proteinID = acParts[2];
        } else {
            ac = headerParts[0];
            proteinID = ac;
        }

        // Extract protein description (everything before OS=)
        String proteinName = "";
        String description = "";
        if (headerParts.length > 1) {
            description = headerParts[1];
            int osIdx = description.indexOf(" OS=");
            if (osIdx > 0) {
                proteinName = description.substring(0, osIdx).trim();
            } else {
                proteinName = description;
            }
        }

        // Extract metadata from key=value pairs
        String rest = headerParts.length > 1 ? headerContent : "";
        String organismName = extractTag(rest, "OS=");
        String organismID = extractTag(rest, "OX=");
        String geneName = extractTag(rest, "GN=");
        String proteinEvidence = extractTag(rest, "PE=");
        String sequenceVersion = extractTag(rest, "SV=");
        String sptr = sourceType;
        String isoform = ac.contains("-") ? "Y" : "N";

        if (organismName.isEmpty()) organismName = description;
        if (organismID.isEmpty()) organismID = "N/A";

        Map<String, Object> doc = new HashMap<>();
        doc.put("ac", ac);
        doc.put("proteinID", proteinID);
        doc.put("proteinName", proteinName.isEmpty() ? (geneName.isEmpty() ? description : geneName) : proteinName);
        doc.put("organismName", organismName);
        doc.put("organismID", organismID);
        doc.put("geneName", geneName);
        doc.put("sptr", sptr);
        doc.put("isoform", isoform);
        doc.put("originalSeq", sequence.toUpperCase());
        doc.put("lToiSeq", sequence.toUpperCase().replaceAll("L", "I"));
        doc.put("length", sequence.length());
        doc.put("proteinEvidence", proteinEvidence);
        doc.put("sequenceVersion", sequenceVersion);
        doc.put("boost", 1.0f);

        return doc;
    }

    private Map<String, Object> parseEnrichedRecord(String header, String sequence, String sourceType) {
        String[] fields = header.split("\\^\\|\\^");
        if (fields.length < 15) return null;

        String headerContent = fields[0].substring(1).trim();
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

        String sptr = sourceType;
        String isoform = ac.contains("-") ? "Y" : "N";

        if (organismID.isEmpty()) organismID = "N/A";

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
        doc.put("geneName", "");
        doc.put("sptr", sptr);
        doc.put("isoform", isoform);
        doc.put("originalSeq", sequence.toUpperCase());
        doc.put("lToiSeq", sequence.toUpperCase().replaceAll("L", "I"));
        doc.put("length", sequence.length());
        doc.put("proteinEvidence", "");
        doc.put("sequenceVersion", "");
        doc.put("boost", boost);

        return doc;
    }

    /**
     * Extract tag value from header string (e.g. extractTag("OS=Homo sapiens OX=9606", "OS=") -> "Homo sapiens")
     */
    private String extractTag(String header, String tag) {
        int start = header.indexOf(tag);
        if (start < 0) return "";
        start += tag.length();
        // Find next tag or end
        int end = header.length();
        for (String nextTag : new String[]{" OX=", " GN=", " PE=", " SV=", " OS="}) {
            int idx = header.indexOf(nextTag, start);
            if (idx > 0 && idx < end) end = idx;
        }
        // Also handle end of string
        return header.substring(start, end).trim();
    }

    public long getIndexedCount() {
        return indexedCount;
    }

    public long getErrorCount() {
        return errorCount;
    }

    /**
     * Force merge the index to a single segment for optimal search performance.
     * Call this after bulk indexing is complete.
     */
    public void optimizeIndex() throws IOException {
        logger.info("Force merging index to 1 segment...");
        client.indices().forcemerge(f -> f
            .index(IndexConfig.INDEX_NAME)
            .maxNumSegments(1L)
        );
        logger.info("Index optimized.");
    }

    /**
     * CLI entry point.
     *
     * Usage: java ESIndexer <data-file> [options]
     *   --delete-existing   Delete and recreate the index before indexing
     *   --batch-size N      Bulk batch size (default: 5000)
     *   --optimize          Force merge index after indexing
     */
    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: ESIndexer <data-file> [options]");
            System.err.println("  --delete-existing   Delete and recreate index");
            System.err.println("  --batch-size N      Bulk batch size (default: 5000)");
            System.err.println("  --optimize          Force merge after indexing");
            System.exit(1);
        }

        String dataFilePath = args[0];
        boolean deleteExisting = false;
        int batchSize = DEFAULT_BULK_BATCH_SIZE;
        boolean optimize = false;
        String source = "tr";

        for (int i = 1; i < args.length; i++) {
            switch (args[i]) {
                case "--delete-existing" -> deleteExisting = true;
                case "--batch-size" -> batchSize = Integer.parseInt(args[++i]);
                case "--optimize" -> optimize = true;
                case "--source" -> source = args[++i];
            }
        }

        ElasticsearchClient client = ESClientFactory.createClient();
        ESIndexer indexer = new ESIndexer(client, batchSize);
        indexer.createIndex(deleteExisting);
        indexer.indexDataFile(new File(dataFilePath), source);
        if (optimize) {
            indexer.optimizeIndex();
        }
    }
}
