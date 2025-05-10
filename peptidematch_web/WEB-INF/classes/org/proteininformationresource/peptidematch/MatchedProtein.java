package org.proteininformationresource.peptidematch;

public class MatchedProtein  {
	private String proteinAC;
	private String proteinID;
	private String reviewStatus;
	private String proteinName;
	private Organism organism;
	private Organism taxonomicGroup;
	private String nist;
	private String peptideAtlas;
	private String pride;
	private String[] iedb;
	private MatchedRange[] matchedRanges;
	private String sequence;
	private int seqLength;
	
	public MatchedProtein() {

	}

	public MatchedProtein(String proteinAC, String proteinID, String reviewStatus, String proteinName, Organism organism, Organism taxonomicGroup, String sequence, int seqLength, MatchedRange[] matchedRanges) {
		this.proteinAC = proteinAC;
		this.proteinID = proteinID;
		this.reviewStatus = reviewStatus;
		this.proteinName = proteinName;
		this.organism = organism;
		this.taxonomicGroup = taxonomicGroup;
		this.sequence = sequence;
		this.seqLength = seqLength; 
		this.matchedRanges = matchedRanges;
	}

	public void setNIST(String nist) {
		this.nist = nist;
	}

	public String getNIST() {
		return this.nist;
	}

	public void setPeptideAtlas(String peptideAtlas) {
		this.peptideAtlas = peptideAtlas;
	}

	public String getPeptideAtlas() {
		return this.peptideAtlas;
	}

	public void setPride(String pride) {
		this.pride = pride;
	}
	
	public String getPride() {
		return this.pride;
	}

        public void setIEDB(String[] iedb) {
		//System.out.println("setting iedb .."+ iedb.toString());
		this.iedb = iedb;
	}
	
	public String[] getIEDB() {
		return this.iedb;
	} 
	public void setProteinAC(String proteinAC) {
		this.proteinAC = proteinAC;
	}
	
	public String getProteinAC() {
		return this.proteinAC;
	} 
	
	public void setProteinID(String proteinID) {
		this.proteinID = proteinID;
	}

	public String getProteinID() {
		return this.proteinID;
	}

	public void setReviewStatus(String reviewStatus) {
		this.reviewStatus = reviewStatus;
	}

	public String getReviewStatus() {
		return this.reviewStatus;
	}

	public void setProteinName(String proteinName) {
		this.proteinName = proteinName;
	}

	public String getProteinName() {
		return this.proteinName;
	}

	public void setOrganism(Organism organism) {
		this.organism = organism;
	}

	public Organism getOrganism() {
		return this.organism;
	}

	public void setTaxonomicGroup(Organism taxonomicGroup) {
		this.taxonomicGroup = taxonomicGroup;
	}

	public Organism getTaxonomicGroup() {
		return this.taxonomicGroup;
	}

	public void setSequence(String sequence) {
		this.sequence = sequence;
	}

	public String getSequence() {
		return this.sequence;
	}

	public void setSeqLength(int seqLength) {
		this.seqLength = seqLength;
	}

	public int getSeqLength() {
		return this.seqLength;
	}

	public void setMatchedRanges(MatchedRange[] matchedRanges) {
		this.matchedRanges = matchedRanges;
	}

	public MatchedRange[] getMatchedRanges() {
		return this.matchedRanges;
	}

	public String getIProClassInfo() {
		String info = ">"+this.proteinAC+ " "+this.proteinID+"^|^"+this.proteinName+"^|^"+this.organism.getName()+"^|^"+this.organism.getTaxonId()+"^|^"+this.taxonomicGroup.getName()+"^|^"+this.taxonomicGroup.getTaxonId();
		return info;
	}

        public String getXMLInfo(boolean uniref100) {
		String info = "<matchedProtein>\n";
		if(uniref100) {
			info += "<UniRef100ClusterID>UniRef100_"+this.proteinAC+"</UniRef100ClusterID>\n";
			info += "<UniRef100RepresentativeProteinAC>"+this.proteinAC+"</UniRef100RepresentativeProteinAC>\n";
			info += "<proteinAC/>\n";
			info += "<proteinID/>\n";
		}
		else {
			info +="<UniRef100ClusterID/>\n";
			info +="<UniRef100RepresentativeProteinAC/>\n";
			info += "<proteinAC>"+this.proteinAC+"</proteinAC>\n";
			info += "<proteinID ";
			if(this.reviewStatus.equals("Y")) {
				info += "type=\"SwissProt\">"+this.proteinID+"</proteinID>\n";
			}
			else {
				info += "type=\"TrEMBL\">"+this.proteinID+"</proteinID>\n";
			}
		}
	        info += "<proteinName>"+this.proteinName+"</proteinName>\n";
	        info += "<seqLength>"+this.seqLength+"</seqLength>\n";
		info += "<organism name=\""+this.organism.getName()+"\" taxonomyId=\""+this.organism.getTaxonId()+"\"/>\n";
		info += "<matchRanges>\n";
		for(int i = 0; i < this.matchedRanges.length; i++) {
			MatchedRange matchedRange = this.matchedRanges[i];
			int[] replacedPos = matchedRange.getReplacedPos();		
			String replacedPosInfo = "";	
			info +="<matchRange start=\""+matchedRange.getStart()+"\" end=\""+matchedRange.getEnd()+"\">\n";
			if(replacedPos != null && replacedPos.length > 0) {
				for(int j=0; j < replacedPos.length; j++) {
					replacedPosInfo += replacedPos[j]+", ";
					info +="<lEqiPos>"+replacedPos[j]+"</lEqiPos>\n";
				}
			}
			info +="</matchRange>\n";
		}
		info += "</matchRanges>\n";
		info +="<proteomicDBs>\n";
		if(this.nist != null && this.nist.length() > 0) {
                       	info += "<nist>"+this.proteinAC+"</nist>\n";
                } 
		if(this.peptideAtlas != null && this.peptideAtlas.length() > 0) {
                       	info += "<peptideAtlas>"+this.proteinAC+"</peptideAtlas>\n";
                } 
		if(this.pride != null && this.pride.length() > 0) {
                       	info += "<pride>"+this.proteinAC+"</pride>\n";
                } 
		info +="</proteomicDBs>\n";
		info +="<iedbs>\n";
		if(this.iedb != null) {
                        for(int i = 0; i < this.iedb.length; i++) {
                                info += "<iedbID>"+this.iedb[i]+"</iedbID>\n";
                        }
                }
		info +="</iedbs>\n";
		info +="</matchedProtein>\n";
		return info;
	}
	
