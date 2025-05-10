<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="query.PeptidePhraseQuery"%>
<%@ page import="query.Tools" %>
<%@ page import="java.math.BigDecimal" %>
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
	String path = application.getRealPath("/");
	String dir = new File(path).getParent();
	if(request.getParameter("peptide")!=null&request.getParameter("organism_id")!=null&request.getParameter("numberfound")!=null){
	String peptide = request.getParameter("peptide");
	String organism_id = request.getParameter("organism_id");
	String numberFound=request.getParameter("numberfound");

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
	
	//FileReader fs = new FileReader(dir+ "/peptidematch/WEB-INF/classes/config/taxongroup.txt");
	FileReader fs = new FileReader(request.getRealPath("/")+"WEB-INF/classes/config/taxongroup.txt");
	BufferedReader br = new BufferedReader(fs);
	PeptidePhraseQuery query;
	String eachLine;
	int peptideCount;
	HashMap<String,Integer> hs=new HashMap<String,Integer>();	
	while ((eachLine = br.readLine()) != null) {
		query=new PeptidePhraseQuery();
		String[] fields = eachLine.split("\t");
		String group=fields[0];
		String taxonGroupName=fields[1];
		String groupID=fields[2];
		if(organism_id.toLowerCase().equals("all"))
			query.queryByPeptideWithTaxonGroup(peptide, groupID, 0, 1, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
		else 
			query.queryByPeptideWithOrganismAndGroup(peptide, organism_id,groupID, 0, 1, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);	
		peptideCount=query.getResult();
	//	out.println(peptideCount);
	//out.println(groupID+":"+peptideCount+"<br>");
	hs.put(groupID,peptideCount);
	if(group.toLowerCase().equals("archaea")){
	if(hs.get("archaea")==null)
			hs.put("archaea",peptideCount);
			else hs.put("archaea",hs.get("archaea")+peptideCount);
	}
	else if(group.toLowerCase().equals("bacteria")){
		if(hs.get("bacteria")==null)
				hs.put("bacteria",peptideCount);
				else hs.put("bacteria",hs.get("bacteria")+peptideCount);
		}
	else if(group.toLowerCase().equals("eukaryota")){
		if(hs.get("eukaryota")==null)
				hs.put("eukaryota",peptideCount);
				else hs.put("eukaryota",hs.get("eukaryota")+peptideCount);
		}
	else if(group.toLowerCase().equals("virus")){
		if(hs.get("virus")==null)
				hs.put("virus",peptideCount);
				else hs.put("virus",hs.get("virus")+peptideCount);
		}
	else if(group.toLowerCase().equals("other")){
		if(hs.get("other")==null)
				hs.put("other",peptideCount);
				else hs.put("other",hs.get("other")+peptideCount);
		}
	}
	fs.close();
	br.close();	
	%>
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
	<table style="margin-left: 100px;" width="60%" border=0>
	<tr>
		<td width=13% align="right" nowrap><b>Query peptide:&nbsp;</b>
		</td>
		 <td nowrap><%=peptide.toUpperCase() %>
		</td>
	</tr>
	<tr>
		<td align="right" nowrap><b>Sequence data set: </b>
		</td>
		<td nowrap>	
		<%
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
		out.print(version);
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

	/*if(organism_id.toLowerCase().equals("all")) out.print("UniProtKB"); 
	else{ 
		//out.print("Taxon ID(s): ");
		String[] organisms=organism_id.split(";");
		for(int i=0;i<organisms.length;i++) {
			if(i == 0) {
				out.print("<a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+organisms[i]+"'>"+organisms[i]+"</a>");
			}
			else {
				out.print("; <a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+organisms[i]+"'>"+organisms[i]+"</a>");
			}
		}
	}*/
		%> 
		</td>
	</tr>
	<tr>
		<td align="right" nowrap><b>Matched:&nbsp;</b></td>
		<td><%=numberFound%> sequence(s)
	</td></tr></table>
<!--	&nbsp;&nbsp;<a title='return to searching page' href=./index.jsp><img src=./imagefiles/restart.png border=0></a>-->

	<br/>
	<table class="taxongroup" border=0>
	<tr>
	<td class="result_td">
	<table class="inner_table">
	<tr class="inner_table_tr"><td colspan=3 class="head" >Archaea (Total: <font color=red><%=hs.get("archaea")%> </font>seq.)</td></tr>
<% 	
//fs = new FileReader(dir+ "/peptidematch/WEB-INF/classes/config/taxongroup.txt");
fs = new FileReader(request.getRealPath("/") + "WEB-INF/classes/config/taxongroup.txt");
String[] fields ;
String group;
String taxonGroupName;
String groupID;
br = new BufferedReader(fs);
double percentage;
//	out.print("<tr class='inner_table_tr'><th>Taxonomy Group</th><th># of Matched Sequences</th><th>% of Matched Sequences</th></tr>");
while ((eachLine = br.readLine()) != null) {
	//out.println(eachLine);
	 fields = eachLine.split("\t");
	 group=fields[0];
	 taxonGroupName=fields[1];
	 groupID=fields[2];
	if(group.toLowerCase().equals("archaea")){
		out.print("<tr class='inner_table_tr'>");
		String[] taxonGroupNames = taxonGroupName.split("/");
		String taxonGroupNameShow = taxonGroupName;
		if(taxonGroupNames.length > 1) {
			taxonGroupNameShow = taxonGroupNames[1];	
		}	
		out.print("<td class='content'><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+groupID+"'>"+taxonGroupNameShow+"</a></td>");
	if(hs.get(groupID)>0)
			out.print("<td class='number'><a href='peptidewithtaxongroup.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organism_id+"&total_number="+numberFound+"&group_name="+taxonGroupName+"&taxongroup_id="+groupID+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly+"'><b>"+hs.get(groupID)+"</b></a></td>");
		else out.print("<td class='number'><font class='lightfont'>0</font></td>");
		if(hs.get(groupID)!=0) percentage=Tools.round(100*1.0*hs.get(groupID)/Integer.parseInt(numberFound),2,BigDecimal.ROUND_HALF_UP); else percentage=0;
		out.print("<td class='percentage'>"+percentage+"%</td>");
		out.print("</tr>");
	}
	}
fs.close();
br.close(); %>
	<tr class='inner_table_tr'><td colspan=3 class="head" >Eukaryota (Total: <font color=red><%=hs.get("eukaryota")%> </font>seq.)</td></tr>
<% 	
fs = new FileReader(request.getRealPath("/") + "WEB-INF/classes/config/taxongroup.txt");
//fs = new FileReader(dir+ "/peptidematch/WEB-INF/classes/config/taxongroup.txt");
br = new BufferedReader(fs);
while ((eachLine = br.readLine()) != null) {
	//out.println(eachLine);
	fields = eachLine.split("\t");
	group=fields[0];
	 taxonGroupName=fields[1];
	groupID=fields[2];
	if(group.toLowerCase().equals("eukaryota")){
		String[] taxonGroupNames = taxonGroupName.split("/");
		String taxonGroupNameShow = taxonGroupName;
		if(taxonGroupNames.length > 1) {
			taxonGroupNameShow = taxonGroupNames[1];	
		}	
		out.print("<tr class='inner_table_tr'>");
		out.print("<td class='content'><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+groupID+"'>"+taxonGroupNameShow+"</a></td>");
		if(hs.get(groupID)>0)
			out.print("<td class='number'><a href='peptidewithtaxongroup.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organism_id+"&total_number="+numberFound+"&group_name="+taxonGroupName+"&taxongroup_id="+groupID+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly+"'><b>"+hs.get(groupID)+"</b></a></td>");
		else out.print("<td class='number'><font class='lightfont'>0</font></td>");
		if(hs.get(groupID)!=0) percentage=Tools.round(100*1.0*hs.get(groupID)/Integer.parseInt(numberFound),2,BigDecimal.ROUND_HALF_UP); else percentage=0;
		out.print("<td class='percentage'>"+percentage+"%</td>");
		out.print("</tr>");
	}
	}
fs.close();
br.close(); %>
</table>
</td>
	<td class="result_td">
	<table class="inner_table">
	<tr class='inner_table_tr'><td colspan=3 class="head" >Bacteria (Total: <font color=red><%=hs.get("bacteria")%> </font>seq.)</td></tr>
<% 	
fs = new FileReader(request.getRealPath("/") + "WEB-INF/classes/config/taxongroup.txt");
//fs = new FileReader(dir+ "/peptidematch/WEB-INF/classes/config/taxongroup.txt");
br = new BufferedReader(fs);
while ((eachLine = br.readLine()) != null) {
	//out.println(eachLine);
	fields = eachLine.split("\t");
	group=fields[0];
	taxonGroupName=fields[1];
	groupID=fields[2];
	if(group.toLowerCase().equals("bacteria")){
		String[] taxonGroupNames = taxonGroupName.split("/");
		String taxonGroupNameShow = taxonGroupName;
		if(taxonGroupNames.length > 1) {
			taxonGroupNameShow = taxonGroupNames[1];	
		}	
		out.print("<tr class='inner_table_tr'>");
        out.print("<td class='content'><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+groupID+"'>"+taxonGroupNameShow+"</a></td>");
		if(hs.get(groupID)>0)
			out.print("<td class='number'><a href='peptidewithtaxongroup.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organism_id+"&total_number="+numberFound+"&group_name="+taxonGroupName+"&taxongroup_id="+groupID+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly+"'><b>"+hs.get(groupID)+"</b></a></td>");
		else out.print("<td class='number'><font class='lightfont'>0</font></td>");
		if(hs.get(groupID)!=0) percentage=Tools.round(100*1.0*hs.get(groupID)/Integer.parseInt(numberFound),2,BigDecimal.ROUND_HALF_UP); else percentage=0;
		out.print("<td class='percentage'>"+percentage+"%</td>");
		out.print("</tr>");
	}
	}
fs.close();
br.close(); %>
	<tr class='inner_table_tr'><td colspan=3 class="head" >Virus (Total: <font color=red><%=hs.get("virus")%> </font>seq.)</td></tr>
<% 	
fs = new FileReader(request.getRealPath("/") + "WEB-INF/classes/config/taxongroup.txt");
//fs = new FileReader(dir+ "/peptidematch/WEB-INF/classes/config/taxongroup.txt");
br = new BufferedReader(fs);
while ((eachLine = br.readLine()) != null) {
	//out.println(eachLine);
	fields = eachLine.split("\t");
	group=fields[0];
	taxonGroupName=fields[1];
	groupID=fields[2];
	if(group.toLowerCase().equals("virus")){
		String[] taxonGroupNames = taxonGroupName.split("/");
		String taxonGroupNameShow = taxonGroupName;
		if(taxonGroupNames.length > 1) {
			taxonGroupNameShow = taxonGroupNames[1];	
		}	
		out.print("<tr class='inner_table_tr'>");
        out.print("<td class='content'><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+groupID+"'>"+taxonGroupNameShow+"</a></td>");
		if(hs.get(groupID)>0)
			out.print("<td class='number'><a href='peptidewithtaxongroup.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organism_id+"&total_number="+numberFound+"&group_name="+taxonGroupName+"&taxongroup_id="+groupID+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly+"'><b>"+hs.get(groupID)+"</b></a></td>");
		else out.print("<td class='number'><font class='lightfont'>0</font></td>");
		if(hs.get(groupID)!=0) percentage=Tools.round(100*1.0*hs.get(groupID)/Integer.parseInt(numberFound),2,BigDecimal.ROUND_HALF_UP); else percentage=0;
		out.print("<td class='percentage'>"+percentage+"%</td>");
		out.print("</tr>");
	}
	}
fs.close();
br.close(); %>

</table>
</td>
</tr>
<tr>
<td colspan=6 align="center">
<table class="other_table" >
	<tr class='inner_table_tr'><td colspan=3 class="head" >Others (Total: <font color=red><%=hs.get("other")%> </font>seq.)</td></tr>
<% 	
//fs = new FileReader(dir+ "/peptidematch/WEB-INF/classes/config/taxongroup.txt");
fs = new FileReader(request.getRealPath("/") + "WEB-INF/classes/config/taxongroup.txt");
br = new BufferedReader(fs);
String taxongroups="";
while ((eachLine = br.readLine()) != null) {
	//out.println(eachLine);
	fields = eachLine.split("\t");
	group=fields[0];
	taxonGroupName=fields[1];
	groupID=fields[2];
	if(group.toLowerCase().equals("other")){
		taxongroups+=groupID+";";
}
}
fs.close();
br.close();
out.print("<tr class='inner_table_tr'>");
out.print("<td class='content'>Others</td>");
if(hs.get("other")>0)
out.print("<td class='number'><a href='peptidewithtaxongroup.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organism_id+"&total_number="+numberFound+"&group_name=Other&taxongroup_id="+taxongroups+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly+"'><b>"+hs.get("other")+"</b></a></td>");
else out.print("<td class='number'><font class='lightfont'>0</font></td>");
if(hs.get("other")!=0) percentage=Tools.round(100*1.0*hs.get("other")/Integer.parseInt(numberFound),2,BigDecimal.ROUND_HALF_UP); else percentage=0;
out.print("<td class='percentage'>"+percentage+"%</td>");
		out.print("</tr>");
	
 %>
</table>
</td>
</tr>
</table>
	</td>
	</tr>
</table>

	<%} else{ %>
	Wrong paramters! &nbsp;&nbsp;&nbsp;
	<a alt="Return to peptide search" title='return to peptide search'
		href=./index.jsp><img src=./imagefiles/restart.png border=0></a>
	<%} %>

<br/><br/>
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
									class="nrm10"><font color="#999999"> &copy; 2018</font> <img
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
