package org.proteininformationresource.PeptideMatch;

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

	private List<String> tokenize(String input, int nGram) throws IOException {
		NGramAnalyzer analyzer = new NGramAnalyzer(nGram);
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
	public void testThreeGramTokens() throws IOException {
		List<String> tokens = tokenize("PEPTIDE", 3);
		assertTrue("expected tokens, got: " + tokens, tokens.size() > 0);
		assertTrue("expected 'pep' token, got: " + tokens, tokens.contains("pep"));
		assertTrue("expected 'ide' token, got: " + tokens, tokens.contains("ide"));
		assertTrue("expected 'tid' token, got: " + tokens, tokens.contains("tid"));
	}

	@Test
	public void testTokensAreLowerCased() throws IOException {
		List<String> tokens = tokenize("AAA", 3);
		for (String token : tokens) {
			assertEquals(token.toLowerCase(), token);
		}
	}

	@Test
	public void testFourGramTokens() throws IOException {
		List<String> tokens = tokenize("PEPTIDE", 4);
		assertTrue("expected 'pept' token, got: " + tokens, tokens.contains("pept"));
		assertTrue("expected 'tide' token, got: " + tokens, tokens.contains("tide"));
	}

	@Test
	public void testNoTokensForTooShortInput() throws IOException {
		List<String> tokens = tokenize("AA", 3);
		assertEquals(0, tokens.size());
	}
}
