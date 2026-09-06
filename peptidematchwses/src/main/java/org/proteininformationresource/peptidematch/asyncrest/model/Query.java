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
	 * SwissProt only filter: "Y" for swissprot only, "N" for all
	 */
	private String swissprot = "N";

	/**
	 * Isoform filter: "N" to exclude isoforms, "Y" to include, "" for all
	 */
	private String isoform = "";

	/**
	 * Output format: "ac" for comma-separated ACs (default), "json" for full JSON
	 */
	private String format = "ac";

	public Query() {
		super();
		lEqi = "true";
		swissprot = "N";
		isoform = "";
		format = "ac";
	}

	/**
	 * @param peps
	 * @param taxIds
	 * @param lEqi
	 * @param swissprot
	 * @param isoform
	 * @param format
	 */
	public Query(List<String> peps, List<Integer> taxIds, String lEqi, String swissprot, String isoform, String format) {
		super();
		this.peps = peps;
		this.taxIds = taxIds;
		this.lEqi = lEqi;
		this.swissprot = swissprot;
		this.isoform = isoform;
		this.format = format;
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
	 * @return the swissprot filter
	 */
	public String getSwissprot() {
		return swissprot;
	}

	/**
	 * @param swissprot the swissprot to set
	 */
	public void setSwissprot(String swissprot) {
		this.swissprot = swissprot;
	}

	/**
	 * @return the isoform filter
	 */
	public String getIsoform() {
		return isoform;
	}

	/**
	 * @param isoform the isoform to set
	 */
	public void setIsoform(String isoform) {
		this.isoform = isoform;
	}

	/**
	 * @return the output format
	 */
	public String getFormat() {
		return format;
	}

	/**
	 * @param format the format to set
	 */
	public void setFormat(String format) {
		this.format = format;
	}

}
