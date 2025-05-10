<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.io.*"%>
<%@ page import="query.TaxonCount"%>
<%@ page import="query.Tools" %>

<html>
<head>
<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<TITLE>Peptide Match [PIR - Protein Information Resource]</TITLE>
<style type="text/css">
body.main {
	background-image: url('./imagefiles/bg02.gif');
	background-color: #cccccc;
	margin-left: 0;
	margin-top: 0;
	margin-right: 0;
	margin-bottom: 0;
	width: 100%;
	height: 100%;
}

.searchBannerBox {
	font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif;
	font-size: 11px;
	WIDTH: 180px;
	HEIGHT: 18px
}

td.searchLable {
	color: #ffffff;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 10px;
	font-weight: bold
}
font.taxon_titile{
font-size: 13px;
}

table.taxongroup {
	font-size:100%;
	background-color:#ffffff;
	width: 60%;
	table-layout: fixed;
	text-align: left;
	font-size: 12px;
	margin-top: 10px;
	margin-left: 5%;
	margin-right: 1px;
	font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif;
	font-size: 1em;
	text-align: left;	
	color: #000000;
	background-repeat: no-repeat;
	background-position: center right;
}
table.result_table_column{
width: 100%;
}
table.inner_table{
border-collapse:collapse;
width: 95%;
}
table.other_table{
width:47.5%;
border-collapse:collapse;
}
tr.inner_table_tr{
width:50%;
}
td.head {
font-size: 13px;
text-align:center;
font-weight:bold;
}
.lightfont{
color:#736F6E;
}
td.result_td{
vertical-align:top;
width:50%
}
td.content  {
border: 1px solid black;
width:55%;
text-align: left;
font-size: 12px;
}
td.number  {
border: 1px solid black;
width:20%;
text-align: right;
font-size: 12px;
}
td.percentage  {
border: 1px solid black;
text-align: right;
width:25%;
font-size: 11px;
}
</style>
</head>
<body class="main">
	<MAP NAME="PIRBanner_Map">
		<AREA SHAPE="rect" alt="home" COORDS="16,16,110,60"
			HREF="http://pir.georgetown.edu/pirwww/index.shtml" TARGET="_top">
		<AREA SHAPE="rect" alt="uniprot" COORDS="140,36,178,50"
			HREF="http://www.uniprot.org/" TARGET="_blank">
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

	<table cellSpacing=0 cellPadding=0 width=100% bgColor=#333333 border=0>
		<tr>
			<TD><img src='./imagefiles/leftSearch.png'></TD>
			<!-- ############### group dependent-->
			<td class=sml01 width=99% background='./imagefiles/bgcolor.png'>&nbsp;</td>
			<noscript>
				<td>
					<table bgcolor="#4a4a4a" width="100%" height="21" border="0"
						cellspacing="0" cellpadding="0">
						<tr>
							<td class="nrm02" nowrap>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<a href="http://pir.georgetown.edu/pirwww/index.shtml" class="m"><font
									face=verdana size="2pt" color="white">Home</font></a>
								&nbsp;&nbsp;&nbsp;&nbsp; <a
								href="http://pir.georgetown.edu/pirwww/about/" class="m"><font
									face=verdana size="2pt" color="white">About PIR</font></a>&nbsp;&nbsp;&nbsp;&nbsp;
								<a href="http://pir.georgetown.edu/pirwww/dbinfo/" class="m"><font
									face=verdana size="2pt" color="white">Databases</font></a>
								&nbsp;&nbsp;&nbsp;&nbsp; <a
								href="http://pir.georgetown.edu/pirwww/search/" class="m"><font
									face=verdana size="2pt" color="white">Search/Retrieval</font></a>
								&nbsp;&nbsp;&nbsp;&nbsp; <a
								href="http://pir.georgetown.edu/pirwww/search/" class="m"><font
									face=verdana size="2pt" color="white">Download</font></a>
								&nbsp;&nbsp;&nbsp;&nbsp; <a
								href="http://pir.georgetown.edu/pirwww/support/" class="m"><font
									face=verdana size="2pt" color="white">Support</font></a>
							</td>
						</tr>
					</table>
				</td>
			</noscript>
		</tr>
	</table>
<%
if(request.getParameter("organism_id")!=null&&request.getParameter("peptide")!=null&&request.getParameter("taxongroup_id")!=null){
String organism_id=	request.getParameter("organism_id").trim();
String peptide=request.getParameter("peptide").trim();
String taxongroup_id=request.getParameter("taxongroup_id").trim();
HashMap<String,Integer> hm=new HashMap<String,Integer>();
TaxonCount taxonCounter=new TaxonCount();
hm=Tools.sortHashMap(taxonCounter.getDistribution(taxongroup_id,organism_id,peptide));
Iterator it=hm.entrySet().iterator();
while(it.hasNext()){
	Map.Entry pairs=(Map.Entry)it.next();
	out.print("organism_id: "+pairs.getKey()+"organism_count: "+pairs.getValue()+"<br>");
}
}

