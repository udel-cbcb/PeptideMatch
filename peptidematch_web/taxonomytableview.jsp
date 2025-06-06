<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="query.PeptidePhraseQuery" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<%@ page import="org.apache.commons.io.FilenameUtils" %>
<%@ page import="org.apache.lucene.*" %>
<%@ page import="org.apache.lucene.search.*" %>
<%@ page import="org.apache.lucene.index.*" %>
<%@ page import="org.apache.lucene.store.*" %>
<%@ page import="org.apache.lucene.document.*" %>
<%@ page import="org.apache.solr.*" %>
<%@ page import="query.PeptidePhraseQuery" %>
<%@ page import="query.TaxonomyTreeNode" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>

<%! class TableView {
	String tableView = "";
	int rowCount = 0;
	TableView(String tableView, int rowCount) {
		this.tableView = tableView;
		this.rowCount = rowCount;
	}		
	public String getTableView() {
		return this.tableView;
	}
	public void setTableView(String tableView) {
		this.tableView = tableView;
	}		
	public int getRowCount() {
		return this.rowCount;
	}
	public void setRowCount(int rowCount) {
		this.rowCount = rowCount;
	}		
    }
%>
<%
	String peptide = request.getParameter("peptide");
        String organism_id = request.getParameter("organism_id");
	String[] organisms = organism_id.split(";") ;
        String numberFound=request.getParameter("numberfound");
	String tableView = (String)session.getAttribute("TaxonomyTableView");
	 HashMap organismHitMap = (HashMap)session.getAttribute("OrgHitMap");
	 if(organismHitMap == null) {
	 	organismHitMap = new HashMap();
	 }
	 HashMap organismHitNameMap = (HashMap)session.getAttribute("OrgHitNameMap");
	 if(organismHitNameMap == null) {
	 	organismHitNameMap = new HashMap();
	 }
	 HashMap organismHitLineageMap = (HashMap)session.getAttribute("OrgHitLineageMap");
	 if(organismHitLineageMap == null) {
	 	organismHitLineageMap = new HashMap();
	 }
	peptide = peptide.replaceAll("[^a-zA-Z]", "");
        if(peptide.length() >= 3) {
	 	//if(organismHitMap.size() == 0 || organismHitNameMap == null && organismHitLineageMap == null && tableView == null) {	
	 	if(tableView == null) {	
	 		InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
         		Properties properties = new Properties();
         		properties.load(inputStream);
         		String indexPath = properties.getProperty("indexpath");
         		String version = properties.getProperty("version");
	 		Query finalQuery;
         		BooleanQuery bQuery = new BooleanQuery();
         		PhraseQuery phraseQuery = new PhraseQuery();
	 		BooleanQuery organismQuery = new BooleanQuery();

         		Directory indexDir = FSDirectory.open(new File(indexPath));
         		IndexSearcher searcher = new IndexSearcher(IndexReader.open(indexDir));
         		TopScoreDocCollector collector;
         
         		for(int j= 0; j <= peptide.length()-3; j++) {
                		phraseQuery.add(new Term("sequence", peptide.toLowerCase().substring(j, j+3)));
                	}
                	if(organism_id.equals("all")) {
                        	finalQuery = phraseQuery;
                	}
                	else {
                        	for (int k = 0; k < organisms.length; k++) {
                         		organismQuery.add(new TermQuery(new Term("organismid", organisms[k])), BooleanClause.Occur.SHOULD);
                        	}
                        	bQuery = new BooleanQuery();
                        	bQuery.add(organismQuery, BooleanClause.Occur.MUST);
                        	bQuery.add(phraseQuery, BooleanClause.Occur.MUST);
                        	finalQuery = bQuery;
                	}
                	collector = TopScoreDocCollector.create(10, true);
                	searcher.search(finalQuery, collector);
                	int totalNumber = collector.getTotalHits();
			collector = TopScoreDocCollector.create(totalNumber, true);
                	searcher.search(finalQuery, collector);
                	ScoreDoc[] hits = collector.topDocs().scoreDocs;
			String id;
			Document doc;
			String description;
			String[] features;
			String lineageStr = "";
			int totalCount = 0;
			for (int i = 0; i < totalNumber; i++) {
                		doc = searcher.doc(hits[i].doc);
				id = (String) doc.get("id");
                		description = (String) doc.get("description");
				lineageStr = (String) doc.get("lineage");	
				features = description.trim().split("\\^\\|\\^");
				if(organismHitMap.get(features[6]) != null) {	
					Integer sum = (Integer)organismHitMap.get(features[6]);
					organismHitMap.put(features[6], new Integer(sum.intValue()+1));
					organismHitNameMap.put(features[6], features[5]);
					totalCount++;
					organismHitLineageMap.put(features[6], lineageStr);
				}
				else {
					organismHitMap.put(features[6], new Integer(1));
					organismHitNameMap.put(features[6], features[5]);
					totalCount++;
					organismHitLineageMap.put(features[6], lineageStr);
				}
        		}
			tableView = ((TableView)buildTaxonomyTable(organismHitMap, organismHitNameMap, organismHitLineageMap, out)).getTableView();
			session.setAttribute("OrgHitMap", organismHitMap);
			session.setAttribute("OrgHitNameMap", organismHitNameMap);
			session.setAttribute("OrgHitLineageMap", organismHitLineageMap);
			session.setAttribute("TaxonomyTableView", tableView);	
		}
		else {
			//tableView = ((TableView)buildTaxonomyTable(organismHitMap, organismHitNameMap, organismHitLineageMap, out)).getTableView();
			tableView = (String)session.getAttribute("TaxonomyTableView");
		}
	}	
	else {
		out.println("The query peptide must be at least 3 characters");
	}
