<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.TreeMap" %>
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
<%@ page import="query.TaxonomyLazyTreeNode" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>

<%
	String errMsg = "";
	//root {[1, no]}	Others {[0, no rank]}; cellular organisms {[131567, no rank]}; Viruses {[10239, superkingdom]}; unclassified sequences {[12908, no rank]}; other sequences {[28384, no rank]}
	String firstLevelLineage = "root {[1, no]}; Others {[0, no rank]}; cellular organisms {[131567, no rank]}; Viruses {[10239, superkingdom]}; unclassified sequences {[12908, no rank]}; other sequences {[28384, no rank]}";
	//String childrenData = "/usr/share/tomcat6/webapps/peptidematch_new/WEB-INF/classes/config/children.txt";
	//String childrenData = request.getRealPath("/")+"WEB-INF/classes/config/children.txt";
	String childrenData = request.getRealPath("/")+"WEB-INF/classes/config/condenseChildren.txt";
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
	
	//String[] taxonRec = firstLevelLineage.split("]}; ");
	String[] taxonRec = null;
	String taxons = "";
	FileInputStream in = null;
        try {
        	in = new FileInputStream(childrenData);
                BufferedReader br = new BufferedReader(new InputStreamReader(in));
                String strLine;
                while((strLine = br.readLine())!= null) {
			if(strLine.startsWith("root {[1, no]}")) {
				String[] rec = strLine.split("\t");
                                String org = rec[0];
                                taxons = rec[1];
                                taxonRec = taxons.split("]}; ");
			}	
		}
	}
	catch(Exception e) {
		e.printStackTrace();
	} finally {
        	try {
                	if (in != null)
                       	in.close();
                } catch (IOException ex) {
                        ex.printStackTrace();
                }
        }
  	String[] taxon;
  	String[] taxonIdAndType;
  	String taxonName;
	String taxonId;
	String type;
	int start = 0;
	int rowsPerPage = 20;	
	String op = "OR";	
	int nodeCount = 0;
	int totalMatch = 0;
	TreeMap nodes = new TreeMap();
	String taxonomyTree = "";

	String peptide = request.getParameter("peptide");
        String organismId = request.getParameter("organism_id");
        String numberFound=request.getParameter("numberfound");
	if(peptide != null && organismId != null && numberFound != null) {
	 	peptide = peptide.replaceAll("[^a-zA-Z]", "");
	 	if(peptide.length() >= 3) {
			for(int i=0; i < taxonRec.length; i++) {
  				taxon = taxonRec[i].split(" \\{\\[");
  				taxonIdAndType = taxon[1].split(", ");
  				taxonName = taxon[0];
				taxonId = taxonIdAndType[0].trim();
				type = taxonIdAndType[1];
				//initial the solr connection
				PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
				SolrDocumentList docs = new SolrDocumentList();
				int match = 0;
				if(peptide.equals("*:*")){
        				peptideQuery.queryAll(start,rowsPerPage, swissprot, isoform, uniref100Only, ilEquivalent, trOnly, isoOnly);
				}
				else {
					if(!organismId.toLowerCase().equals("all")){
        					peptideQuery.queryByPeptideWithFullLineageOrganismAndTaxonId(peptide, organismId,taxonId, start, rowsPerPage, op, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
					}
					else{
        					peptideQuery.queryByPeptideWithFullLineageTaxonId(peptide, taxonId, start, rowsPerPage, op, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
					}
				}
				docs = peptideQuery.getCurrentDocs();
				match = peptideQuery.getResult();
				if(match > 0) {
					nodeCount++;
					totalMatch += match;
					String nodeId = peptide+"-"+taxonId+"-"+nodeCount;
					TaxonomyLazyTreeNode node = null;
					if(nodes.get(nodeId) == null) {
                                                if(taxonName.equals("root")) {
                                                        node = new TaxonomyLazyTreeNode("root", Integer.parseInt(taxonId), "", nodeId, match);
                                                }
                                                else {
                                                        node = new TaxonomyLazyTreeNode(taxonName, Integer.parseInt(taxonId), type, nodeId, match);
                                                }
                                                nodes.put(nodeId, node);
                                        }
			
				}
			}
			if(totalMatch > 0) {
				Iterator iter = nodes.keySet().iterator();
				String children = "<ul>";
				TreeMap childrenNodes = new TreeMap();
                        	while(iter.hasNext()) {
                                	String key = (String)iter.next();
                                        TaxonomyLazyTreeNode node = (TaxonomyLazyTreeNode) nodes.get(key); 
					if(node.getName().equals("root")) {
						taxonomyTree += "<li id='"+node.getId()+"'><span style='font-weight: bold; color: navy;'>"+node.getName()+"</span>";
					}
					else {
						String rank ="";
                                                        if(!node.getType().equals("no rank")) {
								// if($rank eq "superkingdom" || $rank eq "kingdom" || $rank eq "phylum" || $rank eq "class" || $rank eq "order" || $rank eq "family" || $rank eq "genus" || $rank eq "species" 
								if(node.getType().equals("superkingdom")) {
                                                                        rank = "<span style='color: red'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("kingdom")) {
                                                                        rank = "<span style='color: orange'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("phylum")) {
                                                                        rank = "<span style='color: brown'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("class")) {
                                                                        rank = "<span style='color: green'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("order")) {
                                                                        rank = "<span style='color: blue'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("family")) {
                                                                        rank = "<span style='color: purple'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("genus")) {
                                                                        rank = "<span style='color: royalblue'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("species")) {
                                                                        rank = "<span style='color: pink'>["+node.getType()+"]</span>";
                                                                }
                                                        }
						    String taxonNameUrl = "<span><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ node.getTaxonomyID()+"'>" +node.getName() + "</a></span>";
						    //String seqCountUrl = "<span style='padding: 0 20px;'><a href='peptidewithlineagetaxonid.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organismId+"&total_number="+node.getSeqCount()+"&taxon_name="+ node.getName().replaceAll("'", "&#39;")+"&taxon_id="+node.getTaxonomyID()+"'>"+node.getSeqCount()+"</a></span></li>";
						    //String seqCountUrl = " (<a href='peptidewithlineagetaxonid.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organismId+"&total_number="+node.getSeqCount()+"&taxon_name="+ node.getName().replaceAll("'", "&#39;")+"&taxon_id="+node.getTaxonomyID()+"'>"+node.getSeqCount()+"</a>)</li>";
							//out.println(seqCountUrl);	
						    String link = "<a href='peptidewithlineagetaxonid.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organismId+"&total_number="+node.getSeqCount()+"&taxon_name="+ node.getName().replaceAll("'", "&#39;")+"&taxon_id="+node.getTaxonomyID()+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly+"'>"+node.getName() + " " + rank+ " ("+node.getSeqCount()+")</a>";
						    childrenNodes.put(node.getName().toUpperCase(), "<li class='jstree-closed' id='"+node.getId()+"'>"+link);
						    //childrenNodes.put(node.getName().toUpperCase(), "<li class='jstree-closed' id='"+node.getId()+"'>"+taxonNameUrl+rank+seqCountUrl);
					}
                                }
				SortedSet<String> keys = new TreeSet<String>(childrenNodes.keySet());
				for(String key: keys) {
					children += childrenNodes.get(key);
				}
				     children += "</ul>";
				taxonomyTree += children+"</li>";
                        }	
		}
		else {
			errMsg += "<span style=\"color: red;\">The query peptide must be at least 3 characters!</span><br/>";
		}
	}
	else {
		errMsg += "<span style=\"color: red;\">You need to specify the query peptide and organism id(s)!</span><br/>";
	}
%>

<head>
<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<link href="css/tabs/tabs.css" rel="stylesheet" type="text/css" />
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
<TITLE>Peptide Match [PIR - Protein Information Resource] - Taxonomy Tree View</TITLE >
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

<link rel="stylesheet" href="css/treeview/jquery.treeview.css" />
<link rel="stylesheet" href="css/treeview/screen.css" />

<script type="text/javascript" src="js/jsTree/jquery.js"></script>
    <script type="text/javascript" src="js/jsTree/jquery.jstree.js"></script>
    <script type="text/javascript" src="js/jsTree/jquery.cookie.js"></script>
        <script type="text/javascript" class="source">
        $(function ($) {
		jQuery("#tree").bind("loaded.jstree", function (event, data) {
                        //jQuery("#tree").jstree("open_all", -1);
			
        		var depth = 3; 
        		data.inst.get_container().find('li').each(function() { 
                		if(data.inst.get_path($(this)).length<=depth){ 
                        		data.inst.open_node($(this)); 
                		} 
        		});
			 
		});
		
                jQuery("#tree").jstree({
			"core" : { 
				 "animation" : 200,
				"load_open" : true,
				"strings" : "Loading..., please wait"	
				
			},

			"cookies" : {
				//"save_opened" : true,
				"auto_save" : false 
				//cookie_options: { path: '/'}
			},

                        "themes" : {
                        	"theme" : "classic",
                        	"dots" : true,
                        	"icons" : true 
                        },
			"html_data" : {
				"data" : "<%=taxonomyTree%>", 
				"async" : false,
				"ajax" : {
					"url" : "getcondensechildren.jsp",
					//"url" : "getchildren.jsp",
					"type" : 'POST',
					//"cache" : false,
					"data" : function (n) {
						return {
							"peptide" : "<%=peptide%>",
							"organism_id" : "<%=organismId%>",
							"numberfound": "<%=numberFound%>",
							"swissprot": "<%=swissprotValue%>",
							"isoform": "<%=isoformValue%>",
							"uniref100": "<%=uniref100Value%>",
							"lEqi": "<%=lEqiValue%>",
							"sortBy": "<%=sortBy%>",
							"trOnly": "<%=trOnlyValue%>",
							"isoOnly": "<%=isoOnlyValue%>",
							"id" : n.attr ? n.attr("id") : 0		
						};
					}
					 
				},
				"correct_state" : true	
			},
			//"progressive_render" : true,

                        "plugins" : [ "themes", "html_data", "cookies"]
                        //"plugins" : [ "themes", "html_data"]
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
                    / <b><a href="index.jsp">Peptide Match</a></b><!-- ############### page dependent-->
    </td></tr>
</tbody></table>
<br/>
<% if(errMsg.length() > 0) {%>
<table style="font-size: 13px; margin-left: 50px; width:100%"> 
	<tr>
		<td><%=errMsg%>
		</td>
	</tr>
</table>
<% } else {%>
<!--
        <table style="margin-left: 100px; font-size: 11px;" width="60%" border=0>
        <tr>
                <td width=13% align="right"><b>Query peptide:&nbsp;</b>
                </td>
                <td><%=peptide.toUpperCase() %>
                </td>
        </tr>
        <tr>
                <td align="right"><b>Sequence data set: </b>
                </td>
                <td>
                <%
        if(organismId.toLowerCase().equals("all")) out.print("UniProtKB");
        else{
                //out.print("Taxon ID(s): ");
                String[] organisms=organismId.split(";");
                for(int i=0;i<organisms.length;i++) {
                        if(i == 0) {
                                out.print("<a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+organisms[i]+"'>"+organisms[i]+"</a>");
                        }
                        else {
                                out.print("; <a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+organisms[i]+"'>"+organisms[i]+"</a>");
                        }
                }
        }
                %>
                </td>
        </tr>
        <tr>
                <td align="right"><b>Matched:&nbsp;</b></td>
                <td><%=numberFound%> sequence(s)
        </td></tr></table>
<br/>
-->
<table style="font-size: 13px; margin-left: 50px; width:100%"> 
	<tr>
	<td>
  	<div style="width:95%;">
    		<div class="grid-header" style="width:100%; font-size: 15px;" >
      		<label><span style="font-weight: bold; font-size: 14px; color: brown;">Taxonomy Condense Tree View</span> | <span style="font-weight: bold; font-size: 14px;"><a href="taxonomycompletetreeview.jsp?peptide=<%=peptide%>&organism_id=<%=organismId%>&numberfound=<%=numberFound%>&swissprot=<%=swissprotValue%>&isoform=<%=isoformValue%>&uniref100=<%=uniref100Value%>&lEqi=<%=lEqiValue%>&sortBy=<%=sortBy%>&trOnly=<%=trOnly%>&isoOnly=<%=isoOnly%>">Taxonomy Complete Tree View</a></span></label>
    		</div>
  	 </div>
	<br>
	<input type="button" value="Expand All" onclick="jQuery('#tree').jstree('open_all');">&nbsp;&nbsp;&nbsp;&nbsp;
	<input type="button" value="Collapse All" onclick="jQuery('#tree').jstree('close_all');">&nbsp;&nbsp;&nbsp;&nbsp;
	<!--

	<%=taxonomyTree%>
	-->
	<div id="tree"><ul></ul></div>
	</td>
	</tr>
</table>
<% } %>
<!--
<table style="margin-left: 50px">
	<tr>
		<td align=right><br/><br/><br/>Back to Peptide Match</td><td><br/><br/><br/><a title='return to searching page' href=./index.jsp><img src=./imagefiles/restart.png border=0></a></td>
	</tr>
</table>
-->
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
