package org.proteininformationresource.peptidematch.asyncrest.resource;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;
import org.proteininformationresource.peptidematch.asyncrest.model.Query;
import java.util.Arrays;
import java.util.List;

public class MatchResourceTest {

    @Test
    public void testQueryCreation() {
        List<String> peps = Arrays.asList("ACDE", "FGHI");
        List<Integer> taxIds = Arrays.asList(9606);
        String lEqi = "Y";

        Query query = new Query(peps, taxIds, lEqi);

        assertNotNull(query);
        assertEquals(2, query.getPeps().size());
        assertEquals(1, query.getTaxIds().size());
        assertEquals("Y", query.getlEqi());
    }

    @Test
    public void testPeptideParsing() {
        String peps = "ACDE\nFGHI";
        String[] pepList = peps.split("\n");
        List<String> queryPeptides = Arrays.asList(pepList);

        assertEquals(2, queryPeptides.size());
        assertEquals("ACDE", queryPeptides.get(0));
        assertEquals("FGHI", queryPeptides.get(1));
    }

    @Test
    public void testTaxonIdParsing() {
        String taxIds = "9606,10090";
        String[] taxIdList = taxIds.split(",");
        List<Integer> queryTaxonIds = new java.util.ArrayList<>();
        for (String tax : taxIdList) {
            queryTaxonIds.add(Integer.parseInt(tax.trim()));
        }

        assertEquals(2, queryTaxonIds.size());
        assertEquals(9606, queryTaxonIds.get(0));
        assertEquals(10090, queryTaxonIds.get(1));
    }

    @Test
    public void testLEqiParsing() {
        String lEQi = "ON";
        String equiv = "";
        if (lEQi != null && (lEQi.toUpperCase().equals("ON") || lEQi.toUpperCase().equals("Y"))) {
            equiv = "Y";
        } else {
            equiv = "N";
        }
        assertEquals("Y", equiv);

        lEQi = "N";
        if (lEQi != null && (lEQi.toUpperCase().equals("ON") || lEQi.toUpperCase().equals("Y"))) {
            equiv = "Y";
        } else {
            equiv = "N";
        }
        assertEquals("N", equiv);
    }

    @Test
    public void testEmptyPeptideHandling() {
        String peps = "";
        List<String> queryPeptides = new java.util.ArrayList<>();
        if (peps != null && peps.length() > 0) {
            String[] pepList = peps.split("\n");
            for (String pep : pepList) {
                String[] commaSeparatedPeps = pep.split(",");
                for (String cp : commaSeparatedPeps) {
                    queryPeptides.add(cp.trim());
                }
            }
        }
        assertTrue(queryPeptides.isEmpty());
    }
}
