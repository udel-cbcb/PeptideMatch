package org.proteininformationresource.peptidematch;

import java.util.ArrayList;
import java.util.List;

public class Query {
	private String[] peptides;
	private String[] peptideIds;
	private Organism[] selectedOrganisms;
	private String uniref100Only = "N";
	private String lEqi = "N";
	private String swissprot = "Y";
	private String isoform = "Y";
	private String errMsg = "";
	private String originalQueryPeptides;
	private String outputFormat = "tab";
	private String trOnly = "N";
	private String isoOnly = "N";

	public Query() {

	}
	public Query(String[] peptides) {
		this.peptides = peptides;
	}

	public void setPeptides(String[] peptides) {
		this.peptides = peptides;
	}

	public String[] getPeptides() {
		return this.peptides;
	}

	public String[] getPeptideIds() {
		return this.peptideIds;
        }

	public void setPeptideIds(String[] peptideIds) {
		this.peptideIds = peptideIds; 
	}
 
	public void setSelectedOrganisms(Organism[] selectedOrganisms) {
		this.selectedOrganisms = selectedOrganisms;
	}

	public Organism[] getSelectedOrganisms() {
		return this.selectedOrganisms;
	}

	public void setUniRef100Only(String uniref100Only) {
		this.uniref100Only = uniref100Only;
	}

	public String getUniRef100Only() {
		return this.uniref100Only;
	}

	public void setLEqI(String lEqi) {
		this.lEqi = lEqi;
	}

	public String getLEqI() {
		return this.lEqi;
	}

	public String getErrMsg() {
		return this.errMsg;
	}

	public String getSwissprot() {
		return this.swissprot;
	}
	
	public void setSwissprot(String swissprot) {
		this.swissprot = swissprot;
	}

	public String getIsoform() {
		return this.isoform;
	}

	public void setIsoform(String isoform) {
		this.isoform = isoform;
	}

	public void setErrMsg(String errMsg) {
		this.errMsg = errMsg; 
	}
	
	public String getTrOnly() {
		return this.trOnly;
	}

	public void setTrOnly(String trOnly) {
		this.trOnly = trOnly;
	}

	public String getIsoOnly() {
		return this.isoOnly;
	}
	
	public void setIsoOnly(String isoOnly) {
		this.isoOnly = isoOnly;
	}
 
	public void setOriginalQueryPeptides(String originalQueryPeptides) {
		this.originalQueryPeptides = originalQueryPeptides;
	}

	public String getOriginalQueryPeptides() {
		return this.originalQueryPeptides;
	}

	public void setOutputFormat(String format) {
		this.outputFormat = format;
	}

	public String getOutputFormat() {
		return this.outputFormat;
	}

	public List<QueryPeptide> getQueryPeptides() {
		List<QueryPeptide> queryPeptides = new ArrayList<QueryPeptide>();
		for(int i = 0; i < peptides.length; i++) {
			QueryPeptide queryPeptide = new QueryPeptide();
			queryPeptide.setId(peptideIds[i]);
			queryPeptide.setSeq(peptides[i]);
			queryPeptides.add(queryPeptide);
		}
		return queryPeptides;
	}

	public QueryPeptide getQueryPeptide(String peptide) {
		QueryPeptide queryPeptide = null;
		for(int i = 0; i < peptides.length; i++) {
			if(peptides[i].equals(peptide)) {
				if(peptideIds == null) {
					queryPeptide =  new QueryPeptide(null, peptides[i]);
				}
				else {
					queryPeptide =  new QueryPeptide(peptideIds[i], peptides[i]);
				}
				return queryPeptide;
			}	
		}
		return queryPeptide;	
	}
}
