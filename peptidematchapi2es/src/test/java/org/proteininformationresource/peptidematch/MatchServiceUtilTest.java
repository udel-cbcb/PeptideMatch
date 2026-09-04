package org.proteininformationresource.peptidematch;

import io.swagger.model.ReportSearchParameters;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class MatchServiceUtilTest {

    @Test
    void testValidateInputs_valid() {
        assertNull(MatchServiceUtil.validateInputs("ACDEF,GHIKL"));
    }

    @Test
    void testValidateInputs_tooMany() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 101; i++) {
            if (i > 0) sb.append(",");
            sb.append("ACDEF");
        }
        assertNotNull(MatchServiceUtil.validateInputs(sb.toString()));
    }

    @Test
    void testGetQuery() {
        Query query = MatchServiceUtil.getQuery("ACDEF", "9606", true, false, false, true, 0, 10);
        assertEquals("ACDEF", query.getPeps());
        assertNotNull(query.getSearchParameters());
    }

    @Test
    void testGetSearchParameters_defaults() {
        ReportSearchParameters params = MatchServiceUtil.getSearchParameters(
            null, null, null, null, null, null, null);

        assertEquals("", params.getTaxonids());
        assertFalse(params.getSwissprot());
        assertFalse(params.getIsoform());
        assertFalse(params.getUniref100());
        assertFalse(params.getLeqi());
        assertEquals(0, params.getOffset());
        assertEquals(100, params.getSize());
    }

    @Test
    void testGetSearchParameters_custom() {
        ReportSearchParameters params = MatchServiceUtil.getSearchParameters(
            "9606,10090", true, true, false, true, 10, 50);

        assertEquals("9606,10090", params.getTaxonids());
        assertTrue(params.getSwissprot());
        assertTrue(params.getIsoform());
        assertFalse(params.getUniref100());
        assertTrue(params.getLeqi());
        assertEquals(10, params.getOffset());
        assertEquals(50, params.getSize());
    }

    @Test
    void testGetSearchParameters_sizeMinusOne() {
        ReportSearchParameters params = MatchServiceUtil.getSearchParameters(
            "", false, false, false, false, 0, -1);

        assertEquals(Integer.MAX_VALUE, params.getSize());
        assertEquals(0, params.getOffset());
    }
}
