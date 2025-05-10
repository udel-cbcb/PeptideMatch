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
	if(request.getParameter("jobId") != null) {
		jobId = request.getParameter("jobId");
		/*jobIds = jobId.split("_");
		if(jobIds != null && jobIds.length != 2) {
			content = "<font color=red>Invalid job ID</font>";
		}*/
		String parentDir = jobId.substring(0, 8);
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
			//String logHeaderFile = batchWD+"/"+jobIds[0]+"/"+jobIds[1]+"/logHeader.html";
			String logHeaderFile = batchWD+"/"+parentDir+"/"+jobId+"/logHeader.html";
			String logHeader = readFile(logHeaderFile);
			if(logHeader.length() == 0) {
				content = "<font color=red>Invalid job ID or the match results for your job ID has been deleted.</font>";
			}
			else {
				content = logHeader;
				content += "<br/>";
				
			}
		}
	}
	else {
		content = "<font color=red>Invalid job ID</font>";
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

<script type="text/javascript">
<!--
    function toggle_visibility(id) {
       var e = document.getElementById(id);
       if(e.style.display == 'block')
          e.style.display = 'none';
       else
          e.style.display = 'block';
    }
//-->
</script>
<style>
ul li {list-style:none;}
#wrapper {
background:#fff;
margin:10px auto;
width:960px;
min-height: 700px;
}
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
	<form name="myform" id="myform" method="post" action="downloadpeptidematchreports.jsp" onSubmit="return atLeastOneChecked(this);">
	<h4>Download match reports:</h4>
    <input type="checkbox" name="reports" value="perPeptideDetails" id="perPeptideDetails" checked/>
    <label for="perPeptideDetails">Per peptide matching protein(s) detail report</label>
	(<a href="docs/batch_example/perPeptideMatchDetails.txt" target="_blank">Example</a>) 
	<!--<a href="#" onclick="toggle_visibility('moreReports');">More reports ...</a>-->
	<input type="button" value="More reports" onclick="toggle_visibility('moreReports');">
 	<div id="moreReports" style="display: none;">
    <input type="checkbox" name="reports" value="perPeptideSummary" id="perPeptideSummary"/> 
    <label for="perPeptideSummary">Per peptide matching protein(s) summary report</label> 
	(<a href="docs/batch_example/peptideSummary.txt" target="_blank">Example</a>)<br/>

    <input type="checkbox" name="reports" value="perProteinSummary" id="perProteinSummary"/>
    <label for="perProteinSummary">Per protein matching peptide(s) summary report</label>
	(<a href="docs/batch_example/proteinSummary.txt" target="_blank">Example</a>)<br/>
    
    <input type="checkbox" name="reports" value="proteinSeqs" id="proteinSeqs"/>
    <label for="proteinSeqs">Matched protein sequence(s)</label>
	(<a href="docs/batch_example/proteinSeq.fasta" target="_blank">Example</a>)<br/>
    
    <input type="checkbox" name="reports" value="queryPeptides" id="queryPeptides"/>
    <label for="queryPeptides">Original query peptide sequences</label>
	(<a href="docs/batch_example/originalQuerySeq.txt" target="_blank">Example</a>)<br/>

    <input type="checkbox" name="reports" value="missedQueryPeptides" id="missedQueryPeptides"/>
    <label for="missedQueryPeptides">Missed query peptide sequences</label>
	(<a href="docs/batch_example/missedOriginalQuerySeq.txt" target="_blank">Example</a>)<br/>

    <input type="checkbox" name="reports" value="log" id="log"/>
    <label for="log">Log</label>
	(<a href="docs/batch_example/log.txt" target="_blank">Example</a>)<br/>
   
    <br/> 
    <input type="checkbox" id="selectall" />
    <label for="selectall" id="selectControl">Select All</label>
	</div>
    <br/>
    <br/>
    <input type="hidden" name="jobId" value="<%=jobId%>">
    <input type="submit" id="submit" name="submit" value="Download report(s)">
    
  </form>
  
  <script>
	function atLeastOneChecked() {
		var form = document.getElementById('myform');
		var inputs = form.getElementsByTagName('input');
		var is_checked = false;
		for(var x = 0; x < inputs.length; x++) {
    			if(inputs[x].type == 'checkbox' && inputs[x].name == 'reports') {
        			is_checked = inputs[x].checked;
        			if(is_checked) break;
    			}
		}
		if(!is_checked) {
			alert("You need to check at least one checkbox");
			return(false);
		}
	}

	function Check(frm){
  var checkBoxes = frm.elements['reports'];
  var selectControl = document.getElementById("selectControl");
  for (i = 0; i < checkBoxes.length; i++){
    checkBoxes[i].checked = (selectControl.innerHTML == "Select All") ? 'checked' : '';
  }
  selectControl.innerHTML = (selectControl.innerHTML == "Select All") ? "Unselect All" : 'Select All';
}
 
window.onload = function(){
  document.getElementById("selectall").onchange = function(){Check(document.myform)};
};
  </script>

	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
      </td>
    </tr>
</tbody></table>
</div>
<!-- FOOTER -->
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
