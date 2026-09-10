# PeptideMatch - Fast Peptide Match Service for UniProt Knowledgebase

Locating occurrences of a specific peptide in a protein sequence database is important for protein identification in proteomics studies as well as for sequence-based protein retrieval. PeptideMatch is a high-performance web application for peptide matching using Elasticsearch 8.x as the search backend.

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
│  │  └──→ peptidematch_2026_04          │   │
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
./update-index.sh --version 2026_04
```

### 4. Index Data

```bash
# Swiss-Prot (~2 minutes)
java -cp elasticsearch/target/peptidematch-elasticsearch-1.0.0-SNAPSHOT.jar \
  org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d data/inputs/uniprot_sprot_2026_04.fasta \
  --source sp \
  --index-name peptidematch_2026_04

# TrEMBL (~9 hours)
nohup java -cp elasticsearch/target/peptidematch-elasticsearch-1.0.0-SNAPSHOT.jar \
  org.proteininformationresource.peptidematch.cli.PeptideMatchCMD index \
  -d data/inputs/uniprot_trembl_2026_04.fasta \
  --source tr \
  --index-name peptidematch_2026_04 \
  > logs/trembl-2026_04.log 2>&1 &
```

### 5. Create Alias

```bash
curl -X POST 'localhost:9200/_aliases' -H 'Content-Type: application/json' -d '{
  "actions": [
    { "add": { "index": "peptidematch_2026_04", "alias": "peptidematch_current" }}
  ]
}'
```

### 6. Start Web Service

```bash
cd peptidematchwses
mvn jetty:run
# Service starts on http://localhost:9090/peptidematchwses/
```

## API Usage

### Submit a Query

```bash
curl -X POST 'localhost:9090/peptidematchwses/asyncrest' \
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
curl -s 'localhost:9090/peptidematchwses/asyncrest/jobs/PM...'
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
│   ├── trembl-2026_04.log
│   └── web-service.log
├── elasticsearch/           # ES module (indexer, search, CLI)
├── peptidematchwses/        # Web service module
├── docs/                    # Documentation
│   ├── elasticsearch-guide.md
│   └── migration-plan.md
└── update-index.sh          # Automated index update script
```

## Modules

| Module | Description |
|--------|-------------|
| `elasticsearch` | ES indexer, search service, CLI tools |
| `peptidematchwses` | RESTful web service (Jetty) |

## Testing

```bash
# Run all tests
mvn test

# Run FASTA vs Index comparison test
mvn test -Dtest=FastaVsIndexTest -Dtest.index=peptidematch_2026_04

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
