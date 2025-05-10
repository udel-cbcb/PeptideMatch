<%@ page session="true" %>
<%@ page import="java.io.*" %>
<%@ page import ="java.util.*" %>
<%@ page import = "javax.servlet.*" %>
<%
	String content = "";
	String jobId = "";
	String action = "";
	String[] jobIds = null;
	String taxongroupTable = "";
	
	if(request.getParameter("jobId") != null) {
		jobId = request.getParameter("jobId");
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
			String logHeaderFile = batchWD+"/"+parentDir+"/"+jobId+"/logHeader.html";
			String logHeader = readFile(logHeaderFile);
			if(logHeader.length() == 0) {
				content = "<font color=red>Invalid job ID or the match results for your job ID has been deleted.</font>";
			}
			else {
				content = logHeader;
				content += "<br/>";
				String taxongroupTableFile = batchWD+"/"+parentDir+"/"+jobId+"/taxongroup.html";
				taxongroupTable = readFile(taxongroupTableFile);
				
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
	<title>Multiple Peptide Match Taxon Group View (JobID <%= jobId%>) [PIR - Protein Information Resource]</title><!-- ##### page dependent-->
  	<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
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

    <style type="text/css" class="init">
        .dataTables_wrapper .dt-buttons {
                float:none;  
                text-align:center;
        }
        .dataTables_wrapper a {
                text-decoration: none;
        }
        .dataTables_wrapper theader {
                font-weight: bold;
        }
	.dataTables_wrapper table {
		//table-layout: fixed;
                font-size: 13px; 
		cellpadding: 5px;
                text-align:center;
	}
	.dataTables_wrapper td {
		min-width: 120px;
	}
        div.scroll {
                overflow-x:scroll;
                white-space: nowrap;
		width: 1200px;
        }
	.text-left {
		text-align: left;
	}
	a.button {
                //background-color: #008CBA; /* Blue */
                background-color: #A0BCDE;
                border: none;
                color: white;
                padding: 15px 15px;
                text-align: center;
                text-decoration: none;
                display: inline-block;
                font-size: 12px;
                //margin: 4px 2px;
                cursor: pointer;
        }
	a.current {
                background-color: navy;
        }
    </style>

    </script>
        <link rel="stylesheet" type="text/css" href="js/DataTables/datatables.min.css"/>
        <script type="text/javascript" src="js/DataTables/jquery-1.12.4.js"></script> 
        <script type="text/javascript" src="js/DataTables/datatables.min.js"></script> 
        <script type="text/javascript" src="js/DataTables/colResizable-1.5.min.js"></script> 
</head>

<body>
<script>
//$(document).ready(function() {
jQuery(document).ready(function ($) {
    $('#batch_summary').removeAttr('width').DataTable( {
	//scrollX: true,
        scrollCollapse: true,
        fixedColumns:   {
            leftColumns:1, 
        },
	'columnDefs': [{
      		"targets": 0,
     	 	"className": "text-left",
                "width": "400px"
 	}],
        colReorder: true,
        dom: 'Blfrtip',
        buttons: [
            'copyHtml5',
            'excelHtml5',
            'csvHtml5',
           {
                extend: 'pdfHtml5',
                orientation: 'landscape',
                pageSize: 'LEGAL'
            },
             'print',
             'colvis'
        ],
        "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
        initComplete: function(settings) {
            $('#batch_summary').colResizable({liveDrag:true});
        },
	 "footerCallback": function(row, data, start, end, display) {
                var api = this.api();
                // Remove the formatting to get integer data for summation
                var intVal = function ( i ) {
                        return typeof i === 'string' ?
                        i.replace(/<(?:.|\n)*?>/gm, '')*1 :
                        typeof i === 'number' ?
                                i : 0;
                };
                api.columns('.sum', {page: 'current' }).every(function () {
                        var sum = api
                            .cells( null, this.index(), { page: 'current'} )
                            .render('display')
                            .reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);
                        var total = api
                            .cells( null, this.index() )
                            .render('display')
                            .reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);
                        $(this.footer()).html("Sub: "+(sum) +' ('+(total)+' Total)');
                    });
                }

    });
} );
</script> 

</head>
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
                    / <b><a href="batchpeptidematch.jsp">Multiple Peptide Match</a></b><!-- ############### page dependent-->
    </td></tr>
</tbody></table>

	<br/><br/>
<div style="margin-left: 80px; margin-right: 80px; width: 95%">
<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#ffffff" border="0" >
    <tbody>
	<tr valign="top"> 
      		<td align="left">
		<%= content %>	
		</td>
	</tr>
	<tr valign="top"> 
      		<td align="left">
			<a class="button" href="batchresultsummary.jsp?jobId=<%=jobId%>">Summary</a>
                        <a class="button" href="batchresultpeptidehitmap.jsp?jobId=<%=jobId%>">Matches By Peptide View</a>
                        <a class="button" href="batchresultproteinhitmap.jsp?jobId=<%=jobId%>">Matches By Protein View</a>
                        <a class="button current" href="batchresulttaxongroupview.jsp?jobId=<%=jobId%>">Taxonomic Group View</a>
                        <a class="button" href="batchresultorgview.jsp?jobId=<%=jobId%>">Organism View</a>

<!--
<a class="button" href="batchresultsummary.jsp?jobId=<%=jobId%>">Summary</a> <a class="button" style="background-color: navy;" href="batchresulttaxongroupview.jsp?jobId=<%=jobId%>">Taxonomic Group View</a> <a class="button" href="batchresultorgview.jsp?jobId=<%=jobId%>">Organism View</a>
			<a class="button" href="batchresultsummary.jsp?jobId=<%=jobId%>">Summary</a> <a class="button"href="batchresultorgview.jsp?jobId=<%=jobId%>">Organism View</a> 
<a class="button" href="selectbatchpeptidematchresults.jsp?jobId=<%=jobId%>">Download Reports</a>
-->
<br/><br/>
		</td>
	</tr>
	<tr valign="top"> 
      		<td align="left">
<%if(!content.contains("Invalid")){%>
		
	<%= taxongroupTable %>	
<%}%>
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
