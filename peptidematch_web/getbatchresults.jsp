<%@ page session="true" %>
<%@ page import="java.io.*" %>
<%@ page import ="java.util.*" %>
<%@ page import = "javax.servlet.*" %>
<%
	String content = "";
	String jobId = "";
	String action = "";
	String[] jobIds = null;
	String dataTable = "";
	if(request.getParameter("jobId") != null && request.getParameter("action") != null) {
		jobId = request.getParameter("jobId");
		jobIds = jobId.split(":");
		if(jobIds != null && jobIds.length != 2) {
			content = "<font color=red>Invalid job ID</font>";
		}
		action = request.getParameter("action");
		System.out.println("action:"+action+"|");
		if(!(action.equals("viewPeptideMatchResults") ||action.equals("viewQueryPeptides") ||action.equals("viewLog"))) {
			content = "<font color=red>Invalid Action 1</font>";
		} 
		if(content.length() == 0) {
			Properties properties = new Properties();
        		InputStream inputStream = null;
        		String batchWD = (String) request.getSession().getAttribute("batchWD");
        		if(batchWD == null) {
                		try {
                       			inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
                        		properties.load(inputStream);
                        		batchWD = properties.getProperty("batchWD");
                        		request.getSession().setAttribute("batchWD", batchWD);
                		}
                		catch(IOException ioe) {
                        		ioe.printStackTrace();
                		}
        		}
			String logFile = batchWD+"/"+jobIds[0]+"/"+jobIds[1]+"/log.html";
			String log = readFile(logFile);
			if(log.length() == 0) {
				content = "<font color=red>Invalid job ID or the match results for your job ID has been deleted.</font>";
			}
			else {
				String[] inputsText = extractLog(log);
				content = inputsText[0];
				content += "<br/>";
				content += getTabNav(jobId, action);
				if(action.equals("viewLog")) {
					//content += "< rows=50 cols=100>"+inputsText[1]+"</textarea>";
					content += "<div class=\"log\"><br/>"+inputsText[1]+"</div>";	
				}
				if(action.equals("viewQueryPeptides")) {
					String originalQueryPeptideFile = batchWD+"/"+jobIds[0]+"/"+jobIds[1]+"/originalQuery.seq";
					
					//content += "<textarea style=\"height: 400px; width: 60%;\">"+readFile(originalQueryPeptideFile)+"</textarea>";
					content += "<div class=\"log\"><br/>"+readFile(originalQueryPeptideFile).replaceAll("\n", "<br/>")+"</div>";
				}	
				if(action.equals("viewPeptideMatchResults")) {
					dataTable = "var oTable;\n";
					dataTable += "$(document).ready(function() {\n";
               				dataTable += "   jQuery('#example').dataTable( {\n";
               				dataTable += "   \"sPaginationType\": \"full_numbers\",\n";
               				dataTable += "   \"aLengthMenu\": [[25, 50, 100], [25, 50, 100]],\n";
               				dataTable += "   \"iDisplayLength\": 25,\n";
               				dataTable += "   \"aaSorting\": [[1, \"desc\"], [0, \"asc\"]],\n";
               				dataTable += "   \"aoColumns\": [{sWidth: '10%', bSortable: false}, { sWidth: '60%'}, { sWidth: '15%', sClass: \"alignCenter\"}, { sWidth: '15%', sClass: \"alignCenter\"}], \n";
               				dataTable += "   \"bProcessing\": true,\n";
               				dataTable += "   \"bServerSide\": true,\n";
               				dataTable += "   \"sAjaxSource\": \"getbatchmathcresultsource.jsp?jobId="+jobId+"\"\n";
               				dataTable += "   });\n";
					dataTable += "	jQuery('#form').submit( function() {\n";
					dataTable += "		var sData = jQuery('input', oTable.fnGetNodes()).serialize();\n";
					dataTable += "		alert( \"The following data would have been submitted to the server: \"+sData );\n";
					dataTable += "		return false;\n";
					dataTable += "	});\n";
					dataTable += "	oTable = jQuery('#example').dataTable();\n";
					dataTable += " jQuery('#checkall').click( function() {\n";
    					dataTable += " 		jQuery('input', oTable.fnGetNodes()).attr('checked',this.checked);\n";
    					dataTable += " 		alert(\"Check ALL\");\n";
					dataTable += "	});\n";
               				dataTable += "});\n";
					content += 
						"<table style=\"font-size: 11px; width:60%; border: 1px solid black;\">"+
        						"<tr>"+
                						"<td><br/>"+
                        						"<div style=\"position:relative\">"+
                                					"<div>"+
                                        					"<div id=\"container\">"+
                                                					"<div id=\"demo\">"+
												"<form id=\"form\">"+
													"<div style=\"text-align:center; padding-bottom:1em;\">"+
														"<button type=\"submit\">Download selected match results</button>"+
													"</div>"+	
                                                						"<table cellpadding=0 cellspacing=0 border=0 class=\"display\" id=\"example\">"+
                                                        						"<thead><tr><th align=left><input type=\"checkbox\" name=\"checkall\" id=\"checkall\"></th><th>Peptide</th><th align=center># Matched Protein</th><th align=center># Matched Organism</th></tr></thead>"+
                                                        						"<tbody>"+
                                                                						"<tr>"+
                                                                        						"<td colspan=\"3\" class=\"dataTables_empty\">Loading data from server</td>"+
                                                                						"</tr>"+
                                                        						"</tbody>"+
                                                						"</table>"+
												"</form>"+
                                                					"</div>"+
                                        					"</div>"+
                                					"</div>"+
                        						"</div>"+
                						"</td>"+
        						"</tr>"+
						"</table>";
				}
			}
		}
	}
	else {
		content = "<font color=red>Invalid job ID or Action!</font>";
	}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Batch Peptide Match [PIR - Protein Information Resource]</title><!-- ##### page dependent-->
  	<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
 <script type="text/javascript">
		
            //$(document).ready(init);
