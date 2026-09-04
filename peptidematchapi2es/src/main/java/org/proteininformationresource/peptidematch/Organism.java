package org.proteininformationresource.peptidematch;

public class Organism {
	private String name;
	private int taxonId;

	public Organism() {
	}

	public Organism(String name, int taxonId) {
		this.name = name;
		this.taxonId = taxonId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getTaxonId() {
		return taxonId;
	}

	public void setTaxonId(int taxonId) {
		this.taxonId = taxonId;
	}
}
