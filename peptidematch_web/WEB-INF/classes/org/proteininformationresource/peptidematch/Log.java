package org.proteininformationresource.peptidematch;

public class Log {
	int index;
	int total;
	String peptide;
	int numProteins;
	int numOrganisms;
	float timeUsed;
	//(3/3):	Searching CALLRCIPAL	[protein(s): 75, organism(s): 46, time: 0.03 sec.]
	//(2/3):	Searching SVQYDDVPEYK	[protein(s): 40, organism(s): 24, time: 0.02 sec.]
	//(1/3):	Searching AAVEEGIVLGGGCALLR	[protein(s): 60, organism(s): 35, time: 0.25 sec.]
	public Log (int index, int total, String peptide, int numProteins, int numOrganisms, float timeUsed) {
		this.index = index;
		this.total = total;
		this.peptide = peptide;
		this.numProteins = numProteins;
		this.numOrganisms = numOrganisms;
		this.timeUsed = timeUsed;
	}

	public int getIndex() {
		return this.index;
	}
	
	public void setIndex(int index) {
		this.index = index;
	} 	
	
	public int getTotal() {
		return this.total;
	}
	
	public void setTotal(int total) {
		this.total = total;
	} 
	
	public String getPeptide() {
		return this.peptide;
	}
	
	public void setPeptide(String peptide) {
		this.peptide = peptide;
	}

	public int getNumProteins() {
		return this.numProteins;
	}
	
	public void setNumProteins(int numProteins) {
		this.numProteins = numProteins;
	}

	public int getNumOrganisms() {
		return this.numOrganisms;
	}
	
	public void setNumOrganisms(int numOrganisms) {
		this.numOrganisms = numOrganisms;
	}

	public float getTimeUsed() {
		return this.timeUsed;
	}
	
	public void setTimeUsed(float timeUsed) {
		this.timeUsed = timeUsed;
	}

	
}
