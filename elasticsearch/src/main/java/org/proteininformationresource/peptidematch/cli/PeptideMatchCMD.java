package org.proteininformationresource.peptidematch.cli;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import org.proteininformationresource.peptidematch.config.ESClientFactory;
import org.proteininformationresource.peptidematch.indexer.ESIndexer;
import org.proteininformationresource.peptidematch.search.ESSearchService;
import org.proteininformationresource.peptidematch.search.ESSearchService.SearchResult;
import org.proteininformationresource.peptidematch.search.MatchPositionFinder;
import org.proteininformationresource.peptidematch.search.MatchPositionFinder.MatchRange;

/**
 * Elasticsearch-based CLI for PeptideMatch.
 * Replaces the Lucene 4.6-based PeptideMatchCMD.
 *
 * Usage:
 *   java -jar peptidematch-es.jar index -d <dataFile> [--delete-existing] [--batch-size N]
 *   java -jar peptidematch-es.jar query -q <peptides> -o <outputFile> [-e] [--size N]
 *   java -jar peptidematch-es.jar query -Q <queryFile> -o <outputFile> [-e] [-l] [--size N]
 */
public class PeptideMatchCMD {

    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            printUsage();
            return;
        }

        String action = args[0];
        switch (action) {
            case "index" -> runIndex(args);
            case "query" -> runQuery(args);
            default -> {
                System.err.println("Unknown action: " + action);
                printUsage();
            }
        }
    }

    private static void runIndex(String[] args) throws IOException {
        String dataFile = null;
        boolean deleteExisting = false;
        int batchSize = 5000;
        String source = "tr";

        for (int i = 1; i < args.length; i++) {
            switch (args[i]) {
                case "-d", "--dataFile" -> dataFile = args[++i];
                case "--delete-existing" -> deleteExisting = true;
                case "--batch-size" -> batchSize = Integer.parseInt(args[++i]);
                case "--source" -> source = args[++i];
                case "-h", "--help" -> { printUsage(); return; }
            }
        }

        if (dataFile == null) {
            System.err.println("Error: -d <dataFile> is required for index action");
            System.exit(1);
        }

        File file = new File(dataFile);
        if (!file.exists()) {
            System.err.println("Error: file not found: " + dataFile);
            System.exit(1);
        }

        ElasticsearchClient client = ESClientFactory.createClient();
        ESIndexer indexer = new ESIndexer(client, batchSize);
        indexer.createIndex(deleteExisting);

        long start = System.currentTimeMillis();
        indexer.indexDataFile(file, source);
        indexer.optimizeIndex();

        long elapsed = System.currentTimeMillis() - start;
        System.out.printf("Indexing complete: %d documents in %.1f seconds%n",
                indexer.getIndexedCount(), elapsed / 1000.0);

        client._transport().close();
    }

    private static void runQuery(String[] args) throws IOException {
        String peptides = null;
        String queryFile = null;
        String outputFile = null;
        boolean lEqi = false;
        boolean listMode = false;
        int size = 10000;

        for (int i = 1; i < args.length; i++) {
            switch (args[i]) {
                case "-q", "--query" -> peptides = args[++i];
                case "-Q", "--queryFile" -> queryFile = args[++i];
                case "-o", "--outputFile" -> outputFile = args[++i];
                case "-e", "--leqi" -> lEqi = true;
                case "-l", "--list" -> listMode = true;
                case "--size" -> size = Integer.parseInt(args[++i]);
                case "-h", "--help" -> { printUsage(); return; }
            }
        }

        if (outputFile == null) {
            System.err.println("Error: -o <outputFile> is required for query action");
            System.exit(1);
        }

        List<String> queries = new ArrayList<>();
        if (peptides != null) {
            for (String p : peptides.split(",")) {
                queries.add(p.trim());
            }
        } else if (queryFile != null) {
            queries = listMode ? readListFile(queryFile) : readFastaFile(queryFile);
        } else {
            System.err.println("Error: -q <peptides> or -Q <queryFile> is required");
            System.exit(1);
        }

        if (queries.isEmpty()) {
            System.err.println("Error: no query peptides found");
            System.exit(1);
        }

        ElasticsearchClient client = ESClientFactory.createClient();
        ESSearchService searchService = new ESSearchService(client);

        long start = System.currentTimeMillis();
        String leqiFlag = lEqi ? "Y" : "N";

        try (PrintWriter pw = new PrintWriter(outputFile)) {
            pw.println("##Query\tSubject\tSubjectLength\tMatchStart\tMatchEnd" +
                    (lEqi ? "\tMatchedLEqIPositions" : ""));

            for (String query : queries) {
                SearchResult result = searchService.searchByPeptide(
                        query, "", "", "", "", leqiFlag, 0, size, "ac_asc");

                if (result.totalFound() == 0) {
                    pw.println(query + "\tNo match");
                    System.out.println(query + "\thas no match");
                    continue;
                }

                System.out.println(query + "\thas " + result.totalFound() + " match"
                        + (result.totalFound() > 1 ? "es" : ""));

                for (var hit : result.hits()) {
                    String subjectId = (String) hit.get("ac");
                    String seq = (String) hit.get("originalSeq");
                    int subjectLength = seq.length();

                    List<MatchRange> matches = MatchPositionFinder.findMatches(
                            query, seq, lEqi);

                    for (MatchRange match : matches) {
                        StringBuilder lEqiPos = new StringBuilder();
                        if (match.replacedPositions() != null) {
                            for (int pos : match.replacedPositions()) {
                                if (lEqiPos.length() > 0) lEqiPos.append(",");
                                lEqiPos.append(pos);
                            }
                        }
                        pw.printf("%s\t%s\t%d\t%d\t%d%s%n",
                                query, subjectId, subjectLength,
                                match.start(), match.end(),
                                lEqiPos.length() > 0 ? "\t" + lEqiPos : "");
                    }
                }
            }
        }

        long elapsed = System.currentTimeMillis() - start;
        System.out.println("\nQuery finished. Results saved in " + outputFile);
        DateFormat df = new SimpleDateFormat("d 'days', HH 'hours', mm 'mins,' ss.SSS 'seconds'");
        df.setTimeZone(TimeZone.getTimeZone("GMT+0"));
        System.out.println("Time used: " + df.format(new Date(elapsed)));

        client._transport().close();
    }

    private static List<String> readListFile(String path) throws IOException {
        List<String> queries = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(path))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (!line.isEmpty()) queries.add(line);
            }
        }
        return queries;
    }

    private static List<String> readFastaFile(String path) throws IOException {
        List<String> queries = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(path))) {
            String line;
            StringBuilder seq = new StringBuilder();
            while ((line = br.readLine()) != null) {
                if (line.startsWith(">")) {
                    if (seq.length() > 0) {
                        queries.add(seq.toString().replaceAll("\\n", ""));
                        seq.setLength(0);
                    }
                } else {
                    seq.append(line.trim()).append("\n");
                }
            }
            if (seq.length() > 0) {
                queries.add(seq.toString().replaceAll("\\n", ""));
            }
        }
        return queries;
    }

    private static void printUsage() {
        System.out.println("""
            PeptideMatch (Elasticsearch) - Peptide-protein matching tool

            Usage:
              peptidematch index -d <dataFile> [options]
              peptidematch query -q <peptides> -o <outputFile> [options]
              peptidematch query -Q <queryFile> -o <outputFile> [options]

            Index options:
              -d, --dataFile <path>       FASTA file to index
              --delete-existing           Delete and recreate the index
              --batch-size <N>            Bulk batch size (default: 5000)
              --source <sp|tr>            Source type: sp=Swiss-Prot, tr=TrEMBL (default: tr)

            Query options:
              -q, --query <peptides>      Comma-separated peptide sequences
              -Q, --queryFile <path>      File with peptide sequences
              -o, --outputFile <path>     Output file (tab-delimited)
              -e, --leqi                  Treat L and I as equivalent
              -l, --list                  Query file is one peptide per line
              --size <N>                  Max results per query (default: 10000)

            General:
              -h, --help                  Print this message
            """);
    }
}
