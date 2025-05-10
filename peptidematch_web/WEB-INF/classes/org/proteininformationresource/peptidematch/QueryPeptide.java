package org.proteininformationresource.peptidematch;

public class QueryPeptide {
	private String id;
	private String seq;

	public QueryPeptide() {

	}

	public QueryPeptide(String id, String seq) {
		this.id = id;
		this.seq = seq;
	}
	
	public String getId() {
		return this.id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getSeq() {
		return this.seq;
	}

	public void setSeq(String seq) {
		this.seq = seq;
	}	
	
	 /* (non-Javadoc)
         * @see java.lang.Object#hashCode()
         */
        @Override
        public int hashCode() {
                final int prime = 31;
                int result = 1;
                result = prime * result + ((id == null) ? 0 : id.hashCode());
                result = prime * result + ((seq == null) ? 0 : seq.hashCode());
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
                if (!(obj instanceof QueryPeptide)) {
                        return false;
                }
                QueryPeptide other = (QueryPeptide) obj;
                if (id == null) {
                        if (other.id != null) {
                                return false;
                        }
                } else if (!id.equals(other.id)) {
                        return false;
                }
                if (seq == null) {
                        if (other.seq != null) {
                                return false;
                        }
                } else if (!seq.equals(other.seq)) {
                        return false;
                }
                return true;
	}
	
}
