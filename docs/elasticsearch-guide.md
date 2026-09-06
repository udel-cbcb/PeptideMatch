# PeptideMatch Elasticsearch Guide

This document describes how to use the Elasticsearch-based PeptideMatch implementation, which replaces the legacy Solr 3.5 and Lucene 4.6 backends.

## Prerequisites

- Java 17+
- Elasticsearch 8.x running (default: `localhost:9200`)
- Maven (for building)

## Running Elasticsearch with Docker

```bash
# Start Elasticsearch 8.11.3
docker run -d \
  --name peptidematch-es \
  -p 9200:9200 -p 9300:9300 \
  -e "discovery.type=single-node" \
  -e "xpack.security.enabled=false" \
  -e "ES_JAVA_OPTS=-Xms16g -Xmx16g" \
  --user $(id -u):$(id -g) \
  -v /data/chenc/2026/PeptideMatch/data/es-data:/usr/share/elasticsearch/data \
  docker.elastic.co/elasticsearch/elasticsearch:8.11.3
```

The `--user $(id -u):$(id -g)` flag ensures data files are owned by your user, not the container's default user.

```bash
# Stop and remove
docker stop peptidematch-es && docker rm peptidematch-es
```

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

## Data Preparation

Download UniProt reference databases from the UniProt FTP server:

```bash
# Create data directory
mkdir -p /path/to/PeptideMatch/data/inputs

# Download Swiss-Prot (curated, ~575K records, ~275MB)
curl -o /path/to/PeptideMatch/data/inputs/uniprot_sprot.fasta.gz \
  https://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip /path/to/PeptideMatch/data/inputs/uniprot_sprot.fasta.gz

# Download TrEMBL (automatically annotated, ~250M records, ~36GB compressed)
curl -C - -o /path/to/PeptideMatch/data/inputs/uniprot_trembl.fasta.gz \
  https://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz
gunzip /path/to/PeptideMatch/data/inputs/uniprot_trembl.fasta.gz
```

## Index Mapping

The index `peptidematch` uses a trigram (n=3) NGram tokenizer for protein sequence fields:

| Field | Type | Analyzer | Source | Purpose |
|-------|------|----------|--------|---------|
| `ac` | keyword | — | `UniqueIdentifier` | Accession (e.g. `P12345`) |
| `proteinID` | keyword | — | `EntryName` | Protein identifier (e.g. `P12345_HUMAN`) |
| `proteinName` | keyword | — | `ProteinName` (before OS=) | Protein name |
| `organismName` | keyword | — | `OS=` | Organism name (e.g. `Homo sapiens`) |
| `organismID` | keyword | — | `OX=` | NCBI Taxonomy ID (e.g. `9606`) |
| `geneName` | keyword | — | `GN=` | Gene symbol (optional) |
| `proteinEvidence` | keyword | — | `PE=` | Protein existence (1=experimental, 5=predicted) |
| `sequenceVersion` | keyword | — | `SV=` | Sequence version |
| `sptr` | keyword | — | `--source` flag | `sp` or `tr` |
| `isoform` | keyword | — | derived | `Y` if accession contains `-` |
| `originalSeq` | text | `peptide_ngram` | FASTA sequence | Protein sequence (trigram tokenized) |
| `lToiSeq` | text | `peptide_ngram_ltoi` | FASTA sequence | Sequence with L→I replacement |
| `length` | integer | — | derived | Sequence length |
| `boost` | float | — | — | Search boost (default: 1.0) |

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

# Index Swiss-Prot (sets sptr=sp)
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d /path/to/uniprot_sprot.fasta --source sp

# Index TrEMBL (sets sptr=tr)
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d /path/to/uniprot_trembl.fasta --source tr
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
| `searchByPeptide(peptide, taxonids, swissprot, isoform, leqi, offset, size, sort)` | Search with filters |
| `searchAfter(peptide, taxonids, swissprot, isoform, leqi, searchAfterValues, size, sort)` | Search with `search_after` pagination |
| `searchByPeptideWithGroup(peptide, leqi)` | Search grouped by organism |
| `searchById(ac)` | Search by accession ID |

### `ESSearchService.SearchResult`

| Field | Type | Description |
|-------|------|-------------|
| `totalFound` | long | Total number of matching documents |
| `tookMs` | long | Query time in milliseconds |
| `hits` | List<Map> | List of matching document fields |
| `sortValues` | List<FieldValue> | Sort values for `search_after` pagination |

### `ESIndexer`

