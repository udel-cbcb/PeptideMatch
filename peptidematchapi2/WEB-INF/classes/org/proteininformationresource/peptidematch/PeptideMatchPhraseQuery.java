package org.proteininformationresource.peptidematch;

import java.io.*;
import java.util.*;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.client.solrj.SolrRequest.METHOD;
import org.apache.solr.common.params.*;
import org.apache.solr.client.solrj.response.GroupResponse;
import org.apache.solr.client.solrj.response.GroupCommand;
import org.apache.solr.client.solrj.response.Group;
import org.apache.solr.common.util.NamedList;

public class PeptideMatchPhraseQuery {
	private QueryResponse response;
	private CommonsHttpSolrServer solrServer;
	private ArrayList<String> idSets;
	private int result = 0;
	// private String url = "";
	private SolrDocumentList initialDoc;
	private boolean debug = false;
	private NamedList<Object> responseHeader;
	
	public PeptideMatchPhraseQuery(String solrUrl) {
		try {
			solrServer = new CommonsHttpSolrServer(solrUrl);
			
		} catch (Exception e) {
			System.out.println(e.toString());
		}
	}

	// query by the peptide which is no more than 5 characters
	public void queryByPeptide(String query, int start, int rows,
			String uniref100Only, String ilEquivalent, String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}

