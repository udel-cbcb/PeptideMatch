# PeptideMatch: Solr → Elasticsearch Migration Plan

## Overview

Migrate PeptideMatch from Apache Solr 3.5 (EOL) to Elasticsearch 8.x, preserving the NGram-based trigram phrase query approach for peptide-protein matching across ~116M UniProtKB sequences.

**Goal**: Replace Solr with Elasticsearch while maintaining query correctness, improving operational maturity, and eliminating tech debt (multiple Lucene versions, duplicated analyzer classes, no build system).

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

## Phase 1: Elasticsearch Index Design & Proof of Concept

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
      "lToiSeq":          { "type": "text", "analyzer": "peptide_ngram_ltoi" },
      "length":           { "type": "integer" }
    }
  }
}
```

**Note on `lToiSeq`**: The L→I substitution must happen at index time (preprocessing the sequence before indexing), same as the current approach. ES ngram tokenizer cannot do character substitution.

### 1.2 Query Translation

Current Solr pattern:
```java
// Manual trigram decomposition
String phraseQuery = "originalSeq:\"" + trigrams.join("+") + "\"";
```

Elasticsearch equivalent:
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

Elasticsearch:
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

Elasticsearch:
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

### 2.1 Replace SolrJ with Elasticsearch Java Client

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
- Apply L→I substitution during preprocessing (before indexing `lToiSeq`).
- Apply document-level boost via `function_score` or index-time numeric field.

### 3.2 Index Aliases for Zero-Downtime Reindexing

- Use index aliases (`peptidematch_v1`, `peptidematch_v2`, alias `peptidematch_current` → active version).
- Monthly reindex: build new index, swap alias, delete old index.
- Add `_aliases` API calls to the deployment script.

### 3.3 Shard Sizing

- Target shard size: 50–100GB.
- With ~116M docs (est. ~1–2KB each ≈ 150–200GB total): 2–4 primary shards + 1 replica each.
- Test with production-size data to validate.

**Exit criteria**: Full 116M document index built in ES. Alias swap tested.

---

## Phase 4: Deployment & Cutover

**Duration**: 1 week

### 4.1 Infrastructure

- Deploy ES cluster (3+ nodes minimum for production).
- Configure index lifecycle management (ILM) for monthly reindexing.
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
| Phrase query semantics differ between Solr and ES | Validate with full test suite on 10M subset before full migration |
| 116M doc indexing performance | Benchmark bulk indexing rate; tune `bulk_size` and `refresh_interval` |
| L→I equivalence correctness | Dedicated test cases for L/I replacement edge cases |
| Monthly reindex downtime | Use alias swap (zero-downtime) |
| Rollback | Keep Solr running in parallel during cutover |

---

## Timeline Summary

| Phase | Duration | Milestone |
|---|---|---|
| Phase 0: Build modernization | 1 week | Unified build, shared NGramAnalyzer |
| Phase 1: ES index design + PoC | 1–2 weeks | Query correctness validated on 10M subset |
| Phase 2: Client migration | 2 weeks | All API endpoints on ES |
| Phase 3: Indexer migration | 1–2 weeks | Full 116M index in ES |
| Phase 4: Deployment & cutover | 1 week | Production on ES |
| **Total** | **6–8 weeks** | |
