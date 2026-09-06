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
    public void testParameterizedConstructor() {
        List<String> peps = Arrays.asList("ACDE", "FGHI");
        List<Integer> taxIds = Arrays.asList(9606, 10090);
        String lEqi = "Y";

        Query query = new Query(peps, taxIds, lEqi, "N", "", "ac");

        assertEquals(peps, query.getPeps());
        assertEquals(taxIds, query.getTaxIds());
        assertEquals(lEqi, query.getlEqi());
    }

    @Test
    public void testSettersAndGetters() {
        Query query = new Query();

        List<String> peps = Arrays.asList("ACDE");
        query.setPeps(peps);
        assertEquals(peps, query.getPeps());

        List<Integer> taxIds = Arrays.asList(9606);
        query.setTaxIds(taxIds);
        assertEquals(taxIds, query.getTaxIds());

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
    public void testNullTaxIds() {
        Query query = new Query();
        assertNull(query.getTaxIds());
    }
}
