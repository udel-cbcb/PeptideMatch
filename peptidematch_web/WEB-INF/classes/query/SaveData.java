package query;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Iterator;
import query.PeptidePhraseQuery;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;

public class SaveData extends HttpServlet {
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		String originalQuery = "";
		String ids = "";
		String fileName = "";
		int rowsPerPage = 0;
		String format = "";
		String uniref100Only = "N";
		String ilEquivalent = "N";
		if (request.getParameter("keyword") != null)
			originalQuery = request.getParameter("keyword").trim()
					.toUpperCase();
		if (request.getParameter("ids") != null)
			ids = request.getParameter("ids").trim().toUpperCase();
		if (request.getParameter("rowsPerPage") != null)
			rowsPerPage = Integer.parseInt(request.getParameter("format")
					.trim());
		if (request.getParameter("format") != null)
			format = request.getParameter("format").trim().toUpperCase();
		if (request.getParameter("uniref100Only") != null)
			uniref100Only = request.getParameter("uniref100Only").trim()
					.toUpperCase();
		if (request.getParameter("ilEquivalent") != null)
			ilEquivalent = request.getParameter("ilEquivalent").trim()
					.toUpperCase();
		PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
		SolrDocumentList docs = new SolrDocumentList();
		String[] idsets = ids.split(";");
		rowsPerPage = idsets.length;
		ArrayList<String> idList = new ArrayList();
		for (int i = 0; i < idsets.length; i++) {
			idList.add(i, idsets[i]);
		}
		peptideQuery.queryByIDSets(idList, rowsPerPage, uniref100Only,
				ilEquivalent);
		docs = peptideQuery.getCurrentDocs();
		// set the download format
		response.setContentType("text/plain;");
		if (originalQuery.equals("*:*"))
			fileName = "whole_set";
		else
			fileName = originalQuery;
		if (format.equals("tab"))
			fileName = fileName + "_" + rowsPerPage + ".tab";
		else
			fileName = fileName + "_" + rowsPerPage + ".Fasta";
		response.setHeader("Content-disposition", "attachment;filename="
				+ fileName);
		request.setCharacterEncoding("UTF-8");
		if (docs != null) {
			if (format.equals("tab"))
				printTable(docs, response, originalQuery);
			else
				printFasta(docs, response);
		}
	}

	// print the result as table format
	protected void printTable(SolrDocumentList docs,
			HttpServletResponse response, String originalQuery)
			throws IOException {
		PrintWriter out = response.getWriter();
		Iterator<SolrDocument> docItr = docs.iterator();
		SolrDocument doc;
		String sequence;
		int seqLength = 0;
		String id;
		String proteinID;
		String proteinName;
		String organismName;
		String organismID;
		String nist = "";
		String nistStr = "";
		String pride;
		String peptideAtlas;
		String peptideLibrary = "";
		String iedb;
		String iedbStr = "";
		out.print("Protein AC\t");
		out.print("Protein ID\t");
		out.print("Protein Name\t");
		out.print("Length\t");
		out.print("Organism\t");
		out.print("Matched range\t");
		out.print("Proteomic Databases\t");
		out.print("IEDB\t");
		out.print("\n");
		while (docItr.hasNext()) {
			doc = docItr.next();
			sequence = (String) doc.getFieldValue("originalSeq");
			seqLength = sequence.length();
			id = (String) doc.getFieldValue("ac");
			proteinID = (String) doc.getFieldValue("proteinID");
			proteinName = (String) doc.getFieldValue("proteinName");
			organismName = (String) doc.getFieldValue("organismName");
			organismID = (String) doc.getFieldValue("organismID");
			nist = "";
			nistStr = (String) doc.getFieldValue("nist");
			pride = (String) doc.getFieldValue("pride");
			peptideAtlas = (String) doc.getFieldValue("peptideAtlas");
			peptideLibrary = "";
			iedb = (String) doc.getFieldValue("iedb");
			iedbStr = "";
			// System.out.println(id+ " nist: "+nistStr);
/*
			if (nistStr.length() > 0 && !nistStr.equals("Z")) {
				String[] nistRec = nistStr.split(" ");
				nist = "NIST";
				// nist =
				// "<a href=\"http://peptide.nist.gov/browser/proteins.php?description=IT&ProteinAccessionNum="+id+"\">NIST</a>";
				peptideLibrary += nist + ", ";
			}
*/
			if (peptideAtlas.length() > 0 && !peptideAtlas.equals("Z")) {
				peptideAtlas = "PeptideAtlas";
				peptideLibrary += peptideAtlas + ", ";
			}
			if (pride.length() > 0 && !pride.equals("Z")) {
				pride = "PRIDE";
				peptideLibrary += pride + ", ";
			}
			if (peptideLibrary.indexOf(", ") > 0) {
				peptideLibrary = peptideLibrary.substring(0,
						peptideLibrary.length() - 2);
			}
			if (iedb.length() > 0 && !iedb.equals("Z")) {
				String[] iedbs = iedb.split(",");
				for (int i = 0; i < iedbs.length; i++) {
					iedbStr += iedbs[i] + ", ";
				}
				if (iedbStr.indexOf(", ") > 0) {
					iedbStr = iedbStr.substring(0, iedbStr.length() - 2);
				}
			}
			out.print(id + "\t");
			out.print(proteinID + "\t");
			out.print(proteinName + "\t");
			out.print(sequence.length() + "\t");
			out.print(organismName + "\t");
			for (int i = 0; i <= sequence.length() - originalQuery.length(); i++) {
				if (sequence.substring(i, i + originalQuery.length())
						.toUpperCase().equals(originalQuery.toUpperCase())) {
					out.print(i + 1);
					out.print("-");
					out.print(i + originalQuery.length());
					out.print(" ");
					if (i < 5
							&& (i + originalQuery.length() + 5) > sequence
									.length()) {
						out.print(sequence.substring(0, i)
								+ originalQuery
								+ sequence.substring(
										i + originalQuery.length(),
										sequence.length()));
					} else if (i < 5
							&& (i + originalQuery.length() + 5) <= sequence
									.length()) {
						out.print(sequence.substring(0, i)
								+ originalQuery
								+ sequence.substring(
										i + originalQuery.length(), i
												+ originalQuery.length() + 5));
					} else if (i >= 5
							&& (i + originalQuery.length() + 5) > sequence
									.length()) {
						out.print(sequence.substring(i - 5, i)
								+ originalQuery
								+ sequence.substring(
										i + originalQuery.length(),
										sequence.length()));
					} else if (i >= 5
							&& (i + originalQuery.length() + 5) <= sequence
									.length()) {
						out.print(sequence.substring(i - 5, i)
								+ originalQuery
								+ sequence.substring(
										i + originalQuery.length(), i
												+ originalQuery.length() + 5));
					}
					out.print(";");
				}
			}
			out.print("\t");
			out.print(peptideLibrary + "\t");
			out.println(iedbStr + "\t");
		}
	}

	// print the result as fasta forat
	protected void printFasta(SolrDocumentList docs,
			HttpServletResponse response) throws IOException {
		Iterator<SolrDocument> docItr = docs.iterator();
		PrintWriter out = response.getWriter();
		SolrDocument doc;
		String sequence;
		int seqLength = 0;
		String id;
		String proteinID;
		String proteinName;
		String organismName;
		String organismID;
		out.print("Protein ID\t");
		out.print("Protein AC\t");
		out.print("Protein Name\t");
		out.print("Sequence\t");
		out.print("\n");
		while (docItr.hasNext()) {
			doc = docItr.next();
			while (docItr.hasNext()) {
				doc = docItr.next();
				sequence = (String) doc.getFieldValue("originalSeq");
				seqLength = sequence.length();
				id = (String) doc.getFieldValue("ac");
				proteinID = (String) doc.getFieldValue("proteinID");
				proteinName = (String) doc.getFieldValue("proteinName");
				organismName = (String) doc.getFieldValue("organismName");
				organismID = (String) doc.getFieldValue("organismID");
				out.print(">" + id + "\t");
				// String[] desc = description.split("\\^\\|\\^");
				/*
				 * for(int i=0; i <9; i++) { if(i > 0) {
				 * out.print("^|^"+desc[i]); } else { out.print(desc[i]); } }
				 */
				// out.print(description+"\t");
				// out.print("\n");
				for (int i = 0; i < sequence.length(); i++) {
					out.print(sequence.charAt(i));
					if ((i + 1) % 60 == 0) {
						out.print("\n");
					}
				}
				out.print("\n");
			}
		}
	}
}