%>

<head>
<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<TITLE>Peptide Match [PIR - Protein Information Resource] - Taxonomy Table View</TITLE >
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
table.lineage {
	border-width: 1px;
	border-spacing: 1px;
	border-style: solid;
	border-color: navy;
	border-collapse: collapse;
	font-size: 11px;
	width: auto;
	margin-right: 50px;
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
#font-size:10px;
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
font-size:10px;
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
font-size:10px;
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
table.sample {
	border-width: 2px;
	border-spacing: 4px;
	border-style: outset;
	border-color: ;
	border-collapse: collapse;
	background-color: ;
}
table.sample th {
	border-width: 2px;
	padding: 4px;
	border-style: inset;
	border-color: gray;
	background-color: white;
	-moz-border-radius: ;
}
table.sample td {
	border-width: 2px;
	padding: 4px;
	border-style: inset;
	border-color: gray;
	background-color: white;
	-moz-border-radius: ;
}

.cell-title {
      font-weight: bold;
      font-color: blue;
    }

    .cell-effort-driven {
      text-align: center;
    }

    .cell-selection {
      border-right-color: silver;
      border-right-style: solid;
      background: #f5f5f5;
      color: gray;
      text-align: right;
      font-size: 10px;
    }

    .slick-row.selected .cell-selection {
      background-color: transparent; /* show default selected row background */
    }

</style>
<style type="text/css" title="currentStyle">
                       @import "css/DataTable/demo_page.css";
                        @import "css/DataTable/demo_table.css";
                </style>

<link rel="stylesheet" href="css/treeview/jquery.treeview.css" />
<link rel="stylesheet" href="css/treeview/screen.css" />
<script type="text/javascript" language="javascript" src="js/DataTable/jquery.js"></script>
<script type="text/javascript" language="javascript" src="js/DataTable/jquery.dataTables.js"></script>

<script type="text/javascript" charset="utf-8">
                $(document).ready(function() {
                          //jQuery('#example').dataTable( {
                          jQuery('#example').dataTable( {
                		"sPaginationType": "full_numbers",
                		//"sScrollY": 390,
                		//"sScrollX": "100%",
                		//"sScrollXInner": "110%",
                		//"iDisplayLength": 20,
				//"bLengthChage": false,
				//"bAutoWidth": true,
                		"aaSorting": [[0, "asc"]],
                  	 });
               });
</script>

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
                    / <b><i>Peptide Match</i></b><!-- ############### page dependent-->
    </td></tr>
</tbody></table>
<br/>
<table style="font-size: 11px; margin-left: 50px; width:100%"> 
	<tr>
		<td>
			<div style="position:relative">
  <div style="width: 95%;">
    <div class="grid-header" style="width: 100%; font-size: larger;">
      <label><span style="color: blue;">Lineage Table</span> | <a href="taxonomytreeview.jsp?peptide=<%=peptide%>&organism_id=<%=organism_id%>&numberfound=<%=numberFound%>"> <span>Taxonomy Tree</span></a></label>
    </div>
	<div id="container">
                        <div id="demo">
			<br/>
			<%= tableView %>
	</div>
	</div>
  </div>
	</div>
	</td>
	</tr>
</table>
<table style="margin-left: 50px">
	<tr>
		<td align=right><br/><br/><br/>Back to Peptide Match</td><td><br/><br/><br/><a title='return to searching page' href=./index.htm><img src=./imagefiles/restart.png border=0></a></td>
	</tr>
</table>
<br/>
<br/>
<br/>
<br/>
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
              <td colspan="2" align="center" nowrap="" class="footer3"><span class="nrm10"><font color="#999999"> �2009</font>
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
<!--
<script type="text/javascript" src="./imagefiles/jquery-latest.js"></script> 
<script type="text/javascript" src="./imagefiles/jquery.tablesorter.js"></script>
-->
</html>

<%!
	private TableView buildTaxonomyTable(HashMap organismHitMap, HashMap organismHitNameMap, HashMap organismHitLineageMap, JspWriter out) {
		String lst = "";
		String lineageTable  = "<table  cellpadding=0 cellspacing=0 border=0 class=\"display\" id=\"example\">\n";	
		       lineageTable += "	<thead><tr><th>Organism</th><th>Matches</th><th>Lineage</th></tr></thead>\n";	
		       lineageTable += "	<tbody>\n";	
		String lineage = "/usr/share/tomcat6/webapps/peptidematch_new/WEB-INF/classes/config/lineage.txt";
		//String lineage = request.getRealPath("/") + "WEB-INF/classes/config/lineage.txt";
		TableView tabv = null;
	    	HashMap map = new HashMap();
	    	HashMap nameMap = new HashMap();
	    	HashMap typeMap = new HashMap();
	    	HashMap nodes = new HashMap();
		ArrayList processedHitList = new ArrayList();
		int orgCount = 0;
	
		try
		  {
			  FileInputStream in = new FileInputStream(lineage);
			  BufferedReader br = new BufferedReader(new InputStreamReader(in));
			  String strLine;
			  TaxonomyTreeNode root = null;
		  	  nameMap.put(-1, "Others");
		  	  nameMap.put(1, "Organism");
		  	  typeMap.put(-1, "no rank");
			  TaxonomyTreeNode parent = null;
			  String org = null;
			  while((strLine = br.readLine())!= null) {
				  String[] rec = strLine.split("\t");
				  org = rec[0];
				  String taxons = rec[1];
				  if(organismHitMap.get(org) != null) {
					processedHitList.add(org);
				  	int count = ((Integer)organismHitMap.get(org)).intValue();
				  	String[] taxonRec = taxons.split("]}; ");
				  	String[] taxon = taxonRec[0].split(" \\{\\[");
				  	String[] taxonIdAndType = taxon[1].split(", ");
				  	String taxonName = taxon[0];
				  
				  	String taxonId = taxonIdAndType[0].trim();
				  
				  	String type = taxonIdAndType[1];
						
				  	if(nodes.get(Integer.parseInt(taxonId)) == null) {
						if(taxonName.equals("root")) {
					  		root = new TaxonomyTreeNode("Organism", Integer.parseInt(taxonId), "", count);	
					  	}
					  	else {
							root = new TaxonomyTreeNode(taxonName, Integer.parseInt(taxonId), type, count);
					  	}
					  	nodes.put(Integer.parseInt(taxonId), root);
					  	nameMap.put(Integer.parseInt(taxonId), taxonName);
					  	typeMap.put(Integer.parseInt(taxonId), type);
				  	}		
				  	else {
						root = (TaxonomyTreeNode)nodes.get(Integer.parseInt(taxonId));
					  	root.setSeqCount(root.getSeqCount()+count);
				  	}
				  	parent = root;
				  	for(int i=1; i < taxonRec.length; i++) {
						taxon = taxonRec[i].split(" \\{\\[");
						taxonName = taxon[0];
					  	taxonIdAndType = taxon[1].split(", ");
					  	taxonId = taxonIdAndType[0].trim();
					  	type = taxonIdAndType[1];
					  	TaxonomyTreeNode child = null;
					  	if(nodes.get(Integer.parseInt(taxonId)) == null) {
							child = new TaxonomyTreeNode(taxonName, Integer.parseInt(taxonId), type, count);
						  	nodes.put(Integer.parseInt(taxonId), child);
						  	nameMap.put(Integer.parseInt(taxonId), taxonName);
						  	typeMap.put(Integer.parseInt(taxonId), type);
					  	}
					  	else {
							child = (TaxonomyTreeNode)nodes.get(Integer.parseInt(taxonId));
						  	child.setSeqCount(child.getSeqCount()+count);
					  	}
					  
					  	if(!parent.hasChildren(child)) {
							parent.add(child);
						  	map.put(child.getTaxonomyID(), parent.getTaxonomyID());
					  	}
					  	parent = child;
				  	}
				}
			 }
			Iterator iter = organismHitMap.keySet().iterator();
			while(iter.hasNext()) {
				String key = (String)iter.next();
				Integer sum = (Integer)organismHitMap.get(key);
				String name = (String)organismHitNameMap.get(key);
				if(!processedHitList.contains(key)) {
			  		TaxonomyTreeNode orphan = new TaxonomyTreeNode(name, Integer.parseInt(key), "", sum.intValue());
			  		nodes.put(key, orphan);
		  	  		nameMap.put(key, name);
		  	  		typeMap.put(key, orphan.getType());
					
				}
			}
			 iter = map.keySet().iterator();
			  
			  while (iter.hasNext()) {
				Integer child = (Integer) iter.next();
				Integer parentTaxon = (Integer) map.get(child);
				TaxonomyTreeNode childNode = null;
				if(nodes.get(child)==null) {
					childNode = new TaxonomyTreeNode((String) nameMap.get(child), child, (String) typeMap.get(child));
				}
				else {
					childNode = (TaxonomyTreeNode) nodes.get(child);
				}
				
				TaxonomyTreeNode parentNode = null;
				if(nodes.get(parentTaxon)==null) {
					parentNode = new TaxonomyTreeNode((String) nameMap.get(parentTaxon), parentTaxon, (String)typeMap.get(parentTaxon));
				}
				else {
					parentNode = (TaxonomyTreeNode) nodes.get(parentTaxon);
				}
				if (!parentNode.hasChildren(childNode)) {
					parentNode.add(childNode);
				}
				nodes.put(childNode.getTaxonomyID(), childNode);
				nodes.put(parentNode.getTaxonomyID(), parentNode);

			}
			/*
			iter = nodes.keySet().iterator();
                        while(iter.hasNext()) {
                                Integer ttnIndex = (Integer)iter.next();
                                TaxonomyTreeNode ttn = (TaxonomyTreeNode)nodes.get(ttnIndex);
                                if(ttn.isRoot()) {
                                        //ttn.printLevelList();
                                        lst = "<ul id=\"tree\">\n";
                                        lst += ttn.printTree();
                                        lst +="</ul>";
                                        //System.out.println(lst);

                                        break;
                                }
                        }
			*/
			
			iter = organismHitLineageMap.keySet().iterator();
			String lineageTableLine = "";	
			while(iter.hasNext()) {
				org = (String)iter.next();
				orgCount++;
				if(orgCount % 2 == 0) {
					lineageTableLine = "<tr><td><a href=\"http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ org+"\">" +nameMap.get(new Integer(org).intValue())+"</a></td><td align=middle>"+(Integer)organismHitMap.get(org)+"</td><td>";
				}
				else {
					lineageTableLine = "<tr><td><a href=\"http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ org+"\">" +nameMap.get(new Integer(org).intValue())+"</a></td><td align=middle>"+(Integer)organismHitMap.get(org)+"</td><td>";
				}
				String[] lineageArray = ((String)organismHitLineageMap.get(org)).split(", ");
				for(int i=1; i < lineageArray.length-1; i++) {
					if(i==1) {
						lineageTableLine += "<a href=\"http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ lineageArray[i]+"\">" + (String)nameMap.get(new Integer(lineageArray[i]).intValue())+"</a>";
					}
					else {
						lineageTableLine += "; <a href=\"http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ lineageArray[i]+"\">" + (String)nameMap.get(new Integer(lineageArray[i]).intValue())+"</a>";
					}
				}
				lineageTableLine +="</td></tr>\n";
				lineageTable += lineageTableLine;
			}
			lineageTable += "</tbody></table>";

		}catch(Exception e){
			   System.out.println(e);
		}
		tabv = new TableView(lineageTable, orgCount); 
		return tabv;	
	}
%>
