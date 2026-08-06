package org.proteininformationresource.PeptideMatch;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

public class PeptideMatchCMDTest {

	@Rule
	public TemporaryFolder tempFolder = new TemporaryFolder();

	private MatchedRange[] getMatchedRanges(String originalQueryPeptide,
			String originalSeq, boolean ilEquivalent) throws Exception {
		Method m = PeptideMatchCMD.class.getDeclaredMethod("getMatchedRanges",
				String.class, String.class, boolean.class);
		m.setAccessible(true);
		return (MatchedRange[]) m.invoke(null, originalQueryPeptide,
				originalSeq, ilEquivalent);
	}

	@Test
	public void testSingleExactMatch() throws Exception {
		MatchedRange[] ranges = getMatchedRanges("peptide", "xxpeptideyy", false);
		assertEquals(1, ranges.length);
		assertEquals(3, ranges[0].getStart());
		assertEquals(9, ranges[0].getEnd());
	}

	@Test
	public void testMatchAtStart() throws Exception {
		MatchedRange[] ranges = getMatchedRanges("abc", "abcdef", false);
		assertEquals(1, ranges.length);
		assertEquals(1, ranges[0].getStart());
		assertEquals(3, ranges[0].getEnd());
	}

	@Test
	public void testMultipleMatches() throws Exception {
		MatchedRange[] ranges = getMatchedRanges("ab", "abxab", false);
		assertEquals(2, ranges.length);
		assertEquals(1, ranges[0].getStart());
		assertEquals(2, ranges[0].getEnd());
		assertEquals(4, ranges[1].getStart());
		assertEquals(5, ranges[1].getEnd());
	}

	@Test
	public void testOverlappingMatches() throws Exception {
		MatchedRange[] ranges = getMatchedRanges("aaa", "aaaa", false);
		assertEquals(2, ranges.length);
		assertEquals(1, ranges[0].getStart());
		assertEquals(2, ranges[1].getStart());
	}

	@Test
	public void testNoMatch() throws Exception {
		MatchedRange[] ranges = getMatchedRanges("xyz", "abcde", false);
		assertNotNull(ranges);
		assertEquals(0, ranges.length);
	}

	@Test
	public void testCaseInsensitiveMatch() throws Exception {
		MatchedRange[] ranges = getMatchedRanges("PEPTIDE", "peptide", false);
		assertEquals(1, ranges.length);
		assertEquals(1, ranges[0].getStart());
		assertEquals(7, ranges[0].getEnd());
	}

	@Test
	public void testLEqiMatchWithReplacedPosition() throws Exception {
		MatchedRange[] ranges = getMatchedRanges("iic", "lic", true);
		assertEquals(1, ranges.length);
		assertEquals(1, ranges[0].getStart());
		assertEquals(3, ranges[0].getEnd());
		assertArrayEquals(new int[] { 1 }, ranges[0].getReplacedPos());
	}

	@Test
	public void testLEqiNoReplacedPositionWhenQueryAlsoHasL() throws Exception {
		MatchedRange[] ranges = getMatchedRanges("lic", "lic", true);
		assertEquals(1, ranges.length);
		assertEquals(1, ranges[0].getStart());
		assertEquals(3, ranges[0].getEnd());
		int[] replacedPos = ranges[0].getReplacedPos();
		assertEquals(0, replacedPos.length);
	}

	@Test
	public void testLEqiNotAppliedWhenFalse() throws Exception {
		MatchedRange[] ranges = getMatchedRanges("iic", "lic", false);
		assertEquals(0, ranges.length);
	}

	@Test
	public void testLEqiMultipleMatches() throws Exception {
		MatchedRange[] ranges = getMatchedRanges("ii", "lil", true);
		assertEquals(2, ranges.length);
		assertEquals(1, ranges[0].getStart());
		assertEquals(2, ranges[1].getStart());
	}

	@SuppressWarnings("unchecked")
	private ArrayList<Fasta> getFromListFile(String file) throws Exception {
		Method m = PeptideMatchCMD.class.getDeclaredMethod("getFromListFile",
				String.class);
		m.setAccessible(true);
		return (ArrayList<Fasta>) m.invoke(null, file);
	}

	@SuppressWarnings("unchecked")
	private ArrayList<Fasta> getFromFastaFile(String file) throws Exception {
		Method m = PeptideMatchCMD.class.getDeclaredMethod("getFromFastaFile",
				String.class);
		m.setAccessible(true);
		return (ArrayList<Fasta>) m.invoke(null, file);
	}

	@Test
	public void testGetFromListFile() throws Exception {
		File f = tempFolder.newFile("list.txt");
		FileWriter w = new FileWriter(f);
		w.write("PEPTIDE1\nPEPTIDE2\n");
		w.close();
		ArrayList<Fasta> queries = getFromListFile(f.getAbsolutePath());
		assertEquals(2, queries.size());
		assertEquals("PEPTIDE1", queries.get(0).getId());
		assertEquals("PEPTIDE1", queries.get(0).getSeq());
		assertEquals("PEPTIDE2", queries.get(1).getId());
	}

	@Test
	public void testGetFromFastaFile() throws Exception {
		File f = tempFolder.newFile("queries.fasta");
		FileWriter w = new FileWriter(f);
		w.write(">q1 first query\nMKTAYIAKQ\nRQISFVKSHFSRQ\n>q2\nACDEFGHIKLM\n");
		w.close();
		ArrayList<Fasta> queries = getFromFastaFile(f.getAbsolutePath());
		assertEquals(2, queries.size());
		assertEquals("q1", queries.get(0).getId());
		assertEquals("MKTAYIAKQ\nRQISFVKSHFSRQ\n", queries.get(0).getSeq());
		assertEquals("q2", queries.get(1).getId());
		assertEquals("ACDEFGHIKLM\n", queries.get(1).getSeq());
	}

	@Test
	public void testGetFromFastaFileRejectsNonFasta() throws Exception {
		File f = tempFolder.newFile("bad.fasta");
		FileWriter w = new FileWriter(f);
		w.write("not a fasta file\n");
		w.close();
		ArrayList<Fasta> queries = getFromFastaFile(f.getAbsolutePath());
		assertNull(queries);
	}

	@Test
	public void testGetFromFastaFileRejectsMissingSequence() throws Exception {
		File f = tempFolder.newFile("noseq.fasta");
		FileWriter w = new FileWriter(f);
		w.write(">q1\n>q2\nACDE\n");
		w.close();
		ArrayList<Fasta> queries = getFromFastaFile(f.getAbsolutePath());
		assertNull(queries);
	}

	@Test
	public void testGetFromListFileMissingFileReturnsEmpty() throws Exception {
		ArrayList<Fasta> queries = getFromListFile("/nonexistent/file.txt");
		assertNotNull(queries);
		assertEquals(0, queries.size());
	}
}
