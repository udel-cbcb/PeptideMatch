package org.proteininformationresource.peptidematch;

import io.swagger.model.Error;
import io.swagger.model.Protein;
import io.swagger.model.Report;
import io.swagger.model.ReportResults;
import io.swagger.model.ReportSearchParameters;

import java.util.List;

public class MatchServiceUtil {

	public static Error validateInputs(String peptides) {
		Error error = null;
		String[] peps = peptides.replaceAll(" ", "").split(",");
		if (peps.length > 100) {
			error = new Error();
			error.setCode("400");
			error.setMessage("Bad request. Number of query peptides is larger than 100.");
		}
		return error;
	}

	public static Query getQuery(String peptides, String taxonids, Boolean swissprot, Boolean isoform, Boolean uniref100, Boolean leqi, Integer offset,
			Integer size) {
		// String[] peptideList = peptides.split(",\\s+");
		// String[] taxonidList = taxonids.split(",\\s+");
		// ArrayList<String> peptideArray = new
		// ArrayList<String>(Arrays.asList(peptideList));
		// ArrayList<String> taxonidArray = new
		// ArrayList<String>(Arrays.asList(taxonidList));

		return new Query(peptides, getSearchParameters(taxonids, swissprot, isoform, uniref100, leqi, offset, size));
	}

	public static ReportSearchParameters getSearchParameters(String taxonids, Boolean swissprot, Boolean isoform, Boolean uniref100, Boolean leqi,
			Integer offset, Integer size) {
		ReportSearchParameters searchParameters = new ReportSearchParameters();
		if (taxonids == null) {
			searchParameters.setTaxonids("");
		} else {
			searchParameters.setTaxonids(taxonids);
		}
		if (uniref100 != null) {
			searchParameters.setUniref100(uniref100);
		} else {
			searchParameters.setUniref100(false);
		}
		if (leqi != null) {
			searchParameters.setLeqi(leqi);
		} else {
			searchParameters.setLeqi(false);
		}
		if (swissprot != null) {
			searchParameters.setSwissprot(swissprot);
		} else {
			searchParameters.setSwissprot(false);
		}
		if (isoform != null) {
			searchParameters.setIsoform(isoform);
		} else {
			searchParameters.setIsoform(false);
		}
		if (offset != null) {
			searchParameters.setOffset(offset);
		} else {
			searchParameters.setOffset(0);
		}
		if (size != null) {
			if (size == -1) {
				searchParameters.setSize(Integer.MAX_VALUE);
				searchParameters.setOffset(0);
			} else {
				searchParameters.setSize(size);
			}
		} else {
			searchParameters.setSize(100);
		}
		return searchParameters;
	}

	public static String getFASTA(Report report) {
		String fasta = "";
		List<ReportResults> results = report.getResults();
		for (ReportResults result : results) {
			String queryPeptide = result.getQueryPeptide();
			List<Protein> proteins = result.getProteins();
			for (Protein protein : proteins) {
				String status = protein.getReviewStatus();
				String ac = protein.getAc();
				String id = protein.getId();
				String name = protein.getName();
				String orgName = protein.getOrgName();
				Integer orgTaxonId = protein.getOrgTaxonId();
				String orgTaxonGroupName = protein.getOrgTaxonGroupName();
				Integer orgTaxonGroupId = protein.getOrgTaxonGroupId();
				String sequence = protein.getSequence();
				fasta += ">" + status + "|" + ac + "|" + id + " " + name + "^|^" + orgName + "^|^" + orgTaxonId + "^|^" + orgTaxonGroupName + "^|^"
						+ orgTaxonGroupId + " " + queryPeptide + "\n";
				fasta += sequence + "\n";
			}
		}
		return fasta;
	}

	public static String getTSV(Report report) {
		String tsv = "SP/TR\tAC\tID\tName\tOrgName\tOrgTaxonID\tOrgTaxonGroupName\tOrgTaxonGroupID\tSeuqnece\tQueryPeptide\n";
		List<ReportResults> results = report.getResults();
		for (ReportResults result : results) {
			String queryPeptide = result.getQueryPeptide();
			List<Protein> proteins = result.getProteins();
			for (Protein protein : proteins) {
				String status = protein.getReviewStatus();
				String ac = protein.getAc();
				String id = protein.getId();
				String name = protein.getName();
				String orgName = protein.getOrgName();
				Integer orgTaxonId = protein.getOrgTaxonId();
				String orgTaxonGroupName = protein.getOrgTaxonGroupName();
				Integer orgTaxonGroupId = protein.getOrgTaxonGroupId();
				String sequence = protein.getSequence();
				tsv += status + "\t" + ac + "\t" + id + "\t" + name + "\t" + orgName + "\t" + orgTaxonId + "\t" + orgTaxonGroupName + "\t" + orgTaxonGroupId
						+ "\t" + sequence + "\t" + queryPeptide + "\n";
			}
		}
		return tsv;
	}
}
