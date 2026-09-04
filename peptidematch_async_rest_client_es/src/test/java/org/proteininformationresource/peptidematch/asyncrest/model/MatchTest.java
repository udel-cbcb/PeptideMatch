package org.proteininformationresource.peptidematch.asyncrest.model;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.util.Arrays;
import java.util.List;

import org.junit.Test;

public class MatchTest {

	@Test
	public void testDefaultConstructor() {
		Match match = new Match();
		assertNull(match.getAc());
		assertNull(match.getMatchPeps());
	}

	@Test
	public void testParameterizedConstructor() {
		List<String> peps = Arrays.asList("ACDE", "MKTA");
		Match match = new Match("P12345", peps);
		assertEquals("P12345", match.getAc());
		assertEquals(peps, match.getMatchPeps());
	}

	@Test
	public void testSetters() {
		Match match = new Match();
		match.setAc("Q12345");
		match.setMatchPeps(Arrays.asList("TIDE"));
		assertEquals("Q12345", match.getAc());
		assertEquals(Arrays.asList("TIDE"), match.getMatchPeps());
	}

	@Test
	public void testToStringContainsFields() {
		Match match = new Match("P12345", Arrays.asList("ACDE"));
		String str = match.toString();
		assertTrue(str.contains("P12345"));
		assertTrue(str.contains("ACDE"));
	}
}
