package org.proteininformationresource.peptidematch.asyncrest.model;

import java.util.ArrayList;
import java.util.List;

/**
 * This class represents the match result of a query peptide
 * 
 * @author chenc
 *
 */
public class MatchResult {
	/**
	 * The query peptide
	 */
	private Peptide queryPeptide;
	
	/**
	 * A list of matched proteins
	 */
	private List<MatchedProtein> matchedProteinList;

	/**
	 * 
	 */
	public MatchResult() {
		super();
	}

	/**
	 * @param queryPeptide the query peptide
	 * @param matchedProteinList list of matched proteins
	 */
	public MatchResult(Peptide queryPeptide,
			List<MatchedProtein> matchedProteinList) {
		super();
		this.queryPeptide = queryPeptide;
		if(matchedProteinList == null) {
			this.matchedProteinList = new ArrayList<MatchedProtein>();
		}
		else {
			this.matchedProteinList = matchedProteinList;
		}
	}

	/**
	 * @return the queryPeptide the query peptide
	 */
	public Peptide getQueryPeptide() {
		return queryPeptide;
	}

	/**
	 * @param queryPeptide the queryPeptide to set
	 */
	public void setQueryPeptide(Peptide queryPeptide) {
		this.queryPeptide = queryPeptide;
	}

	/**
	 * @return the matchedProteinList a list of matched proteins
	 */
	public List<MatchedProtein> getMatchedProteinList() {
		return matchedProteinList;
	}

	/**
	 * @param matchedProteinList the matchedProteinList to set
	 */
	public void setMatchedProteinList(List<MatchedProtein> matchedProteinList) {
		this.matchedProteinList = matchedProteinList;
	}

	
	
	
}
