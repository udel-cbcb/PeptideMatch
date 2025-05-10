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
<html>
<head>
<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<TITLE>Peptide Match [PIR - Protein Information Resource]</TITLE>
<style type="text/css">
body.main{
/*background-image:url('./imagefiles/bg02.gif');
background-color:#cccccc;*/
margin-left:0;
margin-top:0;
margin-right:0;
margin-bottom:0;
width:100%;
height:100%;
}
form.mainform{
margin-top:1px; 
margin-bottom:1px;
}
table.submittable{
BORDER:0;
cellpadding:0;
cellspacing:0:
width:100%;
margin-bottom:1cm;
}
table.maintable {
border:2px solid #333333;
padding: 1px;
border-collapse: collapse;
width: 100%;
table-layout: fixed;
text-align:left;
font-size:12px;
margin:1px;
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
}

table.headtable{
border:1px solid #333333;
width: 99.9%;
height: 28;
bordercolor:#FFFFFF;
padding:0;
cellspacing:3;
margin:1px;
text-align:center;
background-image:url('./imagefiles/seq_ana_bg3.png');
}

table.result {
border-collapse: collapse;
width: 99.9%;
table-layout: fixed;
text-align:left;
font-size:12px;
margin:1px;
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
}
table.result thead tr .header {
font-size: 1em;
text-align: left;
padding-top: 5px;
padding-bottom: 4px;
background-color: #C1D0DF;
color: #000000;	
background-image: url("./imagefiles/bg.gif");
background-repeat: no-repeat;
background-position: center right;
cursor: pointer;
}
table.result td{
border: 2px solid black;
}
table.result th{
border: 2px solid black;
}
table.result thead tr .headerSortUp {
	background-image: url("./imagefiles/asc.gif");
}
table.result thead tr .headerSortDown {
	background-image: url("./imagefiles/desc.gif");
}
td.tablecontent {
font-size:12px;
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
	vertical-align: center;
	word-wrap: break-word;
}
td.searchLable {
	color:#ffffff;
	font-family:Verdana,Arial, Helvetica, sans-serif;
	font-size:10px;
	font-weight:bold
}
.searchBannerBox {
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
font-size: 11px; 
WIDTH: 180px;  
HEIGHT:18px
}
table.headline{
margin-left:5px;
}
#highlight {
color: red;
}
#headresult{
align:left;
color:black;
font-size: 12px;
}
#headlight{
color:black;
}
#sequencefragment{
font-family:Courier New,monospace;
}
#foot{
width:100%;
frameBorder:0;
align:left;
margin-bottom:1px;
}
#keyword{
width:500px;
}
#inputform{
margin:5px;
max-height:50px;
}
.menulink{
margin-left:8px;
}
#show_organism{
display:none;
}
</style>
<script language="javascript">
function toggle(ac) {
        var ele = document.getElementById("toggleText"+"_"+ac);
        var text = document.getElementById("displayText"+"_"+ac);
        if(ele.style.display == "block") {
                ele.style.display = "none";
                text.innerHTML = "[More...]";
        }
        else {
                ele.style.display = "block";
                text.innerHTML = "[Less]";
        }
}
</script>
<!-- Menu Related -->
<script language="javascript" src="./imagefiles/milonic_src.js" type="text/javascript"></script>
<script language="javascript">
  if(ns4) _d.write("<scr"+"ipt language=JavaScript src=./imagefiles/mmenuns4.js><\/scr"+"ipt>");		
    else _d.write("<scr"+"ipt language=JavaScript src=./imagefiles/mmenudom.js><\/scr"+"ipt>"); 
</script><script language="JavaScript" src="./imagefiles/mmenudom.js"></script><script>function getflta(ap){return _f}</script>
<script language="javascript" src="./imagefiles/menu_data.js" type="text/javascript"></script>
<!-- Menu Related ends -->
<script type="text/javascript" src="./js/jquery-1.9.1.js"></script> 
<script type="text/javascript" src="./js/check_analyze.js"></script>
<script type="text/javascript" src="./js/jquery_ajax.js"></script>
</head>
<body class="main">
<MAP NAME="PIRBanner_Map">
<AREA SHAPE="rect" alt="home" COORDS="16,16,110,60" HREF="http://pir.georgetown.edu/pirwww/index.shtml" TARGET="_top">
<AREA SHAPE="rect" alt="uniprot" COORDS="140,36,178,50" HREF="http://www.uniprot.org/" TARGET="_blank">
</MAP>	
<table cellspacing="0" cellpadding="0" width="100%" border="0" height="80">
<tr> 
      <td><img alt="" src="./imagefiles/PIRBanner.png" border="0" usemap="#PIRBanner_Map"></td> 
      <td width="99%" nowrap="" height="1" background="./imagefiles/blueSpacer.png">
		<img alt="" src="./imagefiles/spacer.gif" width="1" height="1" border="0">
	  </td>
      <td align="right" valign="top" height="80" width="400" background="./imagefiles/gradientHome6.png">
         <table border="0" cellpadding="0" cellspacing="0" width="400" height="80">
          <form action="http://pir.georgetown.edu/cgi-bin/textsearch.pl" id="textSearch" method="get" name="textSearchForm" style="MARGIN: 0px">
   <tr>
              <td width="400" colspan="10"><img alt="" src="./imagefiles/spacer.gif" width="400" height="30"></td>
            </tr>  
            <tr>
              <td><img alt="" src="./imagefiles/spacer.gif" width="60" height="1"></td>
	            <td><input type="radio" name="sitesearch" checked=""></td>
	            <td align="right" nowrap="" class="searchLable">Protein Search</td>
	            <td><input type="radio" name="sitesearch" value="sitesearch"></td>
	            <td align="right" nowrap="" class="searchLable">Site Search</td>
	            <td><img alt="" src="./imagefiles/spacer.gif" width="8" height="1"></td>
              <td align="right"><input alt="submit" type="image" src="./imagefiles/but06.png" border="0" width="18" height="16" name="submit"></td>
              <td><img alt="" src="./imagefiles/spacer.gif" width="2" height="1"></td>
              <td align="right"><input alt="query" name="query0" type="text" class="searchBannerBox" style="background:#CED9E7;" value=""></td>
              <td><img alt="" src="./imagefiles/spacer.gif" width="6" height="1"></td>
            </tr>
