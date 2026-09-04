#!/bin/bash
JAR=/data/chenc/2026/PeptideMatch/elasticsearch/target/peptidematch-elasticsearch-1.0.0-SNAPSHOT.jar
MAIN=org.proteininformationresource.peptidematch.cli.PeptideMatchCMD
SPROT=/data/chenc/2026/PeptideMatch/data/inputs/uniprot_sprot.fasta
TREMBL=/data/chenc/2026/PeptideMatch/data/inputs/uniprot_trembl.fasta
LOG=/data/chenc/2026/PeptideMatch/data/reindex.log

echo "[$(date)] Indexing Swiss-Prot..." >> "$LOG"
java -cp "$JAR" "$MAIN" index -d "$SPROT" --source sp >> "$LOG" 2>&1
echo "[$(date)] Swiss-Prot done." >> "$LOG"

echo "[$(date)] Indexing TrEMBL (batch=10000)..." >> "$LOG"
java -cp "$JAR" "$MAIN" index -d "$TREMBL" --source tr --batch-size 10000 >> "$LOG" 2>&1
echo "[$(date)] All done." >> "$LOG"
