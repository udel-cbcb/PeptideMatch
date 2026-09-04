package org.proteininformationresource.peptidematch;

import io.swagger.model.ReportSearchParameters;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class QueryTest {

    @Test
    void testQuery() {
        ReportSearchParameters params = new ReportSearchParameters();
        params.setLeqi(true);
        params.setSwissprot(false);

        Query query = new Query("ACDEF,GHIKL", params);

        assertEquals("ACDEF,GHIKL", query.getPeps());
        assertNotNull(query.getSearchParameters());
        assertTrue(query.getSearchParameters().getLeqi());
    }

    @Test
    void testSetPeps() {
        ReportSearchParameters params = new ReportSearchParameters();
        Query query = new Query("OLD", params);

        query.setPeps("NEW");
        assertEquals("NEW", query.getPeps());
    }

    @Test
    void testSetSearchParameters() {
        ReportSearchParameters params1 = new ReportSearchParameters();
        Query query = new Query("ACDEF", params1);

        ReportSearchParameters params2 = new ReportSearchParameters();
        params2.setLeqi(true);
        query.setSearchParameters(params2);

        assertTrue(query.getSearchParameters().getLeqi());
    }
}