<input type="hidden" name="field0" value="ALL">
<input type="hidden" name="search" value="1">
</form>
</table>
</td>
</tr>

</table>

<table cellSpacing=0 cellPadding=0 width=100% bgColor=#333333 border=0><tr>
<TD><img src='./imagefiles/leftSearch.png'></TD><!-- ############### group dependent-->
<td class=sml01 width=99% background='./imagefiles/bgcolor.png'>&nbsp;</td>
<noscript>
<td>
		<table bgcolor="#4a4a4a" width="100%" height="21" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td class="nrm02" nowrap>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<a href="http://pir.georgetown.edu/pirwww/index.shtml" class="m"><font face=verdana size="2pt" color="white">Home</font></a> &nbsp;&nbsp;&nbsp;&nbsp; 
					<a href="http://pir.georgetown.edu/pirwww/about/" class="m"><font face=verdana size="2pt" color="white">About PIR</font></a>&nbsp;&nbsp;&nbsp;&nbsp; 
					<a href="http://pir.georgetown.edu/pirwww/dbinfo/" class="m"><font face=verdana size="2pt" color="white">Databases</font></a> &nbsp;&nbsp;&nbsp;&nbsp; 
					<a href="http://pir.georgetown.edu/pirwww/search/" class="m"><font face=verdana size="2pt" color="white">Search/Retrieval</font></a> &nbsp;&nbsp;&nbsp;&nbsp; 
					<a href="http://pir.georgetown.edu/pirwww/search/" class="m"><font face=verdana size="2pt" color="white">Download</font></a> &nbsp;&nbsp;&nbsp;&nbsp; 
					<a href="http://pir.georgetown.edu/pirwww/support/" class="m"><font face=verdana size="2pt" color="white">Support</font></a>
				</td>
			</tr>
		</table>
	</td>
</noscript>
</tr>
</table>
<table style="margin-left: 100px;" border="0" cellspacing="0" cellpadding="0" class="docTitle"><tbody><tr>
  <td width="10" rowspan="2"><img height="20" src="./imagefiles/spacer.gif" width="10" alt=""></td>
<td>
<table border="0" cellpadding="0" cellspacing="0" width="8" height="20">
<tbody><tr>
 <td bgcolor="#336699"><img height="20" src="./imagefiles/spacer.gif" width="8" alt=""></td>
</tr>
</tbody></table>
</td>
<td width="10"><img height="20" src="./imagefiles/spacer.gif" width="10" alt=""></td>

	<td>
	<a href="http://pir.georgetown.edu/pirwww/" class="titleLink"><b>HOME</b></a>
							   / <a href="http://pir.georgetown.edu/pirwww/search/" class="titleLink"><b>Search</b></a>
	    / <b><a href="index.jsp">Peptide Match</a></b><!-- ############### page dependent-->
</td></tr>
</tbody></table>
<% 
//if open the page directly,don't show the result table
if(request.getParameter("initialed")!=null &&request.getParameter("keyword")!=null &&request.getParameter("start")!=null &&request.getParameter("rows")!=null &&request.getParameter("organism_id")!=null){
String originalQuery="";	
int start=0;
int rowsPerPage=20;
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
peptideQuery.queryAll(start,rowsPerPage);
}
else{
originalQuery=originalQuery.replaceAll("[^a-zA-Z]", "");
if(!organism_ID.toLowerCase().equals("all")) {
	peptideQuery.queryByPeptideWithMultiOrganism(originalQuery, organism_ID,start,rowsPerPage);
	if(session.getAttribute("organismsCount-"+originalQuery+"-"+organism_ID) == null) {
		sortedHitOrganismsCount = peptideQuery.queryByPeptideWithMultiOrganismWithGroup(originalQuery, organism_ID);
		session.setAttribute("organismsCount-"+originalQuery+"-"+organism_ID, sortedHitOrganismsCount);
	}
	else {
		sortedHitOrganismsCount = (Map<String, Long>) session.getAttribute("organismsCount-"+originalQuery+"-"+organism_ID); 
	}
	if(session.getAttribute("taxonGroupsCount-"+originalQuery+"-"+organism_ID) == null) {
		sortedHitTaxonGroupsCount = getTaxonGroupCount(originalQuery, organism_ID); 
		session.setAttribute("taxonGroupsCount-"+originalQuery+"-"+organism_ID, sortedHitTaxonGroupsCount);
	}
	else {
		sortedHitTaxonGroupsCount = (Map<String, Long>)session.getAttribute("taxonGroupsCount-"+originalQuery+"-"+organism_ID);
	}	
}
else {
	peptideQuery.queryByPeptide(originalQuery, start,rowsPerPage);
	if(session.getAttribute("organismsCount-"+originalQuery+"-all") == null) {
		sortedHitOrganismsCount = peptideQuery.queryByPeptideWithGroup(originalQuery);
		session.setAttribute("organismsCount-"+originalQuery+"-all", sortedHitOrganismsCount);
		//System.out.println("Set organismsCount-"+originalQuery+"-all");
	}
	else {
		sortedHitOrganismsCount = (Map<String, Long>)session.getAttribute("organismsCount-"+originalQuery+"-all");

	}
	if(session.getAttribute("taxonGroupsCount-"+originalQuery+"-all") == null) {
		sortedHitTaxonGroupsCount = getTaxonGroupCount(originalQuery, "all"); 
		session.setAttribute("taxonGroupsCount-"+originalQuery+"-all", sortedHitTaxonGroupsCount);
	}
	else {
		sortedHitTaxonGroupsCount = (Map<String, Long>)session.getAttribute("taxonGroupsCount-"+originalQuery+"-all");
	}
	
	/*
	for(String organism: sortedHitTaxonGroupsCount.keySet()) {
		out.println(organism+ " "+ sortedHitTaxonGroupsCount.get(organism)+"<br/>");
	}
	*/	
}
}
docs = peptideQuery.getCurrentDocs();
//store the id sets of protein sequences which are matched the keyword
//return how many protein sequence 
session.setAttribute("currentdocs", docs);
session.setAttribute("currentquery", originalQuery);
numberFound = peptideQuery.getResult();	
//String spectraSearch = "Search <a href=peptidespectra.jsp?peptide="+originalQuery+"&db=gpmdb><b>gpmDB</b></a>, <a href=peptidespectra.jsp?peptide="+originalQuery+"&db=nist><b>NIST Peptide Library</b></a>, <a href=peptidespectra.jsp?peptide="+originalQuery+"&db=peptideatlas><b>PeptideAtlas</b></a>, or <a href=peptidespectra.jsp?peptide="+originalQuery+"&db=all><b>All of them</b></a>";

