package org.proteininformationresource.peptidematch;

import org.junit.jupiter.api.Test;
import org.proteininformationresource.peptidematch.indexer.ESIndexer;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for ESIndexer FASTA parsing logic.
 * Tests the record parsing without requiring an Elasticsearch connection.
 */
class ESIndexerTest {

    @Test
    void testParseRecord_standardFormat() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record = ">sp|P12345|P12345_HUMAN Tumor protein p53 OS=Homo sapiens OX=9606 GN=TP53 PE=1 SV=2\nMSEQKLICNVC";

        Map<String, Object> doc = indexer.parseRecord(record, "sp");

        assertNotNull(doc);
        assertEquals("P12345", doc.get("ac"));
        assertEquals("P12345_HUMAN", doc.get("proteinID"));
        assertEquals("Tumor protein p53", doc.get("proteinName"));
        assertEquals("Homo sapiens", doc.get("organismName"));
        assertEquals("9606", doc.get("organismID"));
        assertEquals("TP53", doc.get("geneName"));
        assertEquals("1", doc.get("proteinEvidence"));
        assertEquals("2", doc.get("sequenceVersion"));
        assertEquals("sp", doc.get("sptr"));
        assertEquals("N", doc.get("isoform")); // no dash in AC
        assertEquals("MSEQKLICNVC", doc.get("originalSeq"));
        assertEquals("MSEQKLICNVC".replaceAll("L", "I"), doc.get("lToiSeq"));
        assertEquals(11, doc.get("length"));
        assertEquals(1.0f, doc.get("boost"));
    }

    @Test
    void testParseRecord_isoform() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record = ">sp|P12345-2|P12345-2_HUMAN Isoform 2 OS=Homo sapiens OX=9606 GN=TP53 PE=1 SV=1\nACDEF";

        Map<String, Object> doc = indexer.parseRecord(record, "sp");

        assertNotNull(doc);
        assertEquals("Y", doc.get("isoform")); // has dash
        assertEquals("sp", doc.get("sptr"));
        assertEquals("1", doc.get("sequenceVersion"));
    }

    @Test
    void testParseRecord_trembl() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record = ">tr|A0A1B2CDE9|A0A1B2CDE9_9ARCH Protein OS=Archaea OX=115547 GN=UNKN PE=5 SV=1\nACDEF";

        Map<String, Object> doc = indexer.parseRecord(record, "tr");

        assertNotNull(doc);
        assertEquals("tr", doc.get("sptr"));
        assertEquals("N", doc.get("isoform"));
        assertEquals("5", doc.get("proteinEvidence"));
        assertEquals("1", doc.get("sequenceVersion"));
        assertEquals("UNKN", doc.get("geneName"));
    }

    @Test
    void testParseRecord_emptySequence() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record2 = ">sp|P12345|P12345_HUMAN Protein OS=Homo sapiens OX=9606 GN=TP53 PE=1 SV=1\nAC";
        Map<String, Object> doc = indexer.parseRecord(record2, "sp");
        assertNotNull(doc);
        assertEquals("AC", doc.get("originalSeq"));
    }

    @Test
    void testParseRecord_minimalHeader() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record = ">sp|P12345|TOOSHORT\nACDEF";
        Map<String, Object> doc = indexer.parseRecord(record, "tr");

        // Standard format parses successfully even without OS=, OX=, GN=, PE=, SV= tags
        assertNotNull(doc);
        assertEquals("P12345", doc.get("ac"));
        assertEquals("TOOSHORT", doc.get("proteinID"));
        assertEquals("ACDEF", doc.get("originalSeq"));
    }

    @Test
    void testParseRecord_noGeneName() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record = ">sp|P12345|P12345_HUMAN Protein OS=Homo sapiens OX=9606 PE=1 SV=1\nACDEF";
        Map<String, Object> doc = indexer.parseRecord(record, "sp");

        assertNotNull(doc);
        assertEquals("", doc.get("geneName")); // GN= is optional and absent
        assertEquals("Protein", doc.get("proteinName"));
    }

    @Test
    void testParseRecord_proteinEvidenceAndVersion() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record = ">sp|Q9Y5Q8|TF3C5_HUMAN General transcription factor 3C polypeptide 5 OS=Homo sapiens OX=9606 GN=GTF3C5 PE=1 SV=2\nMKTLLILAVLCLAQ";

        Map<String, Object> doc = indexer.parseRecord(record, "sp");

        assertNotNull(doc);
        assertEquals("Q9Y5Q8", doc.get("ac"));
        assertEquals("TF3C5_HUMAN", doc.get("proteinID"));
        assertEquals("General transcription factor 3C polypeptide 5", doc.get("proteinName"));
        assertEquals("Homo sapiens", doc.get("organismName"));
        assertEquals("9606", doc.get("organismID"));
        assertEquals("GTF3C5", doc.get("geneName"));
        assertEquals("1", doc.get("proteinEvidence"));
        assertEquals("2", doc.get("sequenceVersion"));
        assertEquals("sp", doc.get("sptr"));
    }

    @Test
    void testParseRecord_proteinEvidencePredicted() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record = ">tr|A0A001|PROT1_HUMAN Predicted protein OS=Mus musculus OX=10090 PE=5 SV=3\nACDEF";

        Map<String, Object> doc = indexer.parseRecord(record, "tr");

        assertNotNull(doc);
        assertEquals("5", doc.get("proteinEvidence"));
        assertEquals("3", doc.get("sequenceVersion"));
        assertEquals("tr", doc.get("sptr"));
    }

    @Test
    void testParseRecord_geneNameOnly() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record = ">sp|P00001|P00001_HUMAN Protein OS=Homo sapiens OX=9606 GN=GENE1 PE=1 SV=1\nACDEF";
        Map<String, Object> doc = indexer.parseRecord(record, "sp");

        assertNotNull(doc);
        assertEquals("GENE1", doc.get("geneName"));
        assertEquals("P00001_HUMAN", doc.get("proteinID"));
        assertEquals("Protein", doc.get("proteinName"));
    }

    @Test
    void testParseRecord_boostValues() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        // Boost = 1 (default)
        String r1 = ">sp|P00001|P00001_HUMAN Protein OS=Homo sapiens OX=9606 GN=GENE PE=1 SV=1\nACDEF";
        assertEquals(1.0f, indexer.parseRecord(r1, "sp").get("boost"));

        // PE=5 (predicted) boost still 1.0 for standard format
        String r2 = ">tr|P00002|P00002_HUMAN Predicted OS=Homo sapiens OX=9606 GN=GENE PE=5 SV=1\nACDEF";
        assertEquals(1.0f, indexer.parseRecord(r2, "tr").get("boost"));
    }

    @Test
    void testParseRecord_lToiSeq() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record = ">sp|P00001|P00001_HUMAN Protein OS=Homo sapiens OX=9606 GN=GENE PE=1 SV=1\nALLIICCLL";
        Map<String, Object> doc = indexer.parseRecord(record, "sp");

        assertNotNull(doc);
        assertEquals("ALLIICCLL", doc.get("originalSeq"));
        assertEquals("AIIIICCII", doc.get("lToiSeq"));
    }

    @Test
    void testParseRecord_differentOrganisms() throws IOException {
        ESIndexer indexer = createIndexerWithoutClient();

        String record = ">tr|A0A1B2CDE9|Protein OS=Escherichia coli OX=562 GN=unc PE=3 SV=1\nACDEF";
        Map<String, Object> doc = indexer.parseRecord(record, "tr");

        assertNotNull(doc);
        assertEquals("Escherichia coli", doc.get("organismName"));
        assertEquals("562", doc.get("organismID"));
        assertEquals("unc", doc.get("geneName"));
        assertEquals("3", doc.get("proteinEvidence"));
    }

    private ESIndexer createIndexerWithoutClient() throws IOException {
        return new ESIndexer(null);
    }
}