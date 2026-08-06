package org.proteininformationresource.peptidematch.asyncrest.model;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.junit.Test;

public class ModelTest {

	@Test
	public void testPeptideConstructorAndEquals() {
		Peptide a = new Peptide("P1", "ACDE");
		Peptide b = new Peptide("P1", "ACDE");
		assertEquals("P1", a.getId());
		assertEquals("ACDE", a.getSequence());
		assertTrue(a.equals(b));
		assertEquals(a.hashCode(), b.hashCode());
		assertTrue(a.toString().contains("P1"));
		assertTrue(a.toString().contains("ACDE"));
	}

	@Test
	public void testPeptideSetters() {
		Peptide peptide = new Peptide();
		peptide.setId("Q1");
		peptide.setSequence("MKTA");
		assertEquals("Q1", peptide.getId());
		assertEquals("MKTA", peptide.getSequence());
	}

	@Test
	public void testMatchDefaultConstructor() {
		Match match = new Match();
		assertNull(match.getAc());
		assertNull(match.getMatchPeps());
	}

	@Test
	public void testMatchConstructorAndSetters() {
		Match match = new Match("P12345", Arrays.asList("ACDE"));
		assertEquals("P12345", match.getAc());
		assertEquals(Arrays.asList("ACDE"), match.getMatchPeps());
		match.setAc("Q67890");
		match.setMatchPeps(Arrays.asList("MKTA", "TIDE"));
		assertEquals("Q67890", match.getAc());
		assertEquals(2, match.getMatchPeps().size());
	}

	@Test
	public void testOrganismConstructorAndSetters() {
		Organism organism = new Organism("Homo sapiens", 9606);
		assertEquals("Homo sapiens", organism.getName());
		assertEquals(9606, organism.getTaxonId());
		organism.setName("Mus musculus");
		organism.setTaxonId(10090);
		assertEquals("Mus musculus", organism.getName());
		assertEquals(10090, organism.getTaxonId());
	}

	@Test
	public void testMatchedRange() {
		MatchedRange range = new MatchedRange(1, 5, new int[] { 2, 4 });
		assertEquals(1, range.getStart());
		assertEquals(5, range.getEnd());
		assertEquals(2, range.getlEqiPositionList().length);
		assertTrue(range.toString().contains("1"));
		range.setStart(3);
		range.setEnd(7);
		range.setlEqiPositionList(new int[] { 4 });
		assertEquals(3, range.getStart());
		assertEquals(7, range.getEnd());
		assertEquals(1, range.getlEqiPositionList().length);
	}

	@Test
	public void testMatchResultNullListBecomesEmpty() {
		MatchResult result = new MatchResult(new Peptide("P1", "ACDE"), null);
		assertNotNull(result.getMatchedProteinList());
		assertTrue(result.getMatchedProteinList().isEmpty());
	}

	@Test
	public void testMatchResultWithList() {
		List<MatchedProtein> proteins = new ArrayList<MatchedProtein>();
		proteins.add(new MatchedProtein());
		MatchResult result = new MatchResult(new Peptide("P1", "ACDE"), proteins);
		assertEquals(1, result.getMatchedProteinList().size());
		assertEquals("P1", result.getQueryPeptide().getId());
	}

	@Test
	public void testMatchResultSetters() {
		MatchResult result = new MatchResult();
		result.setQueryPeptide(new Peptide("P2", "MKTA"));
		result.setMatchedProteinList(new ArrayList<MatchedProtein>());
		assertEquals("P2", result.getQueryPeptide().getId());
		assertEquals(0, result.getMatchedProteinList().size());
	}

	@Test
	public void testReport() {
		List<Match> matches = new ArrayList<Match>();
		matches.add(new Match("P12345", Arrays.asList("ACDE")));
		Report report = new Report(matches);
		assertEquals(1, report.getMatchList().size());
		report.setMatchResults(new ArrayList<Match>());
		assertEquals(0, report.getMatchList().size());
	}

	@Test
	public void testLog() {
		Log log = new Log("search", "start", "end", 100L, "ACDE", "9606", "Y");
		assertEquals("search", log.getTaskName());
		assertEquals("start", log.getStartTime());
		assertEquals("end", log.getEndTime());
		assertEquals(100L, log.getDurationInMilliseconds());
		assertEquals("ACDE", log.getPeptideSearched());
		assertEquals("9606", log.getTaxonIds());
		assertEquals("Y", log.getlEQi());
		log.setTaskName("index");
		log.setStartTime("s");
		log.setEndTime("e");
		log.setDurationInMilliseconds(200L);
		log.setPeptideSearched("MKTA");
		log.setTaxonIds("10090");
		log.setlEQi("N");
		assertEquals("index", log.getTaskName());
		assertEquals(200L, log.getDurationInMilliseconds());
	}
}
