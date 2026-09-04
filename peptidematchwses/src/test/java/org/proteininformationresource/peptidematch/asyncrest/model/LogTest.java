package org.proteininformationresource.peptidematch.asyncrest.model;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

public class LogTest {

    @Test
    public void testDefaultConstructor() {
        Log log = new Log();
        assertNotNull(log);
    }

    @Test
    public void testSettersAndGetters() {
        Log log = new Log();

        log.setTaskName("1/5");
        assertEquals("1/5", log.getTaskName());

        log.setPeptideSearched("ACDE");
        assertEquals("ACDE", log.getPeptideSearched());

        log.setTaxonIds("9606,10090");
        assertEquals("9606,10090", log.getTaxonIds());

        log.setlEQi("Y");
        assertEquals("Y", log.getlEQi());

        log.setStartTime("2026-09-03 10:00:00");
        assertEquals("2026-09-03 10:00:00", log.getStartTime());

        log.setEndTime("2026-09-03 10:00:01");
        assertEquals("2026-09-03 10:00:01", log.getEndTime());

        log.setDurationInMilliseconds(1000);
        assertEquals(1000, log.getDurationInMilliseconds());
    }

    @Test
    public void testNullValues() {
        Log log = new Log();
        assertNull(log.getTaskName());
        assertNull(log.getPeptideSearched());
        assertNull(log.getTaxonIds());
    }
}
