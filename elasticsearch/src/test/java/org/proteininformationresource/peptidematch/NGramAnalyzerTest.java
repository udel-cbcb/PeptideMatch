package org.proteininformationresource.peptidematch;

import org.junit.jupiter.api.Test;
import org.proteininformationresource.peptidematch.analyzer.NGramAnalyzer;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for the consolidated NGramAnalyzer.
 * Tests trigram decomposition logic (mirrors ES ngram tokenizer behavior).
 */
class NGramAnalyzerTest {

    @Test
    void testTrigramDecomposition() {
        NGramAnalyzer analyzer = new NGramAnalyzer(3, 3);

        // "ACDEF" should produce trigrams: acd, cde, def
        String[] trigrams = analyzer.getTrigrams("ACDEF");
        assertEquals(3, trigrams.length);
        assertEquals("acd", trigrams[0]);
        assertEquals("cde", trigrams[1]);
        assertEquals("def", trigrams[2]);
    }

    @Test
    void testTrigramDecomposition_lowercase() {
        NGramAnalyzer analyzer = new NGramAnalyzer(3, 3);

        String[] trigrams = analyzer.getTrigrams("MSEQ");
        assertEquals(2, trigrams.length);
        assertEquals("mse", trigrams[0]);
        assertEquals("seq", trigrams[1]);
    }

    @Test
    void testLongerSequence() {
        NGramAnalyzer analyzer = new NGramAnalyzer(3, 3);

        // "ACDEFGH" (7 chars) -> 5 trigrams
        String[] trigrams = analyzer.getTrigrams("ACDEFGH");
        assertEquals(5, trigrams.length);
        assertEquals("acd", trigrams[0]);
        assertEquals("cde", trigrams[1]);
        assertEquals("def", trigrams[2]);
        assertEquals("efg", trigrams[3]);
        assertEquals("fgh", trigrams[4]);
    }

    @Test
    void testShortSequence_noTokens() {
        NGramAnalyzer analyzer = new NGramAnalyzer(3, 3);

        // "AC" (2 chars) -> 0 trigrams for n=3
        String[] trigrams = analyzer.getTrigrams("AC");
        assertEquals(0, trigrams.length);
    }

    @Test
    void testDefaultConstructor() {
        NGramAnalyzer analyzer = new NGramAnalyzer();
        assertEquals(3, analyzer.getMinGram());
        assertEquals(3, analyzer.getMaxGram());
    }

    @Test
    void testCustomGramSize() {
        NGramAnalyzer analyzer = new NGramAnalyzer(2, 5);
        assertEquals(2, analyzer.getMinGram());
        assertEquals(5, analyzer.getMaxGram());
    }

    @Test
    void testNullInput() {
        NGramAnalyzer analyzer = new NGramAnalyzer(3, 3);
        String[] trigrams = analyzer.getTrigrams(null);
        assertEquals(0, trigrams.length);
    }

    @Test
    void testExactTrigramLength() {
        NGramAnalyzer analyzer = new NGramAnalyzer(3, 3);

        // Exactly 3 chars -> 1 trigram
        String[] trigrams = analyzer.getTrigrams("ABC");
        assertEquals(1, trigrams.length);
        assertEquals("abc", trigrams[0]);
    }
}
