package org.proteininformationresource.peptidematch;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class QueryPeptideTest {

	@Test
	public void testConstructor() {
		QueryPeptide peptide = new QueryPeptide("P12345", "MKTAYIAKQR");
		assertEquals("P12345", peptide.getId());
		assertEquals("MKTAYIAKQR", peptide.getSeq());
	}

	@Test
	public void testDefaultConstructor() {
		QueryPeptide peptide = new QueryPeptide();
		assertNull(peptide.getId());
		assertNull(peptide.getSeq());
	}

	@Test
	public void testSetters() {
		QueryPeptide peptide = new QueryPeptide();
		peptide.setId("Q67890");
		peptide.setSeq("ACDEFGHIKLM");
		assertEquals("Q67890", peptide.getId());
		assertEquals("ACDEFGHIKLM", peptide.getSeq());
	}

	@Test
	public void testEqualsSameValues() {
		QueryPeptide a = new QueryPeptide("P1", "ACDE");
		QueryPeptide b = new QueryPeptide("P1", "ACDE");
		assertTrue(a.equals(b));
		assertEquals(a.hashCode(), b.hashCode());
	}

	@Test
	public void testEqualsDifferentSeq() {
		QueryPeptide a = new QueryPeptide("P1", "ACDE");
		QueryPeptide b = new QueryPeptide("P1", "MKTA");
		assertFalse(a.equals(b));
	}

	@Test
	public void testEqualsDifferentId() {
		QueryPeptide a = new QueryPeptide("P1", "ACDE");
		QueryPeptide b = new QueryPeptide("P2", "ACDE");
		assertFalse(a.equals(b));
	}

	@Test
	public void testEqualsNullFields() {
		QueryPeptide a = new QueryPeptide(null, null);
		QueryPeptide b = new QueryPeptide(null, null);
		assertTrue(a.equals(b));
		assertEquals(a.hashCode(), b.hashCode());
	}

	@Test
	public void testEqualsNullVsValue() {
		QueryPeptide a = new QueryPeptide(null, "ACDE");
		QueryPeptide b = new QueryPeptide("P1", "ACDE");
		assertFalse(a.equals(b));
	}

	@Test
	public void testReflexiveEquals() {
		QueryPeptide a = new QueryPeptide("P1", "ACDE");
		assertTrue(a.equals(a));
	}

	@Test
	public void testNotEqualDifferentType() {
		QueryPeptide a = new QueryPeptide("P1", "ACDE");
		assertFalse(a.equals("ACDE"));
		assertNotEquals(null, a);
	}
}
