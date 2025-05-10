<%@ page import="org.apache.solr.common.SolrDocumentList"
 %><%@ page import="java.util.ArrayList" 
 %><%@ page import="java.util.HashMap" 
 %><%@ page import="java.util.Iterator" 
 %><%@ page import="java.util.*" 
 %><%@ page import="java.text.NumberFormat" 
 %><%@ page import="org.apache.solr.common.SolrDocument" 
 %><%@ page import="query.PeptidePhraseQuery" 
 %><%@ page import="java.io.*" 
 %><%@ page import="java.net.*" 
 %><%
request.setCharacterEncoding("UTF-8");
response.reset();
response.setContentType("text/plain;");
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
	rowsPerPage = Integer.parseInt(request.getParameter("rowsPerPage")
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

peptideQuery.queryByIDSets(idList, rowsPerPage,ilEquivalent);
docs = peptideQuery.getCurrentDocs();
// set the download format
if (originalQuery.equalsIgnoreCase("*:*"))
	fileName = "whole_set";
else
	fileName = originalQuery;
if (format.equalsIgnoreCase("tab"))
	fileName = fileName + "_" + rowsPerPage + ".tab";
else
	fileName = fileName + "_" + rowsPerPage + ".Fasta";
response.setHeader("Content-disposition", "attachment;filename="
		+ fileName);
if (docs != null) {
	if (format.equalsIgnoreCase("tab")){
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
                if(uniref100Only.equals("N")){ 
		out.print("Protein AC\t");
		out.print("Protein ID\t");
                }
                else
                {
		out.print("UniRef100 Cluster ID\t");
                out.print("Representative Protein AC\t");
                }
		out.print("Protein Name\t");
		out.print("Length\t");
		out.print("Organism\t");
		out.print("Match range\t");
		out.print("Protein Links to Proteomic DBs\t");
		out.print("Immune Epitope DB\t");
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
			if (nistStr.length() > 0 && !nistStr.equalsIgnoreCase("Z")) {
				String[] nistRec = nistStr.split(" ");
				nist = "NIST";
				peptideLibrary += nist + ", ";
			}
			if (peptideAtlas.length() > 0 && !peptideAtlas.equalsIgnoreCase("Z")) {
				peptideAtlas = "PeptideAtlas";
				peptideLibrary += peptideAtlas + ", ";
			}
			if (pride.length() > 0 && !pride.equalsIgnoreCase("Z")) {
				pride = "PRIDE";
				peptideLibrary += pride + ", ";
			}
			if (peptideLibrary.indexOf(", ") > 0) {
				peptideLibrary = peptideLibrary.substring(0,
						peptideLibrary.length() - 2);
			}
			if (iedb.length() > 0 && !iedb.equalsIgnoreCase("Z")) {
				String[] iedbs = iedb.split(",");
				for (int i = 0; i < iedbs.length; i++) {
					iedbStr += iedbs[i] + ", ";
				}
				if (iedbStr.indexOf(", ") > 0) {
					iedbStr = iedbStr.substring(0, iedbStr.length() - 2);
				}
			}
                     if(uniref100Only.equals("N")){ 
			out.print(id + "\t");
			out.print(proteinID + "\t");
                      }
                      else
                      {
			out.print("UniRef100_"+id + "\t");
                        out.print(id + "\t");                     
                       }
			out.print(proteinName + "\t");
			out.print(sequence.length() + "\t");
			out.print(organismName + "\t");
                        String subString = "";
                        boolean equal;
			for (int i = 0; i <= sequence.length() - originalQuery.length(); i++) {
                              int count = 0;
                              equal = false;
                             subString = sequence.substring(i, i + originalQuery.length()); 
				if (ilEquivalent.equalsIgnoreCase("Y"))
                                   {
	                          if(subString.replaceAll("[Ii]","L").equalsIgnoreCase(originalQuery.replaceAll("[Ii]","L")))
                                                equal = true;
                                    }
                                else
                                  {
                                      if (subString.equalsIgnoreCase(originalQuery)) 
                                                equal = true;     
                                   }
                               if(equal == true)
                                {
                                        if(count>0) 
					    out.print(";");
                                        count++;
					out.print(i + 1);
					out.print("-");
					out.print(i + originalQuery.length());
					out.print(" ");
					if (i < 5
							&& (i + subString.length() + 5) > sequence
									.length()) {
						out.print(sequence.substring(0, i)
								+ subString
								+ sequence.substring(
										i + subString.length(),
										sequence.length()));
					} else if (i < 5
							&& (i + subString.length() + 5) <= sequence
									.length()) {
						out.print(sequence.substring(0, i)
								+ subString
								+ sequence.substring(
										i + subString.length(), i
												+ subString.length() + 5));
					} else if (i >= 5
							&& (i + subString.length() + 5) > sequence
									.length()) {
						out.print(sequence.substring(i - 5, i)
								+ subString
								+ sequence.substring(
										i + subString.length(),
										sequence.length()));
					} else if (i >= 5
							&& (i + subString.length() + 5) <= sequence
									.length()) {
						out.print(sequence.substring(i - 5, i)
								+ subString
								+ sequence.substring(
										i + subString.length(), i
												+ subString.length() + 5));
					}
				}
			}
			out.print("\t");
			out.print(peptideLibrary + "\t");
			out.println(iedbStr + "\t");
		}
		
		
	}	
	else {
	SolrDocument doc;
	Iterator<SolrDocument> docItr = docs.iterator();
	String sequence;
	String proteinAC;
        String proteinID;
	String proteinName;
	String organismName;
	String organismID;
        String taxongroupName;
        String taxongroupID;
//	out.print("Protein ID\t");
//        out.print("Description\t");
//	out.print("Sequence\t");
//	out.print("\n");
	while (docItr.hasNext()) {
		doc = docItr.next();
			sequence = (String) doc.getFieldValue("originalSeq");
			proteinAC = (String) doc.getFieldValue("ac");
			proteinID = (String) doc.getFieldValue("proteinID");
			proteinName = (String) doc.getFieldValue("proteinName");
			organismName = (String) doc.getFieldValue("organismName");
			organismID = (String) doc.getFieldValue("organismID");
                        taxongroupName = (String) doc.getFieldValue("taxongroupName");
                        taxongroupID = (String) doc.getFieldValue("taxongroupID"); 
			out.print(">" + proteinAC + " ");
                        out.print(proteinID+"^|^"+proteinName+"^|^"+organismName+"^|^"+organismID+"^|^"+taxongroupName+"^|^"+taxongroupID+"\n");
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
out.close();

       %>

