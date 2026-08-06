package org.proteininformationresource.peptidematch;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class MatchedProteinTest {

	private MatchedProtein buildMatchedProtein() {
		Organism organism = new Organism("Homo sapiens", "9606");
		Organism taxGroup = new Organism("Eukaryota", "2759");
		MatchedRange[] ranges = { new MatchedRange(1, 4), new MatchedRange(9, 12) };
		MatchedProtein protein = new MatchedProtein("P12345", "P12345_HUMAN", "Y",
				"Sample protein", organism, taxGroup,
				"MKTAYIAKQRQISFVKSHFSRQ", 21, ranges);
		return protein;
	}

	@Test
	public void testGetIProClassInfo() {
		MatchedProtein protein = buildMatchedProtein();
		String info = protein.getIProClassInfo();
		assertTrue(info.startsWith(">P12345 P12345_HUMAN"));
		assertTrue(info.contains("Sample protein"));
		assertTrue(info.contains("Homo sapiens"));
		assertTrue(info.contains("9606"));
		assertTrue(info.contains("Eukaryota"));
		assertTrue(info.contains("2759"));
	}

	@Test
	public void testGetMatchedRangeInfo() {
		MatchedProtein protein = buildMatchedProtein();
		assertEquals("1-4, 9-12", protein.getMatchedRangeInfo());
	}

	@Test
	public void testGetMatchedRangeInfoWithReplacedPositions() {
		MatchedProtein protein = buildMatchedProtein();
		MatchedRange[] ranges = { new MatchedRange(1, 4) };
		ranges[0].setReplacedPos(new int[] { 2, 3 });
		protein.setMatchedRanges(ranges);
		assertEquals("1-4[L=I: 2, 3]", protein.getMatchedRangeInfo());
	}

	@Test
	public void testGetXMLInfoSwissProt() {
		MatchedProtein protein = buildMatchedProtein();
		String xml = protein.getXMLInfo(false);
		assertTrue(xml.contains("<proteinAC>P12345</proteinAC>"));
		assertTrue(xml.contains("type=\"SwissProt\">P12345_HUMAN</proteinID>"));
		assertTrue(xml.contains("<proteinName>Sample protein</proteinName>"));
		assertTrue(xml.contains("<seqLength>21</seqLength>"));
		assertTrue(xml.contains("<matchRange start=\"1\" end=\"4\">"));
		assertTrue(xml.contains("<matchRange start=\"9\" end=\"12\">"));
		assertTrue(xml.contains("</matchedProtein>"));
	}

	@Test
	public void testGetXMLInfoTrEMBL() {
		MatchedProtein protein = buildMatchedProtein();
		protein.setReviewStatus("N");
		String xml = protein.getXMLInfo(false);
		assertTrue(xml.contains("type=\"TrEMBL\">P12345_HUMAN</proteinID>"));
	}

	@Test
	public void testGetXMLInfoUniref100() {
		MatchedProtein protein = buildMatchedProtein();
		String xml = protein.getXMLInfo(true);
		assertTrue(xml.contains("<UniRef100ClusterID>UniRef100_P12345</UniRef100ClusterID>"));
		assertTrue(xml.contains("<UniRef100RepresentativeProteinAC>P12345</UniRef100RepresentativeProteinAC>"));
		assertTrue(xml.contains("<proteinAC/>"));
	}

	@Test
	public void testGetXMLInfoWithReplacedPositions() {
		MatchedProtein protein = buildMatchedProtein();
		MatchedRange[] ranges = { new MatchedRange(1, 4) };
		ranges[0].setReplacedPos(new int[] { 2 });
		protein.setMatchedRanges(ranges);
		String xml = protein.getXMLInfo(false);
		assertTrue(xml.contains("<lEqiPos>2</lEqiPos>"));
	}

	@Test
	public void testGetXMLInfoWithProteomicDBs() {
		MatchedProtein protein = buildMatchedProtein();
		protein.setNIST("Y");
		protein.setPeptideAtlas("Y");
		protein.setPride("Y");
		protein.setIEDB(new String[] { "iedb1", "iedb2" });
		String xml = protein.getXMLInfo(false);
		assertTrue(xml.contains("<nist>P12345</nist>"));
		assertTrue(xml.contains("<peptideAtlas>P12345</peptideAtlas>"));
		assertTrue(xml.contains("<pride>P12345</pride>"));
		assertTrue(xml.contains("<iedbID>iedb1</iedbID>"));
		assertTrue(xml.contains("<iedbID>iedb2</iedbID>"));
	}

	@Test
	public void testGetTabDelimitedInfoSwissProt() {
		MatchedProtein protein = buildMatchedProtein();
		String info = protein.getTabDelimitedInfo(false);
		String[] fields = info.split("\t");
		assertEquals("P12345", fields[0]);
		assertEquals("P12345_HUMAN [sp]", fields[1]);
		assertEquals("Sample protein", fields[2]);
		assertEquals("21", fields[3]);
		assertEquals("Homo sapiens [9606]", fields[4]);
		assertEquals("1-4, 9-12", fields[5]);
	}

	@Test
	public void testGetTabDelimitedInfoTrEMBL() {
		MatchedProtein protein = buildMatchedProtein();
		protein.setReviewStatus("N");
		String info = protein.getTabDelimitedInfo(false);
		assertTrue(info.contains("P12345_HUMAN [tr]"));
	}

	@Test
	public void testGetTabDelimitedInfoUniref100() {
		MatchedProtein protein = buildMatchedProtein();
		String info = protein.getTabDelimitedInfo(true);
		String[] fields = info.split("\t");
		assertEquals("UniRef100_P12345", fields[0]);
		assertEquals("P12345", fields[1]);
	}

	@Test
	public void testGetTabDelimitedInfoWithProteomicDBs() {
		MatchedProtein protein = buildMatchedProtein();
		protein.setPeptideAtlas("Y");
		protein.setPride("Y");
		String info = protein.getTabDelimitedInfo(false);
		assertTrue(info.contains("PeptideAtlas, Pride"));
	}

	@Test
	public void testSettersAndGetters() {
		MatchedProtein protein = buildMatchedProtein();
		assertEquals("P12345", protein.getProteinAC());
		assertEquals("P12345_HUMAN", protein.getProteinID());
		assertEquals("Y", protein.getReviewStatus());
		assertEquals("MKTAYIAKQRQISFVKSHFSRQ", protein.getSequence());
		assertEquals(21, protein.getSeqLength());
		assertEquals(2, protein.getMatchedRanges().length);
	}

	@Test
	public void testMatchResult() {
		MatchedProtein protein = buildMatchedProtein();
		MatchResult result = new MatchResult("ACDE", protein);
		assertEquals("ACDE", result.getQueryPeptide());
		assertEquals(protein, result.getMatchedProtein());
		result.setQueryPeptide("MKTA");
		result.setMatchedProtein(protein);
		assertEquals("MKTA", result.getQueryPeptide());
	}

	@Test
	public void testOrganismCount() {
		Organism organism = new Organism("Homo sapiens", "9606");
		OrganismCount count = new OrganismCount(organism, 5);
		assertEquals(organism, count.getOrganism());
		assertEquals(5, count.getCount());
		count.setOrganism(new Organism("Mus musculus", "10090"));
		count.setCount(10);
		assertEquals("Mus musculus", count.getOrganism().getName());
		assertEquals(10, count.getCount());
	}
}
