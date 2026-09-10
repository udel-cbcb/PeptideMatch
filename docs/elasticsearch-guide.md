# PeptideMatch ElasticSearch Guide

This document describes how to use the ElasticSearch-based PeptideMatch implementation, which replaces the legacy Solr 3.5 and Lucene 4.6 backends.

## Prerequisites

- Java 17+
- ElasticSearch 8.x running (default: `localhost:9200`)
- Maven (for building)

## Running ElasticSearch with Docker

```bash
# Start ElasticSearch 8.11.3
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

## Directory Structure

```
PeptideMatch/
├── data/
│   ├── inputs/              # FASTA files
│   │   ├── uniprot_sprot_2026_04.fasta
│   │   └── uniprot_trembl_2026_04.fasta
│   └── es-data/             # Elasticsearch data (Docker volume)
├── logs/                    # Application logs
│   ├── trembl-2026_04.log   # TrEMBL indexing log
│   └── web-service.log      # Web service log
├── elasticsearch/           # ES module (indexer, search, CLI)
└── peptidematchwses/        # Web service module
```

**Log access:**
```bash
# Indexing logs
tail -f logs/trembl-2026_04.log

# Web service logs
tail -f logs/web-service.log

# Elasticsearch logs (Docker)
docker logs -f peptidematch-es
```

## Data Preparation

Download UniProt reference databases from the UniProt FTP server:

```bash
# Create data directory
mkdir -p /path/to/PeptideMatch/data/inputs

# Download Swiss-Prot (curated, ~575K records, ~288MB)
curl -o /path/to/PeptideMatch/data/inputs/uniprot_sprot.fasta.gz \
  https://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip /path/to/PeptideMatch/data/inputs/uniprot_sprot.fasta.gz

# Download TrEMBL (automatically annotated, ~155M records, ~78GB uncompressed)
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
| `originalSeq.ltoi` | text | `peptide_ngram_ltoi` | derived | Sequence sub-field with L→I char_filter |
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

# Index to a specific index name (for versioned updates)
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d /path/to/uniprot_sprot.fasta --source sp --index-name peptidematch_2026_03
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

# Query a specific index version
java -cp peptidematch-es.jar org.proteininformationresource.peptidematch.cli.PeptideMatchCMD query \
  -q "VWLRRCT" -o results.txt --index-name peptidematch_2026_03
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

## Updating Index with New UniProt Releases

PeptideMatch supports zero-downtime index updates using Elasticsearch aliases. When UniProt releases a new version (quarterly, e.g., `2026_04`), you can update the index without breaking the web service.

### Architecture

