package org.proteininformationresource.PeptideMatch;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import org.junit.Test;

public class FastaTest {

	@Test
	public void testConstructorStoresValues() {
		Fasta fasta = new Fasta("PEPTIDE1", "MKTAYIAKQRQISFVKSHFSRQ");
		assertEquals("PEPTIDE1", fasta.getId());
		assertEquals("MKTAYIAKQRQISFVKSHFSRQ", fasta.getSeq());
	}

	@Test
	public void testSetters() {
		Fasta fasta = new Fasta(null, null);
		fasta.setId("PEPTIDE2");
		fasta.setSeq("ACDEFGHIKLMNPQRSTVWY");
		assertEquals("PEPTIDE2", fasta.getId());
		assertEquals("ACDEFGHIKLMNPQRSTVWY", fasta.getSeq());
	}

	@Test
	public void testDefaultNullFields() {
		Fasta fasta = new Fasta(null, null);
		assertNull(fasta.getId());
		assertNull(fasta.getSeq());
	}
}