</script>
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
<script type="text/javascript" src="js/idTabs/jquery.idTabs.min.js"></script>
<style>
div.log{
	border: 1px solid black;
height: 400px;
width: 60%; 
    float: left;
    overflow: auto;
    #overflow-x:hidden;
}
ul.tab
{
list-style-type:none;
margin:0;
padding:0;
padding-top:6px;
padding-bottom:6px;
}
li.tab
{
display:inline;
}
a.tab:link,a.tab:visited
{
font-weight:bold;
color:#FFFFFF;
#background-color:#98bf21;
#background-color:#1E90FF;
background-color:#336699;
text-align:center;
padding:6px;
text-decoration:none;
#text-transform:uppercase;
}
a.tab:hover,a.tab:active
{
background-color:navy;
}

</style>

 <style type="text/css">
    a:active {  color:#336699; text-decoration:underline}
    a:link {  color:#336699; text-decoration:underline}
    a:visited { color:#996666; text-decoration:underline }
    a:hover {  color: #FFAA00; text-decoration: underline}
    a.nounderline{text-decoration:none}
    </style> 	
 <style>
.radio1 {
	font-size:4px;
	background-color:transparent;
	border:1px;
	border-color:transparent;
	border:transparent;
}
.searchBannerBox {
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
font-size: 11px; 
WIDTH: 180px;  
HEIGHT:18px
}
td.searchLable {
	color:#ffffff;
	font-family:Verdana,Arial, Helvetica, sans-serif;
	font-size:10px;
	font-weight:bold
}
.hide2 { position:absolute; visibility:hidden; }
.show2 { position:absolute; visibility:visible; }
#organismlink{
display:none;
}
#organismlist{
font-size:11px;
}
#organism_name{
display:none;
}
#organism{
display:none;
}
#organism_name_div{
display:none;
}
#result_display{
display:none;
}
#result_newline{
display:none;
}
#show_selected_count{
display:none;
}
th#th_link{
color:#036;
background-color: #369;
}