```
┌─────────────────┐     ┌─────────────────┐
│  Web Service    │     │  Web Service    │
│  (port 9090)    │     │  (port 9091)    │
│  Production     │     │  Test           │
└────────┬────────┘     └────────┬────────┘
         │                       │
         │   elasticsearch.properties
         │   host=localhost:9200  │
         │                       │
         ▼                       ▼
┌─────────────────────────────────────────────┐
│         Elasticsearch (port 9200)            │
│  ┌─────────────────────────────────────┐   │
│  │  Alias: peptidematch_current        │   │
│  │  └──→ peptidematch_2026_03          │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │  Index: peptidematch_2026_04        │   │
│  │  (building...)                      │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

**Key components:**
- **Port 9200**: Elasticsearch server (stores all indexes)
- **Port 9090**: Production web service (uses `peptidematch_current` alias)
- **Port 9091**: Test web service (optional, for testing new indexes)
- **Alias**: `peptidematch_current` points to the active index

### How the Switch Works

1. **Web service** connects to ES via `elasticsearch.properties` (host=localhost, port=9200)
2. **MatchService** queries the alias `peptidematch_current` by default
3. **Alias** points to the active index (e.g., `peptidematch_2026_03`)
4. **To switch**: Update alias in ES → all web service queries automatically use new index
5. **Zero downtime**: Alias update is atomic (< 1 second)

### Deployment Process Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  1. DOWNLOAD                                                    │
│  ./update-index.sh --version 2026_04                            │
│  → Downloads FASTA files to data/inputs/                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  2. INDEX (Background, ~9 hours)                                │
│  java -cp ... PeptideMatchCMD index \                           │
│    -d data/inputs/uniprot_sprot_2026_04.fasta \                 │
│    --source sp --index-name peptidematch_2026_04                 │
│  java -cp ... PeptideMatchCMD index \                           │
│    -d data/inputs/uniprot_trembl_2026_04.fasta \                │
│    --source tr --index-name peptidematch_2026_04                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  3. VALIDATE                                                    │
│  mvn test -Dtest=FastaVsIndexTest -Dtest.index=peptidematch_2026_04
│  curl -X POST localhost:9091/asyncrest -d 'peps=VWLRRCT&index=peptidematch_2026_04'
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  4. FORCE MERGE                                                 │
│  curl -X POST "localhost:9200/peptidematch_2026_04/_forcemerge?max_num_segments=16"
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  5. SWAP ALIAS (Zero-Downtime)                                  │
│  curl -X POST localhost:9200/_aliases -d '{                     │
│    "actions": [                                                 │
│      {"remove": {"index": "peptidematch_2026_03", "alias": "peptidematch_current"}},
│      {"add":    {"index": "peptidematch_2026_04", "alias": "peptidematch_current"}}
│    ]                                                            │
│  }'                                                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  6. CLEANUP (Optional)                                          │
│  curl -X DELETE localhost:9200/peptidematch_2026_03              │
│  (Keep for 1 quarter for rollback)                              │
└─────────────────────────────────────────────────────────────────┘
```

### Timeline

| Step | Duration | Downtime |
|------|----------|----------|
| Download | 5 min | None |
| Index (Swiss-Prot) | 2 min | None |
| Index (TrEMBL) | 9 hours | None |
| Validate | 5 min | None |
| Force merge | 5 min | None |
| Swap alias | <1 second | **Zero** |
| Cleanup | 1 min | None |

**Total: ~9.5 hours, zero downtime**

### Automated Update Script

The `update-index.sh` script downloads files to `data/inputs/` with version suffix (e.g., `uniprot_sprot_2026_04.fasta`):

```bash
# Auto-detect latest version and update
./update-index.sh

# Use specific version
./update-index.sh --version 2026_04

# Preview what would be done (dry run)
./update-index.sh --dry-run

# Skip download (use pre-existing files)
./update-index.sh --version 2026_04 --skip-download
```

**Downloaded files location:**
- `/data/chenc/2026/PeptideMatch/data/inputs/uniprot_sprot_2026_04.fasta`
- `/data/chenc/2026/PeptideMatch/data/inputs/uniprot_trembl_2026_04.fasta`

### Detailed Steps

#### Step 1: Download FASTA Files

```bash
cd /data/chenc/2026/PeptideMatch
./update-index.sh --version 2026_04
```

#### Step 2: Index Data

**Swiss-Prot** (~2 minutes):
```bash
java -cp elasticsearch/target/peptidematch-elasticsearch-1.0.0-SNAPSHOT.jar \
  org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d data/inputs/uniprot_sprot_2026_04.fasta \
  --source sp \
  --index-name peptidematch_2026_04
```

**TrEMBL** (~9 hours, run in background):
```bash
nohup java -cp elasticsearch/target/peptidematch-elasticsearch-1.0.0-SNAPSHOT.jar \
  org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d data/inputs/uniprot_trembl_2026_04.fasta \
  --source tr \
  --index-name peptidematch_2026_04 \
  > logs/trembl-2026_04.log 2>&1 &

# Monitor progress
tail -f logs/trembl-2026_04.log
```

#### Step 3: Validate Index

**Run FASTA vs Index comparison test:**
```bash
cd /data/chenc/2026/PeptideMatch/elasticsearch
mvn test -Dtest=FastaVsIndexTest -Dtest.index=peptidematch_2026_04
```

