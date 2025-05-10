package org.proteininformationresource.peptidematch.asyncrest.model.copy;

import java.util.ArrayList;
import java.util.List;

/**
 * This class represents a matched UniProtKB protein entry
 * 
 * @author chenc
 *
 */
public class MatchedProtein {
	/**
	 * The primary accession number of UniProtKB protein entry
	 */
	private String proteinAC;
	
	/**
	 * The identifier of UniProtKB protein entry
	 */
	private String proteinID;
	
	/**
	 * The review status of UniProtKB protein entry, can be "Reviewed or Unreviewed"
	 */
	private String reviewStatus;
	
	/**
	 * The name of UniProtKB protein entry
	 */
	private String proteinName;
	
	/**
	 * The organism of UniProtKB protein entry
	 */
	private Organism organism;
	
	/**
	 * The organism taxonomic group of UniProtKB protein entry
	 */
	private Organism organismTaxonomicGroup;
	
	/**
	 * Whether the protein is also in NIST database 
	 */
	private boolean proteinInNIST;
	
	/**
	 * Whether the protein is also in PeptideAtlas database
	 */
    private boolean proteinInPeptideAtlas;
    
    /**
     * Whether the protein is also in Pride database
     */
    private boolean proteinInPride;
    
    /**
     * A list of IEDB Ids for the protein
     */
    private List<String> iedbIds;
    
    /**
     * A list of matched ranges
     */
    private List<MatchedRange> matchedRanges;
    
    /**
     * The amino acid sequence of the UniProtKB protein entry
     */
    private String sequence;

	/**
	 * 
	 */
	public MatchedProtein() {
		super();
	}

	/**
	 * @param proteinAC the primary accession number of UniProtKB protein entry
	 * @param proteinID the identifier of UniProtKB protein entry
	 * @param reviewStatus the review status of UniProtKB protein entry, can be "Reviewed or Unreviewed"
	 * @param proteinName the name of UniProtKB protein entry
	 * @param organism the organism of UniProtKB protein entry
	 * @param organismTaxonomicGroup the organism taxonomic group of UniProtKB protein entry
	 * @param proteinInNIST whether the protein is also in NIST database 
	 * @param proteinInPeptideAtlas whether the protein is also in PeptideAtlas database
	 * @param proteinInPride whether the protein is also in Pride database
	 * @param iedbIds a list of IEDB Ids for the protein
	 * @param matchedRanges a list of matched ranges
	 * @param sequence the amino acid sequence of the UniProtKB protein entry
	 */
	public MatchedProtein(String proteinAC, String proteinID,
			String reviewStatus, String proteinName, Organism organism,
			Organism organismTaxonomicGroup, boolean proteinInNIST,
			boolean proteinInPeptideAtlas, boolean proteinInPride,
			List<String> iedbIds, List<MatchedRange> matchedRanges,
			String sequence) {
		super();
		this.proteinAC = proteinAC;
		this.proteinID = proteinID;
		this.reviewStatus = reviewStatus;
		this.proteinName = proteinName;
		this.organism = organism;
		this.organismTaxonomicGroup = organismTaxonomicGroup;
		this.proteinInNIST = proteinInNIST;
		this.proteinInPeptideAtlas = proteinInPeptideAtlas;
		this.proteinInPride = proteinInPride;
		if(iedbIds == null) {
			this.iedbIds = new ArrayList<String>();
		}
		else {
			this.iedbIds = iedbIds;
		}
		this.matchedRanges = matchedRanges;
		this.sequence = sequence;
	}

	/**
	 * @return the proteinAC
	 */
	public String getProteinAC() {
		return proteinAC;
	}

	/**
	 * @param proteinAC the proteinAC to set
	 */
	public void setProteinAC(String proteinAC) {
		this.proteinAC = proteinAC;
	}

	/**
	 * @return the proteinID
	 */
	public String getProteinID() {
		return proteinID;
	}

