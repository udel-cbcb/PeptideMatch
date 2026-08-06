package org.proteininformationresource.peptidematch;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class OrganismTest {

	@Test
	public void testConstructor() {
		Organism organism = new Organism("Homo sapiens", "9606");
		assertEquals("Homo sapiens", organism.getName());
		assertEquals("9606", organism.getTaxonId());
	}

	@Test
	public void testSetters() {
		Organism organism = new Organism(null, null);
		organism.setName("Mus musculus");
		organism.setTaxonId("10090");
		assertEquals("Mus musculus", organism.getName());
		assertEquals("10090", organism.getTaxonId());
	}

	@Test
	public void testEqualsSameValues() {
		Organism a = new Organism("Homo sapiens", "9606");
		Organism b = new Organism("Homo sapiens", "9606");
		assertTrue(a.equals(b));
		assertEquals(a.hashCode(), b.hashCode());
	}

	@Test
	public void testEqualsDifferentName() {
		Organism a = new Organism("Homo sapiens", "9606");
		Organism b = new Organism("Mus musculus", "9606");
		assertFalse(a.equals(b));
	}

	@Test
	public void testEqualsDifferentTaxonId() {
		Organism a = new Organism("Homo sapiens", "9606");
		Organism b = new Organism("Homo sapiens", "10090");
		assertFalse(a.equals(b));
	}

	@Test
	public void testEqualsNullHandling() {
		Organism a = new Organism(null, null);
		Organism b = new Organism(null, null);
		assertTrue(a.equals(b));
		assertEquals(a.hashCode(), b.hashCode());
	}

	@Test
	public void testEqualsNullVsValue() {
		Organism a = new Organism(null, "9606");
		Organism b = new Organism("Homo sapiens", "9606");
		assertFalse(a.equals(b));
	}

	@Test
	public void testNotEqualDifferentObject() {
		Organism a = new Organism("Homo sapiens", "9606");
		assertFalse(a.equals("Homo sapiens"));
		assertNotEquals(null, a);
	}

	@Test
	public void testReflexiveEquals() {
		Organism a = new Organism("Homo sapiens", "9606");
		assertTrue(a.equals(a));
	}
}
