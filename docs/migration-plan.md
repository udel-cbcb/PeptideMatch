# PeptideMatch: Solr → ElasticSearch Migration Plan

## Overview

Migrate PeptideMatch from Apache Solr 3.5 (EOL) to ElasticSearch 8.x, preserving the NGram-based trigram phrase query approach for peptide-protein matching across ~155M UniProtKB sequences.

**Goal**: Replace Solr with ElasticSearch while maintaining query correctness, improving operational maturity, and eliminating tech debt (multiple Lucene versions, duplicated analyzer classes, no build system).

## Current Status (September 2026)

✅ **Phase 0-3 Complete**: Build system, ES index design, client migration, and indexer migration are all done.

**Index Statistics:**
- Total documents: 150,006,383 (575,748 Swiss-Prot + 149,430,635 TrEMBL)
- Index size: 338GB across 16 shards
- Query latency: 20-50ms (warm, cached)
- Indexing rate: ~6,500 docs/sec

**Implemented Features:**
- Full peptide search with trigram phrase queries
- L/I equivalence matching
- Swiss-Prot/TrEMBL filtering
- Taxonomy filtering
- Isoform filtering
- JSON output format
- `search_after` pagination for deep results
- Async REST web service with streaming
- Versioned indexes with alias support for zero-downtime updates
- `--index-name` CLI flag for custom index names
- Automated update script (`update-index.sh`)

---

## Phase 0: Foundation & Build Modernization

**Duration**: 1 week

- Introduce Maven or Gradle build system for all Java modules.
- Consolidate the 4 copies of `NGramAnalyzer.java` into a single shared module.
- Unify on a single Lucene version (latest 9.x, aligned with ES 8.x).
- Set up CI pipeline (build, test, lint).
- Document current query behavior with integration tests (capture expected results for regression testing).

**Exit criteria**: All modules build from a single build tool. Test suite passes.

---

## Phase 1: ElasticSearch Index Design & Proof of Concept

**Duration**: 1–2 weeks

### 1.1 Index Mapping

Create a custom index mapping that mirrors the current Solr schema:

```json
{
  "settings": {
    "analysis": {
      "analyzer": {
        "peptide_ngram": {
          "tokenizer": "peptide_ngram_tokenizer",
          "filter": ["lowercase"]
        },
        "peptide_ngram_ltoi": {
          "tokenizer": "peptide_ngram_tokenizer_ltoi",
          "filter": ["lowercase"]
        },
        "lineage_standard": {
          "tokenizer": "standard"
        }
      },
      "tokenizer": {
        "peptide_ngram_tokenizer": {
          "type": "ngram",
          "min_gram": 3,
          "max_gram": 3
        },
        "peptide_ngram_tokenizer_ltoi": {
          "type": "ngram",
          "min_gram": 3,
          "max_gram": 3,
          "token_chars": ["letter"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "ac":               { "type": "keyword" },
      "proteinID":        { "type": "keyword" },
      "proteinName":      { "type": "keyword" },
      "organismName":     { "type": "keyword" },
      "organismID":       { "type": "keyword" },
      "taxongroupName":   { "type": "keyword" },
      "taxongroupID":     { "type": "keyword" },
      "nist":             { "type": "keyword" },
      "peptideAtlas":     { "type": "keyword" },
      "pride":            { "type": "keyword" },
      "iedb":             { "type": "keyword" },
      "fullLineage":      { "type": "text", "analyzer": "lineage_standard" },
      "shortLineage":     { "type": "text", "analyzer": "lineage_standard" },
      "uniref100":        { "type": "keyword" },
      "sptr":             { "type": "keyword" },
      "isoform":          { "type": "keyword" },
      "originalSeq":      { "type": "text", "analyzer": "peptide_ngram" },
      "originalSeq.ltoi": { "type": "text", "analyzer": "peptide_ngram_ltoi" },
      "length":           { "type": "integer" }
    }
  }
}
```

**Note on L/I equivalence**: The `originalSeq.ltoi` sub-field uses a `char_filter` (mapping type) to replace L→I at index time. At query time, the query text also has L→I replacement before searching this sub-field.

### 1.2 Query Translation

Current Solr pattern:
```java
// Manual trigram decomposition
String phraseQuery = "originalSeq:\"" + trigrams.join("+") + "\"";
```

ElasticSearch equivalent:
```json
{
  "match_phrase": {
    "originalSeq": {
      "query": "ACDEF",
      "analyzer": "peptide_ngram"
    }
  }
}
```

ES decomposes the query into trigrams using the same analyzer — no manual substring slicing needed.

### 1.3 Filter Queries → Bool Filter

Current Solr:
```
q=originalSeq:"acd+cde+def" &fq=uniref100:Y &fq=organismID:9606
```

ElasticSearch:
```json
{
  "bool": {
    "must": [
      { "match_phrase": { "originalSeq": { "query": "ACDEF", "analyzer": "peptide_ngram" } } }
    ],
    "filter": [
      { "term": { "uniref100": "Y" } },
      { "term": { "organismID": "9606" } }
    ]
  }
}
```

### 1.4 Aggregations → Organism Grouping

Current Solr grouping:
```java
params.add(GroupParams.GROUP_FIELD, "organismID");
params.add(GroupParams.GROUP_LIMIT, "100");
```

ElasticSearch:
```json
{
  "aggs": {
    "by_organism": {
      "terms": { "field": "organismID", "size": 500 },
      "aggs": { "top_hits": { "top_hits": { "size": 1 } } }
    }
  }
}
```

### 1.5 Proof of Concept

