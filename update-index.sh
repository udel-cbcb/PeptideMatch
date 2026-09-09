#!/bin/bash
# update-index.sh - Zero-downtime UniProt index update using index aliases
#
# This script downloads the latest UniProt release, creates a new index,
# and swaps the alias to point to the new index without downtime.
#
# Usage: ./update-index.sh [--version YYYY_MM] [--dry-run] [--skip-download]
#
# Examples:
#   ./update-index.sh                    # Auto-detect latest version
#   ./update-index.sh --version 2026_03  # Use specific version
#   ./update-index.sh --dry-run          # Show what would be done
#   ./update-index.sh --skip-download    # Skip download (use pre-existing files)

set -euo pipefail

# Configuration
ES_HOST="localhost:9200"
ALIAS_NAME="peptidematch_current"
DATA_DIR="/data/chenc/2026/PeptideMatch/data/inputs"
JAR_PATH="/data/chenc/2026/PeptideMatch/elasticsearch/target/peptidematch-elasticsearch-1.0.0-SNAPSHOT.jar"
FTP_BASE="https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete"
KEEP_VERSIONS=3  # Keep last N versions for rollback

# Parse arguments
DRY_RUN=false
VERSION=""
SKIP_DOWNLOAD=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --skip-download)
            SKIP_DOWNLOAD=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Function to check if index exists
index_exists() {
    curl -s -o /dev/null -w "%{http_code}" "http://${ES_HOST}/$1" | grep -q "200"
}

# Function to get current alias target
get_current_alias() {
    RESULT=$(curl -s "http://${ES_HOST}/_alias/${ALIAS_NAME}" 2>/dev/null)
    if echo "$RESULT" | grep -q '"error"'; then
        echo ""
    else
        echo "$RESULT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for index in data:
    print(index)
" 2>/dev/null || echo ""
    fi
}

# Auto-detect version if not specified
if [ -z "$VERSION" ]; then
    log "Auto-detecting latest UniProt release version..."
    VERSION=$(curl -s "${FTP_BASE}/reldate.txt" | grep -oP '\d{4}_\d{2}' | head -1)
    if [ -z "$VERSION" ]; then
        echo "Error: Could not detect version from reldate.txt"
        exit 1
    fi
    log "Detected version: ${VERSION}"
fi

INDEX_NAME="peptidematch_${VERSION}"

# Check if index already exists
if index_exists "$INDEX_NAME"; then
    log "Index ${INDEX_NAME} already exists."
    CURRENT_ALIAS=$(get_current_alias)
    if [ "$CURRENT_ALIAS" = "$INDEX_NAME" ]; then
        log "Alias ${ALIAS_NAME} already points to ${INDEX_NAME}. Nothing to do."
        exit 0
    else
        log "Alias ${ALIAS_NAME} points to ${CURRENT_ALIAS:-none}. Will swap to ${INDEX_NAME}."
    fi
fi

# Dry run mode
if [ "$DRY_RUN" = true ]; then
    log "DRY RUN MODE - No changes will be made"
    echo ""
    echo "Would perform the following steps:"
    if [ "$SKIP_DOWNLOAD" = false ]; then
        echo "1. Download FASTA files from UniProt FTP"
    else
        echo "1. Skip download (using pre-existing files)"
    fi
    echo "2. Create index: ${INDEX_NAME}"
    echo "3. Index Swiss-Prot data"
    echo "4. Index TrEMBL data"
    echo "5. Forcemerge to 16 segments"
    echo "6. Swap alias ${ALIAS_NAME} to point to ${INDEX_NAME}"
    echo "7. Clean up old indexes (keep last ${KEEP_VERSIONS})"
    exit 0
fi

# Step 1: Download FASTA files
log "Step 1: Downloading UniProt FASTA files..."
cd "$DATA_DIR"

if [ "$SKIP_DOWNLOAD" = true ]; then
    log "Skipping download (--skip-download flag set)"
    if [ ! -f "uniprot_sprot_${VERSION}.fasta" ] || [ ! -f "uniprot_trembl_${VERSION}.fasta" ]; then
        log "Error: FASTA files not found in ${DATA_DIR}"
        log "Expected: uniprot_sprot_${VERSION}.fasta and uniprot_trembl_${VERSION}.fasta"
        exit 1
    fi
    log "FASTA files found:"
    ls -lh uniprot_sprot_${VERSION}.fasta uniprot_trembl_${VERSION}.fasta
