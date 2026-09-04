package org.proteininformationresource.peptidematch.asyncrest.model;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;
import java.util.Arrays;
import java.util.List;

public class QueryTest {

    @Test
    public void testDefaultConstructor() {
        Query query = new Query();
        assertNotNull(query);
        assertEquals("true", query.getlEqi());
    }

    @Test
    public void testSettersAndGetters() {
        Query query = new Query();

        List<String> peps = Arrays.asList("ACDE", "FGHI");
        query.setPeps(peps);
        assertEquals(peps, query.getPeps());

        query.setlEqi("N");
        assertEquals("N", query.getlEqi());
    }

    @Test
    public void testEmptyPeptideList() {
        Query query = new Query();
        query.setPeps(Arrays.asList());
        assertNotNull(query.getPeps());
        assertTrue(query.getPeps().isEmpty());
    }

    @Test
    public void testMultiplePeptides() {
        List<String> peps = Arrays.asList("PEPTIDE1", "PEPTIDE2", "PEPTIDE3");
        Query query = new Query();
        query.setPeps(peps);
        assertEquals(3, query.getPeps().size());
    }

    @Test
    public void testToString() {
        Query query = new Query();
        query.setPeps(Arrays.asList("ACDE"));
        String str = query.toString();
        assertNotNull(str);
        assertTrue(str.contains("ACDE"));
    }
}
