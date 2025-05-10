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
	String originalQuery = "";
        String organism_ID = "";
        //String resultConstraint = "withorganisms";	
        String resultConstraint = "N";	
        String taxon_id = "";
	int start = 0;
	int rowsPerPage = 20;
	String uniref100Only = "N";
        String ilEquivalent = "N";
	String swissprot = "N";
        String isoform = "N";
        String uniref100Value = "N";
        String lEqiValue = "N";
        String swissprotValue = "N";
        String isoformValue = "N";
        String sortBy = "ac_asc";
	String trOnly = "N";
	String trOnlyValue = "N";
	String isoOnly = "N";
	String isoOnlyValue = "N";

	 if(request.getParameter("constraint")!= null) {
                resultConstraint = request.getParameter("constraint");
        }

        if(request.getParameter("sortBy") != null) {
                sortBy = request.getParameter("sortBy");
        }
	if(request.getParameter("swissprot") != null) {
                swissprotValue = request.getParameter("swissprot");
                swissprot = swissprotValue;
        }
        if(request.getParameter("isoform") != null) {
                isoformValue = request.getParameter("isoform");
                isoform = isoformValue;
        }
        if(request.getParameter("uniref100") != null) {
                uniref100Value = request.getParameter("uniref100");
		uniref100Only = uniref100Value;
        }
        if(request.getParameter("lEqi") != null) {
                lEqiValue = request.getParameter("lEqi");
		ilEquivalent = lEqiValue;
        }
        if(request.getParameter("trOnly") != null) {
                trOnlyValue = request.getParameter("trOnly");
		trOnly = trOnlyValue;
        }
        if(request.getParameter("isoOnly") != null) {
                isoOnlyValue = request.getParameter("isoOnly");
		isoOnly = isoOnlyValue;
        }
        if(request.getParameter("keyword") != null)
	  originalQuery = request.getParameter("keyword").trim().toUpperCase();
        if(request.getParameter("start") != null)
	  start = Integer.parseInt(request.getParameter("start"));
        if(request.getParameter("rows") != null)
	  rowsPerPage = Integer.parseInt(request.getParameter("rows"));
        if(request.getParameter("organism_id") != null)
	  organism_ID = request.getParameter("organism_id");
	//initial the solr connection
	PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
	SolrDocumentList docs = new SolrDocumentList();
	int numberFound = 0;
	if(originalQuery.equals("*:*")){
		peptideQuery.queryAll(start,rowsPerPage, swissprot, isoform, uniref100Only, sortBy, trOnly, isoOnly);
	}
	else
        {
	  originalQuery=originalQuery.replaceAll("[^a-zA-Z]", "");
             if(resultConstraint.equals("withorganisms")) {
		if(!organism_ID.toLowerCase().equals("all")) {
			peptideQuery.queryByPeptideWithMultiOrganism(originalQuery, organism_ID,start,rowsPerPage, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
		}
		else {
			System.out.println("tablecontent withorganism");
			peptideQuery.queryByPeptide(originalQuery, start,rowsPerPage, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
		}
             }
             if(resultConstraint.equals("withlineage")) {
               String op = "OR";
               if(request.getParameter("taxon_id")!=null)
                   taxon_id = request.getParameter("taxon_id");
               if(request.getParameter("op")!=null)
                   op = request.getParameter("op");
               if(!organism_ID.toLowerCase().equals("all")) {
	                peptideQuery.queryByPeptideWithFullLineageOrganismAndTaxonId(originalQuery, organism_ID,taxon_id, start, rowsPerPage, op, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
               }
               else {
	                peptideQuery.queryByPeptideWithFullLineageTaxonId(originalQuery, taxon_id, start, rowsPerPage, op, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
               }
            }
            if(resultConstraint.equals("withtaxongroup")) {
               String taxongroup_id = "";
               if(request.getParameter("taxongroup_id")!=null)
                   taxongroup_id = request.getParameter("taxongroup_id");
              if(!organism_ID.toLowerCase().equals("all")) {
	               peptideQuery.queryByPeptideWithOrganismAndGroup(originalQuery, organism_ID,taxongroup_id, start, rowsPerPage, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
             }
              else {
	               peptideQuery.queryByPeptideWithTaxonGroup(originalQuery, taxongroup_id, start, rowsPerPage, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
              }
           }
           if(resultConstraint.equals("withtaxonid")) {
               String op = "OR";
               if(request.getParameter("taxon_id")!=null)
                   taxon_id = request.getParameter("taxon_id");
               if(request.getParameter("op")!=null)
                   op = request.getParameter("op");
	       peptideQuery.queryByPeptideWithTaxonId(originalQuery, taxon_id, start, rowsPerPage, op, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
           }
          if(resultConstraint.equals("withorganismsNoProteomics")) {
	    if(!organism_ID.toLowerCase().equals("all")) {
			peptideQuery.queryByPeptideWithMultiOrganism(originalQuery, organism_ID,start,rowsPerPage, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
             }
              else {
			System.out.println("tablecontent withorganismsNoProteom");
			peptideQuery.queryByPeptide(originalQuery, start,rowsPerPage, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
            }
	}
       }
	docs = peptideQuery.getCurrentDocs();
	//store the id sets of protein sequences which are matched the keyword
	//return how many protein sequence 
	numberFound = peptideQuery.getResult();	
	Iterator<SolrDocument> docItr = docs.iterator();
	while (docItr.hasNext()) {
	SolrDocument doc = docItr.next();
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
	if(peptideAtlas.length() > 0 && !peptideAtlas.equals("Z")) {
		peptideAtlas = "<a href=https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key="+id+"&apply_action=GO&exact_match=exact_match\">PeptideAtlas</a>";
		peptideLibrary += peptideAtlas+", ";
	}
	if(pride.length() > 0 && !pride.equals("Z")) {
		pride = "<a href=\"http://www.ebi.ac.uk/pride/searchSummary.do?queryTypeSelected=identification%20accession%20number&identificationAccessionNumber="+id+"\">PRIDE</a>";
		peptideLibrary += pride+", ";
	}
	if(peptideLibrary.indexOf(", ") > 0) {
		peptideLibrary = peptideLibrary.substring(0, peptideLibrary.length() - 2);
	}
	if(iedb.length() > 0 && !iedb.equals("Z")) {
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
        <% if(uniref100Only.equals("N"))
        {
        %>
		<td class="tablecontent"><%=id%><br>
			<a href="http://pir.georgetown.edu/cgi-bin/ipcEntry?id=<%=id%>"><img src="./imagefiles/ipc_icon.png" border="0"></a>
			<a href="http://www.uniprot.org/uniprot/<%=id%>"><img src="./imagefiles/<%=uniprotIcon%>" border="0"></a>
		</td>
               	<td class="tablecontent"><%=proteinID%><br>
			<a href="http://www.uniprot.org/uniprot/<%=id%>"><img src="./imagefiles/<%=uniprotIcon%>" border="0"></a>
        	</td>
        <%
         }
         else 
         {
        %>
       		<td class="tablecontent"><a href="http://www.uniprot.org/uniref/UniRef100_<%=id%>">UniRef100_<%=id%>
		</td>
		<td class="tablecontent"><%=id%><br>
			<a href="http://pir.georgetown.edu/cgi-bin/ipcEntry?id=<%=id%>"><img src="./imagefiles/ipc_icon.png" border="0"></a>
			<a href="http://www.uniprot.org/uniprot/<%=id%>"><img src="./imagefiles/<%=uniprotIcon%>" border="0"></a>
		</td>
        <%
         }
        %>
	<td class="tablecontent"><%=proteinName%>
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
//out.println(taxon_id);
if(ilEquivalent.equalsIgnoreCase("N")){	
  for(int i=0;i<=seqLength-originalQuery.length();i++){	
	if(sequence.substring(i, i+originalQuery.length()).equalsIgnoreCase(originalQuery)){
		if(i<5) {
			for(int j=i; j <5; j++) {
				out.print("&nbsp;");
			}
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(0,i)+"<font color='red'>"+originalQuery+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));			
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
         subString = sequence.substring(i, i+originalQuery.length()).toUpperCase();	
	if(subString.replaceAll("[Ii]","L").equalsIgnoreCase(originalQuery.replaceAll("[Ii]","L"))){
            if(!subString.equalsIgnoreCase(originalQuery)) {
            StringBuffer sb = new StringBuffer();
           for(int j =0 ; j < subString.length(); j ++){
             if(subString.charAt(j) != originalQuery.charAt(j))
                    sb.append("<font color='green'>"+subString.charAt(j)+"</font>");
               else
                    sb.append(subString.charAt(j));
             }
            subString = sb.toString();
          }
		if(i<5) {
			for(int j=i; j <5; j++) {
				out.print("&nbsp;");
			}
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(0,i)+"<font color='red'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));			
			}
			else if((i+originalQuery.length()+5)<=seqLength){
			out.print(sequence.substring(0,i)+"<font color='red'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
		}
		else {
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(i-5,i)+"<font color='red'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));	
			}
			else if((i+originalQuery.length()+5)<=seqLength){
				out.print(sequence.substring(i-5,i)+"<font color='red'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
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
<% }  %>

