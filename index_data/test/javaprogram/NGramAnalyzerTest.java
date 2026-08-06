package javaprogram;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;
import org.junit.Test;

public class NGramAnalyzerTest {

	private List<String> tokenize(String input, int min, int max) throws IOException {
		NGramAnalyzer analyzer = new NGramAnalyzer(min, max);
		TokenStream ts = analyzer.tokenStream("field", new StringReader(input));
		CharTermAttribute termAtt = ts.addAttribute(CharTermAttribute.class);
		List<String> tokens = new ArrayList<String>();
		ts.reset();
		while (ts.incrementToken()) {
			tokens.add(termAtt.toString());
		}
		ts.end();
		ts.close();
		analyzer.close();
		return tokens;
	}

	@Test
	public void testDefaultMinNgramSize() {
		NGramAnalyzer analyzer = new NGramAnalyzer();
		assertEquals(3, analyzer.DEFAULT_MIN_NGRAM_SIZE);
		assertEquals(8, analyzer.DEFAULT_MAX_NGRAM_SIZE);
	}

	@Test
	public void testThreeGramTokens() throws IOException {
		List<String> tokens = tokenize("PEPTIDE", 3, 3);
		assertTrue("expected 'pep' token, got: " + tokens, tokens.contains("pep"));
		assertTrue("expected 'ide' token, got: " + tokens, tokens.contains("ide"));
	}

	@Test
	public void testVariableGramLengths() throws IOException {
		List<String> tokens = tokenize("PEPTIDE", 3, 4);
		assertTrue("expected 'pep' token, got: " + tokens, tokens.contains("pep"));
		assertTrue("expected 'pept' token, got: " + tokens, tokens.contains("pept"));
		assertTrue("expected 'tide' token, got: " + tokens, tokens.contains("tide"));
	}
}