| Method | Description |
|--------|-------------|
| `ESIndexer(client, batchSize)` | Constructor with batch size |
| `createIndex(deleteExisting)` | Create index (optionally delete first) |
| `indexDataFile(fastaFile)` | Index a FASTA file |
| `optimizeIndex()` | Force-merge to 1 segment per shard |
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

## Web Service (peptidematchwses)

The asynchronous REST web service provides peptide matching via HTTP API.

### Starting the Service

```bash
cd peptidematchwses
mvn jetty:run
# Service starts on http://localhost:9090/peptidematchwses/
```

### API Endpoints

#### Submit a Query

```
POST /peptidematchwses/asyncrest/
Content-Type: application/x-www-form-urlencoded
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `peps` | string | required | Peptide sequence(s), newline or comma separated |
| `taxIds` | string | empty | Taxonomy ID(s), comma separated (e.g., `9606,10090`) |
| `lEQi` | string | `N` | L/I equivalence: `Y` or `ON` to enable |
| `swissprot` | string | `N` | `Y` to filter Swiss-Prot only, `N` for all |
| `isoform` | string | empty | `N` to exclude isoforms, `Y` to include, empty for all |
| `format` | string | `ac` | `ac` for comma-separated accessions, `json` for full JSON |

**Response**: `202 Accepted` with `Location` header containing job URL.

**Example**:
```bash
# Submit query
curl -X POST 'localhost:9090/peptidematchwses/asyncrest/' \
  -d 'peps=LLALLAL&taxIds=&lEQi=N&swissprot=Y'

# Returns: Location: http://localhost:9090/peptidematchwses/asyncrest/jobs/PM20260905...
```

#### Check Job Status

```
GET /peptidematchwses/asyncrest/jobs/{jobId}
GET /peptidematchwses/asyncrest/jobs/{jobId}/json
```

| Path | Description |
|------|-------------|
| `/jobs/{jobId}` | Returns comma-separated ACs (default) |
| `/jobs/{jobId}/json` | Returns full JSON records (only if job was submitted with `format=json`) |

**Response while running**: `303 See Other` with `Retry-After: 30` header.

**Response when complete**: `200 OK` with results.

**Example**:
```bash
# Poll until complete
curl -L 'localhost:9090/peptidematchwses/asyncrest/jobs/PM20260905...'

# Get JSON results (if format=json was used)
curl -L 'localhost:9090/peptidematchwses/asyncrest/jobs/PM20260905.../json'
```

### Response Formats

#### AC-only (default)
```
A0A2P2GK84,A0QPD4,A2D4U1,A2D670,...
```

#### JSON format
```json
[
  {
    "ac": "A0A2P2GK84",
    "proteinName": "Drimenyl diphosphate synthase",
    "proteinID": "DMS_STREW",
    "organismID": "68268",
    "organismName": "Streptomyces showdoensis",
    "geneName": "VO63_21045",
    "sptr": "sp",
    "isoform": "N",
    "length": 533,
    "originalSeq": "MNASPTPTATTTTEPATAVVRCRTRLARRVVAAVGPDGLLPAPCESRVLESALALALLTEERAEADATARLTAYLRTTLR",
    "proteinEvidence": "1",
    "sequenceVersion": "1",
    "boost": 1.0
  }
]
```

### Query Examples

```bash
# Basic peptide search
curl -X POST 'localhost:9090/peptidematchwses/asyncrest/' \
  -d 'peps=VWLRRCT'

# With L/I equivalence
curl -X POST 'localhost:9090/peptidematchwses/asyncrest/' \
  -d 'peps=III&lEQi=Y'

# Swiss-Prot only, human proteins
curl -X POST 'localhost:9090/peptidematchwses/asyncrest/' \
  -d 'peps=III&lEQi=Y&swissprot=Y&taxIds=9606'

# Full JSON output
curl -X POST 'localhost:9090/peptidematchwses/asyncrest/' \
  -d 'peps=LLALLAL&swissprot=Y&format=json'

# Multiple peptides
curl -X POST 'localhost:9090/peptidematchwses/asyncrest/' \
  -d 'peps=VWLRRCT\nIIIII&lEQi=Y'
```

### Verified Query Results

All filter combinations validated against ES index counts:

| Peptide | lEQi | swissprot | taxon | Result Count |
|---------|------|-----------|-------|--------------|
| LLALLAL | N | N (all) | — | 20,477 |
| LLALLAL | N | Y (sp) | — | 93 |
| III | Y | N (all) | — | 76,322,232 |
| III | Y | N (all) | 9606 | 109,895 |
| III | Y | Y (sp) | 9606 | 12,885 |
