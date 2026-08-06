package query;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class HighLightTest {

	@Test
	public void testNoMatchReturnsOriginalContent() {
		HighLight highLight = new HighLight();
		assertEquals("ABCDEFG", highLight.highLight("ABCDEFG", "XYZ"));
	}

	@Test
	public void testSingleMatchAtStart() {
		HighLight highLight = new HighLight();
		String result = highLight.highLight("PEPTIDESEQUENCE", "PEPTIDE");
		assertEquals("<b id=highlight>PEPTIDE</b>SEQUENCE", result);
	}

	@Test
	public void testSingleMatchInMiddle() {
		HighLight highLight = new HighLight();
		String result = highLight.highLight("XXABCDEYY", "ABCDE");
		assertEquals("XX<b id=highlight>ABCDE</b>YY", result);
	}

	@Test
	public void testMultipleMatches() {
		HighLight highLight = new HighLight();
		String result = highLight.highLight("ABABAB", "AB");
		assertEquals("<b id=highlight>AB</b><b id=highlight>AB</b><b id=highlight>AB</b>", result);
	}

	@Test
	public void testMatchAtEnd() {
		HighLight highLight = new HighLight();
		String result = highLight.highLight("XXABCDE", "ABCDE");
		assertEquals("XX<b id=highlight>ABCDE</b>", result);
	}

	@Test
	public void testQueryLongerThanContent() {
		HighLight highLight = new HighLight();
		assertEquals("ABC", highLight.highLight("ABC", "ABCDEF"));
	}

	@Test
	public void testEmptyContent() {
		HighLight highLight = new HighLight();
		assertEquals("", highLight.highLight("", "AB"));
	}
}