	public String getMatchedRangeInfo() {
		String info = "";
		String matchedRangesInfo = "";
                for(int i = 0; i < this.matchedRanges.length; i++) {
                        MatchedRange matchedRange = this.matchedRanges[i];
                        matchedRangesInfo += matchedRange.getStart() +"-"+ matchedRange.getEnd();
                        int[] replacedPos = matchedRange.getReplacedPos();
                        String replacedPosInfo = "";
                        if(replacedPos != null && replacedPos.length > 0) {
                                for(int j=0; j < replacedPos.length; j++) {
                                        replacedPosInfo += replacedPos[j]+", ";
                                }
                        }
                        if(replacedPosInfo.indexOf(", ") != -1) {
                                replacedPosInfo = replacedPosInfo.substring(0, replacedPosInfo.length() - 2);
                        }
                        if(replacedPosInfo.length() > 0) {
                                matchedRangesInfo += "[L=I: "+replacedPosInfo+"], ";
                        }
                        else {
                                matchedRangesInfo += ", ";
                        }
                }
                if(matchedRangesInfo.indexOf(", ") != -1) {
                        matchedRangesInfo = matchedRangesInfo.substring(0, matchedRangesInfo.length() - 2);
                }
                info += matchedRangesInfo;
		return info;
	}

	public String getTabDelimitedInfo(boolean uniref100) {
		String info = "";
		if(uniref100) {
			info += "UniRef100_"+this.proteinAC+"\t";
			info += this.proteinAC+"\t"; 
		}
		else {
			info += this.proteinAC+"\t"; 
			info += this.proteinID;
			if(this.reviewStatus.equals("Y")) {
				info += " [sp]\t";
			}
			else {
				info += " [tr]\t";
			}	 
		}
		info += this.proteinName+"\t";
		info += this.seqLength+"\t";
		info += this.organism.getName()+" ["+this.organism.getTaxonId()+"]\t";
		String matchedRangesInfo = "";
		for(int i = 0; i < this.matchedRanges.length; i++) {
			MatchedRange matchedRange = this.matchedRanges[i];
			matchedRangesInfo += matchedRange.getStart() +"-"+ matchedRange.getEnd();
			int[] replacedPos = matchedRange.getReplacedPos();		
			String replacedPosInfo = "";	
			if(replacedPos != null && replacedPos.length > 0) {
				for(int j=0; j < replacedPos.length; j++) {
					replacedPosInfo += replacedPos[j]+", ";
				}
			}
			if(replacedPosInfo.indexOf(", ") != -1) {
				replacedPosInfo = replacedPosInfo.substring(0, replacedPosInfo.length() - 2);
			}
			if(replacedPosInfo.length() > 0) {
				matchedRangesInfo += "[L=I: "+replacedPosInfo+"], ";	
			}
			else {
				matchedRangesInfo += ", ";	
			}
		} 					
		if(matchedRangesInfo.indexOf(", ") != -1) {
			matchedRangesInfo = matchedRangesInfo.substring(0, matchedRangesInfo.length() - 2); 
		}
		info += matchedRangesInfo +"\t";
		String proteomicDBs = "";
/*
		if(this.nist != null && !this.nist.equals("Z")) {
			proteomicDBs += "NIST, ";
		}
*/
		if(this.peptideAtlas != null && this.peptideAtlas.equals("Y")) {
			proteomicDBs += "PeptideAtlas, ";
		}
		if(this.pride != null && this.pride.equals("Y")) {
			proteomicDBs += "Pride, ";
		}
		if(proteomicDBs.indexOf(", ") != -1) {
			proteomicDBs = proteomicDBs.substring(0, proteomicDBs.length() - 2); 
		}
		info += proteomicDBs+"\t";
	
		String iedbInfo = "";	
		if(this.iedb != null) {
			for(int i = 0; i < this.iedb.length; i++) {
				iedbInfo += this.iedb[i]+", ";		
			}
			if(iedbInfo.indexOf(", ") != -1) {
				iedbInfo = iedbInfo.substring(0, iedbInfo.length() - 2); 
			}
			info += iedbInfo+"\n";
		}
		else {
			info += "\n";
		}
		return info;
	}
}
