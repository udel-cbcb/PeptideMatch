package org.proteininformationresource.peptidematch.asyncrest.model;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.junit.Test;

public class QueryTest {

	@Test
	public void testDefaultLEqiIsTrue() {
		Query query = new Query();
		assertEquals("true", query.getlEqi());
	}

	@Test
	public void testDefaultPepsIsNull() {
		Query query = new Query();
		assertNull(query.getPeps());
	}

	@Test
	public void testSetAndGetPeps() {
		Query query = new Query();
		List<String> peps = new ArrayList<String>(Arrays.asList("ACDE", "MKTA"));
		query.setPeps(peps);
		assertEquals(peps, query.getPeps());
	}

	@Test
	public void testSetAndGetLEqi() {
		Query query = new Query();
		query.setlEqi("false");
		assertEquals("false", query.getlEqi());
	}

	@Test
	public void testToStringContainsFields() {
		Query query = new Query();
		query.setPeps(Arrays.asList("ACDE"));
		String str = query.toString();
		assertTrue(str.contains("ACDE"));
		assertTrue(str.contains("true"));
	}
}
