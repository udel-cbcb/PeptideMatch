package org.proteininformationresource.peptidematch.asyncrest.model;

import java.util.ArrayList;
import java.util.List;

import javax.ws.rs.core.MediaType;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * This class represents the query to PeptideMatch RESTful web service
 * 
 * @author chenc
 *
 */
@XmlRootElement
public class Query {

	/**
	 * peptideList a list of query peptides
	 */
	private List<String> peps;

	/**
	 * LEqi treat Leucine and Isoleucine be equivalent, default is true
	 */
	private String lEqi = "true";

	/**
	 * 
	 */
	public Query() {
		super();
		lEqi = "true";
	}

	/**
	 * @return the peps
	 */
	public List<String> getPeps() {
		return peps;
	}

	/**
	 * @param pepList
	 *            the peps to set
	 */
	public void setPeps(List<String> peps) {
		this.peps = peps;
	}

	/**
	 * @return the lEqi treat Leucine and Isoleucine be equivalent, default is
	 *         true
	 */
	public String getlEqi() {
		return lEqi;
	}

	/**
	 * @param lEqi
	 *            the lEqi to set
	 */
	public void setlEqi(String lEqi) {
		this.lEqi = lEqi;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "Query [peps=" + peps + ", lEqi=" + lEqi + "]";
	}

}
