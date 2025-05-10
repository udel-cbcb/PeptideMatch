package org.proteininformationresource.peptidematch;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

import org.apache.commons.lang.ArrayUtils;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;

import io.swagger.model.Protein;
import io.swagger.model.ProteinMatchRange;
import io.swagger.model.ProteinMatchingPeptide;
import io.swagger.model.Report;
import io.swagger.model.ReportResults;
import io.swagger.model.ReportSearchParameters;

public class MatchService {

	/**
	 * Input query peptides and search parameters.
	 */
	private Query query;

	/**
	 * Match results.
	 */
	private Report report;

	/**
	 * @param query
	 */
	public MatchService(Query query) {
		super();
		this.query = query;
	}

	/**
	 * @return the query
	 */
	public Query getQuery() {
		return query;
	}

	/**
	 * @param query
	 *            the query to set
	 */
	public void setQuery(Query query) {
		this.query = query;
	}

	/**
	 * @return the report
	 */
	public Report getReport() {
		return report;
	}

	/**
	 * @param report
	 *            the report to set
	 */
	public void setReport(Report report) {
		this.report = report;
	}

	private Properties getProperties() {
		InputStream inputStream;
		Properties prop = null;
		try {
			prop = new Properties();
			String propFileName = "config.properties";

			inputStream = getClass().getClassLoader().getResourceAsStream(propFileName);

			if (inputStream != null) {
				prop.load(inputStream);

			} else {
				throw new FileNotFoundException("property file '" + propFileName + "' not found in the classpath");
			}
			inputStream.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return prop;
	}

	public Report doSearch(Query query) {
		Report report = new Report();
		ReportSearchParameters searchParameters = query.getSearchParameters();
		report.setSearchParameters(query.getSearchParameters());
		// List<String> queryPeptides = query.getPeptides();
		String solrUrl = this.getProperties().getProperty("solrurl");
		PeptideMatchPhraseQuery peptideMatchPhaseQuery = new PeptideMatchPhraseQuery(solrUrl);
		List<ReportResults> results = new ArrayList<ReportResults>();
		// int numFound = 0;
		// for (int i = 0; i < queryPeptides.size(); i++) {
		// String queryPeptide = queryPeptides.get(i);
		ReportResults result = doPhaseQuery(peptideMatchPhaseQuery, query.getPeps(), searchParameters);
		results.add(result);
		// numFound += peptideMatchPhaseQuery.getNumFound();
		// }
		report.setResults(results);
		report.setNumberFound(peptideMatchPhaseQuery.getNumFound());
		report.setQtime((int) peptideMatchPhaseQuery.getElapsedTime());
		report.setStatus(peptideMatchPhaseQuery.getStatus());
		return report;
	}

	// ac, proteinID, proteinName, organismName, organismID, taxongroupName,
	// taxongroupID, nist, peptideAtlas, pride, iedb, fullLineage, shortLineage,
	// uniref100, originalSeq, length
	private ReportResults doPhaseQuery(PeptideMatchPhraseQuery peptideMatchPhaseQuery, String queryPeptide, ReportSearchParameters searchParameters) {
		SolrDocumentList docs = new SolrDocumentList();
		// System.out.println(queryPeptide);
		String taxonids = searchParameters.getTaxonids();
		String uniref100 = "Y";
		if (!searchParameters.getUniref100()) {
			uniref100 = "N";
		}
		String leqi = "Y";
		if (!searchParameters.getLeqi()) {
			leqi = "N";
		}
		String swissprot = "Y";
		if (!searchParameters.getSwissprot()) {
			swissprot = "N";
		}
		String isoform = "Y";
		if (!searchParameters.getIsoform()) {
			isoform = "N";
		}
		Integer offset = searchParameters.getOffset();
		Integer size = searchParameters.getSize();

		peptideMatchPhaseQuery.query(queryPeptide, taxonids, 0, 1, swissprot, isoform, uniref100, leqi, "ac_asc");
		int numberFound = peptideMatchPhaseQuery.getResult();
		// int numberPerPage =
		// Integer.parseInt(this.getProperties().getProperty("numberperpage"));
		ReportResults results = new ReportResults();
		results.setQueryPeptide(queryPeptide);
		List<Protein> proteins = new ArrayList<Protein>();
		if (numberFound > 0) {
			// for (int i = 0; i < numberFound; i += size) {
			peptideMatchPhaseQuery.query(queryPeptide, taxonids, offset, size, swissprot, isoform, uniref100, leqi, "ac_asc");
			docs = peptideMatchPhaseQuery.getCurrentDocs();
			// System.out.println(docs.size());
			Iterator<SolrDocument> docItr = docs.iterator();
			while (docItr.hasNext()) {
				SolrDocument doc = docItr.next();
				// System.out.println(doc.getFieldNames());
				Protein protein = new Protein();

				// doc.add(new Field("ac", ac, Field.Store.YES,
				// Field.Index.NOT_ANALYZED));
				String ac = (String) doc.getFieldValue("ac");
				// System.out.println(ac);
				protein.setAc(ac);
				// doc.add(new Field("proteinID", proteinID,
				// Field.Store.YES, Field.Index.NOT_ANALYZED));
				String proteinID = (String) doc.getFieldValue("proteinID");
				// System.out.println(proteinID);
				protein.setId(proteinID);
				String reviewStatus = (String) doc.getFieldValue("sptr");
				protein.setReviewStatus(reviewStatus);
				// String[] ids = proteinID.split("_");
				// if (ids[0].length() < 6) {
				// protein.setStatus("SP");
				// }
				// else {
				// protein.setStatus("TR");
				// }

				// doc.add(new
				// Field("proteinName",proteinName,Field.Store.YES,Field.Index.NOT_ANALYZED));
				String proteinName = (String) doc.getFieldValue("proteinName");
				protein.setName(proteinName);
				// doc.add(new
				// Field("organismName",organismName,Field.Store.YES,Field.Index.NOT_ANALYZED));
				String organismName = (String) doc.getFieldValue("organismName");
				protein.setOrgName(organismName);
				// doc.add(new
				// Field("organismID",organismID,Field.Store.YES,Field.Index.NOT_ANALYZED));
				Integer organismID = Integer.valueOf((String) doc.getFieldValue("organismID"));
				protein.setOrgTaxonId(organismID);
				// doc.add(new
				// Field("taxongroupName",taxongroupName,Field.Store.YES,Field.Index.NOT_ANALYZED));
				String taxongroupName = (String) doc.getFieldValue("taxongroupName");
				protein.setOrgTaxonGroupName(taxongroupName);
				// doc.add(new
				// Field("taxongroupID",taxongroupID,Field.Store.YES,Field.Index.NOT_ANALYZED));
				Integer taxongroupID = Integer.valueOf((String) doc.getFieldValue("taxongroupID"));
				protein.setOrgTaxonGroupId(taxongroupID);
				String seq = (String) doc.getFieldValue("originalSeq");
				protein.setSequence(seq);
				addMatchingPeptides(protein, queryPeptide, leqi);
				proteins.add(protein);
			}
			// }
		}
		results.setProteins(proteins);

		return results;
	}

	private void addMatchingPeptides(Protein protein, String queryPeptide, String leqi) {
		String[] peptides = queryPeptide.replaceAll(" ", "").split(",");
		List<ProteinMatchingPeptide> matchingPeptides = new ArrayList<ProteinMatchingPeptide>();
		for(int i = 0; i < peptides.length; i++) {
			String peptide = peptides[i];
			
			if(getMatchRanges(peptide, protein.getSequence(), leqi).size() >0) {
				ProteinMatchingPeptide matchingPeptide = new ProteinMatchingPeptide();
				matchingPeptide.setPeptide(peptide);
				matchingPeptide.setMatchRange(getMatchRanges(peptide, protein.getSequence(), leqi));
				matchingPeptides.add(matchingPeptide);
			}
		}
		protein.setMatchingPeptide(matchingPeptides);
	}

	private ArrayList<ProteinMatchRange> getMatchRanges(String originalQueryPeptide, String originalSeq, String ilEquivalent) {
		String sequence = originalSeq;
		String queryPeptide = originalQueryPeptide;
		ArrayList<ProteinMatchRange> matchedRangeList = new ArrayList<ProteinMatchRange>();
		if (ilEquivalent.equals("Y")) {
			sequence = sequence.replaceAll("L", "I");
			queryPeptide = queryPeptide.replaceAll("L", "I");
		}
		int seqLength = sequence.length();
		for (int i = 0; i <= seqLength - queryPeptide.length(); i++) {
			if (sequence.substring(i, i + queryPeptide.length()).toUpperCase().equals(queryPeptide.toUpperCase())) {
				ProteinMatchRange matchRange = new ProteinMatchRange();
				matchRange.setStart(i + 1);
				matchRange.setEnd(i + queryPeptide.length());
				if (ilEquivalent.equals("Y")) {
					ArrayList<Integer> replacedPosList = new ArrayList<Integer>();
					for (int j = i; j < i + queryPeptide.length(); j++) {
						char originalChar = originalSeq.charAt(j);
						char replacedChar = sequence.charAt(j);
						if (originalChar != replacedChar && originalChar != originalQueryPeptide.charAt(j - i)) {
							replacedPosList.add(new Integer(j + 1));
						}
					}
					//int[] replacedPos = ArrayUtils.toPrimitive(replacedPosList.toArray(new Integer[0]));
					if(replacedPosList.size() > 0) {
						matchRange.setReplacedLocs(replacedPosList);
					}
				}
				//if(matchRange)
				matchedRangeList.add(matchRange);
			}
		}
		//ProteinMatchRange[] matchedRanges = new ProteinMatchRange[matchedRangeList.size()];
		return matchedRangeList;
		
	}

}
