package org.proteininformationresource.peptidematch;

import io.swagger.model.ReportSearchParameters;

public class Query {
	private String peps;
	private ReportSearchParameters searchParameters;

	public Query(String peps, ReportSearchParameters searchParameters) {
		super();
		this.peps = peps;
		this.searchParameters = searchParameters;
	}

	public String getPeps() {
		return peps;
	}

	public void setPeps(String peps) {
		this.peps = peps;
	}

	public ReportSearchParameters getSearchParameters() {
		return searchParameters;
	}

	public void setSearchParameters(ReportSearchParameters searchParameters) {
		this.searchParameters = searchParameters;
	}
}
