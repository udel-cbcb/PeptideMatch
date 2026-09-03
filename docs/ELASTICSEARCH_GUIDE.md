# PeptideMatch Elasticsearch Guide

This document describes how to use the Elasticsearch-based PeptideMatch implementation, which replaces the legacy Solr 3.5 and Lucene 4.6 backends.

## Prerequisites

- Java 17+
- Elasticsearch 8.x running (default: `localhost:9200`)
- Maven (for building)

## Building

```bash
cd elasticsearch
mvn clean package -DskipTests
```

## Configuration

Edit `elasticsearch/src/main/resources/elasticsearch.properties`:

```properties
elasticsearch.host=localhost
elasticsearch.port=9200
elasticsearch.scheme=http
# elasticsearch.username=
# elasticsearch.password=
```

## Index Mapping

The index `peptidematch` uses a trigram (n=3) NGram tokenizer for protein sequence fields:

| Field | Type | Analyzer | Purpose |
|-------|------|----------|---------|
| `ac` | keyword | — | Accession (e.g. `P12345`) |
| `proteinID` | keyword | — | Protein identifier |
| `originalSeq` | text | `peptide_ngram` | Protein sequence (trigram tokenized) |
| `lToiSeq` | text | `peptide_ngram_ltoi` | Sequence with L→I replacement |
| `proteinName` | keyword | — | Protein name |
| `organismName` | keyword | — | Organism name |
| `length` | integer | — | Sequence length |
| `boost` | float | — | Search boost |
| `sptr` | keyword | — | `sp` or `tr` |
| `fullLineage` | text | `lineage_analyzer` | Taxonomy lineage |
| `shortLineage` | text | `lineage_analyzer` | Short lineage |

## CLI Usage

### Indexing proteins

```bash
# Basic indexing
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d /path/to/uniprot_sprot.fasta

# Delete existing index and re-index
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d /path/to/uniprot_sprot.fasta --delete-existing

# Custom batch size (default: 5000)
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d /path/to/uniprot_sprot.fasta --batch-size 10000
```

**FASTA format expected:**

```
>sp|P12345|PROTName Protein OS=Homo sapiens OX=9606 GN=PROT PE=1 SV=1
MKTLLILAVLCLAQ...
```

Header fields are parsed as: `type|ac|proteinID Protein OS=organismName OX=organismID GN=proteinName PE=... SV=...`

### Querying peptides

```bash
# Single peptide
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD query \
  -q "VWLRRCT" -o results.txt

# Multiple comma-separated peptides
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD query \
  -q "VWLRRCT,IIIII" -o results.txt

# With L/I equivalence
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD query \
  -q "III" -e -o results.txt

# Query from FASTA file
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD query \
  -Q queries.fasta -o results.txt

# Query from list file (one peptide per line)
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD query \
  -Q peptides.txt -l -o results.txt

# Limit results per query
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD query \
  -q "VWLRRCT" -o results.txt --size 100
```

### Output Format

Tab-delimited with header:

```
##Query	Subject	SubjectLength	MatchStart	MatchEnd
VWLRRCT	P12345	342	15	21
```

With `-e` (L/I equivalence), an additional column shows replaced positions:

```
##Query	Subject	SubjectLength	MatchStart	MatchEnd	MatchedLEqIPositions
III	P12345	342	10	12	10,11,12
```

## Java API

### Creating a client

```java
import org.proteininformationresource.peptidematch.config.ESClientFactory;

// From elasticsearch.properties on classpath
ElasticsearchClient client = ESClientFactory.createClient();

// Explicit host/port/scheme
ElasticsearchClient client = ESClientFactory.createClient("localhost", 9200, "http");
```

### Indexing proteins

```java
import org.proteininformationresource.peptidematch.indexer.ESIndexer;

ElasticsearchClient client = ESClientFactory.createClient();
ESIndexer indexer = new ESIndexer(client, 5000); // batch size

indexer.createIndex(true); // true = delete existing
indexer.indexDataFile(new File("uniprot_sprot.fasta"));
indexer.optimizeIndex();

System.out.println("Indexed: " + indexer.getIndexedCount());

client._transport().close();
```

