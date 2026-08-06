package query;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.junit.Test;

public class ToolsTest {

	@Test
	public void testRoundHalfUp() {
		assertEquals(2.35, Tools.round(2.346, 2, BigDecimal.ROUND_HALF_UP), 0.0001);
		assertEquals(2.34, Tools.round(2.344, 2, BigDecimal.ROUND_HALF_UP), 0.0001);
	}

	@Test
	public void testRoundZeroPrecision() {
		assertEquals(3.0, Tools.round(2.6, 0, BigDecimal.ROUND_HALF_UP), 0.0001);
		assertEquals(2.0, Tools.round(2.4, 0, BigDecimal.ROUND_HALF_UP), 0.0001);
	}

	@Test
	public void testRoundFloor() {
		assertEquals(2.34, Tools.round(2.349, 2, BigDecimal.ROUND_FLOOR), 0.0001);
	}

	@Test
	public void testSortHashMapReturnsSortedByValueDescending() {
		HashMap<String, Integer> input = new HashMap<String, Integer>();
		input.put("low", 1);
		input.put("high", 100);
		input.put("mid", 50);
		HashMap<String, Integer> sorted = Tools.sortHashMap(input);
		ArrayList<String> keys = new ArrayList<String>(sorted.keySet());
		assertEquals("high", keys.get(0));
		assertEquals("mid", keys.get(1));
		assertEquals("low", keys.get(2));
		assertEquals(Integer.valueOf(100), sorted.get("high"));
		assertEquals(Integer.valueOf(50), sorted.get("mid"));
		assertEquals(Integer.valueOf(1), sorted.get("low"));
	}

	@Test
	public void testSortHashMapSingleEntry() {
		HashMap<String, Integer> input = new HashMap<String, Integer>();
		input.put("only", 42);
		Map<String, Integer> sorted = Tools.sortHashMap(input);
		assertEquals(1, sorted.size());
		assertEquals(Integer.valueOf(42), sorted.get("only"));
	}

	@Test
	public void testSortHashMapEmpty() {
		HashMap<String, Integer> input = new HashMap<String, Integer>();
		HashMap<String, Integer> sorted = Tools.sortHashMap(input);
		assertTrue(sorted.isEmpty());
	}
}