- Load a 10M document subset into ES.
- Run the existing test queries against both Solr and ES.
- Compare result counts and match positions.
- Benchmark query latency (target: ≤ current Solr latency).

**Exit criteria**: All test queries return identical results. Latency ≤ Solr baseline on 10M subset.

---

## Phase 2: Client Library Migration

**Duration**: 2 weeks

### 2.1 Replace SolrJ with ElasticSearch Java Client

- Add `elasticsearch-java` (or `elasticsearch-rest-high-level-client`) dependency.
- Create a new `ElasticSearchMatchService` class parallel to the existing `MatchService`.
- Implement all query variants:
  - `queryByPeptide()`
  - `queryByPeptideWithOrganism()`
  - `queryByPeptideWithMultiOrganism()`
  - `queryByPeptideWithOrganismAndGroup()`
  - `queryByPeptideWithTaxonId()`
  - `queryByPeptideWithFullLineageTaxonId()`
  - `queryByPeptideWithShortLineageOrganismAndTaxonId()`
  - `queryByPeptideWithGroup()` (aggregation-based)
  - `queryByID()`

### 2.2 Update API Layer

- `peptidematchapi2`: Update `MatchGetApiServiceImpl` and `MatchPostApiServiceImpl` to use ES client.
- `peptidematchws`: Update `MatchService` in the async REST layer.
- `peptidematch_web`: Update `PeptideMatchWS` servlet.

### 2.3 Remove Solr Dependencies

- Remove SolrJ JARs.
- Remove embedded Jetty/Solr deployment.
- Remove `solr.properties`.
- Update `classpath.txt`.

**Exit criteria**: All API endpoints functional with ES backend. Solr JARs removed.

---

## Phase 3: Indexer Migration

**Duration**: 1–2 weeks

### 3.1 Replace NGramIndexer

- Create `ESIndexer.java` using `BulkProcessor` or `_bulk` API.
- Read from the same enriched FASTA input (output of `create_data` pipeline).
- Apply L→I substitution via `originalSeq.ltoi` sub-field with char_filter at index time.
- Apply document-level boost via `function_score` or index-time numeric field.

### 3.2 Index Aliases for Zero-Downtime Reindexing

- Use index aliases (`peptidematch_v1`, `peptidematch_v2`, alias `peptidematch_current` → active version).
- Quarterly reindex: build new index, swap alias, delete old index.
- Add `_aliases` API calls to the deployment script.

### 3.3 Shard Sizing

- Target shard size: 50–100GB.
- With ~155M docs (est. ~2KB each ≈ ~340GB total): 16 primary shards + 1 replica each.
- Tested with production-size data to validate.

**Exit criteria**: Full 155M document index built in ES. Shard balance validated.

---

## Phase 4: Deployment & Cutover

**Duration**: 1 week

### 4.1 Infrastructure

- Deploy ES cluster (3+ nodes minimum for production).
- Configure index lifecycle management (ILM) for quarterly reindexing.
- Set up monitoring (cluster health, query latency, indexing rate).

### 4.2 Parallel Run

- Run Solr and ES in parallel for 1–2 weeks.
- Compare results via shadow traffic or dual-query approach.
- Validate no regressions in match counts or positions.

### 4.3 Cutover

- Switch DNS/load balancer to ES-backed API.
- Keep Solr running (read-only) for 1 week as rollback option.
- Decommission Solr after validation period.

**Exit criteria**: Production traffic served by ES. Solr decommissioned.

---

## Risk Mitigation

| Risk | Mitigation |
|---|---|
| Phrase query semantics differ between Solr and ES | Validated with full test suite on 155M documents |
| 155M doc indexing performance | Bulk indexing at ~6,500 docs/sec; ~7 hours for full reindex |
| L→I equivalence correctness | Dedicated test cases for L/I replacement edge cases |
| Quarterly reindex downtime | Use alias swap (zero-downtime) |
| Rollback | Keep Solr running in parallel during cutover |

---

## Timeline Summary

| Phase | Duration | Milestone | Status |
|---|---|---|---|
| Phase 0: Build modernization | 1 week | Unified build, shared NGramAnalyzer | ✅ Complete |
| Phase 1: ES index design + PoC | 1–2 weeks | Query correctness validated on 10M subset | ✅ Complete |
| Phase 2: Client migration | 2 weeks | All API endpoints on ES | ✅ Complete |
| Phase 3: Indexer migration | 1–2 weeks | Full 155M index in ES | ✅ Complete |
| Phase 4: Deployment & cutover | 1 week | Production deployment | 🔄 In Progress |

---

## UniProt Release Update Workflow

UniProt releases quarterly (e.g., `2026_01`, `2026_02`, `2026_03`). PeptideMatch supports zero-downtime updates using versioned indexes and aliases.

### Index Naming Convention

- **Versioned index**: `peptidematch_YYYY_MM` (e.g., `peptidematch_2026_03`)
- **Alias**: `peptidematch_current` (always points to active index)

### Update Script

```bash
# Automated update
./update-index.sh

# Manual steps
VERSION=2026_03
# 1. Download FASTA files
# 2. Create index peptidematch_${VERSION}
# 3. Index Swiss-Prot + TrEMBL
# 4. Forcemerge to 16 segments
# 5. Swap alias to new index
# 6. Delete old indexes (keep last 3)
```

### Rollback

```bash
# Swap alias to previous version
curl -X POST 'localhost:9200/_aliases' -d '{
  "actions": [
    { "remove": { "index": "peptidematch_2026_03", "alias": "peptidematch_current" }},
    { "add":    { "index": "peptidematch_2026_02", "alias": "peptidematch_current" }}
  ]
}'
```
| **Total** | **6–8 weeks** | | |
