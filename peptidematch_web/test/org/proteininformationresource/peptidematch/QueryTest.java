package org.proteininformationresource.peptidematch;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.util.List;

import org.junit.Test;

public class QueryTest {

	@Test
	public void testDefaultValues() {
		Query query = new Query();
		assertEquals("N", query.getUniRef100Only());
		assertEquals("N", query.getLEqI());
		assertEquals("Y", query.getSwissprot());
		assertEquals("Y", query.getIsoform());
		assertEquals("tab", query.getOutputFormat());
		assertEquals("N", query.getTrOnly());
		assertEquals("N", query.getIsoOnly());
		assertEquals("", query.getErrMsg());
	}

	@Test
	public void testConstructorWithPeptides() {
		String[] peptides = { "ACDE", "MKTA" };
		Query query = new Query(peptides);
		assertEquals(2, query.getPeptides().length);
		assertEquals("ACDE", query.getPeptides()[0]);
	}

	@Test
	public void testSetters() {
		Query query = new Query();
		String[] peptides = { "ACDE" };
		query.setPeptides(peptides);
		query.setPeptideIds(new String[] { "P1" });
		query.setUniRef100Only("Y");
		query.setLEqI("Y");
		query.setSwissprot("N");
		query.setIsoform("N");
		query.setTrOnly("Y");
		query.setIsoOnly("Y");
		query.setErrMsg("some error");
		query.setOriginalQueryPeptides("ACDE");
		query.setOutputFormat("xml");

		assertEquals("ACDE", query.getPeptides()[0]);
		assertEquals("P1", query.getPeptideIds()[0]);
		assertEquals("Y", query.getUniRef100Only());
		assertEquals("Y", query.getLEqI());
		assertEquals("N", query.getSwissprot());
		assertEquals("N", query.getIsoform());
		assertEquals("Y", query.getTrOnly());
		assertEquals("Y", query.getIsoOnly());
		assertEquals("some error", query.getErrMsg());
		assertEquals("ACDE", query.getOriginalQueryPeptides());
		assertEquals("xml", query.getOutputFormat());
	}

	@Test
	public void testGetQueryPeptides() {
		String[] peptides = { "ACDE", "MKTA" };
		String[] ids = { "P1", "P2" };
		Query query = new Query(peptides);
		query.setPeptideIds(ids);
		List<QueryPeptide> result = query.getQueryPeptides();
		assertEquals(2, result.size());
		assertEquals("P1", result.get(0).getId());
		assertEquals("ACDE", result.get(0).getSeq());
		assertEquals("P2", result.get(1).getId());
		assertEquals("MKTA", result.get(1).getSeq());
	}

	@Test
	public void testGetQueryPeptideFound() {
		String[] peptides = { "ACDE", "MKTA" };
		Query query = new Query(peptides);
		query.setPeptideIds(new String[] { "P1", "P2" });
		QueryPeptide result = query.getQueryPeptide("MKTA");
		assertTrue(result != null);
		assertEquals("P2", result.getId());
		assertEquals("MKTA", result.getSeq());
	}

	@Test
	public void testGetQueryPeptideFoundWithoutIds() {
		String[] peptides = { "ACDE" };
		Query query = new Query(peptides);
		QueryPeptide result = query.getQueryPeptide("ACDE");
		assertTrue(result != null);
		assertNull(result.getId());
		assertEquals("ACDE", result.getSeq());
	}

	@Test
	public void testGetQueryPeptideNotFound() {
		String[] peptides = { "ACDE" };
		Query query = new Query(peptides);
		assertNull(query.getQueryPeptide("NOPE"));
	}

	@Test
	public void testSelectedOrganisms() {
		Query query = new Query();
		Organism[] organisms = { new Organism("Homo sapiens", "9606") };
		query.setSelectedOrganisms(organisms);
		assertEquals(1, query.getSelectedOrganisms().length);
		assertEquals("Homo sapiens", query.getSelectedOrganisms()[0].getName());
	}
}
