package org.proteininformationresource.peptidematch.search;

import java.util.ArrayList;
import java.util.List;

/**
 * Finds exact match positions of a peptide within a protein sequence.
 *
 * This replaces the brute-force substring scanning logic found in:
 * - MatchService.getMatchRanges()
 * - PeptideMatchCMD.getMatchedRanges()
 * - MatchedRange.java
 *
 * The approach is identical to the original: after ES returns candidate proteins,
 * we scan the sequence to find exact match positions.
 */
public class MatchPositionFinder {

    /**
     * Find all match positions of a peptide within a sequence.
     *
     * @param peptide       the query peptide
     * @param sequence      the protein sequence
     * @param leqi          whether to treat L/I as equivalent
     * @return list of MatchRange objects with start/end positions and replaced locations
     */
    public static List<MatchRange> findMatches(String peptide, String sequence, boolean leqi) {
        List<MatchRange> matches = new ArrayList<>();
        if (peptide == null || sequence == null || peptide.isEmpty() || sequence.isEmpty()) {
            return matches;
        }

        String seq = sequence;
        String query = peptide;

        if (leqi) {
            seq = seq.toUpperCase().replaceAll("L", "I");
            query = query.toUpperCase().replaceAll("L", "I");
        }

        int seqLen = seq.length();
        int queryLen = query.length();

        for (int i = 0; i <= seqLen - queryLen; i++) {
            if (seq.substring(i, i + queryLen).equalsIgnoreCase(query)) {
                List<Integer> replacedPositions = null;
                if (leqi) {
                    replacedPositions = new ArrayList<>();
                    for (int j = i; j < i + queryLen; j++) {
                        char origSeqChar = sequence.charAt(j);
                        char origPeptideChar = peptide.charAt(j - i);
                        if (origSeqChar != origPeptideChar) {
                            replacedPositions.add(j + 1); // 1-based
                        }
                    }
                    if (replacedPositions.isEmpty()) replacedPositions = null;
                }
                matches.add(new MatchRange(i + 1, i + queryLen, replacedPositions));
            }
        }
        return matches;
    }

    /**
     * Match position record.
     */
    public record MatchRange(int start, int end, List<Integer> replacedPositions) {}
}
