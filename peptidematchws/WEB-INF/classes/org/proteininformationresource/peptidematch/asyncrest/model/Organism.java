package org.proteininformationresource.peptidematch.asyncrest.model;

/**
 * This class represents an organism
 * 
 * @author chenc
 *
 */
public class Organism {
	/**
	 * Organism name
	 */
	private String name;
	
	/**
	 * Organism NCBI taxon Id
	 */
	private int taxonId;
	
	public Organism() {
		super();
	}

	/**
	 * @param name
	 * @param taxonId
	 */
	public Organism(String name, int taxonId) {
		super();
		this.name = name;
		this.taxonId = taxonId;
	}

	/**
	 * @return the name organism name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @param name the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}

	/**
	 * @return the taxonId organism NCBI taxon Id
	 */
	public int getTaxonId() {
		return taxonId;
	}

	/**
	 * @param taxonId the taxonId to set
	 */
	public void setTaxonId(int taxonId) {
		this.taxonId = taxonId;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "Organism [name=" + name + ", taxonId=" + taxonId + "]";
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + taxonId;
		return result;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		if (!(obj instanceof Organism)) {
			return false;
		}
		Organism other = (Organism) obj;
		if (name == null) {
			if (other.name != null) {
				return false;
			}
		} else if (!name.equals(other.name)) {
			return false;
		}
		if (taxonId != other.taxonId) {
			return false;
		}
		return true;
	}
	
	
	
}
