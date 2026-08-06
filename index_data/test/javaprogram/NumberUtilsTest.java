package javaprogram;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class NumberUtilsTest {

	@Test
	public void testPadSingleDigit() {
		assertEquals("0000000001", NumberUtils.pad(1));
	}

	@Test
	public void testPadZero() {
		assertEquals("0000000000", NumberUtils.pad(0));
	}

	@Test
	public void testPadTenDigits() {
		assertEquals("1234567890", NumberUtils.pad(1234567890));
	}

	@Test
	public void testPadNegativeNumber() {
		assertEquals("-0000000001", NumberUtils.pad(-1));
	}

	@Test
	public void testPadIntegerMaxValue() {
		assertEquals("2147483647", NumberUtils.pad(Integer.MAX_VALUE));
	}
}
