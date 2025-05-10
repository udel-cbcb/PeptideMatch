package org.proteininformationresource.peptidematch;

import io.swagger.model.ReportSearchParameters;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Query {
	/**
	 * A comma-separated list of query peptide sequences.
	 */
	private String peps;
	
	/**
	 * Search parameters
	 */
	private ReportSearchParameters searchParameters;

	/**
	 * @param peps
	 * @param searchParameters
	 */
	public Query(String peps, ReportSearchParameters searchParameters) {
		super();
		this.peps = peps;
		this.searchParameters = searchParameters;
	}

	/**
	 * @return the peps
	 */
	public String getPeps() {
		return peps;
	}

	/**
	 * @param peps the peps to set
	 */
	public void setPeps(String peps) {
		this.peps = peps;
	}

	/**
	 * @return the searchParameters
	 */
	public ReportSearchParameters getSearchParameters() {
		return searchParameters;
	}

	/**
	 * @param searchParameters the searchParameters to set
	 */
	public void setSearchParameters(ReportSearchParameters searchParameters) {
		this.searchParameters = searchParameters;
	}
	
	/**
	 * Get a list of peptides.
	 * @return a list of peptide 
	 */
//	public List<String> getPeptides() {
//		String[] peptideList = peps.replaceAll(" ", "").split(",");
//		
//		return new ArrayList<String>(Arrays.asList(peptideList));
//	}
	
}
