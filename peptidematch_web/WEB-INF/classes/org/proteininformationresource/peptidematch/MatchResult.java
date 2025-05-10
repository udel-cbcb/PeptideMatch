package org.proteininformationresource.peptidematch;

public class MatchResult {
	String queryPeptide;
	MatchedProtein matchedProtein;

	public MatchResult(String queryPeptide, MatchedProtein matchedProtein) {
		this.queryPeptide = queryPeptide;
		this.matchedProtein = matchedProtein;
	}

	public void setQueryPeptide(String queryPeptide) {
		this.queryPeptide = queryPeptide;
	}

	public String getQueryPeptide() {
		return this.queryPeptide;
	}
		
	public void setMatchedProtein(MatchedProtein matchedProtein) {
		this.matchedProtein = matchedProtein;
	}

	public MatchedProtein getMatchedProtein() {
		return this.matchedProtein;
	} 
}
