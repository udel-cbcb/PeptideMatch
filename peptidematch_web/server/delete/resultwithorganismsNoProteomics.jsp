<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="query.PeptidePhraseQuery" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%
if(request.getParameter("initialed")!=null &&request.getParameter("keyword")!=null &&request.getParameter("start")!=null &&request.getParameter("rows")!=null &&request.getParameter("organism_id")!=null){
        Properties properties = new Properties();
        InputStream inputStream = null;
        String version = "";
        Map<String, String> orgIdToNameMap = new HashMap<String, String>();
        try {
                inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
                properties.load(inputStream);
                version = properties.getProperty("version");
        }
        catch(IOException ioe) {
                ioe.printStackTrace();
        }

	String originalQuery="";	
	int start=0;
	int rowsPerPage=20;
	
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
	originalQuery = request.getParameter("keyword").trim().toUpperCase();
	start = Integer.parseInt(request.getParameter("start"));
	rowsPerPage = Integer.parseInt(request.getParameter("rows"));
	String organism_ID=request.getParameter("organism_id");
	//initial the solr connection
	PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
	SolrDocumentList docs = new SolrDocumentList();
	int numberFound = 0;
	Map<String, Long> sortedHitOrganismsCount = new LinkedHashMap();
	Map<String, Long> sortedHitTaxonGroupsCount = new LinkedHashMap();
	if(originalQuery.equals("*:*")){
		peptideQuery.queryAll(start,rowsPerPage, uniref100Only, sortBy);
	}
	else{
		originalQuery=originalQuery.replaceAll("[^a-zA-Z]", "");
		if(!organism_ID.toLowerCase().equals("all")) {
			peptideQuery.queryByPeptideWithMultiOrganism(originalQuery, organism_ID,start,rowsPerPage, uniref100Only, ilEquivalent, sortBy);
/*			if(session.getAttribute("organismsCount-"+originalQuery+"-"+organism_ID+"-"+uniref100Only+"-"+ilEquivalent) == null) {
				sortedHitOrganismsCount = peptideQuery.queryByPeptideWithMultiOrganismWithGroup(originalQuery, organism_ID, uniref100Only, ilEquivalent, sortBy);
				session.setAttribute("organismsCount-"+originalQuery+"-"+organism_ID+"-"+uniref100Only+"-"+ilEquivalent, sortedHitOrganismsCount);
			}
			else {
				sortedHitOrganismsCount = (Map<String, Long>) session.getAttribute("organismsCount-"+originalQuery+"-"+organism_ID+"-"+uniref100Only+"-"+ilEquivalent); 
			}
			if(session.getAttribute("taxonGroupsCount-"+originalQuery+"-"+organism_ID+"-"+uniref100Only+"-"+ilEquivalent) == null) {
				sortedHitTaxonGroupsCount = getTaxonGroupCount(originalQuery, organism_ID, uniref100Only, ilEquivalent, sortBy); 
				session.setAttribute("taxonGroupsCount-"+originalQuery+"-"+organism_ID+"-"+uniref100Only+"-"+ilEquivalent, sortedHitTaxonGroupsCount);
			}
			else {
				sortedHitTaxonGroupsCount = (Map<String, Long>)session.getAttribute("taxonGroupsCount-"+originalQuery+"-"+organism_ID+"-"+uniref100Only+"-"+ilEquivalent);
			}	*/	
		}
		else {
			peptideQuery.queryByPeptide(originalQuery, start,rowsPerPage, uniref100Only, ilEquivalent, sortBy);
/*			if(session.getAttribute("organismsCount-"+originalQuery+"-all"+"-"+uniref100Only+"-"+ilEquivalent) == null) {
				sortedHitOrganismsCount = peptideQuery.queryByPeptideWithGroup(originalQuery, uniref100Only, ilEquivalent, sortBy);
				session.setAttribute("organismsCount-"+originalQuery+"-all"+"-"+uniref100Only+"-"+ilEquivalent, sortedHitOrganismsCount);
				//System.out.println("Set organismsCount-"+originalQuery+"-all"+"-"+uniref100Only+"-"+ilEquivalent);
			}
			else {
				sortedHitOrganismsCount = (Map<String, Long>)session.getAttribute("organismsCount-"+originalQuery+"-all"+"-"+uniref100Only+"-"+ilEquivalent);
			}
			if(session.getAttribute("taxonGroupsCount-"+originalQuery+"-all"+"-"+uniref100Only+"-"+ilEquivalent) == null) {
				sortedHitTaxonGroupsCount = getTaxonGroupCount(originalQuery, "all", uniref100Only, ilEquivalent, sortBy); 
				session.setAttribute("taxonGroupsCount-"+originalQuery+"-all"+"-"+uniref100Only+"-"+ilEquivalent, sortedHitTaxonGroupsCount);
			}
			else {
				sortedHitTaxonGroupsCount = (Map<String, Long>)session.getAttribute("taxonGroupsCount-"+originalQuery+"-all"+"-"+uniref100Only+"-"+ilEquivalent);
			}*/
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
	//String description=(String)doc.getFieldValue("description");				
	//int seqLength=Integer.parseInt((String)doc.getFieldValue("length"));	
	//int seqLength=(Integer)doc.getFieldValue("length");	
	//String seqLength=String.valueOf((Integer)doc.getFieldValue("length"));	
	//int seqLength=FieldType.indexedToReadable((String)doc.getFieldValue("length"));	
	//String[] features=description.trim().split("\\^\\|\\^");
	String sequence=(String)doc.getFieldValue("originalSeq");	
	int seqLength=sequence.length();	
	String id=(String)doc.getFieldValue("ac");
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
		nist =  "<a href=\"http://peptide.nist.gov/browser/proteins.php?description=IT&organism="+nistRec[1]+"&ProteinAccessionNum="+id+"\">NIST</a>";
		peptideLibrary += nist+", ";
	}
	if(peptideAtlas.length() > 0 && !peptideAtlas.equals("X")) {
		peptideAtlas = "<a href=https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key="+peptideAtlas+"&apply_action=GO&exact_match=exact_match\">PeptideAtlas</a>";
		peptideLibrary += peptideAtlas+", ";
	}
	if(pride.length() > 0 && !pride.equals("X")) {
		pride = "<a href=\"http://www.ebi.ac.uk/pride/searchSummary.do?queryTypeSelected=identification%20accession%20number&identificationAccessionNumber="+pride+"\">PRIDE</a>";
		peptideLibrary += pride+", ";
	}
	if(peptideLibrary.indexOf(", ") > 0) {
		peptideLibrary = peptideLibrary.substring(0, peptideLibrary.length() - 2);
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
			iedbStr += "<a id=\"displayText_"+id+"\" href=\"javascript:toggle('"+id+"');\">[More...]</a><br/><br/>";
			iedbStr +="<div id=\"toggleText_"+id+"\" style=\"display: none; \">";
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
	<td class="tablecontent"><input type=checkbox onClick="current_sel(mainform,this.value,'<%=organism_ID%>','<%=originalQuery%>','<%=ilEquivalent%>')" name=idlist value=<%=id%>></td> 
	<td class="tablecontent"><%=id%><br>
	<a href="http://pir.georgetown.edu/cgi-bin/ipcEntry?id=<%=id%>"><img src="./imagefiles/ipc_icon.png" border="0"></a>
	<!--
	<a href="http://www.uniprot.org/uniprot/<%=id%>"><img src="./imagefiles/tr_icon.png" border="0"></a>
	-->
	<a href="http://www.uniprot.org/uniprot/<%=id%>"><img src="./imagefiles/<%=uniprotIcon%>" border="0"></a>
	</td>
        <td class="tablecontent"><%=proteinID%></td>
	<td class="tablecontent"><%=proteinName%><br>
	<a href='http://pir.georgetown.edu/cgi-bin/biothesaurus.pl?id=<%=id%>'><img src="./imagefiles/biot_icon2.png" border="0"> </a>					  		
	</td>  
	<td class="tablecontent"><%=seqLength%></td>
	<td class="tablecontent"><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id=<%=organismID%>'><%=organismName%></a></td> 
	<td class="tablecontent" id="sequencefragment">
<%
if(originalQuery.equals("*:*")){
	out.println(sequence);
}
else{
String color = "red";
if(ilEquivalent.equalsIgnoreCase("N")){	
  for(int i=0;i<=seqLength-originalQuery.length();i++){	
	if(sequence.substring(i, i+originalQuery.length()).equalsIgnoreCase(originalQuery)){
		if(i<5) {
			for(int j=i; j <5; j++) {
				out.print("&nbsp;");
			}
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(0,i)+"<font color='red' >"+originalQuery+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));			
			}
			else if((i+originalQuery.length()+5)<=seqLength){
			out.print(sequence.substring(0,i)+"<font color='red'>"+originalQuery+"</font>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
		}
		else {
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(i-5,i)+"<font color='red'>"+originalQuery+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));	
			}
			else if((i+originalQuery.length()+5)<=seqLength){
				out.print(sequence.substring(i-5,i)+"<font color='red'>"+originalQuery+"</font>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
		}
	out.print(" ");
	out.print(i+1);
	out.print("-");
	out.print(i+originalQuery.length());
	out.println("<br>");
	}
  }
}
else{
String subString = "";
for(int i=0;i<=seqLength-originalQuery.length();i++){
         subString = sequence.substring(i, i+originalQuery.length());	
	if(subString.replaceAll("[Ii]","L").equalsIgnoreCase(originalQuery.replaceAll("[Ii]","L"))){
            if(!subString.equalsIgnoreCase(originalQuery))
                                                    color="green";
		if(i<5) {
			for(int j=i; j <5; j++) {
				out.print("&nbsp;");
			}
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(0,i)+"<font color='"+color+"'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));			
			}
			else if((i+originalQuery.length()+5)<=seqLength){
			out.print(sequence.substring(0,i)+"<font color='"+color+"'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
		}
		else {
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(i-5,i)+"<font color='"+color+"'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));	
			}
			else if((i+originalQuery.length()+5)<=seqLength){
				out.print(sequence.substring(i-5,i)+"<font color='"+color+"'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
		}
	out.print(" ");
	out.print(i+1);
	out.print("-");
	out.print(i+originalQuery.length());
	out.println("<br>");
	}
  }
}
}
 %>
</td>
<td class="tablecontent"><%=peptideLibrary%></td> 
<td class="tablecontent"><%=iedbStr%></td> 
</tr>
<% } } %>