String spectraSearch  ="<table border=0>\n";
spectraSearch +="	<tr><td valign=top style=\"white-space: nowrap;\">Search query peptide in</td>\n";
spectraSearch +=" 	    <td valign=top><form name=\"spectrasearchform\" action=\"peptidespectra.jsp\" onSubmit=\"return spectraSearchInputCheck(this)\">\n"; 
spectraSearch +="		<select name=\"db\">\n";
spectraSearch +="		 	<option value=\"nist\">NIST Peptide Library</option>\n";
spectraSearch +="		 	<option value=\"gpmdb\">gpmDB</option>\n";
spectraSearch +="		 	<option value=\"peptideatlas\">PeptideAtlas</option>\n";
spectraSearch +="		 	<option value=\"pride\">PRIDE</option>\n";
spectraSearch +="		 	<option value=\"all\">All of above</option>\n";
spectraSearch +="		 </select>\n";
spectraSearch +="		<td valign=top><input type=\"submit\"</td>\n";
spectraSearch +="		<input type=\"hidden\" name=\"peptide\" value=\""+originalQuery+"\">\n";
spectraSearch +="		</form></td>\n";
spectraSearch +="	</tr>\n";
spectraSearch +="</table>\n";
%>
<TABLE width=100% border=0> 
<tr>
<td width=35% valign=top style="white-space: nowrap;">
<form id=inputform action=peptidewithorganisms.jsp method=get name="searchform" onSubmit="return InputCheck(this)">
<a title='return to searching page' href=./index.jsp><img src=./imagefiles/restart.png border=0></a>
Query peptide:&nbsp;&nbsp;<input type=text name="keyword" style="width:200px;" id="keyword" onblur="reminder()" onfocus="if(!this._haschanged){this.value=''};this._haschanged=true;" value=<%
//session.invalidate();
if(request.getParameter("keyword")!=null) {
	out.print(request.getParameter("keyword").toUpperCase().replaceAll("[^a-zA-Z]", "")); 
}

