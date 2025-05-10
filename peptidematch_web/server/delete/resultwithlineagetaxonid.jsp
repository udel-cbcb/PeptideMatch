<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="query.PeptidePhraseQuery" %>

<%if(request.getParameter("initialed")!=null &&request.getParameter("keyword")!=null &&request.getParameter("start")!=null &&request.getParameter("rows")!=null &&request.getParameter("organism_id")!=null &&request.getParameter("taxon_id")!=null &&request.getParameter("taxon_name")!=null &&request.getParameter("total_number")!=null
){
String op = request.getParameter("op");
if(op == null) {
	op = "OR";
}
String originalQuery="";	
int start=0;
int rowsPerPage=20;
originalQuery = request.getParameter("keyword").trim().toUpperCase();
start = Integer.parseInt(request.getParameter("start"));
rowsPerPage = Integer.parseInt(request.getParameter("rows"));
String organism_ID=request.getParameter("organism_id");
String taxon_id=request.getParameter("taxon_id");
String taxon_name=request.getParameter("taxon_name");
String total_number=request.getParameter("total_number");

        Map<String, String> orgIdToNameMap = new HashMap<String, String>();
	Properties properties = new Properties();
        InputStream inputStream = null;
        String version = (String) session.getAttribute("version");
        if(version == null) {
                try {
                        inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
                        properties.load(inputStream);
                        version = properties.getProperty("version");
                        session.setAttribute("version", version);
                }
                catch(IOException ioe) {
                        ioe.printStackTrace();
                }
        }

String uniref100Only ="N";
        String ilEquivalent = "N";
        String uniref100Value = "N";
        String lEqiValue = "N";
        String sortBy = "proteomic_asc";
        if(request.getParameter("sortBy") != null) {
                sortBy = request.getParameter("sortBy");
        }
        if(request.getParameter("uniref100") != null) {
                uniref100Value = request.getParameter("uniref100");
                uniref100Only = uniref100Value;
        }
        if(request.getParameter("lEqi") != null) {
                lEqiValue = request.getParameter("lEqi");
                ilEquivalent = lEqiValue;
        }
//initial the solr connection
PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
SolrDocumentList docs = new SolrDocumentList();
int numberFound = 0;
if(originalQuery.equals("*:*")){
	peptideQuery.queryAll(start,rowsPerPage, uniref100Only, ilEquivalent);
}
else{
if(!organism_ID.toLowerCase().equals("all")){
	peptideQuery.queryByPeptideWithFullLineageOrganismAndTaxonId(originalQuery, organism_ID,taxon_id, start, rowsPerPage, op, uniref100Only, ilEquivalent, sortBy);
}
else{
	peptideQuery.queryByPeptideWithFullLineageTaxonId(originalQuery, taxon_id, start, rowsPerPage, op, uniref100Only, ilEquivalent, sortBy);
}
}
docs = peptideQuery.getCurrentDocs();
//store the id sets of protein sequences which are matched the keyword
//return how many protein sequence 
session.setAttribute("currentdocs", docs);
session.setAttribute("currentquery", originalQuery);
numberFound = peptideQuery.getResult();

	Iterator<SolrDocument> docItr = docs.iterator();
	while (docItr.hasNext()) {
	SolrDocument doc = docItr.next();
        //int seqLength=(Integer)doc.getFieldValue("length");
        //int seqLength=Integer.parseInt((String)doc.getFieldValue("length"));
	String ac=(String)doc.getFieldValue("ac");
	String sequence=(String)doc.getFieldValue("originalSeq");
        int seqLength=sequence.length();
        //String[] features=description.trim().split("\\^\\|\\^");
        String proteinID=(String)doc.getFieldValue("proteinID");
        String proteinName=(String)doc.getFieldValue("proteinName");
        String organismName=(String)doc.getFieldValue("organismName");
        String organismID=(String)doc.getFieldValue("organismID");
        String nist = "";
        String nistStr = (String)doc.getFieldValue("nist");
        String pride = (String)doc.getFieldValue("pride");
        String peptideAtlas = (String)doc.getFieldValue("peptideAtlas");
        String peptideLibrary = "";
        String iedb = (String)doc.getFieldValue("iedb");
        String iedbStr = "";
        if(nistStr.length() > 0 && !nistStr.equals("X")) {
                String[] nistRec = nistStr.split(" ");
                nist =  "<a href=\"http://peptide.nist.gov/browser/proteins.php?description=IT&organism="+nistRec[1]+"&ProteinAccessionNum="+ac+"\">NIST</a>";

                // (Coverage: "+nistRec[1]+"%, Total # peptides: "+nistRec[2]+", # tryptic peptides: "+nistRec[3]+")";
                peptideLibrary += nist+", ";
        }
        //peptideAtlas = features[10];
        if(peptideAtlas.length() > 0 && !peptideAtlas.equals("X")) {
                peptideAtlas = "<a href=https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key="+peptideAtlas+"&apply_action=GO&exact_match=exact_match\">PeptideAtlas</a>";
                peptideLibrary += peptideAtlas+", ";
        }
        //pride = features[11];
        if(pride.length() > 0 && !pride.equals("X")) {
                pride = "<a href=\"http://www.ebi.ac.uk/pride/searchSummary.do?queryTypeSelected=identification%20accession%20number&identificationAccessionNumber="+pride+"\">PRIDE</a>";
                peptideLibrary += pride+", ";
        }
        if(peptideLibrary.indexOf(", ") > 0) {
                peptideLibrary = peptideLibrary.substring(0, peptideLibrary.length() - 2);
                //peptideLibrary = peptideLibrary.replaceAll(", ", "<br/>");
        }
        if(iedb.length() > 0) {
                String[] iedbs = iedb.split(",");
                if(iedbs.length <10) {
                        for(int i=0; i < iedbs.length; i++) {
                                iedbStr += "<a href=\"http://www.iedb.org/epId/"+iedbs[i]+"\">"+iedbs[i]+"</a>, ";
                        }
                        if(iedbStr.indexOf(", ") > 0) {
                                iedbStr = iedbStr.substring(0, iedbStr.length() - 2);
                        }
                }
                else {
                        for(int i=0; i < 9; i++) {
                                iedbStr += "<a href=\"http://www.iedb.org/epId/"+iedbs[i]+"\">"+iedbs[i]+"</a>, ";
                        }
                        iedbStr += "<a id=\"displayText_"+ac+"\" href=\"javascript:toggle('"+ac+"');\">[More...]</a><br/><br/>";
                        iedbStr +="<div id=\"toggleText_"+ac+"\" style=\"display: none; \">";
                        for(int i=9; i < iedbs.length; i++) {
                                iedbStr += "<a href=\"http://www.iedb.org/epId/"+iedbs[i]+"\">"+iedbs[i]+"</a>, ";
                        }
                        if(iedbStr.indexOf(", ") > 0) {
                                iedbStr = iedbStr.substring(0, iedbStr.length() - 2);
                        }
                        iedbStr+="</div>";
                }      
        }      
	String[] ids = proteinID.split("_");
        String uniprotIcon = "";
        if(ids[0].length() < 6) {
                uniprotIcon = "sp_icon.png";
        }
        else {
                uniprotIcon = "tr_icon.png";
        }

	%>
	<tr>
	<td class="tablecontent"><input type=checkbox onClick="current_sel(mainform)" name=idlist value=<%=ac%>></td> 
	<td class="tablecontent"><%=ac%><br>
	<a href="http://pir.georgetown.edu/cgi-bin/ipcEntry?id=<%=ac%>"><img src="./imagefiles/ipc_icon.png" border="0"></a>
	<a href="http://www.uniprot.org/uniprot/<%=ac%>"><img src="./imagefiles/<%=uniprotIcon%>" border="0"></a>
	</td>
	<td class="tablecontent"><%=proteinID%><br>

	<a href="http://www.uniprot.org/uniprot/<%=ac%>"><img src="./imagefiles/<%=uniprotIcon%>" border="0"></a>
	<td class="tablecontent"><%=proteinName%><br>
	<a href='http://pir.georgetown.edu/cgi-bin/biothesaurus.pl?id=<%=ac%>'><img src="./imagefiles/biot_icon2.png" border="0"> </a>					  		
	</td>  
	<td class="tablecontent"><%=seqLength%></td>
	<td class="tablecontent"><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id=<%=organismID%>'><%=organismName%></a></td> 
	<td class="tablecontent" id="sequencefragment">
<%
if(originalQuery.equals("*:*")){
	out.println(sequence);
}
else{	
for(int i=0;i<=sequence.length()-originalQuery.length();i++){	
	if(sequence.substring(i, i+originalQuery.length()).toUpperCase().equals(originalQuery.toUpperCase())){
		if(i<5&&(i+originalQuery.length()+5)>sequence.length()){
			out.print(sequence.substring(0,i)+"<b id=highlight>"+originalQuery+"</b>"+sequence.substring(i+originalQuery.length(),sequence.length()));			
			}
			else if(i<5&&(i+originalQuery.length()+5)<=sequence.length()){
			out.print(sequence.substring(0,i)+"<b id=highlight>"+originalQuery+"</b>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
			else if(i>=5&&(i+originalQuery.length()+5)>sequence.length()){
			out.print(sequence.substring(i-5,i)+"<b id=highlight>"+originalQuery+"</b>"+sequence.substring(i+originalQuery.length(),sequence.length()));	
			}
			else if(i>=5&&(i+originalQuery.length()+5)<=sequence.length()){
			out.print(sequence.substring(i-5,i)+"<b id=highlight>"+originalQuery+"</b>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
	out.print(" ");
	out.print(i+1);
	out.print("-");
	out.print(i+originalQuery.length());
	out.println("<br>");
	}
	}
}
 %>
</td>
<td class="tablecontent"><%=peptideLibrary%></td>
<td class="tablecontent"><%=iedbStr%></td> 
</tr>
<% }} %>