### Searching for peptides

```java
import org.proteininformationresource.peptidematch.search.ESSearchService;
import org.proteininformationresource.peptidematch.search.MatchPositionFinder;

ElasticsearchClient client = ESClientFactory.createClient();
ESSearchService searchService = new ESSearchService(client);

// Search (leqiFlag = "Y" or "N")
ESSearchService.SearchResult result = searchService.searchByPeptide(
    "VWLRRCT",    // peptide sequence
    "",           // organism filter
    "",           // taxon group filter
    "",           // accession filter
    "",           // protein ID filter
    "N",          // L/I equivalence
    0,            // offset
    10000,        // max results
    "ac_asc"      // sort
);

System.out.println("Total matches: " + result.totalFound());

for (Map<String, Object> hit : result.hits()) {
    String ac = (String) hit.get("ac");
    String seq = (String) hit.get("originalSeq");

    // Find exact positions
    List<MatchPositionFinder.MatchRange> matches =
        MatchPositionFinder.findMatches("VWLRRCT", seq, false);

    for (MatchPositionFinder.MatchRange m : matches) {
        System.out.printf("  %s: %d-%d%n", ac, m.start(), m.end());
    }
}

client._transport().close();
```

### Filtering by taxonomy

```java
// Filter by organism name
ESSearchService.SearchResult result = searchService.searchByPeptide(
    "VWLRRCT", "Homo sapiens", "", "", "", "N", 0, 10000, "ac_asc");

// Filter by taxon group
ESSearchService.SearchResult result = searchService.searchByPeptide(
    "VWLRRCT", "", "Mammals", "", "", "N", 0, 10000, "ac_asc");
```

## How Matching Works

1. **Trigram decomposition**: Each protein sequence is split into overlapping 3-character tokens (e.g., `MKTL` → `MKT`, `KTL`)
2. **Phrase query**: The query peptide is decomposed into trigrams and executed as an exact phrase query (`slop=0`)
3. **Post-search verification**: `MatchPositionFinder` does a brute-force substring scan to find exact match positions and return them with 1-based coordinates
4. **L/I equivalence**: When enabled, both the query (`I` → `L`) and a parallel `lToiSeq` field (all `L` → `I` in the index) are used to match isobaric leucine/isoleucine

## API Reference

### `ESSearchService`

| Method | Description |
|--------|-------------|
| `searchByPeptide(peptide, organism, taxonGroup, accession, proteinID, leqiFlag, offset, size, sort)` | Search for peptide matches with filters |
| `searchByPeptide(peptide, leqiFlag)` | Simple search without filters |
| `close()` | Close the client |

### `ESIndexer`

| Method | Description |
|--------|-------------|
| `ESIndexer(client, batchSize)` | Constructor with batch size |
| `createIndex(deleteExisting)` | Create index (optionally delete first) |
| `indexDataFile(fastaFile)` | Index a FASTA file |
| `optimizeIndex()` | Force-merge to 1 segment |
| `getIndexedCount()` | Number of indexed documents |
| `parseRecord(header, sequence)` | Parse FASTA header into a document map |
| `close()` | Close the client |

### `MatchPositionFinder`

| Method | Description |
|--------|-------------|
| `findMatches(peptide, sequence, leqi)` | Find all match positions (1-based) |
| `hasMatch(peptide, sequence, leqi)` | Check if peptide exists in sequence |
| `MatchRange` | Record: `start`, `end`, `replacedPositions` |

### `ESClientFactory`

| Method | Description |
|--------|-------------|
| `createClient()` | Create client from `elasticsearch.properties` |
| `createClient(host, port, scheme)` | Create client with explicit parameters |
| `createClient(props)` | Create client from `Properties` |

## Running Tests

```bash
cd elasticsearch
mvn test              # Unit tests only
mvn verify            # Unit + integration tests (requires ES running)
mvn verify -DskipITs  # Skip integration tests
```
