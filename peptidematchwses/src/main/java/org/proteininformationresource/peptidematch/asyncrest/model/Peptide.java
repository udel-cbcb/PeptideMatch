package org.proteininformationresource.peptidematch.asyncrest.model;

/**
 * This class represents a query peptide
 * 
 * @author chenc
 *
 */
public class Peptide {
	
	/**
	 * Optional id of a peptide sequence, for example, the identifier of the sequence in FASTA format
	 */
	private String id;
	
	/**
	 * The amino acid sequence of a peptide
	 */
	private String sequence;

	/**
	 * 
	 */
	public Peptide() {
		super();
	}

	/**
	 * @param id optional id of a peptide sequence, for example, the identifier of the sequence in FASTA format
	 * @param sequence the amino acid sequence of a peptide
	 */
	public Peptide(String id, String sequence) {
		super();
		this.id = id;
		this.sequence = sequence;
	}

	/**
	 * @return the id optional id of a peptide sequence, for example, the identifier of the sequence in FASTA format
	 */
	public String getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(String id) {
		this.id = id;
	}

	/**
	 * @return the sequence  the amino acid sequence of a peptide
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
		return "Peptide [id=" + id + ", sequence=" + sequence + "]";
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result
				+ ((sequence == null) ? 0 : sequence.hashCode());
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
		if (!(obj instanceof Peptide)) {
			return false;
		}
		Peptide other = (Peptide) obj;
		if (id == null) {
			if (other.id != null) {
				return false;
			}
		} else if (!id.equals(other.id)) {
			return false;
		}
		if (sequence == null) {
			if (other.sequence != null) {
				return false;
			}
		} else if (!sequence.equals(other.sequence)) {
			return false;
		}
		return true;
	}
	
	
	

}
