package org.proteininformationresource.peptidematch;

import org.junit.jupiter.api.Test;
import org.proteininformationresource.peptidematch.search.MatchPositionFinder;
import org.proteininformationresource.peptidematch.search.MatchPositionFinder.MatchRange;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for MatchPositionFinder.
 * Validates exact substring match position detection.
 */
class MatchPositionFinderTest {

    @Test
    void testSingleMatch() {
        List<MatchRange> matches = MatchPositionFinder.findMatches(
                "CDEF", "ABCDEFXYZ", false);

        assertEquals(1, matches.size());
        assertEquals(3, matches.get(0).start());
        assertEquals(6, matches.get(0).end());
    }

    @Test
    void testMultipleMatches() {
        List<MatchRange> matches = MatchPositionFinder.findMatches(
                "ABC", "ABCXYZABC", false);

        assertEquals(2, matches.size());
        assertEquals(1, matches.get(0).start());
        assertEquals(3, matches.get(0).end());
        assertEquals(7, matches.get(1).start());
        assertEquals(9, matches.get(1).end());
    }

    @Test
    void testNoMatch() {
        List<MatchRange> matches = MatchPositionFinder.findMatches(
                "ZZZ", "ABCDEF", false);

        assertTrue(matches.isEmpty());
    }

    @Test
    void testCaseInsensitive() {
        List<MatchRange> matches = MatchPositionFinder.findMatches(
                "cdef", "ABCDEF", false);

        assertEquals(1, matches.size());
        assertEquals(3, matches.get(0).start());
    }

    @Test
    void testLeqiEquivalent_matchLwithI() {
        List<MatchRange> matches = MatchPositionFinder.findMatches(
                "CDEF", "ACDEFGH", true);

        assertEquals(1, matches.size());
        assertEquals(2, matches.get(0).start());
    }

    @Test
    void testLeqiEquivalent_LreplacedByI() {
        // Sequence has L at position 5 (1-based), query has I
        List<MatchRange> matches = MatchPositionFinder.findMatches(
                "CDEI", "ACDELGH", true);

        assertEquals(1, matches.size());
        assertEquals(2, matches.get(0).start());
        // Position 5 (1-based) had L in seq matched by I in query
        assertNotNull(matches.get(0).replacedPositions());
        assertTrue(matches.get(0).replacedPositions().contains(5));
    }

    @Test
    void testLeqiEquivalent_IreplacedByL() {
        // Sequence has I at position 5 (1-based), query has L
        List<MatchRange> matches = MatchPositionFinder.findMatches(
                "CDEL", "ACDEIGH", true);

        assertEquals(1, matches.size());
        assertEquals(2, matches.get(0).start());
        // Position 5 (1-based) had I in seq matched by L in query
        assertNotNull(matches.get(0).replacedPositions());
        assertTrue(matches.get(0).replacedPositions().contains(5));
    }

    @Test
    void testEmptyInputs() {
        assertTrue(MatchPositionFinder.findMatches("", "ABC", false).isEmpty());
        assertTrue(MatchPositionFinder.findMatches("ABC", "", false).isEmpty());
        assertTrue(MatchPositionFinder.findMatches(null, "ABC", false).isEmpty());
        assertTrue(MatchPositionFinder.findMatches("ABC", null, false).isEmpty());
    }

    @Test
    void testPeptideLongerThanSequence() {
        assertTrue(MatchPositionFinder.findMatches("ABCDEFG", "ABC", false).isEmpty());
    }

    @Test
    void testExactLengthMatch() {
        List<MatchRange> matches = MatchPositionFinder.findMatches(
                "ABC", "ABC", false);

        assertEquals(1, matches.size());
        assertEquals(1, matches.get(0).start());
        assertEquals(3, matches.get(0).end());
    }

    @Test
    void testOverlappingMatches() {
        // "AAAA" -> "AAA" matches at positions 1 and 2
        List<MatchRange> matches = MatchPositionFinder.findMatches(
                "AAA", "AAAA", false);

        assertEquals(2, matches.size());
        assertEquals(1, matches.get(0).start());
        assertEquals(3, matches.get(0).end());
        assertEquals(2, matches.get(1).start());
        assertEquals(4, matches.get(1).end());
    }
}