else{
	out.println("Wrong parameter");
}




%>


	<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#eeeeee"
		border="0" class="nrm02">
		<tbody>
			<tr>
				<td align="center" valign="middle" nowrap="" bgcolor="#71a1cf">
					<img src="./imagefiles/pirlogo2.png" alt="PIR">
				</td>
				<td align="left" valign="top">
					<table background="./imagefiles/spacer.gif" width="686" border="0"
						cellpadding="3" cellspacing="0" class="nrm02">
						<tbody>
							<tr>
								<td align="left" valign="bottom" nowrap="">&nbsp;<a
									href="http://pir.georgetown.edu/pirwww/" target="_blank"
									class="footerMenu">Home</a> |&nbsp;<a
									href="http://pir.georgetown.edu/pirwww/about/" target="_blank"
									class="footerMenu">About PIR</a> |&nbsp;<a
									href="http://pir.georgetown.edu/pirwww/dbinfo" target="_blank"
									class="footerMenu">Databases</a> |&nbsp;<a
									href="http://pir.georgetown.edu/pirwww/search/" target="_blank"
									class="footerMenu">Search/Analysis</a> |&nbsp;<a
									href="http://pir.georgetown.edu/pirwww/download/"
									target="_blank" class="footerMenu">Download</a> |&nbsp;<a
									href="http://pir.georgetown.edu/pirwww/support/"
									target="_blank" class="footerMenu">Support</a>
								</td>
								<td align="right" valign="bottom" nowrap="" class="nrm01">
									&nbsp;<a
									href="http://pir.georgetown.edu/pirwww/support/sitemap.shtml"
									target="_blank" class="footer">SITE MAP</a> |&nbsp;<a
									href="http://pir.georgetown.edu/pirwww/about/linkpir.shtml"
									target="_blank" class="footer">TERMS OF USE</a>
								</td>
							</tr>
							<tr>
								<td colspan="2" align="center" nowrap="" class="footer3"><span
									class="nrm10"><font color="#999999"> ©2009</font> <img
										src="./imagefiles/spacer.gif" alt="" width="20" height="1">
										<b><a href="http://pir.georgetown.edu/pirwww/index.shtml"
											target="_blank">Protein Information Resource</a></b> <img
										src="./imagefiles/spacer.gif" alt="" width="105" height="1"></span></td>
							</tr>
							<tr>
								<td colspan="2" nowrap=""><table border="0" cellpadding="2"
										cellspacing="0" class="nrm02" width="100%">
										<tbody>
											<tr>
												<td><img src="./imagefiles/spacer.gif" alt=""
													width="50" height="1"></td>
												<td nowrap="" align="center" class="footer"><a
													href="http://bioinformatics.udel.edu/"><font
														color="#999999">University of Delaware</font></a> <br> <font
													color="#999999">15 Innovation Way, Suite 205 <br>Newark,
														DE 19711, USA
												</font></td>
												<td><img src="./imagefiles/spacer.gif" alt=""
													width="20" height="1"></td>

												<td nowrap="" align="center" class="footer"><a
													href="http://gumc.georgetown.edu/"><font
														color="#999999">Georgetown University Medical
															Center</font></a> <br> <font color="#999999">3300
														Whitehaven Street, NW, Suite 1200 <br>Washington, DC
														20007, USA
												</font></td>
											</tr>
										</tbody>
									</table></td>
							</tr>
						</tbody>
					</table>
				</td>
				<td width="99%">&nbsp;</td>
			</tr>
		</tbody>
	</table>
</body>

<!-- Menu Related -->
<script language="javascript" src="./imagefiles/milonic_src.js"
	type="text/javascript"></script>
<script language="javascript">
  if(ns4) _d.write("<scr"+"ipt language=JavaScript src=./imagefiles/mmenuns4.js><\/scr"+"ipt>");		
    else _d.write("<scr"+"ipt language=JavaScript src=./imagefiles/mmenudom.js><\/scr"+"ipt>"); 
</script>
<script language="JavaScript" src="./imagefiles/mmenudom.js"></script>
<script>function getflta(ap){return _f}</script>
<script language="javascript" src="./imagefiles/menu_data.js"
	type="text/javascript"></script>

<!-- Menu Related ends -->