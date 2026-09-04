package org.proteininformationresource.peptidematch.asyncrest.model;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;
import java.util.Arrays;
import java.util.List;

public class MatchTest {

    @Test
    public void testDefaultConstructor() {
        Match match = new Match();
        assertNotNull(match);
    }

    @Test
    public void testParameterizedConstructor() {
        String ac = "P12345";
        List<String> matchPeps = Arrays.asList("ACDE", "FGHI");

        Match match = new Match(ac, matchPeps);

        assertEquals(ac, match.getAc());
        assertEquals(matchPeps, match.getMatchPeps());
    }

    @Test
    public void testSettersAndGetters() {
        Match match = new Match();

        match.setAc("Q67890");
        assertEquals("Q67890", match.getAc());

        List<String> peps = Arrays.asList("ACDE", "JKLM");
        match.setMatchPeps(peps);
        assertEquals(peps, match.getMatchPeps());
    }

    @Test
    public void testSinglePeptide() {
        String ac = "P11111";
        List<String> peps = Arrays.asList("ACDE");

        Match match = new Match(ac, peps);

        assertEquals(ac, match.getAc());
        assertEquals(1, match.getMatchPeps().size());
        assertEquals("ACDE", match.getMatchPeps().get(0));
    }

    @Test
    public void testEmptyPeptideList() {
        Match match = new Match();
        match.setMatchPeps(Arrays.asList());
        assertNotNull(match.getMatchPeps());
        assertTrue(match.getMatchPeps().isEmpty());
    }

    @Test
    public void testNullAc() {
        Match match = new Match();
        assertNull(match.getAc());
    }
}