</style>   
<style type="text/css" title="currentStyle">

                       @import "css/DataTable/demo_page.css";
                        @import "css/DataTable/demo_table.css";

                </style>
<script type="text/javascript" language="javascript" src="js/DataTable/jquery.js"></script>
<script type="text/javascript" language="javascript" src="js/DataTable/jquery.dataTables.js"></script>

<script type="text/javascript" charset="utf-8">
                <%=dataTable%>
</script>  
 </head>
<!--
 <body bgcolor="#cccccc" background="./imagefiles/bg02.gif" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0"><span id="progress" class="hide2"><form name="dialog"><table width="220" height="70" border="4" cellpadding="0" cellspacing="0" align="center" bgcolor="#FFFFFF"><tbody><tr><td align="center"> Processing ... <br><input type="text" name="bar" size="25" bar.style="color:navy;"><br></td></tr></tbody></table></form></span>
-->
 <body bgcolor="" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<table border="0" cellspacing="0" cellpadding="0" width="100%"><tbody><tr><td>
<map name="PIRBanner_Map">
<area shape="rect" alt="home" coords="16,16,110,60" href="http://pir.georgetown.edu/pirwww/index.shtml" target="_top">
<area shape="rect" alt="uniprot" coords="140,36,178,50" href="http://www.uniprot.org/" target="_blank">
</map>	
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
</tbody></table>




<noscript>
    &lt;td&gt;
			&lt;table bgcolor="#4a4a4a" width="100%" height="21" border="0" cellspacing="0" cellpadding="0"&gt;
				&lt;tr&gt;
					&lt;td class="nrm02" nowrap&gt;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;
						&lt;a href="http://pir.georgetown.edu/pirwww/index.shtml" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;Home&lt;/font&gt;&lt;/a&gt; &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp; 
						&lt;a href="http://pir.georgetown.edu/pirwww/about/" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;About PIR&lt;/font&gt;&lt;/a&gt;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp; 
						&lt;a href="http://pir.georgetown.edu/pirwww/dbinfo/" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;Databases&lt;/font&gt;&lt;/a&gt; &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp; 
						&lt;a href="http://pir.georgetown.edu/pirwww/search/" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;Search/Retrieval&lt;/font&gt;&lt;/a&gt; &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp; 
						&lt;a href="http://pir.georgetown.edu/pirwww/download/" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;Download&lt;/font&gt;&lt;/a&gt; &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp; 
						&lt;a href="http://pir.georgetown.edu/pirwww/support/" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;Support&lt;/font&gt;&lt;/a&gt;
					&lt;/td&gt;
				&lt;/tr&gt;
			&lt;/table&gt;
		&lt;/td&gt;
</noscript>

<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#333333" border="0"><tbody><tr>
	<td><img src="./imagefiles/leftSearch.png"></td><!-- ############### group dependent-->
	<td class="sml01" width="99%" background="./imagefiles/bgcolor.png">&nbsp;</td>
</tr></tbody></table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="docTitle"><tbody><tr>
	<td width=100></td>
          <td width="10" rowspan="2"><img height="20" src="./imagefiles/spacer.gif" width="10" alt="???"></td>
         	<td bgcolor="#336699" width=8><img height="20" src="./imagefiles/spacer.gif" width="8" alt=""></td>
		<td width=10></td>
                <td>
                <a href="http://pir.georgetown.edu/pirwww/" class="titleLink"><b>HOME</b></a>
                                                                   / <a href="http://pir.georgetown.edu/pirwww/search/" class="titleLink"><b>Search</b></a>
                    / <b><a href="batchpeptidematch.jsp">Batch Peptide Match</a></b><!-- ############### page dependent-->
    </td></tr>
</tbody></table>

<div style="margin-left: 80px;">
<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#ffffff" border="0" >
    <tbody>
	<tr valign="top"> 
      <td id="inputtd" align="left" nowrap="" bgcolor="#ffffff" width="50%">
	<br/>
	<%= content %>	
	<br/>
	<br/>
	<br/>
      </td>
    </tr>