else
    if [ ! -f "uniprot_sprot_${VERSION}.fasta" ]; then
        log "Downloading uniprot_sprot.fasta.gz..."
        wget -q "${FTP_BASE}/uniprot_sprot.fasta.gz" -O "uniprot_sprot_${VERSION}.fasta.gz"
        gunzip -k "uniprot_sprot_${VERSION}.fasta.gz"
    else
        log "Swiss-Prot FASTA already exists, skipping download"
    fi

    if [ ! -f "uniprot_trembl_${VERSION}.fasta" ]; then
        log "Downloading uniprot_trembl.fasta.gz (this may take a while)..."
        wget -q "${FTP_BASE}/uniprot_trembl.fasta.gz" -O "uniprot_trembl_${VERSION}.fasta.gz"
        gunzip -k "uniprot_trembl_${VERSION}.fasta.gz"
    else
        log "TrEMBL FASTA already exists, skipping download"
    fi
fi

# Step 2: Create new index
log "Step 2: Creating index ${INDEX_NAME}..."
if ! index_exists "$INDEX_NAME"; then
    curl -X PUT "http://${ES_HOST}/${INDEX_NAME}" \
        -H 'Content-Type: application/json' \
        -d @/data/chenc/2026/PeptideMatch/elasticsearch/src/main/resources/index-mapping.json
    log "Index ${INDEX_NAME} created"
else
    log "Index ${INDEX_NAME} already exists"
fi

# Step 3: Index Swiss-Prot data
log "Step 3: Indexing Swiss-Prot data..."
java -cp "$JAR_PATH" org.proteininformationresource.peptidematch.cli.PeptideMatchCMD \
    index \
    -d "uniprot_sprot_${VERSION}.fasta" \
    --source sp \
    --index-name "$INDEX_NAME" \
    --batch-size 5000

# Step 4: Index TrEMBL data
log "Step 4: Indexing TrEMBL data..."
java -cp "$JAR_PATH" org.proteininformationresource.peptidematch.cli.PeptideMatchCMD \
    index \
    -d "uniprot_trembl_${VERSION}.fasta" \
    --source tr \
    --index-name "$INDEX_NAME" \
    --batch-size 5000

# Step 5: Forcemerge
log "Step 5: Forcemerging to 16 segments..."
curl -X POST "http://${ES_HOST}/${INDEX_NAME}/_forcemerge?max_num_segments=16"

# Step 6: Swap alias (atomic operation)
log "Step 6: Swapping alias ${ALIAS_NAME} to ${INDEX_NAME}..."
CURRENT_INDEX=$(get_current_alias)

if [ -n "$CURRENT_INDEX" ]; then
    curl -X POST "http://${ES_HOST}/_aliases" \
        -H 'Content-Type: application/json' \
        -d "{
            \"actions\": [
                { \"remove\": { \"index\": \"${CURRENT_INDEX}\", \"alias\": \"${ALIAS_NAME}\" }},
                { \"add\":    { \"index\": \"${INDEX_NAME}\", \"alias\": \"${ALIAS_NAME}\" }}
            ]
        }"
    log "Alias swapped from ${CURRENT_INDEX} to ${INDEX_NAME}"
else
    curl -X POST "http://${ES_HOST}/_aliases" \
        -H 'Content-Type: application/json' \
        -d "{
            \"actions\": [
                { \"add\": { \"index\": \"${INDEX_NAME}\", \"alias\": \"${ALIAS_NAME}\" }}
            ]
        }"
    log "Alias ${ALIAS_NAME} created pointing to ${INDEX_NAME}"
fi

# Step 7: Clean up old indexes
log "Step 7: Cleaning up old indexes (keeping last ${KEEP_VERSIONS})..."
OLD_INDEXES=$(curl -s "http://${ES_HOST}/_cat/indices/peptidematch_*?h=index" | \
    sort -r | \
    tail -n +$((KEEP_VERSIONS + 1)) | \
    tr -d ' ')

for OLD_INDEX in $OLD_INDEXES; do
    if [ "$OLD_INDEX" != "$INDEX_NAME" ]; then
        log "Deleting old index: ${OLD_INDEX}"
        curl -X DELETE "http://${ES_HOST}/${OLD_INDEX}"
    fi
done

log "Update complete!"
log "Current index: ${INDEX_NAME}"
log "Alias ${ALIAS_NAME} now points to ${INDEX_NAME}"

# Verify
log "Verifying index stats..."
curl -s "http://${ES_HOST}/${INDEX_NAME}/_stats" | python3 -c "
import sys, json
data = json.load(sys.stdin)
primaries = data['_all']['primaries']
print(f\"  Documents: {primaries['docs']['count']:,}\")
print(f\"  Size: {primaries['store']['size_in_bytes'] / 1024 / 1024 / 1024:.2f} GB\")
"
