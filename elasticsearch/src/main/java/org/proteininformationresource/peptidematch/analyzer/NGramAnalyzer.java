package org.proteininformationresource.peptidematch.analyzer;

/**
 * NGramAnalyzer placeholder for CLI tool compatibility.
 *
 * In the Elasticsearch migration, NGram tokenization is handled by the ES index
 * analyzer (peptide_ngram_tokenizer with min_gram=3, max_gram=3).
 *
 * This class exists only for backward compatibility with the CLI tool
 * (peptidematch_cmd) which uses direct Lucene indexing.
 *
 * @deprecated Use ES index analyzer instead. This class will be removed
 * when the CLI tool is migrated to use ES.
 */
@Deprecated
public class NGramAnalyzer {

    public static final int DEFAULT_MIN_NGRAM_SIZE = 3;
    public static final int DEFAULT_MAX_NGRAM_SIZE = 3;

    private final int minGram;
    private final int maxGram;

    public NGramAnalyzer(int minGram, int maxGram) {
        this.minGram = minGram;
        this.maxGram = maxGram;
    }

    public NGramAnalyzer() {
        this(DEFAULT_MIN_NGRAM_SIZE, DEFAULT_MAX_NGRAM_SIZE);
    }

    public int getMinGram() {
        return minGram;
    }

    public int getMaxGram() {
        return maxGram;
    }

    /**
     * Decompose a peptide string into overlapping trigrams.
     * This mirrors what the ES ngram tokenizer does at index/query time.
     *
     * @param peptide the input peptide sequence
     * @return array of trigram tokens
     */
    public String[] getTrigrams(String peptide) {
        if (peptide == null || peptide.length() < minGram) {
            return new String[0];
        }
        int count = peptide.length() - minGram + 1;
        String[] trigrams = new String[count];
        for (int i = 0; i < count; i++) {
            trigrams[i] = peptide.substring(i, i + minGram).toLowerCase();
        }
        return trigrams;
    }
}
