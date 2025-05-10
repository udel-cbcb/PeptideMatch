<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="query.PeptidePhraseQuery" %>
<html>
<head>
<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">


<TITLE>Peptide Match [PIR - Protein Information Resource]</TITLE>
<style type="text/css">
body.main{
background-image:url('http://pir.georgetown.edu/pirwww/images/temp/bg02.gif');
background-color:#cccccc;
margin-left:0;
margin-top:0;
margin-right:0;
margin-bottom:0;
width:100%;
height:100%;
}
table.result {
border-collapse: collapse;
width: 100%;
table-layout: fixed;
text-align:left;
font-size:12px;
margin-left:1px;
margin-right:1px;
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
}
table.result, table.result thead tr .header, table.result tbody td{
	border: 2px solid black;
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
td.tablecontent {
font-size:12px;
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
	vertical-align: center;
	word-wrap: break-word;
}

table.result thead tr .headerSortUp {
	background-image: url("./imagefiles/asc.gif");
}
table.result thead tr .headerSortDown {
	background-image: url("./imagefiles/desc.gif");
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
width:1024px;
}
.menulink{
margin-left:8px;
}
</style>
</head>
<body class="main">

<MAP NAME="PIRBanner_Map">
<AREA SHAPE="rect" alt="home" COORDS="16,16,110,60" HREF="http://pir.georgetown.edu/pirwww/index.shtml" TARGET="_top">
<AREA SHAPE="rect" alt="uniprot" COORDS="140,36,178,50" HREF="http://www.uniprot.org/" TARGET="_blank">
</MAP>	

<table cellspacing="0" cellpadding="0" width="100%" border="0" height="80">
    <tbody><tr> 
      <td><img alt="" src="./imagefiles/PIRBanner.png" border="0" usemap="#PIRBanner_Map"></td> 
      <td width="99%" nowrap="" height="1" background="./imagefiles/blueSpacer.png">
		<img alt="" src="./imagefiles/spacer.gif" width="1" height="1" border="0">
	  </td>
      <td align="right" valign="top" height="80" width="400" background="./imagefiles/gradientHome6.png">
         <table border="0" cellpadding="0" cellspacing="0" width="400" height="80">
          <form action="http://pir.georgetown.edu/cgi-bin/textsearch.pl" id="textSearch" method="get" name="textSearchForm" style="MARGIN: 0px"></form>
            <tbody><tr>
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
        </tbody></table>
      </td>
    </tr>
</tbody>
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

<TABLE BORDER=0 cellpadding=0 cellspacing=0 width=100%> 
<tr>
<td>
<form id=inputform action=showpeptidewithid.jsp method=get name="searchform" onSubmit="return InputCheck(this)">
Query peptide:&nbsp;&nbsp;<input type=text name="keyword" id="keyword" onfocus="if(!this._haschanged){this.value=''};this._haschanged=true;" value=<%if(request.getParameter("keyword")!=null)out.print(request.getParameter("keyword").toUpperCase()); %> > 
<input type="hidden"name="start" value=0> 
<input type="hidden" name="initialed" value="false"> 
<input type="hidden" name="searchtype" value="id">
<input type="hidden" name="rows" value="20">
<input type=submit value="Submit">
<input type="reset"  value="Reset" >
</form>
</td>
</tr>
</TABLE>

<% 

//if open the page directly,don't show the result table
if(request.getParameter("initialed")!=null){
String originalQuery="";	
int start=0;
int rowsPerPage=20;
originalQuery = request.getParameter("keyword").trim().toUpperCase();
start = Integer.parseInt(request.getParameter("start"));
rowsPerPage = Integer.parseInt(request.getParameter("rows"));
String searchType=request.getParameter("searchtype");

//initial the solr connection
PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
SolrDocumentList docs = new SolrDocumentList();
int numberFound = 0;
peptideQuery.queryByID(originalQuery);
docs=peptideQuery.getCurrentDocs();
//store the id sets of protein sequences which are matched the keyword
//return how many protein sequence 
session.setAttribute("currentdocs", docs);
session.setAttribute("currentquery", originalQuery);
numberFound = peptideQuery.getResult();	
	
if (numberFound > 0) {			
	%>
	<table  class="headline" width="100%" border="0" cellpadding="0" cellpadding="0">
	<tbody>
	<tr>
	<td>
	</td>
	<td id="peptide">
	</td>
	</tr>
	<tr>
	<td id=headresult>
	<%=numberFound%> Proteins Matched&nbsp;|&nbsp;Page <%=start/rowsPerPage+1 %> of <%=(numberFound-1)/rowsPerPage+1 %>&nbsp;(<%=rowsPerPage%> Rows/Page)
	</td>
	<td align=right>
	<table border="0" cellpadding="0" cellspacing="0">
			  <tbody><tr>
				<td align="right"><img alt="save" src="./imagefiles/save_as.png"></td>
				<td class="nrm02" width="4" align="center">&nbsp;</td>
				<td align="center"><a href=<% out.print("./"+response.encodeUrl("SaveData")+"?filetype=tab&query="+originalQuery+"&start="+start); %>><input type="image" src="./imagefiles/save_fxn_tbl.jpg"></td></a></td>
				<td class="nrm02" width="4" align="center">|</td>
				<td align="center"><a href=<% out.print("./"+response.encodeUrl("SaveData")+"?filetype=fasta&query="+originalQuery+"&start="+start); %>><input alt="save FASTA" type="image" name="save_fasta" src="./imagefiles/save_fxn_fasta.jpg"></a></td>
				<td><img alt="" src="./imagefiles/transparent_dot.png" border="0" height="2" width="50"></td>
			  </tr>  
	</tbody></table>
	</td>
	</tr>
	</tbody>
	</table>
	
	<table class="result" id="sortedresulttable">
	<thead>
	<tr>
		<!--
		<th width=15% ><b>Protein AC/ID</b></th>
		<th width=28% ><b>Protein Name</b></th>
		<th width=7% ><b>Length</b></th>
		<th width=25%><b>Description</b></th>
		<th width=10%><b>PIRSF ID</b></th>
		<th width=15%><b>Match Range</b></th>	
		-->
		<th width=15%><b>Protein AC/ID</b></th>
<th width=25% ><b>Protein Name</b></th>
<th width=5% ><b>Length</b></th>
<th width=25%><b>Organism</b></th>
<th width=8%><b>Proteomic Databases</b></th>
<th width=18%><b>Match Range</b></th>

		</tr>
		</thead>
	<tbody>
<%		
	Iterator<SolrDocument> docItr = docs.iterator();
	while (docItr.hasNext()) {
	SolrDocument doc = docItr.next();
	String id=(String)doc.getFieldValue("id");
	String description=(String)doc.getFieldValue("description");				
	String sequence=(String)doc.getFieldValue("sequence");	
	String[] features=description.trim().split("\\^\\|\\^");
	String proteinID="";
	String proteinName="";
	String pirsfID="";
	String organism="";
	String organismID="";
	String nist = "";
        String nistStr = "";
        String pride = "";
        String peptideLibrary = "";
	if(features.length>=7){
		proteinID=features[0];
		proteinName=features[2];
		pirsfID=features[3];
		organism=features[5];
		organismID=features[6];
		nistStr = features[9];
                if(nistStr.length() > 0) {
                        String[] nistRec = nistStr.split(" ");
                        nist =  "<a href=\"http://peptide.nist.gov/browser/proteins.php?description=IT&organism="+nistRec[0]+"&ProteinAccessionNum="+id+"\">NIST</a>";
                        // (Coverage: "+nistRec[1]+"%, Total # peptides: "+nistRec[2]+", # tryptic peptides: "+nistRec[3]+")";
                        peptideLibrary += nist+", ";
                }
                pride = features[10];
                if(pride.length() > 0) {
                        pride = "<a href=\"http://www.ebi.ac.uk/pride/searchSummary.do?queryTypeSelected=identification%20accession%20number&identificationAccessionNumber="+pride+"\">PRIDE</a>";
                        peptideLibrary += pride+", ";
                }
                if(peptideLibrary.indexOf(", ") > 0) {
                        peptideLibrary = peptideLibrary.substring(0, peptideLibrary.length() - 2);
                        //peptideLibrary = peptideLibrary.replaceAll(", ", "<br/>");
                }

	}
	String[] pirsfIDs=pirsfID.split(";");
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
	<td class="tablecontent">
	<% out.println(id+"/"+proteinID); %><br>
	<a href="http://pir.georgetown.edu/cgi-bin/ipcEntry?id=<%=id%>"><img src="./imagefiles/ipc_icon.png" border="0"></a>
	<a href="http://www.uniprot.org/uniprot/<%=id%>"><img src="./imagefiles/<%=uniprotIcon%>" border="0"></a>
	</td>
	<td class="tablecontent"><%=proteinName%><br>
	<a href='http://pir.georgetown.edu/cgi-bin/biothesaurus.pl?id=<%=id%>'><img src="./imagefiles/biot_icon2.png" border="0"> </a>					  		
	</td>  
	<td class="tablecontent"><%=sequence.length()%></td>
	<td class="tablecontent"><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id=<%=organismID%>'><%=description%></a></td> 
	<td class="tablecontent"><%=peptideLibrary%>
<%
	<!--
	for(int i=0;i<pirsfIDs.length;i++){
	if(!pirsfIDs[i].equals(""))
	out.println("<a href='http://pir.georgetown.edu/cgi-bin/ipcSF?id="+pirsfIDs[i]+"'>"+"PIR"+pirsfIDs[i]+"</a><br>");
	}
	-->
%>
	</td> 
	<td class="tablecontent" id="sequencefragment">
<%
out.println(sequence);
 %>
</td>
</tr>
<% } %>
</tbody>
	</table>	
<%	
//if the number sequences returned is greater than rows per page , need to paging
if (numberFound > rowsPerPage) {
	if( start/ rowsPerPage >6){
		out.print("<a href='./peptidewithorganism.jsp"
				+"?searchtype=peptide&initialed=true&keyword="
				+ originalQuery
				+ "&start=0"
				+ "&rows="
				+ rowsPerPage
				+ "&numberfound="
				+ numberFound
				+ "'>"
				+ "<<" + "</a>" + " ");	
				}
//	if the page is not at the first page, then produce a previous action	
	if(start>0){
		out.print("<a href='./peptidewithorganism.jsp"
				+"?searchtype=peptide&initialed=true&keyword="
				+ originalQuery
				+ "&start="
				+ (start-rowsPerPage)
				+ "&rows="
				+ rowsPerPage
				+ "&numberfound="
				+ numberFound
				+ "'>"
				+ "[Previous]" + "</a>" + " ");	
				}
//if the page is at the first 6 page, 
			if (start / rowsPerPage < 6) {
				//10 pages are showed at a time,if the paging is less then 10 pages, break at the result page	
				for (int i = 1; i <= 10; i++) {
					if ((i - 1) * rowsPerPage > (numberFound-1))break;
					if (i == start / rowsPerPage + 1)
						out.print("<a href='./peptidewithorganism.jsp"
						+"?searchtype=peptide&initialed=true&keyword="
								+ originalQuery
								+ "&start="
								+ (i - 1)*rowsPerPage
								+ "&rows="
								+ rowsPerPage
								+ "&numberfound="
								+ numberFound
								+ "'>"
								+ "<b>["
								+ i
								+ "]</b>" + "</a>" + " ");
					else{
						out.print("<a href='./peptidewithorganism.jsp"
								+"?searchtype=peptide&initialed=true&keyword="
								+ originalQuery
								+ "&start="
								+ (i - 1)*rowsPerPage
								+ "&rows="
								+ rowsPerPage
								+ "&numberfound="
								+ numberFound
								+ "'>"
								+ "["
								+ i
								+ "]" + "</a>" + " ");			
						}
				}
	//if the page is at more then 6, then produce the previous 4 page link and the next 5 page link, if the next 5 page is more than the total  
			} else {
				for (int i = (start / rowsPerPage - 4); i <= (start/rowsPerPage + 5); i++) {
					if ((i - 1) * rowsPerPage > (numberFound-1))
						break;
					if (i == start / rowsPerPage + 1)
						out.print("<a href='./peptidewithorganism.jsp"
								+"?searchtype=peptide&initialed=true&keyword="
								+ originalQuery
								+ "&start="
								+ (i - 1)*rowsPerPage
								+ "&rows="
								+ rowsPerPage
								+ "&numberfound="
								+ numberFound
								+ "'>"
								+ "<b>["
								+ i
								+ "]</b>" + "</a>" + " ");
					else
						out.print("<a href='./peptidewithorganism.jsp"
								+"?searchtype=peptide&initialed=true&keyword="
								+ originalQuery
								+ "&start="
								+ (i - 1)*rowsPerPage
								+ "&rows="
								+ rowsPerPage
								+ "&numberfound="
								+ numberFound
								+ "'>"
								+ "["
								+ i
								+ "]" + "</a>" + " ");
				}
			}
			
			if((start+rowsPerPage)<numberFound){
				out.print("<a href='./peptidewithorganism.jsp"
						+"?searchtype=peptide&initialed=true&keyword="
						+ originalQuery
						+ "&start="
						+ (start+rowsPerPage)
						+ "&rows="
						+ rowsPerPage
						+ "&numberfound="
						+ numberFound
						+ "'>"
						+ "[NEXT]" + "</a>" + " ");	
			}
			
			//if the page is more then 10 page then produce the fast paging
			if((numberFound-1)/rowsPerPage+1>10){
				//if the page is at the first 6 paging, then produce the fast paging
				//or the page is at the 5 page before, also produce the page
				if(start/rowsPerPage<((numberFound-1)/rowsPerPage-4)||start / rowsPerPage < 6)
				out.print("<a href='./peptidewithorganism.jsp"
						+"?searchtype=peptide&initialed=true&keyword="
						+ originalQuery
						+ "&start="
						+ ( (numberFound-1) / rowsPerPage) * rowsPerPage
						+ "&rows="
						+ rowsPerPage
						+ "&numberfound="
						+ numberFound
						+ "'>"
						+ ">>" + "</a>" + " ");				
			}
			
		}
else out.println("<b>[1]</b>");
}
    else {
	%>
	<p>0 result returned</p>
<% } 
}

%>
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
              <td colspan="2" align="center" nowrap="" class="footer3"><span class="nrm10"><font color="#999999"> ©2009</font>
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
<!-- Menu Related -->
<script language="javascript" src="./imagefiles/milonic_src.js" type="text/javascript"></script>
<script language="javascript">
  if(ns4) _d.write("<scr"+"ipt language=JavaScript src=./imagefiles/mmenuns4.js><\/scr"+"ipt>");		
    else _d.write("<scr"+"ipt language=JavaScript src=./imagefiles/mmenudom.js><\/scr"+"ipt>"); 
</script><script language="JavaScript" src="./imagefiles/mmenudom.js"></script><script>function getflta(ap){return _f}</script>
<script language="javascript" src="./imagefiles/menu_data.js" type="text/javascript"></script><div class="mmenu" onmouseout="startClose()" onmouseover="stopClose()" onselectstart="return" _f="" id="menu0" style="padding: 0px; background-color: rgb(255, 255, 255); position: absolute; top: 80px; left: 94px; z-index: 999; visibility: visible; width: 685px; height: 21px; background-position: initial initial; background-repeat: initial initial; "><a name="mM1" id="mmlink0" onclick="return clickAction(this._itemRef)" onmouseout="_mot=setTimeout(&#39;_mOUt(this._itemRef)&#39;,99)" onmouseover="return changeStatus(this._itemRef)" style="line-height: normal; background-color: transparent; text-decoration: none; overflow: hidden; position: absolute; z-index: 1; width: 137px; height: 21px; top: 0px; left: 274px; visibility: hidden; background-position: initial initial; background-repeat: initial initial; " title="" target="" href="http://pir.georgetown.edu/pirwww/search/"></a><table class="milonictable" border="0" cellpadding="0" cellspacing="0" style="padding:0px" id="tbl0"><tbody><tr><td width="1" id="el0" onmouseover="_popi(0)" style="padding: 0px; background-color: rgb(255, 255, 255); background-position: initial initial; background-repeat: initial initial; "><table class="milonictable" border="0" cellpadding="0" cellspacing="0" style="padding:0px" height="100%" width="100%" id="MTbl0"><tbody><tr id="td0"><td><img onload="imgfix(0)" style="display:block" id="img0" src="./imagefiles/b_about_off.png"></td></tr></tbody></table></td><td width="1" id="el1" onmouseover="_popi(1)" style="padding: 0px; background-color: rgb(255, 255, 255); background-position: initial initial; background-repeat: initial initial; "><table class="milonictable" border="0" cellpadding="0" cellspacing="0" style="padding:0px" height="100%" width="100%" id="MTbl1"><tbody><tr id="td1"><td><img onload="imgfix(0)" style="display:block" id="img1" src="./imagefiles/b_databases_off.png"></td></tr></tbody></table></td><td width="1" id="el2" onmouseover="_popi(2)" style="padding: 0px; background-color: rgb(255, 255, 255); background-position: initial initial; background-repeat: initial initial; "><table class="milonictable" border="0" cellpadding="0" cellspacing="0" style="padding:0px" height="100%" width="100%" id="MTbl2"><tbody><tr id="td2"><td><img onload="imgfix(0)" style="display:block" id="img2" src="./imagefiles/b_search_analy_off.png"></td></tr></tbody></table></td><td width="1" id="el3" onmouseover="_popi(3)" style="padding:0px;background:#ffffff;;"><table class="milonictable" border="0" cellpadding="0" cellspacing="0" style="padding:0px" height="100%" width="100%" id="MTbl3"><tbody><tr id="td3"><td><img onload="imgfix(0)" style="display:block" id="img3" src="./imagefiles/b_download_off.png"></td></tr></tbody></table></td><td width="1" id="el4" onmouseover="_popi(4)" style="padding:0px;background:#ffffff;;"><table class="milonictable" border="0" cellpadding="0" cellspacing="0" style="padding:0px" height="100%" width="100%" id="MTbl4"><tbody><tr id="td4"><td><img onload="imgfix(0)" style="display:block" id="img4" src="./imagefiles/b_support_off.png"></td></tr></tbody></table></td></tr></tbody></table></div><div class="mmenu" onmouseout="startClose()" onmouseover="stopClose()" onselectstart="return" _f="" id="menu1" style="padding: 0px; background-color: rgb(255, 255, 255); border: 1px solid rgb(41, 100, 136); position: absolute; top: 101px; left: 94px; width: 170px; height: 215px; z-index: 1000; visibility: hidden; background-position: initial initial; background-repeat: initial initial; "><a name="mM1" id="mmlink1" onclick="return clickAction(this._itemRef)" onmouseout="_mot=setTimeout(&#39;_mOUt(this._itemRef)&#39;,99)" onmouseover="return changeStatus(this._itemRef)" style="line-height: normal; background-color: transparent; text-decoration: none; overflow: hidden; position: absolute; z-index: 1; width: 170px; height: 23px; top: -1px; left: -1px; visibility: hidden; background-position: initial initial; background-repeat: initial initial; " title="" target="" href="http://pir.georgetown.edu/pirwww/about/aboutpir.shtml"></a><table class="milonictable" border="0" cellpadding="0" cellspacing="0" style="padding:0px" id="tbl1"><tbody><tr id="pTR5"><td nowrap="" tabindex="5" id="el5" onmouseover="_popi(5)" style="padding: 5px; background-color: rgb(255, 255, 255); background-position: initial initial; background-repeat: initial initial; "><a name="mM1" href="http://pir.georgetown.edu/pirwww/about/aboutpir.shtml" id="lnk5" style="background-color: transparent; display: block; font-family: Verdana, Tahoma, Arial; font-weight: bold; font-style: normal; font-size: 11px; text-decoration: none; color: rgb(0, 51, 102); background-position: initial initial; background-repeat: initial initial; ">History</a></td></tr><tr><td style="padding:0px;" id="sep5" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR6"><td nowrap="" tabindex="6" id="el6" onmouseover="_popi(6)" style="padding: 5px; background-color: rgb(255, 255, 255); background-position: initial initial; background-repeat: initial initial; "><a name="mM1" href="http://pir.georgetown.edu/pirwww/about/brochure.pdf" id="lnk6" style="background-color: transparent; display: block; font-family: Verdana, Tahoma, Arial; font-weight: bold; font-style: normal; font-size: 11px; text-decoration: none; color: rgb(0, 51, 102); background-position: initial initial; background-repeat: initial initial; ">PIR Brochure</a></td></tr><tr><td style="padding:0px;" id="sep6" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR7"><td nowrap="" tabindex="7" id="el7" onmouseover="_popi(7)" style="padding: 5px; background-color: rgb(255, 255, 255); background-position: initial initial; background-repeat: initial initial; "><a name="mM1" href="http://pir.georgetown.edu/pirwww/about/sponsor.shtml" id="lnk7" style="background-color: transparent; display: block; font-family: Verdana, Tahoma, Arial; font-weight: bold; font-style: normal; font-size: 11px; text-decoration: none; color: rgb(0, 51, 102); background-position: initial initial; background-repeat: initial initial; ">Funding &amp; Sponsors</a></td></tr><tr><td style="padding:0px;" id="sep7" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR8"><td nowrap="" tabindex="8" id="el8" onmouseover="_popi(8)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/about/publication.shtml" id="lnk8" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Publications</a></td></tr><tr><td style="padding:0px;" id="sep8" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR9"><td nowrap="" tabindex="9" id="el9" onmouseover="_popi(9)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/about/presentations.shtml" id="lnk9" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Presentations/Abstracts</a></td></tr><tr><td style="padding:0px;" id="sep9" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR10"><td nowrap="" tabindex="10" id="el10" onmouseover="_popi(10)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/about/staff.shtml" id="lnk10" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Staff</a></td></tr><tr><td style="padding:0px;" id="sep10" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR11"><td nowrap="" tabindex="11" id="el11" onmouseover="_popi(11)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/about/linkpir.shtml" id="lnk11" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Use/Link to PIR</a></td></tr><tr><td style="padding:0px;" id="sep11" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR12"><td nowrap="" tabindex="12" id="el12" onmouseover="_popi(12)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/about/employment.shtml" id="lnk12" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Employment</a></td></tr><tr><td style="padding:0px;" id="sep12" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR13"><td nowrap="" tabindex="13" id="el13" onmouseover="_popi(13)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/support/contact.shtml" id="lnk13" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Contact</a></td></tr></tbody></table></div><div class="mmenu" onmouseout="startClose()" onmouseover="stopClose()" onselectstart="return" _f="" id="menu2" style="padding: 0px; background-color: rgb(255, 255, 255); border: 1px solid rgb(41, 100, 136); position: absolute; top: 101px; left: 231px; width: 122px; height: 119px; z-index: 1000; visibility: hidden; background-position: initial initial; background-repeat: initial initial; "><a name="mM1" id="mmlink2" href="http://pir.georgetown.edu/pirwww/search/peptide.shtml#" onclick="return clickAction(this._itemRef)" onmouseout="_mot=setTimeout(&#39;_mOUt(this._itemRef)&#39;,99)" onmouseover="return changeStatus(this._itemRef)" style="line-height: normal; background-color: transparent; text-decoration: none; height: 1px; width: 1px; overflow: hidden; position: absolute; visibility: hidden; background-position: initial initial; background-repeat: initial initial; "></a><table class="milonictable" border="0" cellpadding="0" cellspacing="0" style="padding:0px" id="tbl2"><tbody><tr id="pTR14"><td nowrap="" tabindex="14" id="el14" onmouseover="_popi(14)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/dbinfo/iproclass.shtml" id="lnk14" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;"><font color="red"><i>i</i></font>ProClass</a></td></tr><tr><td style="padding:0px;" id="sep14" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR15"><td nowrap="" tabindex="15" id="el15" onmouseover="_popi(15)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/dbinfo/pirsf.shtml" id="lnk15" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">PIRSF</a></td></tr><tr><td style="padding:0px;" id="sep15" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR16"><td nowrap="" tabindex="16" id="el16" onmouseover="_popi(16)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/dbinfo/pir_psd.shtml" id="lnk16" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">PIR-PSD</a></td></tr><tr><td style="padding:0px;" id="sep16" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR17"><td nowrap="" tabindex="17" id="el17" onmouseover="_popi(17)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/dbinfo/nref.shtml" id="lnk17" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">PIR-NREF</a></td></tr><tr><td style="padding:0px;" id="sep17" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR18"><td nowrap="" tabindex="18" id="el18" onmouseover="_popi(18)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/dbinfo/uniprot.shtml" id="lnk18" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">UniProt&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td></tr></tbody></table></div><div class="mmenu" onmouseout="startClose()" onmouseover="stopClose()" onselectstart="return" _f="" id="menu3" style="padding: 0px; background-color: rgb(255, 255, 255); border: 1px solid rgb(41, 100, 136); position: absolute; top: 101px; left: 368px; width: 169px; height: 287px; z-index: 1001; visibility: hidden; background-position: initial initial; background-repeat: initial initial; "><a name="mM1" id="mmlink3" onclick="return clickAction(this._itemRef)" onmouseout="_mot=setTimeout(&#39;_mOUt(this._itemRef)&#39;,99)" onmouseover="return changeStatus(this._itemRef)" style="line-height: normal; background-color: transparent; text-decoration: none; overflow: hidden; position: absolute; z-index: 1; width: 169px; height: 23px; top: -1px; left: -1px; visibility: hidden; background-position: initial initial; background-repeat: initial initial; " href="http://pir.georgetown.edu/pirwww/search/searchtools.shtml" title="" target=""></a><table class="milonictable" border="0" cellpadding="0" cellspacing="0" style="padding:0px" id="tbl3"><tbody><tr id="pTR19"><td nowrap="" tabindex="19" id="el19" onmouseover="_popi(19)" style="padding: 5px; background-color: rgb(255, 255, 255); background-position: initial initial; background-repeat: initial initial; "><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/searchtools.shtml" id="lnk19" style="background-color: transparent; display: block; font-family: Verdana, Tahoma, Arial; font-weight: bold; font-style: normal; font-size: 11px; text-decoration: none; color: rgb(0, 51, 102); background-position: initial initial; background-repeat: initial initial; ">Search &amp; Analysis Tools</a></td></tr><tr><td style="padding:0px;" id="sep19" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR20"><td nowrap="" tabindex="20" id="el20" onmouseover="_popi(20)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/textsearch.shtml" id="lnk20" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Text Search</a></td></tr><tr><td style="padding:0px;" id="sep20" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR21"><td nowrap="" tabindex="21" id="el21" onmouseover="_popi(21)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/batch.shtml" id="lnk21" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Batch Retrieval</a></td></tr><tr><td style="padding:0px;" id="sep21" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR22"><td nowrap="" tabindex="22" id="el22" onmouseover="_popi(22)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/blast.shtml" id="lnk22" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">BLAST Search</a></td></tr><tr><td style="padding:0px;" id="sep22" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR23"><td nowrap="" tabindex="23" id="el23" onmouseover="_popi(23)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/fasta.shtml" id="lnk23" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">FASTA Search</a></td></tr><tr><td style="padding:0px;" id="sep23" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR24"><td nowrap="" tabindex="24" id="el24" onmouseover="_popi(24)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="./imagefiles/Peptide Match [PIR - Protein Information Resource].htm" id="lnk24" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Peptide Match</a></td></tr><tr><td style="padding:0px;" id="sep24" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR25"><td nowrap="" tabindex="25" id="el25" onmouseover="_popi(25)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/pattern.shtml" id="lnk25" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Pattern Search</a></td></tr><tr><td style="padding:0px;" id="sep25" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR26"><td nowrap="" tabindex="26" id="el26" onmouseover="_popi(26)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/pairwise.shtml" id="lnk26" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Pairwise Alignment</a></td></tr><tr><td style="padding:0px;" id="sep26" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR27"><td nowrap="" tabindex="27" id="el27" onmouseover="_popi(27)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/multialn.shtml" id="lnk27" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Multiple Alignment</a></td></tr><tr><td style="padding:0px;" id="sep27" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR28"><td nowrap="" tabindex="28" id="el28" onmouseover="_popi(28)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/idmapping.shtml" id="lnk28" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">ID Mapping</a></td></tr><tr><td style="padding:0px;" id="sep28" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR29"><td nowrap="" tabindex="29" id="el29" onmouseover="_popi(29)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/pirsfscan.shtml" id="lnk29" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">PIRSF Scan</a></td></tr><tr><td style="padding:0px;" id="sep29" align="center"><div style=";background:#E5E5E5;overflow:hidden;width:100%;padding:0px;height:1px;font-size:1px;"></div></td></tr><tr id="pTR30"><td nowrap="" tabindex="30" id="el30" onmouseover="_popi(30)" style=";padding:5px;background:#ffffff;"><a name="mM1" href="http://pir.georgetown.edu/pirwww/search/comp_mw.shtml" id="lnk30" style="null;background:transparent;display:block;color:#003366;font-Family:Verdana, Tahoma, Arial;font-Weight:bold;font-Style:normal;font-Size:11;text-Decoration:none;">Composition/Mol Weight</a></td></tr></tbody></table></div><div class="mmenu" onmouseout="startClose()" onmouseover="stopClose()" onselectstart="return" _f="" id="menu4" style="padding:0px;background:#ffffff;border:1px solid #296488;z-index:499;visibility:hidden;position:absolute;top:-999px;;"><a name="mM1" id="mmlink4" href="http://pir.georgetown.edu/pirwww/search/peptide.shtml#" onclick="return clickAction(this._itemRef)" onmouseout="_mot=setTimeout(&#39;_mOUt(this._itemRef)&#39;,99)" onmouseover="return changeStatus(this._itemRef)" style="line-height:normal;background:transparent;text-decoration:none;height:1px;width:1px;overflow:hidden;position:absolute;"></a></div><div class="mmenu" onmouseout="startClose()" onmouseover="stopClose()" onselectstart="return" _f="" id="menu5" style="padding:0px;background:#ffffff;border:1px solid #296488;z-index:499;visibility:hidden;position:absolute;top:-999px;;"><a name="mM1" id="mmlink5" href="http://pir.georgetown.edu/pirwww/search/peptide.shtml#" onclick="return clickAction(this._itemRef)" onmouseout="_mot=setTimeout(&#39;_mOUt(this._itemRef)&#39;,99)" onmouseover="return changeStatus(this._itemRef)" style="line-height:normal;background:transparent;text-decoration:none;height:1px;width:1px;overflow:hidden;position:absolute;"></a></div>
<script language="JavaScript" src="./imagefiles/tooltips.js" type="text/javascript"></script><div class="mmenu" onmouseout="startClose()" onmouseover="stopClose()" onselectstart="return" _f="" id="menu6" style="padding:0px;background:#ffffa1;border:1px solid #999999;z-index:499;visibility:hidden;position:absolute;top:-999px;;"><a name="mM1" id="mmlink6" href="http://pir.georgetown.edu/pirwww/search/peptide.shtml#" onclick="return clickAction(this._itemRef)" onmouseout="_mot=setTimeout(&#39;_mOUt(this._itemRef)&#39;,99)" onmouseover="return changeStatus(this._itemRef)" style="line-height:normal;background:transparent;text-decoration:none;height:1px;width:1px;overflow:hidden;position:absolute;"></a></div>

<!-- Menu Related ends -->
<script type="text/javascript" src="./imagefiles/jquery-latest.js"></script> 
<script type="text/javascript" src="./imagefiles/jquery.tablesorter.js"></script>
<script type="text/javascript">
function showPeptide(originalQuery)
{
	var content=originalQuery;
 document.getElementById("peptide").innerHTML=content;  
}
function InputCheck(searchform) {
	if (searchform.keyword.value.length < 3) {
	alert("Please input the keyword at least 3 characters");
	searchform.keyword.focus();
	return (false);
	}
	else{
		var keyword=searchform.keyword.value;
		document.searchform.submit();
		}
}
function hiddenpage(searchtype) {
	if (searchtype.value == "peptide") {
	document.getElementById("rows").style.display = "";
	} 
	else {
	document.getElementById("rows").style.display = "none";
		}
	}
function reloadPage(selectoption){
	document.pagingform.submit();
	return document.all[selectoption].value;
}

</script>

<script>
$.tablesorter.addParser({ 
    // set a unique id 
    id: 'starter', 
    is: function(s) { 
        // return false so this parser is not auto detected 
        return false; 
    }, 
    format: function(s) { 
        // format your data for normalization 
        return s.replace(new RegExp(/-([\s\S]*)/),""); 
    }, 
    // set type, either numeric or text 
    type: 'numeric' 
}); 

$(function() { 
    $("table").tablesorter({ 
        headers: { 
            5: { 
                sorter:'starter' 
            } 
        } 
    }); 
});  
</script>
</html>