**Test with web service:**
```bash
# Submit query to test index
curl -X POST 'localhost:9090/peptidematchwses/asyncrest' \
  -d 'peps=VWLRRCT&index=peptidematch_2026_04'

# Check job status
curl -s 'localhost:9090/peptidematchwses/asyncrest/jobs/PM...'
```

#### Step 4: Force Merge

```bash
curl -X POST "localhost:9200/peptidematch_2026_04/_forcemerge?max_num_segments=16"
```

#### Step 5: Swap Alias (Zero-Downtime)

```bash
curl -X POST 'localhost:9200/_aliases' -H 'Content-Type: application/json' -d '{
  "actions": [
    { "remove": { "index": "peptidematch_2026_03", "alias": "peptidematch_current" }},
    { "add":    { "index": "peptidematch_2026_04", "alias": "peptidematch_current" }}
  ]
}'
```

**Verify:**
```bash
curl -s 'localhost:9200/_alias/peptidematch_current'
# Should return: {"peptidematch_2026_04":{"aliases":{"peptidematch_current":{}}}}
```

#### Step 6: Cleanup Old Index (Optional)

```bash
# Delete old index (keep for 1 quarter for rollback)
curl -X DELETE 'localhost:9200/peptidematch_2026_03'
```

### Preparing New Index Before Release

When UniProt provides pre-release data (typically 2-4 weeks before official release):

1. Place pre-release FASTA files in `data/inputs/` with version suffix:
   - `uniprot_sprot_2026_07.fasta`
   - `uniprot_trembl_2026_07.fasta`

2. Index to test index (skip download since you already have the files):
   ```bash
   java -cp elasticsearch/target/peptidematch-elasticsearch-1.0.0-SNAPSHOT.jar \
     org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
     -d data/inputs/uniprot_sprot_2026_07.fasta --source sp --index-name peptidematch_2026_07
   
   java -cp elasticsearch/target/peptidematch-elasticsearch-1.0.0-SNAPSHOT.jar \
     org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
     -d data/inputs/uniprot_trembl_2026_07.fasta --source tr --index-name peptidematch_2026_07
   ```

3. Run integration tests against test index:
   ```bash
   mvn test -Dtest=FastaVsIndexTest -Dtest.index=peptidematch_2026_07
   ```

4. Query test index via web service:
   ```bash
   curl -X POST 'localhost:9090/peptidematchwses/asyncrest' \
     -d 'peps=VWLRRCT&index=peptidematch_2026_07'
   ```

5. After validation, rename test index to production version:
   ```bash
   curl -X POST 'localhost:9200/_aliases' -H 'Content-Type: application/json' -d '{
     "actions": [
       { "add": { "index": "peptidematch_2026_07_test", "alias": "peptidematch_2026_07" }}
     ]
   }'
   ```

### Configuring Web Service to Use Alias

The web service uses the alias `peptidematch_current` by default. No code changes needed.

**Priority order for index selection:**
1. `-Dindex.name=...` (system property)
2. `index=...` (API query parameter)
3. `peptidematch_current` (default alias)

**Two-server setup (optional):**
```bash
# Production server (port 9090) - uses alias
screen -dmS prod bash -c 'cd peptidematchwses && mvn jetty:run -Djetty.port=9090 > logs/web-service.log 2>&1'

# Test server (port 9091) - uses specific index
screen -dmS test bash -c 'cd peptidematchwses && mvn jetty:run -Djetty.port=9091 -Dindex.name=peptidematch_2026_04 > logs/web-service-test.log 2>&1'
```

### Rollback

If the new index has issues, quickly rollback to the previous version:

```bash
# Find previous index
curl -s 'localhost:9200/_cat/indices/peptidematch_*?h=index' | sort -r | head -2

# Swap alias back
curl -X POST 'localhost:9200/_aliases' -H 'Content-Type: application/json' -d '{
  "actions": [
    { "remove": { "index": "peptidematch_2026_04", "alias": "peptidematch_current" }},
    { "add":    { "index": "peptidematch_2026_03", "alias": "peptidematch_current" }}
  ]
}'
```

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

