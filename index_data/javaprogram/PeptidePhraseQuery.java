package javaprogram;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Properties;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocumentList;

public class PeptidePhraseQuery {
	private QueryResponse response;
	private CommonsHttpSolrServer solrServer;
	private ArrayList<String> idSets;
	private int result = 0;
	private String url = "";
	private SolrDocumentList initialDoc;

	// initial the URL connection
	public PeptidePhraseQuery() {
		try {
			InputStream inputStream = this.getClass().getClassLoader()
					.getResourceAsStream("config/solr.properties");
			Properties properties = new Properties();
			// load the inputStream using the Properties
			properties.load(inputStream);
			// get the value of the property
			url = properties.getProperty("solrurl");
			solrServer = new CommonsHttpSolrServer(url);
		} 
		catch (Exception e) {
			System.out.println(e.toString());
		}
	}

	// query by the peptide which is no more than 5 characters
	public void queryByPeptide(String query, int start, int rows) {
		String queryField = "sequence:";
		// Construct the Phrase query
		String phraseQuery = queryField + "\""
				+ query.substring(0, 3).toLowerCase();
		for (int i = 1; i <= query.length() - 3; i++) {
			phraseQuery = phraseQuery + "+"
					+ query.substring(i, i + 3).toLowerCase();
		}
		phraseQuery += "\"";
		// Construct the solr query
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", phraseQuery);
		solrQuery.setParam("q.op", "AND");
		solrQuery.setParam("sort", "id asc");
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		// System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			System.out.print("search fail ");
			e.printStackTrace();
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithOrganism(String query, String organism_id,
			int start, int rows) {
		// process the peptide into the phrasequery
		String phraseQuery = "sequence:" + "\""
				+ query.substring(0, 3).toLowerCase();
		for (int i = 1; i <= query.length() - 3; i++) {
			phraseQuery = phraseQuery + "+"
					+ query.substring(i, i + 3).toLowerCase();
		}
		phraseQuery += "\"";
		// put the organismid with the phrase query
		String organismQuery = "organismid:" + organism_id;
		String finalQuery = organismQuery + " " + phraseQuery;
		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		solrQuery.setParam("sort", "id asc");
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			System.out.print("search fail ");
			e.printStackTrace();
		}
		initialDoc = docs;
	}
	
	public void queryByPeptideWithMultiOrganism(String query, String organism_ids,
			int start, int rows) {
		// process the peptide into the phrasequery
		String phraseQuery = "sequence:" + "\""
				+ query.substring(0, 3).toLowerCase();
		for (int i = 1; i <= query.length() - 3; i++) {
			phraseQuery = phraseQuery + "+"
					+ query.substring(i, i + 3).toLowerCase();
		}
		phraseQuery += "\"";
		// put the organismid with the phrase query
		String organisms[]=organism_ids.split(";");
		String organismQuery = "(organismid:" + organisms[0];
		for(int i=1;i<organisms.length;i++){
			organismQuery=organismQuery+" OR organismid:" + organisms[i];
		}
		organismQuery+=")";
		String finalQuery = organismQuery + " " + phraseQuery;
		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		solrQuery.setParam("sort", "id asc");
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			System.out.print("search fail ");
			e.printStackTrace();
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithOrganismAndGroup(String query,
			String organism_id, String taxonGroup, int start, int rows) {
		// process the peptide into the phrasequery
		
		String phraseQuery = "sequence:" + "\""
				+ query.substring(0, 3).toLowerCase();
		for (int i = 1; i <= query.length() - 3; i++) {
			phraseQuery = phraseQuery + "+"
					+ query.substring(i, i + 3).toLowerCase();
		}
		phraseQuery += "\"";
		// put the organismid with the phrase query
		String organisms[]=organism_id.split(";");
		String organismQuery = "(organismid:" + organisms[0];
		for(int i=1;i<organisms.length;i++){
			organismQuery=organismQuery+" OR organismid:" + organisms[i];
		}
		organismQuery+=")";
		
		String groups[]=taxonGroup.split(";");
		String groupQuery = "(taxongroupid:" + groups[0];
		for(int i=1;i<groups.length;i++){
			groupQuery=groupQuery+" OR taxongroupid:" + groups[i];
		}
		groupQuery+=")";
		
		String finalQuery = groupQuery + " " + organismQuery + " "
				+ phraseQuery;
		// System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		solrQuery.setParam("sort", "id asc");
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			System.out.print("search fail ");
			e.printStackTrace();
		}
		initialDoc = docs;
	}

