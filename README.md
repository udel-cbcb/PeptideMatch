# PeptideMatch - Fast Peptide Match Service for UniProt Knowledgebase

Locating occurrences of a specific peptide in a protein sequence database is important for protein identification in proteomics studies as well as for sequence-based protein retrieval. PeptideMatch is a high-performance web application for peptide matching using Elasticsearch 8.x as the search backend.

## Production use

Peptide Match has been a UniProt service since 2017. It has run 3.5 million search jobs on 11.4 million peptide sequences, including 2.1 million jobs from January through September 2026. The stand-alone command-line tool ([`peptidematch_cmd`](./peptidematch_cmd/)), which searches a user's own protein database, was downloaded 2,257 times in the same period.

## Features

- **Fast peptide matching** against UniProtKB (Swiss-Prot + TrEMBL)
- **L/I equivalence** - treats isobaric leucine and isoleucine as equivalent
- **Isoform support** - includes/excludes protein isoforms
- **Taxonomy filtering** - filter by organism or taxonomic group
- **RESTful API** - asynchronous REST endpoints for programmatic access
- **Zero-downtime updates** - quarterly index updates without service interruption

## Architecture

```
┌─────────────────┐     ┌─────────────────┐
│  Web Service    │     │  Web Service    │
│  (port 9090)    │     │  (port 9091)    │
│  Production     │     │  Test           │
└────────┬────────┘     └────────┬────────┘
         │                       │
         ▼                       ▼
┌─────────────────────────────────────────────┐
│         Elasticsearch (port 9200)            │
│  ┌─────────────────────────────────────┐   │
│  │  Alias: peptidematch_current        │   │
│  │  └──→ peptidematch_2026_03          │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

- Java 17+
- Maven 3.6+
- Docker (for Elasticsearch)

### 1. Start Elasticsearch

```bash
docker run -d \
  --name peptidematch-es \
  -p 9200:9200 -p 9300:9300 \
  -e "discovery.type=single-node" \
  -e "xpack.security.enabled=false" \
  -e "ES_JAVA_OPTS=-Xms16g -Xmx16g" \
  --user $(id -u):$(id -g) \
  -v $(pwd)/data/es-data:/usr/share/elasticsearch/data \
  docker.elastic.co/elasticsearch/elasticsearch:8.11.3
```

### 2. Build

```bash
mvn clean package -DskipTests
```

### 3. Download Data

```bash
./update-index.sh --version 2026_03
```

### 4. Index Data

```bash
# Swiss-Prot (~2 minutes)
java -cp elasticsearch/target/peptidematch-elasticsearch-1.0.0-SNAPSHOT.jar \
  org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d data/inputs/uniprot_sprot_2026_03.fasta \
  --source sp \
  --index-name peptidematch_2026_03

# TrEMBL (~9 hours)
nohup java -cp elasticsearch/target/peptidematch-elasticsearch-1.0.0-SNAPSHOT.jar \
  org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d data/inputs/uniprot_trembl_2026_03.fasta \
  --source tr \
  --index-name peptidematch_2026_03 \
  > logs/trembl-2026_03.log 2>&1 &
```

### 5. Create Alias

```bash
curl -X POST 'localhost:9200/_aliases' -H 'Content-Type: application/json' -d '{
  "actions": [
    { "add": { "index": "peptidematch_2026_03", "alias": "peptidematch_current" }}
  ]
}'
```

### 6. Start Web Service

#### Option A: Jetty (Development)

```bash
cd peptidematchwses
mvn jetty:run
# Service starts on http://localhost:9090/peptidematchws/
```

#### Option B: Tomcat (Production)

The WAR file is compatible with **Tomcat 10.x+** (uses `jakarta.servlet` namespace).

```bash
# Build WAR
mvn clean package -DskipTests

# Deploy to Tomcat 10+
cp peptidematchwses/target/peptidematchws.war $CATALINA_HOME/webapps/

