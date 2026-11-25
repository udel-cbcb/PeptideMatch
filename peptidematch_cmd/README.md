# PeptideMatchCMD

A stand-alone command-line tool for searching peptide sequences against a user's own protein sequence database, using the same n-gram index approach as the Peptide Match service.

The tool has two actions:

1. **index**: build a Lucene index from a protein sequence database in FASTA format.
2. **query**: search peptide sequences against that index. Queries can be a single peptide, a comma-separated list of peptides, or a file in FASTA format or with one peptide per line.

## Requirements
- Java 7 or later
- Libraries (the versions used in development): `lucene-core-4.6.0.jar`, `lucene-analyzers-common-4.6.0.jar`, `lucene-queryparser-4.6.0.jar`, `commons-cli-1.2.jar` and `commons-io-2.4.jar`, placed in `lib/`

## Build
From this directory:

```bash
mkdir -p build
javac -cp "lib/*" -d build $(find src -name '*.java')
```

On Windows, use `;` instead of `:` in the classpath in the commands below.

## Run
Show all options:

```bash
java -cp "build:lib/*" org.proteininformationresource.PeptideMatch.PeptideMatchCMD -h
```

| Option | Description |
|---|---|
| `-a`, `--action` | `index` or `query` (required) |
| `-i`, `--indexDir` | Directory where the index is stored (required) |
| `-d`, `--dataFile` | FASTA file to index (required for `index`) |
| `-f`, `--force` | Overwrite an existing index directory |
| `-q`, `--query` | One peptide, or a comma-separated list of peptides |
| `-Q`, `--queryFile` | File of query peptides, in FASTA format or one per line |
| `-l`, `--list` | The query file has one peptide per line (not FASTA) |
| `-e`, `--LeqI` | Treat leucine (L) and isoleucine (I) as equivalent |
| `-o`, `--outputFile` | Result file (required for `query`) |

### Examples

```bash
# Build an index from a FASTA database
java -cp "build:lib/*" org.proteininformationresource.PeptideMatch.PeptideMatchCMD \
  -a index -d my_proteins.fasta -i my_index

# Search two peptides, treating L and I as equivalent
java -cp "build:lib/*" org.proteininformationresource.PeptideMatch.PeptideMatchCMD \
  -a query -i my_index -q AAVEEGIVLGGGCALLR,VWLRRCT -e -o results.tsv

# Search a file with one peptide per line
java -cp "build:lib/*" org.proteininformationresource.PeptideMatch.PeptideMatchCMD \
  -a query -i my_index -Q peptides.txt -l -o results.tsv
```

### Output
The result file is tab-delimited, with one line per match: query, subject (protein ID), subject length, match start and match end. With `-e`, an extra column lists the positions where L and I were treated as equivalent. Queries with no match are listed with `No match`.