</tbody></table>
</div>
<!-- FOOTER -->
<!--
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
</td></tr></tbody></table>

-->
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


<!-- Input process starts -->
<script language="JavaScript" src="js/peptidesearch.js"> </script>
<!-- Input process ends -->



</html>
<%!
	private String readFile(String filePathAndName) {
        String fileContent = "";
        try {
                File file = new File(filePathAndName);
                FileReader fr = new FileReader(file);
                BufferedReader br = new BufferedReader(fr);
                String line = null;
                while((line = br.readLine()) != null) {
                        fileContent += line+"\n";
                }
                br.close();
        }
        catch(IOException ioe) {
                ioe.printStackTrace();
        }
        return fileContent;
    }
	
    private String[] extractLog(String str) {
	String[] lines = str.split("\n");
	String inputsInfo = "";
	String log = "";
	boolean logStart = false;
	for(int i = 0; i < lines.length; i++) {
		//System.out.println(lines[i]+"\n");
		if(lines[i].indexOf("Searching") > 0) {
			logStart = true;
			log += lines[i]+"\n";
		}
		else if(logStart){
			log += lines[i]+"\n";
		}
		else {
			inputsInfo += lines[i]+"\n";
		}	
	}
	String[] results = new String[2];
	results[0] = inputsInfo;
	//System.out.println(inputsInfo);
	results[1] = log;
	return results;
    }
	
    private String getTabNav(String jobId, String action) { 
	String tabNav = "";
	if(action.equals("viewPeptideMatchResults")) {
		tabNav +="<ul class=\"tab\">\n";
		tabNav +="<li class=\"tab\"><a href=\"getbatchresults.jsp?jobId="+jobId+"&action=viewPeptideMatchResults\" style=\"background-color: gray;\" class=\"tab\">Batch Peptide Match Results</a></li>\n";
		tabNav +="<li class=\"tab\"><a href=\"getbatchresults.jsp?jobId="+jobId+"&action=viewQueryPeptides\" class=\"tab\">Query Peptides</a></li>\n";
		tabNav +="<li class=\"tab\"><a href=\"getbatchresults.jsp?jobId="+jobId+"&action=viewLog\" class=\"tab\">Log</a></li>\n";
		tabNav +="</ul>\n";
	}
	else if(action.equals("viewQueryPeptides")) {
		tabNav +="<ul class=\"tab\">\n";
		tabNav +="<li class=\"tab\"><a href=\"getbatchresults.jsp?jobId="+jobId+"&action=viewPeptideMatchResults\" class=\"tab\">Batch Peptide Match Results</a></li>\n";
		tabNav +="<li class=\"tab\"><a href=\"getbatchresults.jsp?jobId="+jobId+"&action=viewQueryPeptides\" style=\"background-color: gray;\" class=\"tab\">Query Peptides</a></li>\n";
		tabNav +="<li class=\"tab\"><a href=\"getbatchresults.jsp?jobId="+jobId+"&action=viewLog\" class=\"tab\">Log</a></li>\n";
		tabNav +="</ul>\n";
	}
	else if(action.equals("viewLog")) {
		tabNav +="<ul class=\"tab\">\n";
		tabNav +="<li class=\"tab\"><a href=\"getbatchresults.jsp?jobId="+jobId+"&action=viewPeptideMatchResults\" class=\"tab\">Batch Peptide Match Results</a></li>\n";
		tabNav +="<li class=\"tab\"><a href=\"getbatchresults.jsp?jobId="+jobId+"&action=viewQueryPeptides\" class=\"tab\">Query Peptides</a></li>\n";
		tabNav +="<li class=\"tab\"><a href=\"getbatchresults.jsp?jobId="+jobId+"&action=viewLog\" style=\"background-color: gray;\" class=\"tab\">Log</a></li>\n";
		tabNav +="</ul>\n";
	}

	return tabNav;
    }
%>
