package org.proteininformationresource.peptidematch.asyncrest.model;

import java.util.List;

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
	
	private List<Integer> taxIds;
	
		
	/**
	 * LEqi treat Leucine and Isoleucine be equivalent, default is true
	 */
	private String lEqi = "true";
	
	/**
	 * Search SwissProt only, default is false;
	 */
	
	private String swissProtOnly = "false";
	
	
	/**
	 * 
	 */
	public Query() {
		super();
		lEqi = "true";
		swissProtOnly = "false";
	}


	

	/**
	 * @param peps
	 * @param taxIds
	 * @param lEqi
	 */
	public Query(List<String> peps, List<Integer> taxIds, String lEqi, String swissProtOnly) {
		super();
		this.peps = peps;
		this.taxIds = taxIds;
		this.lEqi = lEqi;
		this.swissProtOnly = swissProtOnly;
	}




	/**
	 * @return the peps
	 */
	public List<String> getPeps() {
		return peps;
	}




	/**
	 * @param pepList the peps to set
	 */
	public void setPeps(List<String> peps) {
		this.peps = peps;
	}




	/**
	 * @return the lEqi treat Leucine and Isoleucine be equivalent, default is true
	 */
	public String getlEqi() {
		return lEqi;
	}

	/**
	 * @param lEqi the lEqi to set
	 */
	public void setlEqi(String lEqi) {
		this.lEqi = lEqi;
	}




	/**
	 * @return the taxIds
	 */
	public List<Integer> getTaxIds() {
		return taxIds;
	}




	/**
	 * @param taxIds the taxIds to set
	 */
	public void setTaxIds(List<Integer> taxIds) {
		this.taxIds = taxIds;
	}




	/**
	 * @return the swissProtOnly
	 */
	public String getSwissProtOnly() {
		return swissProtOnly;
	}




	/**
	 * @param swissProtOnly the swissProtOnly to set
	 */
	public void setSwissProtOnly(String swissProtOnly) {
		this.swissProtOnly = swissProtOnly;
	}

	

	

	

}