// Index to a specific version (for zero-downtime updates)
ESIndexer indexer = new ESIndexer(client, 5000, "peptidematch_2026_03");
indexer.createIndex(true);
indexer.indexDataFile(new File("uniprot_sprot_2026_03.fasta"), "sp");
indexer.optimizeIndex();
```

### Searching for peptides

```java
import org.proteininformationresource.peptidematch.search.ESSearchService;
import org.proteininformationresource.peptidematch.search.MatchPositionFinder;

ElasticsearchClient client = ESClientFactory.createClient();
ESSearchService searchService = new ESSearchService(client); // Uses default index

// Or use a specific index version
ESSearchService searchService = new ESSearchService(client, "peptidematch_2026_03");

// Or use the alias for automatic versioning
ESSearchService searchService = new ESSearchService(client, "peptidematch_current");

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
4. **L/I equivalence**: When enabled, the query (`I` → `L`) is searched against the `originalSeq.ltoi` sub-field (which has an L→I char_filter applied at index time) to match isobaric leucine/isoleucine

## API Reference

### `ESSearchService`

| Method | Description |
|--------|-------------|
| `ESSearchService(client)` | Constructor using default index (`peptidematch`) |
| `ESSearchService(client, indexName)` | Constructor with custom index name |
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
| `optimizeIndex()` | Force-merge to 16 segments (1 per shard) for optimal search performance (fault-tolerant, logs warning on failure) |
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

#### Option A: Jetty (Development)

```bash
cd peptidematchwses
mvn jetty:run
# Service starts on http://localhost:9090/peptidematchwses/
```

#### Option B: Tomcat (Production)

The module produces a standard WAR file compatible with **Tomcat 10.x+** (uses `jakarta.servlet` namespace).

```bash
# Build WAR
mvn clean package -DskipTests

# Deploy to Tomcat 10+
cp peptidematchwses/target/PeptideMatchWSAsync-ES.war $CATALINA_HOME/webapps/

# Or rename for shorter context path
cp peptidematchwses/target/PeptideMatchWSAsync-ES.war $CATALINA_HOME/webapps/peptidematch.war
# Service accessible at http://localhost:8080/peptidematch/asyncrest/
```

**Tomcat configuration notes:**
- Requires **Tomcat 10.x+** (Tomcat 9 uses `javax.servlet` and is not compatible)
- Ensure `config.properties` is in classpath (already inside `WEB-INF/classes` in WAR)
- Ensure work directory (`/tmp/peptidematch-jobs`) is writable by Tomcat process
- Set `ES_HOST` and `ES_PORT` in `config.properties` or via environment variables

### Running Two Servers (Production + Testing)

For zero-downtime updates, run two servers on different ports:

```bash
# Production server (port 9090) - uses alias peptidematch_current
screen -dmS prod bash -c 'cd peptidematchwses && mvn jetty:run -Djetty.port=9090 > logs/web-service.log 2>&1'

# Test server (port 9091) - uses specific index version
screen -dmS test bash -c 'cd peptidematchwses && mvn jetty:run -Djetty.port=9091 -Dindex.name=peptidematch_2026_03 > logs/web-service-test.log 2>&1'
```

**Priority order for index selection:**
1. System property `-Dindex.name=...` (highest priority)
2. Query parameter `index=...`
3. Default alias `peptidematch_current`

**Example usage:**
```bash
# Query production (port 9090)
curl -X POST 'localhost:9090/peptidematchwses/asyncrest' -d 'peps=VWLRRCT'

# Query test index (port 9091)
curl -X POST 'localhost:9091/peptidematchwses/asyncrest' -d 'peps=VWLRRCT'

# Or override index via query parameter (any port)
curl -X POST 'localhost:9090/peptidematchwses/asyncrest' -d 'peps=VWLRRCT&index=peptidematch_2026_03'
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
| `index` | string | `peptidematch_current` | Index name or alias (e.g., `peptidematch_2026_03`) |

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

> **Note**: These counts were validated against the March 2026 UniProt release. Counts will change with new data releases.