	public void queryByPeptideWithTaxonGroup(String query, String taxonGroup,
			int start, int rows) {
		// process the peptide into the phrasequery
		String phraseQuery = "sequence:" + "\""
				+ query.substring(0, 3).toLowerCase();
		for (int i = 1; i <= query.length() - 3; i++) {
			phraseQuery = phraseQuery + "+"
					+ query.substring(i, i + 3).toLowerCase();
		}
		phraseQuery += "\"";
		// put the organismid with the phrase query
		String groups[]=taxonGroup.split(";");
		String groupQuery = "(taxongroupid:" + groups[0];
		for(int i=1;i<groups.length;i++){
			groupQuery=groupQuery+" OR taxongroupid:" + groups[i];
		}
		groupQuery+=")";
		
		
		String finalQuery = groupQuery + " " + phraseQuery;
		System.out.println(finalQuery);
		// connect to the solrQuery
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", finalQuery);
		solrQuery.setParam("q.op", "AND");
		solrQuery.setParam("sort", "id asc");
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery);
			docs = response.getResults();
			if (docs != null) {
				result = (int) docs.getNumFound();
			} else
				result = 0;
		} catch (SolrServerException e) {
			System.out.print("search fail ");
			e.printStackTrace();
		}
		initialDoc = docs;
	}

	// query by peptide by the ID sets
	public void queryByIDSets(ArrayList IDSets, int rowsPerPage) {
		String query = "";
		String queryField = "id:";
		for (int i = 0; i < IDSets.size(); i++) {
			query = query + queryField + IDSets.get(i) + " ";
		}
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", query);
		solrQuery.setParam("q.op", "OR");
		solrQuery.setParam("sort", "id asc");
		// Even use the OR operation, still need to set the rows to
		// return,default is 10
		solrQuery.setRows(rowsPerPage);
		try {
			response = solrServer.query(solrQuery);
			docs = response.getResults();
			result = (int) docs.getNumFound();
		} catch (SolrServerException e) {
			System.out.print("search fail");
			e.printStackTrace();
		}
		initialDoc = docs;
	}

	public void queryByID(String ID) {
		String queryField = "id:";
		String query = queryField + ID;
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", query);
		solrQuery.setParam("sort", "id asc");
		// solrQuery.setParam("q.op","OR");
		// System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery);
			docs = response.getResults();
			result = (int) docs.getNumFound();
		} catch (SolrServerException e) {
			System.out.print("search fail ");
			e.printStackTrace();
		}
		initialDoc = docs;
	}

	public void queryByOrganismID(String organism_id, int start, int rows) {
		String queryField = "organismid:";
		String query = queryField + organism_id;
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", query);
		solrQuery.setParam("sort", "id asc");
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		// solrQuery.setParam("q.op","OR");
		// System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery);
			docs = response.getResults();
			result = (int) docs.getNumFound();
		} catch (SolrServerException e) {
			System.out.print("search fail ");
			e.printStackTrace();
		}
		initialDoc = docs;
	}

	public void queryByOrganismIDs(String organism_ids, int start, int rows) {
		String[] organisms=organism_ids.split(";");
		String organismQuery = "(organismid:" + organisms[0];
		for(int i=1;i<organisms.length;i++){
			organismQuery=organismQuery+" OR organismid:" + organisms[i];
		}
		organismQuery+=")";
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", organismQuery);
		solrQuery.setParam("sort", "id asc");
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		// solrQuery.setParam("q.op","OR");
		// System.out.println(solrQuery);
		try {
			response = solrServer.query(solrQuery);
			docs = response.getResults();
			result = (int) docs.getNumFound();
		} catch (SolrServerException e) {
			System.out.print("search fail ");
			e.printStackTrace();
		}
		initialDoc = docs;
	}

	public void queryAll(int start, int rows) {
		String query = "*:*";
		SolrQuery solrQuery = new SolrQuery();
		SolrDocumentList docs = new SolrDocumentList();
		solrQuery.setParam("q", query);
		solrQuery.setParam("sort", "id asc");
		solrQuery.setStart(start);
		solrQuery.setRows(rows);
		try {
			response = solrServer.query(solrQuery);
			docs = response.getResults();
			result = (int) docs.getNumFound();
		} catch (SolrServerException e) {
			System.out.print("search fail ");
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
}
