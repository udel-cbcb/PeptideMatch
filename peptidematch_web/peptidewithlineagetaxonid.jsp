<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="query.PeptidePhraseQuery" %>

<html>
<head>
<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-39280281-1']);
  _gaq.push(['_trackPageview']);
  _gaq.push(['_trackPageLoadTime']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
<TITLE>Peptide Match [PIR - Protein Information Resource] - match results  for a taxononmy ID</TITLE>
<style type="text/css">
body.main{
background-image:url('./imagefiles/bg02.gif');
background-color:#cccccc;
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
frameBorder=0;
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
<script type="text/javascript" src="./js/jquery_ajax.js"></script>
<script type="text/javascript" src="./js/check_analyze.js"></script>
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

<% 
//if open the page directly,don't show the result table
if(request.getParameter("initialed")!=null &&request.getParameter("keyword")!=null &&request.getParameter("start")!=null &&request.getParameter("rows")!=null &&request.getParameter("organism_id")!=null &&request.getParameter("taxon_id")!=null &&request.getParameter("taxon_name")!=null &&request.getParameter("total_number")!=null
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
	String swissprot ="N";
        String isoform = "N";
        String uniref100Only ="N";
        String ilEquivalent = "N";
        String swissprotValue = "N";
        String isoformValue = "N";
        String uniref100Value = "N";
        String lEqiValue = "N";
        String sortBy = "ac_asc";
	
	String trOnly = "N";
        String trOnlyValue = "N";
        String isoOnly = "N";
        String isoOnlyValue = "N";

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
	//initial the solr connection
PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
SolrDocumentList docs = new SolrDocumentList();
int numberFound = 0;
if(originalQuery.equals("*:*")){
	peptideQuery.queryAll(start,rowsPerPage, swissprot, isoform, uniref100Only, ilEquivalent, trOnly, isoOnly);
}
else{
if(!organism_ID.toLowerCase().equals("all")){
	peptideQuery.queryByPeptideWithFullLineageOrganismAndTaxonId(originalQuery, organism_ID,taxon_id, start, rowsPerPage, op, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
}
else{
	peptideQuery.queryByPeptideWithFullLineageTaxonId(originalQuery, taxon_id, start, rowsPerPage, op, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
}
}
docs = peptideQuery.getCurrentDocs();
//store the id sets of protein sequences which are matched the keyword
//return how many protein sequence 
session.setAttribute("currentdocs", docs);
session.setAttribute("currentquery", originalQuery);
numberFound = peptideQuery.getResult();	
//String spectraSearch = "Search query peptide against <a href=peptidespectra.jsp?peptide="+originalQuery+"&db=gpmdb><b>gpmDB</b></a>, <a href=peptidespectra.jsp?peptide="+originalQuery+"&db=nist><b>NIST Peptide Library</b></a>, <a href=peptidespectra.jsp?peptide="+originalQuery+"&db=peptideatlas><b>PeptideAtlas</b></a>, or <a href=peptidespectra.jsp?peptide="+originalQuery+"&db=all><b>All of them</b></a>";

String spectraSearch  ="<table border=0>\n";
	spectraSearch +="       <tr><td valign=top style=\"white-space: nowrap;\">Search query peptide in <a href=\"docs/userguide.htm#spectra\">proteomic DBs</a>: </td>\n";
       spectraSearch +="            <td valign=top><form name=\"spectrasearchform\" action=\"peptidespectra.jsp\" onSubmit=\"return spectraSearchInputCheck(this)\">\n";
       spectraSearch +="                <select name=\"db\">\n";
       spectraSearch +="                        <option value=\"nist\">NIST Peptide Libraries</option>\n";
       spectraSearch +="                        <option value=\"gpmdb\">gpmDB</option>\n";
       spectraSearch +="                        <option value=\"peptideatlas\">PeptideAtlas</option>\n";
	spectraSearch +="                        <option value=\"pride\">PRIDE</option>\n";
       spectraSearch +="                        <option value=\"all\">All of above</option>\n";
       spectraSearch +="                 </select>\n";
       spectraSearch +="                <td valign=top><input type=\"submit\"</td>\n";
       spectraSearch +="                <input type=\"hidden\" name=\"peptide\" value=\""+originalQuery+"\">\n";
       spectraSearch +="                </form></td>\n";
       spectraSearch +="        </tr>\n";
       spectraSearch +="</table>\n";

%>
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
<br/>
<TABLE  width=100% border=0> 
<tr>
<!--
<td width=35% valign=top style="white-space: nowrap;">
<form id=inputform action=peptidewithorganisms.jsp method=get name="searchform" onSubmit="return InputCheck(this)">
<a title='return to searching page' href=./index.jsp><img src=./imagefiles/restart.png border=0></a>
Query peptide:&nbsp;&nbsp;<input type=text name="keyword" style="width:200px;" id="keyword" onblur="reminder()" onfocus="if(!this._haschanged){this.value=''};this._haschanged=true;" value=<%
        //session.invalidate();
        if(request.getParameter("keyword")!=null) {
                out.print(request.getParameter("keyword").toUpperCase().replaceAll("[^a-zA-Z]", "")); 
        }

%> >
-->
<!--
<td width=60%>
<form id=inputform action=peptidewithorganisms.jsp method=get name="searchform" onSubmit="return InputCheck(this)">
Query peptide:&nbsp;&nbsp;<input type=text name="keyword" id="keyword" onblur="reminder()" onfocus="if(!this._haschanged){this.value=''};this._haschanged=true;" value=<%if(request.getParameter("keyword")!=null)out.print(request.getParameter("keyword").toUpperCase()); %> > 
<input type="hidden"name="start" value=0> 
<input type="hidden" name="initialed" value="false"> 
<input type="hidden" name="organism_id" value="<%if(request.getParameter("organism_id")!=null)out.print(request.getParameter("organism_id"));else out.print("all");%>" >
<input type="hidden" name="swissprot" value="<%=swissprotValue %>" >
<input type="hidden" name="isoform" value="<%=isoformValue %>" >
<input type="hidden" name="uniref100" value="<%=uniref100Value %>" >
<input type="hidden" name="lEqi" value="<%=lEqiValue%>" >
<input type="hidden" name="sortBy" value="<%=sortBy%>" >
<input type="hidden" name="trOnly" value="<%=trOnly%>" >
<input type="hidden" name="isoOnly" value="<%=isoOnly%>" >
<input type="hidden" name="rows" value="20">
<input type=submit value="Submit">
<input type="reset"  value="Reset" >
</form>
</td>
-->
<td align="left" valign=top style="white-space: nowrap;">
<!--
<img alt='' src=./imagefiles/result_z.png border=0>
-->
<%=version%><%
        if(swissprot.equals("Y")) {
                out.print(" | SwissProt only");
        }
        if(isoform.equals("Y")) {
                out.print(" | Include Isoforms");
        }
        if(uniref100Only.equals("Y")) {
                out.print(" | UniRef100 only");
        }
        if(ilEquivalent.equals("Y")) {
                //out.print(" | Leucine (L) and IsoLeucine (I) are equivalent");
                out.print(" | L and I are equivalent");
        }
	out.print("<br/>Query peptide: "+originalQuery.toUpperCase()+"");
%>
<!--
<span style="color: #777777;"><b>Peptide Match Result ( <%
if(request.getParameter("organism_id")!=null){
if(!request.getParameter("organism_id").toLowerCase().equals("all")){
if(request.getParameter("organism_id").toLowerCase().split(";").length==1)
out.print("ToxonID:<a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+request.getParameter("organism_id")+"'>"+request.getParameter("organism_id")+"</a>");
else
out.print("ToxonID:<a href='#' onclick='show_organism_details();'>Multiple organisms</a>");		
}
else out.print("<a href='http://www.uniprot.org/help/uniprotkb'>UniProtKB</a>");
}
else out.print("<a href='http://www.uniprot.org/help/uniprotkb'>UniProtKB</a>");

if(request.getParameter("taxon_name")!=null&&request.getParameter("taxon_name")!="")
	out.print(" & Organism:<a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+request.getParameter("taxon_id")+"'/>"+request.getParameter("taxon_name")+"</a>");	
else if(request.getParameter("taxon_id")!=null)
	out.print(" & Organism:<a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+request.getParameter("taxon_id")+"'/>"+request.getParameter("taxon_id")+"</a>");
else out.print(" & TaxonId:null");
			%>)
</b>

</span>
<td width=5% style="white-space: nowrap;">&nbsp;</td>
-->
</td>
<td width=5% style="white-space: nowrap;">&nbsp;</td>
<!--
<td width=25% align=right style="white-space: nowrap;" valign=top>
        <%=spectraSearch%>
</td>
-->
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
	<table  class="headline" width="100%" border="0" cellpadding="0" cellpadding="0">
	<tbody>
	<tr>
	<td id=headresult>
	<br/>
        <span style="font-size: 14px;"><%=numberFound%> Proteins Matched&nbsp;|&nbsp;Page <%=start/rowsPerPage+1 %> of <%=(numberFound-1)/rowsPerPage+1 %>&nbsp;(<%=rowsPerPage%> Rows/Page)

	</td>
	<td align=right>
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
<table cellspacing="0" cellpadding="0" border="1"><tbody><tr><td>
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
<td nowrap="">
<!--
<input type="image" name="blast" src="./imagefiles/blast.png" onclick="return verifyNums('blast','<%=organism_ID%>')">
<input type="image" name="fasta" src="./imagefiles/fasta.png" onclick="return verifyNums('fasta','<%=organism_ID%>' )">
<input type="image" name="pat" src="./imagefiles/pat.png" onclick="return verifyNums('pat','<%=organism_ID%>')">
-->
<input type="image" name="maln" src="./imagefiles/maln.png" onclick="return verifyNums('maln','<%=organism_ID%>')">
<input type="image" name="dom" src="./imagefiles/dom.png" onclick="return verifyNums('dom','<%=organism_ID%>')"></td>
<td><img src="./imagefiles/transparent_dot.png" border="0" height="2" width="32"></td>
<td>
<table border="0" cellpadding="0" cellspacing="0">
				<tbody><tr>
					<td align="right"><img alt="save" src="./imagefiles/save_as.png"></td>
					<td class="nrm02" width="4" align="center">&nbsp;</td>
					<td align="center"><input type="image" alt="save as Table" onclick="return save_data('tab','<%=originalQuery%>','<%=ilEquivalent%>');" name="save_tab" src="./imagefiles/save_fxn_tbl.jpg"></td></td>
					<td class="nrm02" width="4" align="center">|</td>
					<td align="center"><input alt="save as FASTA" onclick="return save_data('fasta','<%=originalQuery%>','<%=ilEquivalent%>');" type="image" name="save_fasta" src="./imagefiles/save_fxn_fasta.jpg"></td>
					<td><img alt="" src="./imagefiles/transparent_dot.png" border="0" height="2" w
idth="50"></td>
					</tr>  
				</tbody></table>
</td>
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
<th width=2% ><input type=checkbox id="all_box"  name=all value="all"  onClick="current_sel(mainform,this.value,'<%=organism_ID%>','<%=originalQuery%>','<%=ilEquivalent%>');"></th>
<% if(uniref100Only.equals("N")){
%>
<th width=11% id="ac_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Protein AC</b></th>
<th width=9%  id="proteinID_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Protein ID</b></th>
<th width=15% id ="proteinName_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)" ><b>Protein Name</b></th>
<th width=5%  id="length_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)" ><b>Length</b></th>
<th width=15% id ="organismName_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Organism</b></th>
<th style="background-color:#C1D0DF"><b>Match Range</b></th>	
<th width=13% id="proteomic_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Protein Links to Proteomic DBs</b></th>
<th width=10% id="iedb_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)" ><b>Immune Epitope DB</b></th>
<%
} 
 else {
%>
<th width=12% id="ac_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>UniRef100 Cluster ID</b></th>
<th width=12% id="ac_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Representative Protein AC</b></th>
<th width=15% id ="proteinName_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)" ><b>Protein Name</b></th>
<th width=6%  id="length_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)" ><b>Length</b></th>
<th width=15% id ="organismName_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Organism</b></th>
<th style="background-color:#C1D0DF"><b>Match Range</b></th>	
<th width=13% id="proteomic_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Protein Links to Proteomic DBs</b></th>
<th width=11% id="iedb_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)" ><b>Immune Epitope DB</b></th>
<%
}
%>
<!--
<th width=11% id="ac_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Protein AC</b></th>
<th width=9%  id="proteinID_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Protein ID</b></th>
<th width=15% id ="proteinName_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)" ><b>Protein Name</b></th>
<th width=5%  id="length_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)" ><b>Length</b></th>
<th width=15% id ="organismName_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Organism</b></th>
<th style="background-color:#C1D0DF"><b>Match Range</b></th>	
<th width=10% id="proteomic_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)"><b>Proteomic Databases</b></th>
<th width=10% id="iedb_header" class="header" onclick="sortTable('false','<%=originalQuery%>','<%=organism_ID%>','<%=taxon_id%>','<%=taxon_name%>','','','0','20','<%=numberFound%>','<%=swissprotValue%>','<%=isoformValue%>','<%=uniref100Value%>','<%=lEqiValue%>','<%=trOnly%>','<%=isoOnly%>',this.id)" ><b>IEDB</b></th>
-->
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
<input style="display:none" id="current_sortby" value="<%=sortBy%>"></input>
<input style="display:none" id="trOnly" value="<%=trOnly%>"></input>
<input style="display:none" id="isoOnly" value="<%=isoOnly%>"></input>
<input style="display:none" id="constraint" value="withlineage"></input>
<input style="display:none" id="swissprot" value="<%=swissprotValue%>"></input>
<input style="display:none" id="isoform" value="<%=isoformValue%>"></input>
<input style="display:none" id="uniref100" value="<%=uniref100Value%>"></input>
<%	out.println("<script language='javascript'>paging(\"false\",\""+originalQuery+"\",\""+organism_ID+"\",\""+taxon_id+"\",\""+taxon_name+"\",\"\",\"\",\"0\",\"20\",\""+numberFound+"\",\""+swissprotValue+"\",\""+isoformValue+"\",\""+uniref100Value+"\",\""+lEqiValue+"\",\""+sortBy+"\",\""+trOnly+"\",\""+isoOnly+"\");</script>");
}
    else {
	%>
	<p>&nbsp;&nbsp;0 result returned</p>
<% } 
}

%>
</td></tr>
<tr><td>
<span id="div-paging"></span>
</td></tr>
<tr>
<td>
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
              <td colspan="2" align="center" nowrap="" class="footer3"><span class="nrm10"><font color="#999999"> &copy; 2018</font>
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

</td>
</tr>
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
