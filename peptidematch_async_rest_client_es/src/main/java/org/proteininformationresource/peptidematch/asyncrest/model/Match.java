package org.proteininformationresource.peptidematch.asyncrest.model;

import java.util.List;

import javax.xml.bind.annotation.XmlRootElement;

/**
 * This class represents a match
 * 
 * UniProtAC, list of matched peptides
 * 
 * @author chenc
 *
 */
@XmlRootElement
public class Match {
	private String ac;

	private List<String> matchPeps;

	/**
	 * 
	 */
	public Match() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param ac
	 * @param matchPeps
	 */
	public Match(String ac, List<String> matchPeps) {
		super();
		this.ac = ac;
		this.matchPeps = matchPeps;
	}

	/**
	 * @return the ac
	 */
	public String getAc() {
		return ac;
	}

	/**
	 * @param ac
	 *            the ac to set
	 */
	public void setAc(String ac) {
		this.ac = ac;
	}

	/**
	 * @return the matchPeps
	 */
	public List<String> getMatchPeps() {
		return matchPeps;
	}

	/**
	 * @param matchPeps
	 *            the matchPeps to set
	 */
	public void setMatchPeps(List<String> matchPeps) {
		this.matchPeps = matchPeps;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "Match [ac=" + ac + ", matchPeps=" + matchPeps + "]";
	}
}
