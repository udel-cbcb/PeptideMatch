package org.proteininformationresource.peptidematch.asyncrest.model;

import java.util.List;

import javax.xml.bind.annotation.XmlRootElement;

/**
 * This class represents a match job report
 * 
 * @author chenc
 *
 */
@XmlRootElement
public class Report {
	/**
	 * The id of a match job
	 */
	//private String jobId;
	
	/**
	 * A list of match results
	 */
	private List<Match> matchList;
	
	
	/**
	 * 
	 */
	public Report() {
		super();
	}

	/**
	 * @param jobId id of a match job
	 * @param matchResults a list of match results
	 */
	public Report(List<Match> matchList) {
		super();
		//this.jobId = jobId;
		this.matchList = matchList;
	}

	

	/**
	 * @return the matchList a list of match results
	 */
	public List<Match> getMatchList() {
		return matchList;
	}

	/**
	 * @param matchList the matchList to set
	 */
	public void setMatchResults(List<Match> matchList) {
		this.matchList = matchList;
	}


	

	
	
	
}
