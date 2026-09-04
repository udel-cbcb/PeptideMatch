package org.proteininformationresource.peptidematch;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import org.proteininformationresource.peptidematch.config.ESClientFactory;
import org.proteininformationresource.peptidematch.search.ESSearchService;
import org.proteininformationresource.peptidematch.search.ESSearchService.SearchResult;
import org.proteininformationresource.peptidematch.search.MatchPositionFinder;

import io.swagger.model.Protein;
import io.swagger.model.ProteinMatchRange;
import io.swagger.model.ProteinMatchingPeptide;
import io.swagger.model.Report;
import io.swagger.model.ReportResults;
import io.swagger.model.ReportSearchParameters;

public class MatchService {

	private Query query;
	private Report report;
	private static ESSearchService searchService;

	static {
		try {
			ElasticsearchClient client = ESClientFactory.createClient();
			searchService = new ESSearchService(client);
		} catch (Exception e) {
			throw new RuntimeException("Failed to initialize ES client", e);
		}
	}

	public MatchService(Query query) {
		super();
		this.query = query;
	}

	public Query getQuery() {
		return query;
	}

	public void setQuery(Query query) {
		this.query = query;
	}

	public Report getReport() {
		return report;
	}

	public void setReport(Report report) {
		this.report = report;
	}

	public Report doSearch(Query query) {
		Report report = new Report();
		ReportSearchParameters searchParameters = query.getSearchParameters();
		report.setSearchParameters(query.getSearchParameters());

		List<ReportResults> results = new ArrayList<ReportResults>();
		ReportResults result = doESQuery(query.getPeps(), searchParameters);
		results.add(result);
		report.setResults(results);

		try {
			String leqi = searchParameters.getLeqi() ? "Y" : "N";
			String swissprot = searchParameters.getSwissprot() ? "Y" : "N";
			String isoform = searchParameters.getIsoform() ? "Y" : "N";
			String taxonids = searchParameters.getTaxonids() != null ? searchParameters.getTaxonids() : "";

			long totalFound = searchService.countByPeptide(
				query.getPeps(), taxonids, swissprot, isoform, leqi);
			report.setNumberFound((int) totalFound);
			report.setQtime(0);
			report.setStatus(200);
		} catch (IOException e) {
			report.setStatus(500);
		}

		return report;
	}

	private ReportResults doESQuery(String queryPeptide, ReportSearchParameters searchParameters) {
		ReportResults results = new ReportResults();
		results.setQueryPeptide(queryPeptide);
		List<Protein> proteins = new ArrayList<Protein>();

		try {
			String taxonids = searchParameters.getTaxonids() != null ? searchParameters.getTaxonids() : "";
			String leqi = searchParameters.getLeqi() ? "Y" : "N";
			String swissprot = searchParameters.getSwissprot() ? "Y" : "N";
			String isoform = searchParameters.getIsoform() ? "Y" : "N";
			Integer offset = searchParameters.getOffset() != null ? searchParameters.getOffset() : 0;
			Integer size = searchParameters.getSize() != null ? searchParameters.getSize() : 10;

			SearchResult searchResult = searchService.searchByPeptide(
				queryPeptide, taxonids, swissprot, isoform, leqi,
				offset, size, "ac_asc");

			for (Map<String, Object> hit : searchResult.hits()) {
				Protein protein = new Protein();

				String ac = (String) hit.get("ac");
				protein.setAc(ac);

				String proteinID = (String) hit.get("proteinID");
				protein.setId(proteinID);

				String reviewStatus = (String) hit.get("sptr");
				protein.setReviewStatus(reviewStatus);

				String proteinName = (String) hit.get("proteinName");
				protein.setName(proteinName);

				String organismName = (String) hit.get("organismName");
				protein.setOrgName(organismName);

				Object organismIDObj = hit.get("organismID");
				Integer organismID = Integer.valueOf(organismIDObj.toString());
				protein.setOrgTaxonId(organismID);

				String seq = (String) hit.get("originalSeq");
				protein.setSequence(seq);

				addMatchingPeptides(protein, queryPeptide, leqi);
				proteins.add(protein);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}

		results.setProteins(proteins);
		return results;
	}

	private void addMatchingPeptides(Protein protein, String queryPeptide, String leqi) {
		String[] peptides = queryPeptide.replaceAll(" ", "").split(",");
		List<ProteinMatchingPeptide> matchingPeptides = new ArrayList<ProteinMatchingPeptide>();
		for (int i = 0; i < peptides.length; i++) {
			String peptide = peptides[i];
			List<MatchPositionFinder.MatchRange> matches =
				MatchPositionFinder.findMatches(peptide, protein.getSequence(), "Y".equals(leqi));

			if (!matches.isEmpty()) {
				ProteinMatchingPeptide matchingPeptide = new ProteinMatchingPeptide();
				matchingPeptide.setPeptide(peptide);
				ArrayList<ProteinMatchRange> matchRanges = new ArrayList<ProteinMatchRange>();
				for (MatchPositionFinder.MatchRange match : matches) {
					ProteinMatchRange range = new ProteinMatchRange();
					range.setStart(match.start());
					range.setEnd(match.end());
					if (match.replacedPositions() != null) {
						range.setReplacedLocs(new ArrayList<>(match.replacedPositions()));
					}
					matchRanges.add(range);
				}
				matchingPeptide.setMatchRange(matchRanges);
				matchingPeptides.add(matchingPeptide);
			}
		}
		protein.setMatchingPeptide(matchingPeptides);
	}
}
