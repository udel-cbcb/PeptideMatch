package org.proteininformationresource.peptidematch.asyncrest.resource.bean;

import java.util.List;

import javax.ws.rs.QueryParam;

import org.proteininformationresource.peptidematch.asyncrest.model.Organism;
import org.proteininformationresource.peptidematch.asyncrest.model.Peptide;


public class MatchQueryParamBean {
	private @QueryParam("peptideList") List<Peptide> peptideList;
	private @QueryParam("targetOrganismList") List<Organism> targetOrganismList;
	private @QueryParam("uniref100Only") boolean uniref100Only;
	private @QueryParam("swissProtOnly") boolean swissProtOnly;
	private @QueryParam("lEqi") boolean lEqi;
	private @QueryParam("reportFormat") String reportFormat;
	/**
	 * @return the peptideList
	 */
	public List<Peptide> getPeptideList() {
		return peptideList;
	}
	/**
	 * @param peptideList the peptideList to set
	 */
	public void setPeptideList(List<Peptide> peptideList) {
		this.peptideList = peptideList;
	}
	/**
	 * @return the targetOrganismList
	 */
	public List<Organism> getTargetOrganismList() {
		return targetOrganismList;
	}
	/**
	 * @param targetOrganismList the targetOrganismList to set
	 */
	public void setTargetOrganismList(List<Organism> targetOrganismList) {
		this.targetOrganismList = targetOrganismList;
	}
	/**
	 * @return the uniref100Only
	 */
	public boolean isUniref100Only() {
		return uniref100Only;
	}
	/**
	 * @param uniref100Only the uniref100Only to set
	 */
	public void setUniref100Only(boolean uniref100Only) {
		this.uniref100Only = uniref100Only;
	}
	/**
	 * @return the swissProtOnly
	 */
	public boolean isSwissProtOnly() {
		return swissProtOnly;
	}
	/**
	 * @param swissProtOnly the swissProtOnly to set
	 */
	public void setSwissProtOnly(boolean swissProtOnly) {
		this.swissProtOnly = swissProtOnly;
	}
	/**
	 * @return the lEqi
	 */
	public boolean islEqi() {
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
	 * @param reportFormat the reportFormat to set
	 */
	public void setReportFormat(String reportFormat) {
		this.reportFormat = reportFormat;
	}
	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "MatchQueryParamBean [peptideList=" + peptideList
				+ ", targetOrganismList=" + targetOrganismList
				+ ", uniref100Only=" + uniref100Only + ", swissProtOnly="
				+ swissProtOnly + ", lEqi=" + lEqi + ", reportFormat="
				+ reportFormat + "]";
	}
	
	
	
}
