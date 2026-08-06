package org.proteininformationresource.PeptideMatch;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import org.junit.Test;

public class MatchedRangeTest {

	@Test
	public void testConstructorStoresStartAndEnd() {
		MatchedRange range = new MatchedRange(10, 20);
		assertEquals(10, range.getStart());
		assertEquals(20, range.getEnd());
	}

	@Test
	public void testSetters() {
		MatchedRange range = new MatchedRange(1, 2);
		range.setStart(5);
		range.setEnd(15);
		assertEquals(5, range.getStart());
		assertEquals(15, range.getEnd());
	}

	@Test
	public void testReplacedPosDefaultsToNull() {
		MatchedRange range = new MatchedRange(1, 5);
		assertNull(range.getReplacedPos());
	}

	@Test
	public void testReplacedPosSetter() {
		MatchedRange range = new MatchedRange(1, 5);
		int[] replacedPos = { 2, 4 };
		range.setReplacedPos(replacedPos);
		assertArrayEquals(replacedPos, range.getReplacedPos());
	}
}