# Or rename for shorter context path
cp peptidematchwses/target/peptidematchws.war $CATALINA_HOME/webapps/peptidematch.war
# Service accessible at http://localhost:8080/peptidematch/asyncrest/
```

## API Usage

### Submit a Query

```bash
curl -X POST 'localhost:9090/peptidematchws/asyncrest' \
  -d 'peps=VWLRRCT&swissprot=Y&format=json'
```

**Parameters:**
| Parameter | Description |
|-----------|-------------|
| `peps` | Peptide sequence(s), comma separated |
| `taxIds` | Taxonomy ID(s), comma separated |
| `lEQi` | `Y` to enable L/I equivalence |
| `swissprot` | `Y` for Swiss-Prot only |
| `isoform` | `Y` to include isoforms |
| `format` | `ac` for accessions, `json` for full JSON |
| `index` | Index name (default: `peptidematch_current`) |

### Check Job Status

```bash
curl -s 'localhost:9090/peptidematchws/asyncrest/jobs/PM...'
```

## Directory Structure

```
PeptideMatch/
├── data/
│   ├── inputs/              # FASTA files
│   │   ├── uniprot_sprot_2026_03.fasta
│   │   └── uniprot_trembl_2026_03.fasta
│   └── es-data/             # Elasticsearch data (Docker volume)
├── logs/                    # Application logs
│   ├── trembl-2026_03.log
│   └── web-service.log
├── elasticsearch/           # ES module (indexer, search, CLI)
├── peptidematchwses/        # Web service module
├── docs/                    # Documentation
│   ├── elasticsearch-guide.md
│   └── migration-plan.md
└── update-index.sh          # Automated index update script
```

## Modules

The current service runs on Elasticsearch. Modules from the earlier Apache Solr/Lucene version are kept for reference; [docs/migration-plan.md](docs/migration-plan.md) describes the migration.

| Module | Status | Description |
|--------|--------|-------------|
| `elasticsearch` | Current | Elasticsearch indexer, search service, CLI tools |
| `peptidematchwses` | Current | Asynchronous RESTful web service (Jetty or Tomcat) |
| `peptidematchapi2es` | Current | API v2 on the Elasticsearch backend |
| `peptidematch_async_rest_client_es` | Current | Client for the asynchronous REST service |
| `peptidematch_cmd` | Current | Stand-alone command-line tool for a user's own FASTA database (Lucene); see its [README](peptidematch_cmd/README.md) |
| `create_data` | Data preparation | Perl scripts that build the sequence and taxonomy input files |
| `peptidematch_web` | Legacy | Original web application (JSP, Solr) |
| `peptidematchws` | Legacy | Original web service (Solr) |
| `peptidematchapi2` | Legacy | Original API v2 (Swagger, Solr) |
| `peptidematch_async_rest_client` | Legacy | Original asynchronous REST client |
| `index_data` | Legacy | Original Lucene/Solr indexing programs |

## Testing

```bash
# Run all tests
mvn test

# Run FASTA vs Index comparison test
mvn test -Dtest=FastaVsIndexTest -Dtest.index=peptidematch_2026_03

# Run web service integration test
mvn test -Dtest=MatchServiceIntegrationTest -Dws.port=9090
```

## Documentation

- [Elasticsearch Guide](docs/elasticsearch-guide.md) - Full API docs, update workflow, configuration
- [Migration Plan](docs/migration-plan.md) - Solr to Elasticsearch migration details

## Publication

Chuming Chen; Zhiwen Li; Hongzhan Huang; Baris E. Suzek; Cathy H. Wu; UniProt Consortium.
[A fast Peptide Match Service for UniProt Knowledgebase](https://bioinformatics.oxfordjournals.org/content/29/21/2808).
Bioinformatics 2013; doi: 10.1093/bioinformatics/btt484.

## License
License: to be assigned (MIT intended)
