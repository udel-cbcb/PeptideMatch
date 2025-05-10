package org.proteininformationresource.peptidematch.asyncrest.model.copy;

import java.util.Arrays;

/**
 * This class represents a matched range
 * 
 * @author chenc
 *
 */
public class MatchedRange {
	/**
	 * The start position of match
	 */
	private int start;
	
	/**
	 * The end position of match
	 */
    private int end;
    
    /**
     * A list of Leucine and Isoleucine equivalent positions
     */
    private int[] lEqiPositionList;

	/**
	 * 
	 */
	public MatchedRange() {
		super();
	}

	/**
	 * @param start the start position of match
	 * @param end the end position of match
	 * @param lEqiPositionList a list of Leucine and Isoleucine equivalent positions
	 */
	public MatchedRange(int start, int end, int[] lEqiPositionList) {
		super();
		this.start = start;
		this.end = end;
		this.lEqiPositionList = lEqiPositionList;
	}

	/**
	 * @return the start the start position of match
	 */
	public int getStart() {
		return start;
	}

	/**
	 * @param start the start position of match to set
	 */
	public void setStart(int start) {
		this.start = start;
	}

	/**
	 * @return the end the end position of match
	 */
	public int getEnd() {
		return end;
	}

	/**
	 * @param end the end position of match to set
	 */
	public void setEnd(int end) {
		this.end = end;
	}

	/**
	 * @return the lEqiPositionList a list of Leucine and Isoleucine equivalent positions
	 */
	public int[] getlEqiPositionList() {
		return lEqiPositionList;
	}

	/**
	 * @param lEqiPositionList a list of Leucine and Isoleucine equivalent positions to set
	 */
	public void setlEqiPositionList(int[] lEqiPositionList) {
		this.lEqiPositionList = lEqiPositionList;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "MatchedRange [start=" + start + ", end=" + end
				+ ", lEqiPositionList=" + Arrays.toString(lEqiPositionList)
				+ "]";
	}
    
    
    
}
