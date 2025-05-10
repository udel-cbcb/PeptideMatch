package org.proteininformationresource.peptidematch.asyncrest.model.copy;

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
	private List<Peptide> peptideList;
	
	/**
	 * targetOrganismList a list of target organisms
	 */
	private List<Organism> targetOrganismList;
	
	/**
	 * uniref100Only only search in uniref100 entries, default is false
	 */
	private Boolean uniref100Only = false;

	/**
	 * swissProtOnly only search in SwissProt entries, default is false
	 */
	private Boolean swissProtOnly = false;
	
	/**
	 * LEqi treat Leucine and Isoleucine be equivalent, default is true
	 */
	private Boolean lEqi = true;
	
	/**
	 * reportFormat the format of match report, default is JSON
	 */
	private String reportFormat;

	/**
	 * 
	 */
	public Query() {
		super();
		lEqi = true;
		swissProtOnly = false;
		uniref100Only = false;
		reportFormat= "json";
	}

	/**
	 * @param peptideList a list of query peptides
	 * @param targetOrganismList a list of target organisms
	 * @param uniref100Only only search in uniref100 entries, default is false
	 * @param swissProtOnly only search in SwissProt entries, default is false
	 * @param lEqi treat Leucine and Isoleucine be equivalent, default is true
	 * @param reportFormat the format of match report, default is JSON
	 */
	public Query(List<Peptide> peptideList, List<Organism> targetOrganismList,
			Boolean uniref100Only, Boolean swissProtOnly, Boolean lEqi,
			String reportFormat) {
		super();
		if(peptideList == null) {
			this.peptideList = new ArrayList<Peptide>();
		}
		else {
			this.peptideList = peptideList;
		}
		if(targetOrganismList == null) {
			this.targetOrganismList = new ArrayList<Organism>();
		}
		else {
			this.targetOrganismList = targetOrganismList;
		}
		this.uniref100Only = uniref100Only;
		this.swissProtOnly = swissProtOnly;
		if(lEqi == null) {
			this.lEqi = true;
		}
		else {
			this.lEqi = lEqi;
		}
		if(this.reportFormat == null) {
			this.reportFormat = MediaType.APPLICATION_JSON;
		}
		else {
			this.reportFormat = reportFormat;
		}
	}

	/**
	 * @return the peptideList a list of query peptides
	 */
	public List<Peptide> getPeptideList() {
		return peptideList;
	}

	/**
	 * @param peptideList a list of query peptides to set
	 */
	public void setPeptideList(List<Peptide> peptideList) {
		this.peptideList = peptideList;
	}

	/**
	 * @return the targetOrganismList a list of target organisms
	 */
	public List<Organism> getTargetOrganismList() {
		return targetOrganismList;
	}

	/**
	 * @param targetOrganismList the a list of target organisms to set
	 */
	public void setTargetOrganismList(List<Organism> targetOrganismList) {
		this.targetOrganismList = targetOrganismList;
	}

	/**
	 * @return the uniref100Only only search in uniref100 entries, default is false
	 */
	public Boolean isUniref100Only() {
		return uniref100Only;
	}

	/**
	 * @param uniref100Only the uniref100Only to set
	 */
	public void setUniref100Only(Boolean uniref100Only) {
		this.uniref100Only = uniref100Only;
	}

	/**
	 * @return the swissProtOnly only search in SwissProt entries, default is false
	 */
	public Boolean isSwissProtOnly() {
		return swissProtOnly;
	}

	/**
	 * @param swissProtOnly the swissProtOnly to set
	 */
	public void setSwissProtOnly(Boolean swissProtOnly) {
		this.swissProtOnly = swissProtOnly;
	}

	/**
	 * @return the lEqi treat Leucine and Isoleucine be equivalent, default is true
	 */
	public Boolean islEqi() {
		return lEqi;
	}

	/**
	 * @param lEqi the lEqi to set
	 */
	public void setlEqi(boolean lEqi) {
		this.lEqi = lEqi;
	}

	/**
	 * @return the reportFormat
	 */
	public String getReportFormat() {
		return reportFormat;
	}

	/**
	 * @param reportFormat the format of match report, default is JSON
	 */
	public void setReportFormat(String reportFormat) {
		this.reportFormat = reportFormat;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "Query [peptideList=" + peptideList + ", targetOrganismList="
				+ targetOrganismList + ", uniref100Only=" + uniref100Only
				+ ", swissProtOnly=" + swissProtOnly + ", lEqi=" + lEqi
				+ ", reportFormat=" + reportFormat + "]";
	}

	

}