	/**
	 * @param proteinID the proteinID to set
	 */
	public void setProteinID(String proteinID) {
		this.proteinID = proteinID;
	}

	/**
	 * @return the reviewStatus
	 */
	public String getReviewStatus() {
		return reviewStatus;
	}

	/**
	 * @param reviewStatus the reviewStatus to set
	 */
	public void setReviewStatus(String reviewStatus) {
		this.reviewStatus = reviewStatus;
	}

	/**
	 * @return the proteinName
	 */
	public String getProteinName() {
		return proteinName;
	}

	/**
	 * @param proteinName the proteinName to set
	 */
	public void setProteinName(String proteinName) {
		this.proteinName = proteinName;
	}

	/**
	 * @return the organism
	 */
	public Organism getOrganism() {
		return organism;
	}

	/**
	 * @param organism the organism to set
	 */
	public void setOrganism(Organism organism) {
		this.organism = organism;
	}

	/**
	 * @return the organismTaxonomicGroup
	 */
	public Organism getOrganismTaxonomicGroup() {
		return organismTaxonomicGroup;
	}

	/**
	 * @param organismTaxonomicGroup the organismTaxonomicGroup to set
	 */
	public void setOrganismTaxonomicGroup(Organism organismTaxonomicGroup) {
		this.organismTaxonomicGroup = organismTaxonomicGroup;
	}

	/**
	 * @return the proteinInNIST
	 */
	public boolean isProteinInNIST() {
		return proteinInNIST;
	}

	/**
	 * @param proteinInNIST the proteinInNIST to set
	 */
	public void setProteinInNIST(boolean proteinInNIST) {
		this.proteinInNIST = proteinInNIST;
	}

	/**
	 * @return the proteinInPeptideAtlas
	 */
	public boolean isProteinInPeptideAtlas() {
		return proteinInPeptideAtlas;
	}

	/**
	 * @param proteinInPeptideAtlas the proteinInPeptideAtlas to set
	 */
	public void setProteinInPeptideAtlas(boolean proteinInPeptideAtlas) {
		this.proteinInPeptideAtlas = proteinInPeptideAtlas;
	}

	/**
	 * @return the proteinInPride
	 */
	public boolean isProteinInPride() {
		return proteinInPride;
	}

	/**
	 * @param proteinInPride the proteinInPride to set
	 */
	public void setProteinInPride(boolean proteinInPride) {
		this.proteinInPride = proteinInPride;
	}

	/**
	 * @return the iedbIds
	 */
	public List<String> getIedbIds() {
		return iedbIds;
	}

	/**
	 * @param iedbIds the iedbIds to set
	 */
	public void setIedbIds(List<String> iedbIds) {
		this.iedbIds = iedbIds;
	}

	/**
	 * @return the matchedRanges
	 */
	public List<MatchedRange> getMatchedRanges() {
		return matchedRanges;
	}

	/**
	 * @param matchedRanges the matchedRanges to set
	 */
	public void setMatchedRanges(List<MatchedRange> matchedRanges) {
		this.matchedRanges = matchedRanges;
	}

	/**
	 * @return the sequence
	 */
	public String getSequence() {
		return sequence;
	}

	/**
	 * @param sequence the sequence to set
	 */
	public void setSequence(String sequence) {
		this.sequence = sequence;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "MatchedProtein [proteinAC=" + proteinAC + ", proteinID="
				+ proteinID + ", reviewStatus=" + reviewStatus
				+ ", proteinName=" + proteinName + ", organism=" + organism
				+ ", organismTaxonomicGroup=" + organismTaxonomicGroup
				+ ", proteinInNIST=" + proteinInNIST
				+ ", proteinInPeptideAtlas=" + proteinInPeptideAtlas
				+ ", proteinInPride=" + proteinInPride + ", iedbIds=" + iedbIds
				+ ", matchedRanges=" + matchedRanges + ", sequence=" + sequence
				+ "]";
	}
    
    

}
