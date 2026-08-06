package org.proteininformationresource.peptidematch.asyncrest.model;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

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
	public void testParameterizedConstructor() {
		List<String> peps = Arrays.asList("ACDE", "MKTA");
		List<Integer> taxIds = Arrays.asList(9606, 10090);
		Query query = new Query(peps, taxIds, "Y");
		assertEquals(peps, query.getPeps());
		assertEquals(taxIds, query.getTaxIds());
		assertEquals("Y", query.getlEqi());
	}

	@Test
	public void testSetters() {
		Query query = new Query();
		query.setPeps(Arrays.asList("ACDE"));
		query.setTaxIds(Arrays.asList(9606));
		query.setlEqi("false");
		assertEquals(Arrays.asList("ACDE"), query.getPeps());
		assertEquals(Arrays.asList(9606), query.getTaxIds());
		assertEquals("false", query.getlEqi());
	}

	@Test
	public void testDefaultTaxIdsIsNull() {
		Query query = new Query();
		assertNull(query.getTaxIds());
	}
}