		// Construct the solr query
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		// solrQuery.setParam("q", phraseQuery);
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 1 ");
		}
		
		initialDoc = docs;
	}

	public Map<String, Long> queryByPeptideWithGroup(String query,
			String uniref100Only, String ilEquivalent, String sortBy) {
		String queryField = "originalSeq:";
		if (ilEquivalent.equals("Y")) {
			queryField = "lToiSeq:";
			query = query.replaceAll("L", "I");
		}
		HashMap<String, String> idToName = new HashMap<String, String>();
		try {
			InputStream inputStream = this.getClass().getClassLoader()
					.getResourceAsStream("config/taxToTaxGroup.txt");
			BufferedReader br = new BufferedReader(new InputStreamReader(
					inputStream));
			String strLine;
			while ((strLine = br.readLine()) != null) {
				String[] rec = strLine.split("\t");
				String taxonId = rec[0];
				String taxonName = rec[1];
				idToName.put(taxonId, taxonName);
			}
			inputStream = this.getClass().getClassLoader()
					.getResourceAsStream("config/orgNameToTaxon.txt");
			br = new BufferedReader(new InputStreamReader(inputStream));
			while ((strLine = br.readLine()) != null) {
				String[] rec = strLine.split("\t");
				String taxonId = rec[1];
				String taxonName = rec[0];
				String name = idToName.get(taxonId);
				if (name == null || name.equals("")) {
					idToName.put(taxonId, taxonName);
				}
			}
		} catch (IOException ioe) {
			ioe.printStackTrace();
		}
		// Construct the Phrase query
		String phraseQuery = queryField + "\""
				+ query.substring(0, 3).toLowerCase();
		for (int i = 1; i <= query.length() - 3; i++) {
			phraseQuery = phraseQuery + "+"
					+ query.substring(i, i + 3).toLowerCase();
		}
		phraseQuery += "\"";
		String finalQuery = phraseQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		// Construct the solr query
		SolrQuery solrQuery = new SolrQuery();
		// SolrDocumentList docs = new SolrDocumentList();
		SolrDocumentList gdocs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		solrQuery.set(GroupParams.GROUP, true);
		solrQuery.set(GroupParams.GROUP_MAIN, false);
		solrQuery.setRows(Integer.MAX_VALUE);
		solrQuery.setFields("ac", "organismID");
		solrQuery.set(GroupParams.GROUP_SORT);
		solrQuery.set(GroupParams.GROUP_FIELD, "organismID");
		solrQuery.set(GroupParams.GROUP_TOTAL_COUNT, "true");
		HashMap<String, Long> groupCount = new HashMap<String, Long>();
		Map<String, Long> sortedGroupSum = new LinkedHashMap<String, Long>();
		// System.out.println(solrQuery);
		try {
			//System.out.println("Before solr group query: " + new Date());
			response = solrServer.query(solrQuery, METHOD.POST);
			//System.out.println("After solr group query: " + new Date());
			GroupResponse groupResponse = response.getGroupResponse();
			if (groupResponse != null) {
				List<GroupCommand> groupResponseValues = groupResponse
						.getValues();
				for (int i = 0; i < groupResponseValues.size(); i++) {
					GroupCommand gcmd = groupResponseValues.get(i);
					// System.out.print(gcmd.getName() +" "+gcmd.getMatches() +
					// " "+gcmd.getNGroups()+"\n");
					List<Group> groups = gcmd.getValues();
					for (int j = 0; j < groups.size(); j++) {
						Group group = groups.get(j);
						gdocs = group.getResult();
						// System.out.println("Group: "+group.getGroupValue()+" "+gdocs.getNumFound());
						// groupCount.put(group.getGroupValue(),
						// gdocs.getNumFound());
						groupCount.put(idToName.get(group.getGroupValue())
								+ "<|>" + group.getGroupValue(),
								gdocs.getNumFound());
					}
					// System.out.println();
					//System.out.println("Before sorting: " + new Date());
					sortedGroupSum = sortByValue(groupCount, gcmd.getMatches(),
							gcmd.getNGroups());
					//System.out.println("After sorting: " + new Date());
					/*
					 * for (String organism : sortedGroupSum.keySet()){
					 * System.out.println(organism + " " +
					 * sortedGroupSum.get(organism)); }
					 */
				}
			}
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 2 ");
		}
		return sortedGroupSum;
	}

	@SuppressWarnings("unchecked")
	public Map<String, Long> sortByValue(Map<String, Long> map,
			long totalMatches, long totalGroups) {
		List list = new LinkedList(map.entrySet());
		Collections.sort(list, new Comparator() {
			public int compare(Object o1, Object o2) {
				if (((Map.Entry) (o2)).getValue() == ((Map.Entry) (o1))
						.getValue()) {
					return ((Comparable) ((Map.Entry) (o1)).getKey())
							.compareTo(((Map.Entry) (o2)).getKey());
				}
				return ((Comparable) ((Map.Entry) (o2)).getValue())
						.compareTo(((Map.Entry) (o1)).getValue());

			}
		});

		Map<String, Long> result = new LinkedHashMap<String, Long>();
		// int count = 0;
		result.put("totalOrganismMatches", totalMatches);
		result.put("totalOrganismGroups", totalGroups);
		for (Iterator it = list.iterator(); it.hasNext();) {
			Map.Entry entry = (Map.Entry) it.next();
			result.put((String) entry.getKey(), (Long) entry.getValue());
		}
		return result;
	}

	public void queryByPeptideWithOrganism(String query, String organism_id,
			int start, int rows, String swissprot, String isoform, String uniref100Only, String ilEquivalent,
			String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		if(swissprot.equals("Y")) {
			finalQuery += " sptr:sp";
		}
		if(!isoform.equals("Y")) {
			finalQuery += " !isoform:Y";
		}
		// put the organismid with the phrase query
		// String organismQuery = "organismID:" + organism_id;
		if (organism_id != null && organism_id.length() > 0) {
			String organisms[] = organism_id.replaceAll(" ", "").split(",");
			String organismQuery = "";

			organismQuery = "(organismID:" + organisms[0];
			for (int i = 1; i < organisms.length; i++) {
				organismQuery = organismQuery + " OR organismID:"
						+ organisms[i];
			}
			organismQuery += ")";

			finalQuery += " " + organismQuery;
		}
		System.out.println("Final Query: " + finalQuery);

		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");

		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		//solrQuery.setFields("ac", "organismID");
		System.out.println("SolrQuery: "+ solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 3 ");
		}
		initialDoc = docs;
	}
	
	public void query(String query, String organism_id,
			int start, int rows, String swissprot, String isoform, String uniref100Only, String ilEquivalent,
			String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		if(swissprot.equals("Y")) {
			finalQuery += " sptr:sp";
		}
		if(!isoform.equals("Y")) {
			finalQuery += " !isoform:Y";
		}
		// put the organismid with the phrase query
		// String organismQuery = "organismID:" + organism_id;
		if (organism_id != null && organism_id.length() > 0) {
			String organisms[] = organism_id.replaceAll(" ", "").split(",");
			String organismQuery = "";

			organismQuery = "(fullLineage:" + organisms[0];
			for (int i = 1; i < organisms.length; i++) {
				organismQuery = organismQuery + " OR fullLineage:"
						+ organisms[i];
			}
			organismQuery += ")";

			finalQuery += " " + organismQuery;
		}
		System.out.println("Final Query: " + finalQuery);

		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");

		System.out.println("start: "+ start + " rows: " + rows);
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		//solrQuery.setFields("ac", "organismID");
		System.out.println("SolrQuery in query: "+ solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else {
				result = 0;
			}
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 3 ");
		}
		//responseHeader = response.getHeader();
		initialDoc = docs;
	}

	private String createPhrase(String queryInput, String ilEquivalent) {
		// process the peptide into the phrasequery
		String phraseQuery = "";
		String[] peptides = queryInput.replaceAll(" ", "").split(",");
		//System.out.println("query: "+ queryInput + " | Query peptides: " + Arrays.toString(peptides));
		for(int i = 0; i < peptides.length; i++) {
			String query = peptides[i];
			String singlePhrase = "";
			String queryField = "originalSeq:";
			if (ilEquivalent.equals("Y")) {
				//System.out.println("ilEq: " + ilEquivalent);
				queryField = "lToiSeq:";
				query = query.replaceAll("L", "I");
			}
			singlePhrase = queryField + "\""
					+ query.substring(0, 3).toLowerCase();
			for (int j = 1; j <= query.length() - 3; j++) {
				singlePhrase = singlePhrase + "+"
						+ query.substring(j, j + 3).toLowerCase();
			}
			singlePhrase += "\"";
			
			if(phraseQuery.length() == 0) {
				phraseQuery += singlePhrase;
			}
			else {
				phraseQuery += " OR " + singlePhrase;
			}
		}
		//System.out.println("Phrases: " + phraseQuery);
		return "("+phraseQuery+")";
	}

	public Map<String, Long> queryByPeptideWithMultiOrganismWithGroup(
			String query, String organism_ids, String uniref100Only,
			String ilEquivalent, String sortBy) {
		HashMap<String, String> idToName = new HashMap<String, String>();
		try {
			InputStream inputStream = this.getClass().getClassLoader()
					.getResourceAsStream("config/taxToTaxGroup.txt");
			BufferedReader br = new BufferedReader(new InputStreamReader(
					inputStream));
			String strLine;
			while ((strLine = br.readLine()) != null) {
				String[] rec = strLine.split("\t");
				String taxonId = rec[0];
				String taxonName = rec[1];
				idToName.put(taxonId, taxonName);
			}
		} catch (IOException ioe) {
			ioe.printStackTrace();
		}
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		// put the organismid with the phrase query
		String organisms[] = organism_ids.split(";");
		String organismQuery = "(organismID:" + organisms[0];
		for (int i = 1; i < organisms.length; i++) {
			organismQuery = organismQuery + " OR organismID:" + organisms[i];
		}
		organismQuery += ")";
		finalQuery += " " + organismQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		SolrDocumentList gdocs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		solrQuery.set(GroupParams.GROUP, true);
		solrQuery.set(GroupParams.GROUP_MAIN, false);
		solrQuery.setRows(Integer.MAX_VALUE);
		solrQuery.setFields("ac", "organismID");
		solrQuery.set(GroupParams.GROUP_SORT);
		solrQuery.set(GroupParams.GROUP_FIELD, "organismID");
		solrQuery.set(GroupParams.GROUP_TOTAL_COUNT, "true");
		HashMap<String, Long> groupCount = new HashMap<String, Long>();
		Map<String, Long> sortedGroupSum = new LinkedHashMap<String, Long>();
		//System.out.println("org group: " + solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			GroupResponse groupResponse = response.getGroupResponse();
			if (groupResponse != null) {
				List groupResponseValues = groupResponse.getValues();
				for (int i = 0; i < groupResponseValues.size(); i++) {
					GroupCommand gcmd = (GroupCommand) groupResponseValues
							.get(i);
					// System.out.print(gcmd.getName() +" "+gcmd.getMatches() +
					// " "+gcmd.getNGroups()+"\n");
					List groups = gcmd.getValues();
					for (int j = 0; j < groups.size(); j++) {
						Group group = (Group) groups.get(j);
						gdocs = group.getResult();
						// System.out.println("Group: "+group.getGroupValue()+" "+gdocs.getNumFound());
						// groupCount.put(group.getGroupValue(),
						// gdocs.getNumFound());
						groupCount.put(idToName.get(group.getGroupValue())
								+ "<|>" + group.getGroupValue(),
								gdocs.getNumFound());
					}
					//System.out.println("Before sorting: " + new Date());
					sortedGroupSum = sortByValue(groupCount, gcmd.getMatches(),
							gcmd.getNGroups());
					//System.out.println("After sorting: " + new Date());
					/*
					 * for (String organism : sortedGroupSum.keySet()){
					 * System.out.println(organism + " " +
					 * sortedGroupSum.get(organism)); }
					 */
				}
			}
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 4 ");
		}
		return sortedGroupSum;
	}

	public void queryByPeptideWithMultiOrganism(String query,
			String organism_ids, int start, int rows, String uniref100Only,
			String ilEquivalent, String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		// put the organismid with the phrase query
		String organisms[] = organism_ids.split(";");
		String organismQuery = "(organismID:" + organisms[0];
		for (int i = 1; i < organisms.length; i++) {
			organismQuery = organismQuery + " OR organismID:" + organisms[i];
		}
		organismQuery += ")";
		finalQuery += " " + organismQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}

		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 5 ");
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithOrganismAndGroup(String query,
			String organism_id, String taxonGroup, int start, int rows,
			String uniref100Only, String ilEquivalent, String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		// put the organismid with the phrase query
		String organisms[] = organism_id.split(";");
		String organismQuery = "(organismID:" + organisms[0];
		for (int i = 1; i < organisms.length; i++) {
			organismQuery = organismQuery + " OR organismID:" + organisms[i];
		}
		organismQuery += ")";

		String groups[] = taxonGroup.split(";");
		String groupQuery = "(taxongroupID:" + groups[0];
		for (int i = 1; i < groups.length; i++) {
			groupQuery = groupQuery + " OR taxongroupID:" + groups[i];
		}
		groupQuery += ")";

		finalQuery += " " + groupQuery + " " + organismQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		// System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}

		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 6 ");
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithOrganismAndTaxonId(String query,
			String organism_id, String taxon, int start, int rows, String op,
			String uniref100Only, String ilEquivalent, String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		// put the organismid with the phrase query
		String organisms[] = organism_id.split(";");
		String organismQuery = "(organismID:" + organisms[0];
		for (int i = 1; i < organisms.length; i++) {
			organismQuery = organismQuery + " OR organismID:" + organisms[i];
		}
		organismQuery += ")";

		String taxons[] = taxon.split(";");
		String taxonQuery = "(organismID:" + taxons[0];
		for (int i = 1; i < taxons.length; i++) {
			// taxonQuery=taxonQuery+" OR lineage:" + taxons[i];
			taxonQuery = taxonQuery + " " + op + " organismID:" + taxons[i];
		}
		taxonQuery += ")";

		finalQuery += " " + taxonQuery + " " + organismQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}

		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 7 ");
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithFullLineageOrganismAndTaxonId(String query,
			String organism_id, String taxon, int start, int rows, String op,
			String uniref100Only, String ilEquivalent, String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		// put the organismid with the phrase query
		String organisms[] = organism_id.split(";");
		String organismQuery = "(fullLineage:" + organisms[0];
		for (int i = 1; i < organisms.length; i++) {
			organismQuery = organismQuery + " OR fullLineage:" + organisms[i];
		}
		organismQuery += ")";

		String taxons[] = taxon.split(";");
		String taxonQuery = "(fullLineage:" + taxons[0];
		for (int i = 1; i < taxons.length; i++) {
			// taxonQuery=taxonQuery+" OR lineage:" + taxons[i];
			taxonQuery = taxonQuery + " " + op + " fullLineage:" + taxons[i];
		}
		taxonQuery += ")";

		finalQuery += " " + taxonQuery + " " + organismQuery;

		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}

		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 8 ");
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithTaxonGroup(String query, String taxonGroup,
			int start, int rows, String uniref100Only, String ilEquivalent,
			String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		// put the organismid with the phrase query
		String groups[] = taxonGroup.split(";");
		String groupQuery = "(taxongroupID:" + groups[0];
		for (int i = 1; i < groups.length; i++) {
			groupQuery = groupQuery + " OR taxongroupID:" + groups[i];
		}
		groupQuery += ")";

		finalQuery += " " + groupQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}

		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 9 ");
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithTaxonId(String query, String taxonId,
			int start, int rows, String op, String uniref100Only,
			String ilEquivalent, String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		// put the organismid with the phrase query
		String ids[] = taxonId.split(";");
		String idQuery = "(organismID:" + ids[0];
		for (int i = 1; i < ids.length; i++) {
			// idQuery=idQuery+" OR lineage:" + ids[i];
			idQuery = idQuery + " " + op + " organismID:" + ids[i];
		}
		idQuery += ")";

		finalQuery += " " + idQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 10 ");
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithFullLineageTaxonId(String query,
			String taxonId, int start, int rows, String op,
			String uniref100Only, String ilEquivalent, String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		// put the organismid with the phrase query
		String ids[] = taxonId.split(";");
		String idQuery = "(fullLineage:" + ids[0];
		for (int i = 1; i < ids.length; i++) {
			// idQuery=idQuery+" OR lineage:" + ids[i];
			idQuery = idQuery + " " + op + " fullLineage:" + ids[i];
		}
		idQuery += ")";

		finalQuery += " " + idQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}

		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 11 ");
		}
		initialDoc = docs;
	}

	// query by peptide by the ID sets
	public void queryByIDSets(ArrayList IDSets, int rowsPerPage, String sortBy) {
		String query = "";
		String queryField = "ac:";
		for (int i = 0; i < IDSets.size(); i++) {
			query = query + queryField + IDSets.get(i) + " ";
		}
		// if(uniref100Only.equals("Y")) {
		// query += " uniref100:Y";
		// }
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", query);
		solrQuery.setParam("q.op", "OR");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}
		// Even use the OR operation, still need to set the rows to
		// return,default is 10
		solrQuery.setRows(rowsPerPage);
		solrQuery.setFields("ac", "organismID");
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			result = (int) docs.getNumFound();
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 12 ");
		}
		initialDoc = docs;
	}

	public void queryByID(String ID, String uniref100Only, String sortBy) {
		String queryField = "ac:";
		String query = queryField + ID;
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		if (uniref100Only.equals("Y")) {
			query += " uniref100:Y";
		}
		solrQuery.setParam("q", query);
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}
		// solrQuery.setParam("q.op","OR");
		// System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			result = (int) docs.getNumFound();
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 13 ");
		}
		initialDoc = docs;
	}

	public void queryByOrganismID(String organism_id, int start, int rows,
			String uniref100Only, String sortBy) {
		String queryField = "organismID:";
		String query = queryField + organism_id;
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		if (uniref100Only.equals("Y")) {
			query += " uniref100:Y";
		}
		solrQuery.setParam("q", query);
		solrQuery.setParam("sort", "ac asc");
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		// solrQuery.setParam("q.op","OR");
		// System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			result = (int) docs.getNumFound();
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 14 ");
		}
		initialDoc = docs;
	}

	public void queryByOrganismIDs(String organism_ids, int start, int rows,
			String uniref100Only, String sortBy) {
		String[] organisms = organism_ids.split(";");
		String organismQuery = "(organismID:" + organisms[0];
		for (int i = 1; i < organisms.length; i++) {
			organismQuery = organismQuery + " OR organismID:" + organisms[i];
		}
		organismQuery += ")";
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		if (uniref100Only.equals("Y")) {
			organismQuery += " uniref100:Y";
		}
		solrQuery.setParam("q", organismQuery);
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		// solrQuery.setParam("q.op","OR");
		// System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			result = (int) docs.getNumFound();
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 15 ");
		}
		initialDoc = docs;
	}

	public void queryAll(int start, int rows, String uniref100Only,
			String sortBy) {
		String query = "*:*";
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		if (uniref100Only.equals("Y")) {
			query += " uniref100:Y";
		}
		solrQuery.setParam("q", query);
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			result = (int) docs.getNumFound();
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 16 ");
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithShortLineageOrganismAndTaxonId(String query,
			String organism_id, String taxon, int start, int rows, String op,
			String uniref100Only, String ilEquivalent, String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		// put the organismid with the phrase query
		String organisms[] = organism_id.split(";");
		String organismQuery = "(shortLineage:" + organisms[0];
		for (int i = 1; i < organisms.length; i++) {
			organismQuery = organismQuery + " OR shortLineage:" + organisms[i];
		}
		organismQuery += ")";

		String taxons[] = taxon.split(";");
		String taxonQuery = "(shortLineage:" + taxons[0];
		for (int i = 1; i < taxons.length; i++) {
			// taxonQuery=taxonQuery+" OR lineage:" + taxons[i];
			taxonQuery = taxonQuery + " " + op + " shortLineage:" + taxons[i];
		}
		taxonQuery += ")";

		finalQuery += " " + taxonQuery + " " + organismQuery;

		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}
		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}

		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 17 ");
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithShortLineageTaxonId(String query,
			String taxonId, int start, int rows, String op,
			String uniref100Only, String ilEquivalent, String sortBy) {
		String phraseQuery = createPhrase(query, ilEquivalent);
		String finalQuery = phraseQuery;
		// put the organismid with the phrase query
		String ids[] = taxonId.split(";");
		String idQuery = "(shortLineage:" + ids[0];
		for (int i = 1; i < ids.length; i++) {
			// idQuery=idQuery+" OR lineage:" + ids[i];
			idQuery = idQuery + " " + op + " shortLineage:" + ids[i];
		}
		idQuery += ")";

		finalQuery += " " + idQuery;
		if (uniref100Only.equals("Y")) {
			finalQuery += " uniref100:Y";
		}

		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		// solrQuery.setParam("sort", "ac asc");
		// solrQuery.setParam("sort",
		// "nist asc, peptideAtlas asc, pride asc, iedb desc, ac asc");
		solrQuery.setParam("sort",
				"peptideAtlas asc, pride asc, iedb desc, ac asc");
		if (sortBy.equals("proteomic_desc")) {
			// solrQuery.setParam("sort",
			// "nist desc, peptideAtlas desc, pride desc, ac asc");
			solrQuery.setParam("sort", "peptideAtlas desc, pride desc, ac asc");
		}
		if (sortBy.equals("ac_asc")) {
			solrQuery.setParam("sort", "ac asc");
		}
		if (sortBy.equals("ac_desc")) {
			solrQuery.setParam("sort", "ac desc");
		}
		if (sortBy.equals("proteinID_asc")) {
			solrQuery.setParam("sort", "proteinID asc");
		}
		if (sortBy.equals("proteinID_desc")) {
			solrQuery.setParam("sort", "proteinID desc");
		}
		if (sortBy.equals("proteinName_asc")) {
			solrQuery.setParam("sort", "proteinName asc");
		}
		if (sortBy.equals("proteinName_desc")) {
			solrQuery.setParam("sort", "proteinName desc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_asc")) {
			solrQuery.setParam("sort", "organismName asc");
		}
		if (sortBy.equals("organismName_desc")) {
			solrQuery.setParam("sort", "organismName desc");
		}
		if (sortBy.equals("length_asc")) {
			solrQuery.setParam("sort", "length asc");
		}
		if (sortBy.equals("length_desc")) {
			solrQuery.setParam("sort", "length desc");
		}
		if (sortBy.equals("iedb_asc")) {
			solrQuery.setParam("sort", "iedb asc");
		}
		if (sortBy.equals("iedb_desc")) {
			solrQuery.setParam("sort", "iedb desc");
		}
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		solrQuery.setFields("ac", "organismID");
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery, METHOD.POST);
			docs = response.getResults();
			
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			e.printStackTrace();
			System.out.print("search fail 18 ");
		}
		initialDoc = docs;
	}

	// store the results from the peptide search
	public int getResult() {
		return this.result;
	}

	public ArrayList<String> getIDSets() {
		return idSets;
	}

	public SolrDocumentList getCurrentDocs() {
		return initialDoc;
	}
	
	public NamedList<Object> getQueryResponseHeader() {
		return this.responseHeader;
	}
	
	public int getNumFound() {
		return this.response.getResults().size();
	}
	public int getQTime() {
		return this.response.getQTime();
	}
	
	public long getElapsedTime() {
		return this.response.getElapsedTime();
	}
	public int getStatus() {
		return this.response.getStatus();
	}
	
}
