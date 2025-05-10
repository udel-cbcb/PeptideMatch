package org.proteininformationresource.peptidematch.asyncrest.model.copy;

import java.util.List;

import javax.ws.rs.core.Link;
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
	private String jobId;
	
	/**
	 * A list of match results
	 */
	private List<MatchResult> matchResults;
	
	
	/**
	 * 
	 */
	public Report() {
		super();
	}

	/**
	 * @param jobId id of a match job
	 * @param matchResults a list of match results
	 * @param links list of links to resource for HATEOAS
	 */
	public Report(String jobId, List<MatchResult> matchResults) {
		super();
		this.jobId = jobId;
		this.matchResults = matchResults;
	}

	/**
	 * @return the jobId the id of a match job
	 */
	public String getJobId() {
		return jobId;
	}

	/**
	 * @param jobId the jobId to set
	 */
	public void setJobId(String jobId) {
		this.jobId = jobId;
	}

	/**
	 * @return the matchResults a list of match results
	 */
	public List<MatchResult> getMatchResults() {
		return matchResults;
	}

	/**
	 * @param matchResults the matchResults to set
	 */
	public void setMatchResults(List<MatchResult> matchResults) {
		this.matchResults = matchResults;
	}

	

	
	
	
}
