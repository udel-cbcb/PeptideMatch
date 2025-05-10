package org.proteininformationresource.peptidematch;

public class OrganismCount {
	private Organism organism;
	private int count;
	
	public OrganismCount() {

	}

	public OrganismCount(Organism organism, int count) {
		this.organism = organism;
		this.count = count;
	}

	public Organism getOrganism() {
		return this.organism;
	}

	public void setOrganism(Organism organism) {
		this.organism = organism;
	}

	public int getCount() {
		return this.count;
	}

	public void setCount(int count) {
		this.count = count;
	}
}
