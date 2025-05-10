package org.proteininformationresource.peptidematch;

public class Organism {
	private String name;
	private String taxonId;
	
	public Organism (String name, String taxonId) {
		this.name = name;
		this.taxonId = taxonId;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getName() {
		return this.name;
	}
	
	public void setTaxonId(String taxonId) {
		this.taxonId = taxonId;
	}

	public String getTaxonId() {
		return this.taxonId;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + ((taxonId == null) ? 0 : taxonId.hashCode());
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
		if (taxonId == null) {
			if (other.taxonId != null) {
				return false;
			}
		} else if (!taxonId.equals(other.taxonId)) {
			return false;
		}
		return true;
	}

		
}