%> > 
<input type="hidden"name="start" value=0> 
<input type="hidden" name="initialed" value="false"> 
<input type="hidden" name="organism_id" value="<%if(request.getParameter("organism_id")!=null)out.print(request.getParameter("organism_id"));else out.print("all");%>" >
<input type="hidden" name="rows" value="20">
<input type=submit value="Submit">
<input type="reset"  value="Reset" >
</form>
</td>
<td width=5% style="white-space: nowrap; ">&nbsp;</td>
<td width=35% align=center style="white-space: nowrap;" valign=top>
<%=spectraSearch%>
</td>
<td width=5% style="white-space: nowrap;">&nbsp;</td>
<td align="right" valign=top style="white-space: nowrap;">
<font color='#777777'><img alt='' src=./imagefiles/result_z.png border=0><b>Peptide Match Result (<%
if(request.getParameter("organism_id")!=null){
if(!request.getParameter("organism_id").toLowerCase().equals("all")){
	if(request.getParameter("organism_id").toLowerCase().split(";").length==1)
		out.print("TaxonID:<a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+request.getParameter("organism_id")+"'>"+request.getParameter("organism_id")+"</a>");
	else
		out.print("TaxonID:<a href='javascript:void(0)' onclick='show_organism_details();'>Multiple organisms</a>");		
}
else out.print("<a href='http://www.uniprot.org/help/uniprotkb'>UniProtKB</a>");
}
else out.print("<a href='http://www.uniprot.org/help/uniprotkb'>UniProtKB</a>");
		%>)</b></font>
<br>
</td>
</tr>
</TABLE>
<div id='show_organism' style="float: right;">
<%
String[] organisms=request.getParameter("organism_id").toLowerCase().split(";");
out.print("Taxon ID(s): ");
for(int i=0;i<organisms.length;i++){
out.print("<a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+organisms[i]+"'>"+organisms[i]+"</a>");
if(i!=organisms.length-1) out.print("; ");

}
out.print("<a href='javascript:void(0)' onclick='close_organism_details()'><img onclick='close_organism_details' src='./imagefiles/off.png'></a>");
%>
</div>
<%	
if (numberFound > 0) {		
		
%>

<table width=100% border=0>
<tr><td>
<%=createHitSummary(sortedHitOrganismsCount, sortedHitTaxonGroupsCount, originalQuery, organism_ID, numberFound)%>
</td></tr>
</table>

<table width=100% align=right border=0>
<tr>
	<td>
	<table  class="" width="100%" border="0" cellpadding="0" cellpadding="0">
		<tbody> <tr>
			<td id=headresult><br/>
			<span style="font-size: 14px;"><%=numberFound%> Proteins Matched&nbsp;|&nbsp;Page <%=start/rowsPerPage+1 %> of <%=(numberFound-1)/rowsPerPage+1 %>&nbsp;(<%=rowsPerPage%> Rows/Page)&nbsp;|&nbsp;
			<% out.print("Browse by <b><a href=taxonomylazytreeview.jsp?peptide="+originalQuery+"&organism_id="+organism_ID+"&numberfound="+numberFound+">Taxonomy Tree</a></b> or <b>"); %>
			<% out.print("<a href=taxongroup.jsp?peptide="+originalQuery+"&organism_id="+organism_ID+"&numberfound="+numberFound+">Taxonomy Group</a></b>"); %></span>
			</td>
			<td align=right>
				<table border="0" cellpadding="0" cellspacing="0">
				<tbody><tr>
					<td align="right"><img alt="save" src="./imagefiles/save_as.png"></td>
					<td class="nrm02" width="4" align="center">&nbsp;</td>
					<td align="center"><a href=<% out.print("./"+response.encodeUrl("SaveData")+"?filetype=tab&query="+originalQuery+"&start="+start+"&organism="+organism_ID); %>><input type="image" alt="save as Table" src="./imagefiles/save_fxn_tbl.jpg"></td></a></td>
					<td class="nrm02" width="4" align="center">|</td>
					<td align="center"><a href=<% out.print("./"+response.encodeUrl("SaveData")+"?filetype=fasta&query="+originalQuery+"&start="+start+"&organism="+organism_ID); %>><input alt="save as FASTA" type="image" name="save_fasta" src="./imagefiles/save_fxn_fasta.jpg"></a></td>
					<td><img alt="" src="./imagefiles/transparent_dot.png" border="0" height="2" width="50"></td>
					</tr>  
				</tbody></table>
			</td>
			</tr>
		</tbody>
	</table>
<form class="mainform" name="mainform" method="post"  action="http://pir.georgetown.edu/cgi-bin/peptidematch.pl"> 
<table class="maintable">
<tbody>
<tr>
<td>
<table class="headtable">
<tbody>
<tr>
<td> 
<table cellspacing="0" cellpadding="0" border="0"><tbody><tr><td>
<table cellspacing="0" cellpadding="0" border="0" background="./imagefiles/bg02.gif">
<tbody>
<tr> 
<td  align="right" id="select_box"><img src="./imagefiles/check_do.png" border="0"></td></tr> 
</tbody></table></td></tr></tbody></table> 
<input type="hidden" name="hidden_id" value=""> 
<input type="hidden" name="searchstr" value=""> 
</td><td width="100%"></td><td align="right"> 
<table border="0">
<tbody><tr> 
<td nowrap=""><input type="image" name="blast" src="./imagefiles/blast.png" onclick="return verifyNums('blast','<%=organism_ID%>')">
<input type="image" name="fasta" src="./imagefiles/fasta.png" onclick="return verifyNums('fasta','<%=organism_ID%>' )">
<input type="image" name="pat" src="./imagefiles/pat.png" onclick="return verifyNums('pat','<%=organism_ID%>')">
<input type="image" name="maln" src="./imagefiles/maln.png" onclick="return verifyNums('maln','<%=organism_ID%>')">
<input type="image" name="dom" src="./imagefiles/dom.png" onclick="return verifyNums('dom','<%=organism_ID%>')"></td>
<td><img src="./imagefiles/transparent_dot.png" border="0" height="2" width="32"></td>
</tr>
</tbody></table> 
</td>
</tr>
</tbody>
</table>
</td>
</tr>
<tr>
<td >	
<table class="result" id="sortedresulttable">
<thead>
<tr>
<th width=2% ><input type=checkbox id="all_box" name=all value="all"  onClick="current_sel(mainform,'<%=organism_ID%>','<=%originalQuery%>','<%=ilEquivalent%>');"></th>
<th width=11% id="ac_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','','','','','0','20','<%=numberFound%>','<%=uniref100Value%>','<%=lEqiValue%>',this.id)"><b>Protein AC</b></th>
<th width=9%  id="proteinID_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','','','','','0','20','<%=numberFound%>','<%=uniref100Value%>','<%=lEqiValue%>',this.id)"><b>Protein ID</b></th>
<th width=20% id ="proteinName_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','','','','','0','20','<%=numberFound%>','<%=uniref100Value%>','<%=lEqiValue%>',this.id)" ><b>Protein Name</b></th>
<th width=5%  id="length_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','','','','','0','20','<%=numberFound%>','<%=uniref100Value%>','<%=lEqiValue%>',this.id)" ><b>Length</b></th>
<th width=20% id ="organismName_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','','','','','0','20','<%=numberFound%>','<%=uniref100Value%>','<%=lEqiValue%>',this.id)"><b>Organism</b></th>
<th style="background-color:#C1D0DF"><b>Match Range</b></th>	
<th width=10% id="proteomic_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','','','','','0','20','<%=numberFound%>','<%=uniref100Value%>','<%=lEqiValue%>',this.id)"><b>Proteomic Databases</b></th>
<th width=15% id="iedb_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','','','','','0','20','<%=numberFound%>','<%=uniref100Value%>','<%=lEqiValue%>',this.id)" ><b>IEDB</b></th>
</tr>
</thead>
<tbody id="result_content">
</tbody>
</table>	
</td>
</tr>
</tbody>
</table>
</Form>
<input hidden id="current_sortby" value="<%=sortBy%>"></input>
<%	out.println("<script language='javascript'>window.onload=paging(\"false\",\""+originalQuery+"\",\""+organism_ID+"\",\""+taxon_id+"\",\""+taxon_name+"\",\"\",\"\",\"0\",\"20\",\""+numberFound+"\",\""+uniref100Value+"\",\""+lEqiValue+"\",\""+sortBy+"\");</script>");

//out.println("<script language='javascript'>window.onload=getPageContentWithTaxOnId(\"false\",\""+originalQuery+"\",\""+organism_ID+"\",\""+taxon_id+"\",\""+taxon_name+"\",\"0\",\"20\",\""+numberFound+"\",\""+uniref100Value+"\",\""+lEqiValue+"\",\""+sortBy+"\");</script>");


}
    else {
	%>
	<p>&nbsp;&nbsp;0 result returned</p>
<% } 
}

%>
</td></tr></table>
<div id="div-paging"></div>
<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#eeeeee" border="0" class="nrm02">
  <tbody>
    <tr> 
<td align="center" valign="middle" nowrap="" bgcolor="#71a1cf">
<img src="./imagefiles/pirlogo2.png" alt="PIR">
</td>
 <td align="left" valign="top"> 
<table background="./imagefiles/spacer.gif" width="686" border="0" cellpadding="3" cellspacing="0" class="nrm02">
<tbody>
<tr> 
<td align="left" valign="bottom" nowrap="">
                  &nbsp;<a href="http://pir.georgetown.edu/pirwww/" target="_blank" class="footerMenu">Home</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/about/" target="_blank" class="footerMenu">About PIR</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/dbinfo" target="_blank" class="footerMenu">Databases</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/search/" target="_blank" class="footerMenu">Search/Analysis</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/download/" target="_blank" class="footerMenu">Download</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/support/" target="_blank" class="footerMenu">Support</a>
              </td>
              <td align="right" valign="bottom" nowrap="" class="nrm01">
                  &nbsp;<a href="http://pir.georgetown.edu/pirwww/support/sitemap.shtml" target="_blank" class="footer">SITE MAP</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/about/linkpir.shtml" target="_blank" class="footer">TERMS OF USE</a>
              </td>
            </tr>
            <tr> 
              <td colspan="2" align="center" nowrap="" class="footer3"><span class="nrm10"><font color="#999999"> &copy; 2013</font>
                                    <img src="./imagefiles/spacer.gif" alt="" width="20" height="1">
                                    <b><a href="http://pir.georgetown.edu/pirwww/index.shtml" target="_blank">Protein Information Resource</a></b>
                                    <img src="./imagefiles/spacer.gif" alt="" width="105" height="1"></span></td>
            </tr>

            <tr><td colspan="2" nowrap=""><table border="0" cellpadding="2" cellspacing="0" class="nrm02" width="100%">
                         <tbody><tr><td><img src="./imagefiles/spacer.gif" alt="" width="50" height="1"></td>
                             <td nowrap="" align="center" class="footer"><a href="http://bioinformatics.udel.edu/"><font color="#999999">University of Delaware</font></a>
                                          <br><font color="#999999">15 Innovation Way, Suite 205
                                          <br>Newark, DE 19711, USA</font></td>
                             <td><img src="./imagefiles/spacer.gif" alt="" width="20" height="1"></td>

                            <td nowrap="" align="center" class="footer"><a href="http://gumc.georgetown.edu/"><font color="#999999">Georgetown University Medical Center</font></a>
                                  <br><font color="#999999">3300 Whitehaven Street, NW, Suite 1200
                                  <br>Washington, DC 20007, USA</font></td>
                          </tr></tbody></table></td>
            </tr>
          </tbody>
        </table></td>
			<td width="99%">&nbsp;
			</td>       
    </tr>
</tbody>
</table>

</body>
<script type="text/javascript">
function show_organism_details(){
	document.getElementById('show_organism').style.display='inline';
}
function close_organism_details(){
	document.getElementById('show_organism').style.display='none';
}
function reminder(){
	if(document.getElementById('keyword').value==""){
		 document.getElementById('keyword').value = "Please type a query peptide here";  
	}
}
 
function showPeptide(originalQuery)
{
var content=originalQuery;
document.getElementById("peptide").innerHTML=content;  
}

function InputCheck(searchform) {
	var keyword=searchform.keyword.value;
	if(keyword=="*:*"){
		document.searchform.submit();
	}
	else
	{
		if(keyword == "Please type a query peptide here") {
			alert("You need to type a query peptide");
			document.getElementById("keyword").value = "";
                	document.getElementById("keyword").focus();
			return (false);	
		}
		else {
			var validinput=keyword.replace(/[^a-zA-Z]+/g,'');	
			searchform.keyword.value=validinput;
			if(validinput.length>=3){	
				document.searchform.submit();
			}
			else{
				alert("Please input the keyword at least 3 valid characters(only letters are accepted)");
				searchform.keyword.focus();
				return (false);	
			}
		}
	}
}

function spectraSearchInputCheck(spectrasearchform) {
	var peptide=spectrasearchform.peptide.value;
	var keyword = document.getElementById("inputform").keyword.value;
	//var searchform = document.getElementByName("searchform");
	if(keyword == "Please type a query peptide here") {
		alert("You need to type a query peptide");
		document.getElementById("keyword").value = "";
               	document.getElementById("keyword").focus();
		return (false);	
	}
	else {
		var validinput=keyword.replace(/[^a-zA-Z]+/g,'');	
		if(validinput.length>=3){
			spectrasearchform.peptide.value = validinput	
			document.spectrasearchform.submit();
		}
		else{
			alert("Please input the keyword at least 3 valid characters(only letters are accepted)");
			searchform.keyword.focus();
			return (false);	
		}
	}
		
}
</script>
</html>
<%!
	private Map<String, Long> getTaxonGroupCount(String peptide, String organism_id) {
		HashMap<String, Long> hits = new HashMap<String, Long>();
		Map<String, Long> sortedHits = new LinkedHashMap();
        	try {
			InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/taxongroup.txt");
			BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
                	String strLine;
			PeptidePhraseQuery query = null;
			int hitCount = 0;
			int totalHits = 0;
			int totalTaxonGroups = 0;
                	while((strLine = br.readLine())!= null) {
				String[] rec = strLine.split("\t");
				String group = rec[0];
				String taxonGroupName = rec[1];
				String groupID = rec[2];
				query=new PeptidePhraseQuery();
				if(organism_id.toLowerCase().equals("all")) {
					query.queryByPeptideWithTaxonGroup(peptide, groupID, 0, 1);
				}
				else {
					query.queryByPeptideWithOrganismAndGroup(peptide, organism_id, groupID, 0, 1);
				}
				hitCount = query.getResult();
				totalHits += hitCount;
				if(hitCount > 0) {
					totalTaxonGroups++;
					hits.put(taxonGroupName+"<|>"+groupID, Long.valueOf(hitCount));	 	
				}
				//hits.put(groupID, Long.valueOf(hitCount));	 	
                	}
			inputStream.close();
			br.close();
			sortedHits = sortByValue(hits, totalHits, totalTaxonGroups);	
        	}
        	catch(Exception e) {
                	e.printStackTrace();
        	}
		return sortedHits;
	}

	public Map<String, Long> sortByValue(Map<String, Long> map, long totalMatches, long totalGroups) {
                List list = new LinkedList(map.entrySet());
                Collections.sort(list, new Comparator() {
                        //@Override
                        public int compare(Object o1, Object o2) {
                                if(((Map.Entry) (o2)).getValue() == ((Map.Entry) (o1)).getValue()) {
					//System.out.println(((Map.Entry) (o2)).getKey()+" " +((Map.Entry)(o1)).getKey());	
					return ((Comparable)((Map.Entry) (o2)).getKey()).compareTo(((Map.Entry)(o1)).getKey());	
				}
					//System.out.println(((Map.Entry) (o2)).getKey()+" " +((Map.Entry)(o2)).getValue() + " | " + ((Map.Entry) (o1)).getKey()+" " +((Map.Entry)(o1)).getValue());	
                                return ((Comparable) ((Map.Entry) (o2)).getValue()).compareTo(((Map.Entry) (o1)).getValue());
                        }
                });

                Map result = new LinkedHashMap();
                int count = 0;
                result.put("totalTaxonGroupMatches", totalMatches);
                result.put("totalTaxonGroups", totalGroups);
                for (Iterator it = list.iterator(); it.hasNext();) {
                        Map.Entry entry = (Map.Entry) it.next();
                        result.put(entry.getKey(), entry.getValue());
                }
                return result;
        }
		
	private String createHitSummary(Map<String, Long> sortedHitOrganismsCount, Map<String, Long> sortedHitTaxonGroupsCount, String originalQuery, String organism_ID, int numberFound) {
		long totalOrganismMatches =0 ;
		long totalOrganismGroups =0 ;
		long totalTaxonGroupMatches =0 ;
		long totalTaxonGroups =0 ;
		int totalShow = 5;
		HashMap taxonToName = new HashMap();
        	try {
			InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/taxToTaxGroup.txt");
			BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
                	String strLine;
                	while((strLine = br.readLine())!= null) {
				String[] rec = strLine.split("\t");
				taxonToName.put(rec[0], rec[1]);
                	}
			inputStream.close();
			br.close();
        	}
        	catch(Exception e) {
                	e.printStackTrace();
        	}

		String chart  = "<script type=\"text/javascript\" src=\"http://www.google.com/jsapi\"></script>\n";
		       chart += "<script type=\"text/javascript\">\n";			
		       chart += "	google.load('visualization', '1', {packages: ['corechart']})\n";			
		       chart += "</script>";			
		       chart += "<script type=\"text/javascript\">\n";			
		       chart += " function drawVisualization() {\n";
		       chart += "   var orgData = google.visualization.arrayToDataTable([\n";
		       chart += "   	['OrganismCount', 'Hits per organsim'], \n";
			int topOrgCount = 0;
			int topOrgTotal = 0;
		       if(sortedHitOrganismsCount.keySet().size() > 7) {
				for(String key: sortedHitOrganismsCount.keySet()) {
					if(key.equals("totalOrganismMatches")) {
						totalOrganismMatches = sortedHitOrganismsCount.get(key);
					}
					else if(key.equals("totalOrganismGroups")) {
						totalOrganismGroups = sortedHitOrganismsCount.get(key);
					}
					else {
						//String orgName = (String) taxonToName.get(key);
						String[] rec = key.split("\\<\\|\\>");
						String orgName = rec[0];
						long orgCount = (Long)sortedHitOrganismsCount.get(key);	
						topOrgCount++;
						if(topOrgCount <= totalShow) {
							chart += "['"+orgName+"', "+orgCount+"],\n";
							topOrgTotal += orgCount;
						}
						else {
							chart += "['Others', "+ (totalOrganismMatches - topOrgTotal)+"],\n";
							break;
						}
					}
				}
		       }
		       else {
				for(String key: sortedHitOrganismsCount.keySet()) {
					if(key.equals("totalOrganismMatches")) {
						totalOrganismMatches = sortedHitOrganismsCount.get(key);
					}
					else if(key.equals("totalOrganismGroups")) {
						totalOrganismGroups = sortedHitOrganismsCount.get(key);
					}
					else {
						//String orgName = (String) taxonToName.get(key);
						String[] rec = key.split("\\<\\|\\>");
						String orgName = rec[0];
						long orgCount = (Long)sortedHitOrganismsCount.get(key);	
						chart += "['"+orgName+"', "+orgCount+"],\n";
					}
				}


			}
			chart = chart.substring(0, chart.length() -2)+"\n";
			chart += "]);\n";

			chart += "   var taxonGroupData = google.visualization.arrayToDataTable([\n";
                       chart += "       ['TaxonGroupCount', 'Hits per taxonGroup'], \n";
                        int topTaxonGroupCount = 0;
                        int topTaxonGroupTotal = 0;
                       if(sortedHitTaxonGroupsCount.keySet().size() > 7) {
                                for(String key: sortedHitTaxonGroupsCount.keySet()) {
                                        if(key.equals("totalTaxonGroupMatches")) {
                                                totalTaxonGroupMatches = sortedHitTaxonGroupsCount.get(key);
                                        }
                                        else if(key.equals("totalTaxonGroups")) {
                                                totalTaxonGroups = sortedHitTaxonGroupsCount.get(key);
                                        }
                                        else {
						String[] rec = key.split("\\<\\|\\>");
						String taxonGroupId =  rec[1];
						String taxonGroupName = rec[0];
                                                long taxonGroupCount = (Long)sortedHitTaxonGroupsCount.get(key);
                                                topTaxonGroupCount++;
                                                if(topTaxonGroupCount <= totalShow) {
                                                        chart += "['"+taxonGroupName+"', "+taxonGroupCount+"],\n";
                                                        topTaxonGroupTotal += taxonGroupCount;
                                                }
                                                else {
                                                        chart += "['Others', "+ (totalTaxonGroupMatches - topTaxonGroupTotal)+"],\n";
                                                        break;
                                                }
                                        }
                                }
                       }
                       else {
                                for(String key: sortedHitTaxonGroupsCount.keySet()) {
                                        if(key.equals("totalTaxonGroupMatches")) {
                                                totalTaxonGroupMatches = sortedHitTaxonGroupsCount.get(key);
                                        }
                                        else if(key.equals("totalTaxonGroups")) {
                                                totalTaxonGroups = sortedHitTaxonGroupsCount.get(key);
                                        }
                                        else {
						String[] rec = key.split("\\<\\|\\>");
						String taxonGroupId =  rec[1];
						String taxonGroupName = rec[0];
                                                long taxonGroupCount = (Long)sortedHitTaxonGroupsCount.get(key);
                                                chart += "['"+taxonGroupName+"', "+taxonGroupCount+"],\n";
                                        }
                                }


                        }
			chart = chart.substring(0, chart.length() -2)+"\n";
                        chart += "]);\n";  
			chart += "var options = {\n";
			//chart += "	colors: ['red', 'orange', 'brown', 'green', 'blue', 'navy'],\n";
			chart += "	colors: ['DodgerBlue', 'DeepSkyBlue', 'Lavender', 'LightBlue', 'LightSkyBlue', 'LightSteelBlue'],\n";
			chart += "	legend: 'none', \n";
			//chart += "	backgroundColor: { fill: 'transparent'}, \n";
			chart += "	backgroundColor: { fill: 'none'}, \n";
			//chart += "	backgroundColor: { stroke:null, fill: null, strokeSize: 0}, \n";
			chart += "	pieSliceText: 'none',\n"; 
			chart += "	 chartArea: {top:10, width:150, height:150},\n";  
                	chart += "	tooltipTextStyle: {bold: true, fontSize: 11}}\n";
			chart += "var orgChart = new google.visualization.PieChart(document.getElementById('orgChart'))\n";
			chart += "	orgChart.draw(orgData, options);\n";
			chart += "var taxonGroupChart = new google.visualization.PieChart(document.getElementById('taxonGroupChart'))\n";
			chart += "	taxonGroupChart.draw(taxonGroupData, options);\n";
			chart += "}\n";
			chart += "google.setOnLoadCallback(drawVisualization);\n"; 
		        chart += "</script>";			

			String	colors[]  = {"DodgerBlue", "DeepSkyBlue", "Lavender", "LightBlue", "LightSkyBlue", "LightSteelBlue"};
			//String colors[] = {"red", "orange", "brown", "green", "blue", "navy"};
			chart += "<table width=\"100%\" border=0>\n";
			chart += "	<tr>\n";
			chart += "		<td width=\"50%\" align=\"right\">\n";
			chart += "		<table border=0 width=\"100%\" align=\"right\">\n";
			chart += "			<tr><th align=center colspan=\"2\" style=\"font-size: small;\">Organisms (Total: "+totalOrganismGroups+", #seqs: "+totalOrganismMatches+")</th></tr>\n";	
			chart += "			<tr>\n";
			chart += "				<td align=\"right\">\n";
			//chart += "					<div style=\"background:url(./imagefiles/bg02.gif);\">\n";
			chart += "					<div id=\"orgChart\" style=\" width: 170px; height: 170px; \"></div>\n";
			//chart += "					</div>\n";
			chart += "				</td>\n";
			chart += "				<td width=\"55%\" align=\"left\">\n";	
			chart += "					<table border=0 style=\"font-size: 14px;\">\n";
			topOrgCount = 0;
			topOrgTotal = 0;
			NumberFormat nf = NumberFormat.getInstance();
			nf.setMinimumFractionDigits(1);
			nf.setMaximumFractionDigits(1);
			if(sortedHitOrganismsCount.keySet().size() > 7) {
                                for(String key: sortedHitOrganismsCount.keySet()) {
                                        if(!key.equals("totalOrganismMatches") && !key.equals("totalOrganismGroups")) {
                                                //String orgName = (String) taxonToName.get(key);
						String[] rec = key.split("\\<\\|\\>");
						String orgName = rec[0];
						String orgId = rec[1];
                                                long orgCount = (Long)sortedHitOrganismsCount.get(key);
                                                topOrgCount++;
                                                if(topOrgCount <= totalShow) {
							String countUrl = "peptidewithtaxonid.jsp?initialed=false&start=0&rows=20&keyword="+originalQuery+"&organism_id="+organism_ID+"&total_number="+numberFound+"&taxon_name="+orgName+"&taxon_id="+orgId;
                                                       chart += "					<tr><td style=\"background-color: "+colors[topOrgCount-1]+";\" width=10px>&nbsp;<td nowrap>"+orgName+" [<a href=\""+countUrl+"\">"+orgCount+"</a>, "+nf.format(100.0*orgCount/totalOrganismMatches)+"%]</td></tr>\n";
                                                        //chart += "					<tr><td style=\"background-color: "+colors[topOrgCount-1]+";\" width=10px>&nbsp;<td nowrap>"+orgName+" ["+orgCount+", "+nf.format(100.0*orgCount/totalOrganismMatches)+"%]</td></tr>\n";
                                                        topOrgTotal += orgCount;
                                                }
                                                else {
							int othersCount = (int)totalOrganismMatches - topOrgTotal;
							String othersUrl = "organismlazytableview.jsp?peptide="+originalQuery+"&organism_id="+organism_ID+"&numberfound="+numberFound +"&total_orgs="+sortedHitOrganismsCount.get("totalOrganismGroups");
                                                        chart += "					<tr><td style=\"background-color: "+colors[topOrgCount-1]+";\" width=10px>&nbsp;<td nowrap><a href=\""+othersUrl+"\">Others</a> ["+ othersCount+", "+nf.format(100.0*othersCount/totalOrganismMatches)+"%]</td></tr>\n";
                                                        break;
                                                }
                                        }
                                }
                       }
                       else {
                                for(String key: sortedHitOrganismsCount.keySet()) {
                                        if(!key.equals("totalOrganismMatches") && !key.equals("totalOrganismGroups")) {
                                                //String orgName = (String) taxonToName.get(key);
						String[] rec = key.split("\\<\\|\\>");
						String orgName = rec[0];
						String orgId = rec[1];
                                                long orgCount = (Long)sortedHitOrganismsCount.get(key);
                                                topOrgCount++;
						String countUrl = "peptidewithtaxonid.jsp?initialed=false&start=0&rows=20&keyword="+originalQuery+"&organism_id="+organism_ID+"&total_number="+numberFound+"&taxon_name="+orgName+"&taxon_id="+orgId;
                                                //chart += "					<tr><td style=\"background-color: "+colors[topOrgCount-1]+";\" width=10px>&nbsp;<td nowrap>"+orgName +" ["+orgCount+", "+100*orgCount/totalOrganismMatches+"%]</td></tr>\n";
                                                chart += "					<tr><td style=\"background-color: "+colors[topOrgCount-1]+";\" width=10px>&nbsp;<td nowrap>"+orgName +" [<a href=\""+countUrl+"\">"+orgCount+"</a>, "+100*orgCount/totalOrganismMatches+"%]</td></tr>\n";
                                        }
                                }
                        }
			chart += "					</table>\n";	
			chart += "				</td>\n";	
			chart += "			</tr>\n";	
			chart += "		</table>\n";	
			chart += "		</td>\n";
			

			chart += "              <td width=\"50%\" align=\"left\">\n";
                        chart += "              <table border=0 width=\"100%\" align=\"right\">\n";
                        chart += "                      <tr><th align=center colspan=\"2\" style=\"font-size: small;\">Taxonomy Groups (Total: "+totalTaxonGroups+", #seqs: "+totalTaxonGroupMatches+")</th></tr>\n";
                        chart += "                      <tr>\n";
                        chart += "                              <td align=\"right\">\n";
                        chart += "                                      <div id=\"taxonGroupChart\" style=\" width: 170px; height: 170px;\"></div>\n";
                        chart += "                              </td>\n";
                        chart += "                              <td width=\"55%\" align=\"left\">\n";
                        chart += "                                      <table border=0 style=\"font-size: 14px;\">\n";
                        topTaxonGroupCount = 0;
                        topTaxonGroupTotal = 0;
                        if(sortedHitTaxonGroupsCount.keySet().size() > 7) {
                                for(String key: sortedHitTaxonGroupsCount.keySet()) {
                                        if(!key.equals("totalTaxonGroupMatches") && !key.equals("totalTaxonGroups")) {
						String[] rec = key.split("\\<\\|\\>");
                                                String taxonGroupId =  rec[1];
                                                String taxonGroupName = rec[0];
                                                long taxonGroupCount = (Long)sortedHitTaxonGroupsCount.get(key);
                                                topTaxonGroupCount++;
                                                if(topTaxonGroupCount <= totalShow) {
							String countUrl = "peptidewithtaxongroup.jsp?initialed=false&start=0&rows=20&keyword="+originalQuery+"&organism_id="+organism_ID+"&total_number="+numberFound+"&group_name="+taxonGroupName+"&taxongroup_id="+taxonGroupId;	
                                                        chart += "                                      <tr><td style=\"background-color: "+colors[topTaxonGroupCount-1]+";\" width=10px>&nbsp;<td nowrap>"+taxonGroupName+" [<a href=\""+countUrl+"\">"+taxonGroupCount+"</a>, "+nf.format(100.0*taxonGroupCount/totalTaxonGroupMatches)+"%]</td></tr>\n";
                                                        topTaxonGroupTotal += taxonGroupCount;
                                                }
                                                else {
							String othersUrl = "taxongroup.jsp?peptide="+originalQuery+"&organism_id="+organism_ID+"&numberfound="+numberFound;
                                                        int othersCount = (int)totalTaxonGroupMatches - topTaxonGroupTotal;
                                                        chart += "                                      <tr><td style=\"background-color: "+colors[topTaxonGroupCount-1]+";\" width=10px>&nbsp;<td nowrap><a href=\""+othersUrl+"\">Others</a> ["+ othersCount+", "+nf.format(100.0*othersCount/totalTaxonGroupMatches)+"%]</td></tr>\n";
                                                        break;
                                                }
                                        }
                                }
                       }
                       else {
                                for(String key: sortedHitTaxonGroupsCount.keySet()) {
                                        if(!key.equals("totalTaxonGroupMatches") && !key.equals("totalTaxonGroups")) {
						String[] rec = key.split("\\<\\|\\>");
                                                String taxonGroupId =  rec[1];
                                                String taxonGroupName = rec[0];
                                                long taxonGroupCount = (Long)sortedHitTaxonGroupsCount.get(key);
                                                topTaxonGroupCount++;
						String countUrl = "peptidewithtaxongroup.jsp?initialed=false&start=0&rows=20&keyword="+originalQuery+"&organism_id="+organism_ID+"&total_number="+numberFound+"&group_name="+taxonGroupName+"&taxongroup_id="+taxonGroupId;	
                                                chart += "                                      <tr><td style=\"background-color: "+colors[topTaxonGroupCount-1]+";\" width=10px>&nbsp;<td nowrap>"+taxonGroupName+" [<a href=\""+countUrl+"\">"+taxonGroupCount+"</a>, "+nf.format(100.0*taxonGroupCount/totalTaxonGroupMatches)+"%]</td></tr>\n";
                                               // chart += "                                      <tr><td style=\"background-color: "+colors[topTaxonGroupCount-1]+";\" width=10px>&nbsp;<td nowrap>"+taxonGroupName +" ["+taxonGroupCount+", "+100*taxonGroupCount/totalTaxonGroupMatches+"%]</td></tr>\n";
                                        }
                                }
                        }
                        chart += "                                      </table>\n";
                        chart += "                              </td>\n";      
                        chart += "                      </tr>\n";
                        chart += "              </table>\n";
                        chart += "              </td>\n"; 	
			chart += "	</tr>\n";	
			chart += "</table\n";	
			
		return chart;	
	}
%>
